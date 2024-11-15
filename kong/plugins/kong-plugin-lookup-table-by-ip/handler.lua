local lookuptablebyip = {
    PRIORITY = 1010, -- set the plugin priority, which determines plugin execution order
    VERSION = "0.9",
  }
local ipmatcher = require("resty.ipmatcher")

function lookuptablebyip:access(config)
    local ip
    if not config.use_header_instead_of_real_ip then
        ip = ngx.var.remote_addr
    else
        ip = kong.request.get_header(config.header_instead_of_ip)
    end

    if not ip then
        kong.log.err("No IP address found")
	kong.response.exit(config.fail_status_code, config.fail_status_message, {["Content-Type"] = config.fail_status_content_type})
    end

    kong.log.debug("IP found: " .. ip)

    local header_value = ""
    local ip_cache_key = "ip-lookup-" .. ip
    local opts = { ttl = config.cache_ttl }

    local header_value, err = kong.cache:get(ip_cache_key, opts, lookup_ip, config, ip)

    if err then
      kong.log.err(err)
	if config.fail_on_missing_lookup then
	    kong.response.exit(config.fail_status_code, config.fail_status_message, {["Content-Type"] = config.fail_status_content_type})
        end 
    end

    if header_value == "" then
	if config.fail_on_missing_lookup then
	    kong.response.exit(config.fail_status_code, config.fail_status_message, {["Content-Type"] = config.fail_status_content_type})
	else 
            header_value = config.default_value_if_lookup_fails
	end
    end

    kong.log.debug("Setting header " .. config.header_name .. " to " .. header_value)
    kong.service.request.set_header(config.header_name, header_value)
end

function lookup_ip(config, ip)
    kong.log.debug("Looking up IP " .. ip)
    local header_value = ""
    local range_index = 1
    for index,ranges in ipairs(config.ip_ranges) do
        local range = {}
        for value in string.gmatch(ranges, "([^,]+)") do
            table.insert(range, value)
        end
        local matcher = ipmatcher.new(range)
        if matcher:match(ip) then
            kong.log.debug("IP is in CIDR " .. range_index)
	    header_value = config.header_value[range_index]
        end
	range_index = range_index + 1
    end

    kong.log.debug("Header value is found: " .. header_value)
    return header_value
end

return lookuptablebyip

