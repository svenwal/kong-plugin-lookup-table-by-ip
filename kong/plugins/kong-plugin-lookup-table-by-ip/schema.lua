local typedefs = require "kong.db.schema.typedefs"

local function validator_cidrs_in_array(value)
  if not value then
    return nil, string.format("ip_ranges entry must not be empty")
  end
  if value == "" then
    return nil, string.format("ip_ranges entry must not be empty")
  end
  for cidr in string.gmatch(value, "([^,]+)") do
    if not type(value) == typedefs.ip_or_cidr then
      return nil, string.format("'%s' is not a valid CIDR", tostring(cidr))
    end
  end
  return true
end

return {
  name = "lookup-table-by-ip",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
                { use_header_instead_of_real_ip = { type = "boolean",required = false, default = false}, },
                { header_instead_of_ip = { type = "string",required = false,  default = "x-forwarded-ip"}, },
                { header_name = { type = "string",required = true,  default = "x-kong-lookup"}, },
                { default_value_if_lookup_fails = { type = "string",required = true,  default = "0"}, },
		            { ip_ranges = { type = "array", required = true, default = {"127.0.0.1,192.168.0.0/16,::1,fe80::/32,34.182.154.0/24"}, elements = { type = "string"}, }, },
                --{ ip_ranges = { type = "array", required = true, default = {"127.0.0.1,192.168.0.0/16,::1,fe80::/32,34.182.154.0/24"}, elements = { type = "string", custom_validator = validator_cidrs_in_array,  }  }, },
		            { header_value = { type = "array", required = true, default = {"cidr-range-1"}, elements = { type = "string"}, }, },
                { fail_on_missing_lookup = { type = "boolean",required = false, default = false}, },
                { fail_status_code = { type = "number",required = false, default = 403, between = { 100, 999 } } },
                { fail_status_message = { type = "string",required = false, default = "{ \"error\": \"No valid IP address\" }"}, },
                { fail_status_content_type = { type = "string",required = false, default = "application/json"}, },
                { cache_ttl = { type = "number",required = true, default = 3600, gt = -1, } },
        },
      },
    },
  },
  entity_checks = {

  },
}

