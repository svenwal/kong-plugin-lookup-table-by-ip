# Kong plugin for adding a header value based on the request source IP

# About

This Kong 🦍 plugin will lookup the callers IP address and based on provided CIDRs set a header name.

The original use case I have built it for was looking up branches of a retailer which have fixed IPs and the backend service needing the info which branch made the call.

## Configuration parameters

|FORM PARAMETER|DEFAULT|DESCRIPTION|
|:----|:------|:------|
|config.header_name|x-kong-lookup|The to be set header name|
|config.ip_ranges|127.0.0.1,192.168.0.0/16,::1,fe80::/32,34.182.154.0/24|The array of CIDR-ranges to met. Each entry can have multiple CIDRs (comma-seperated). It is to be seen in combination with config.header_value - for example third array entry here will set the third header value from header_value|
|config.header_value|cidr-range-1|The values of the header to be set. See config.ip_ranges on matching|
|config.default_value_if_lookup_fails|0|The value to be set if no CIDR matched. Does not apply if config.fail_on_missing_lookup is set to true|
|config.cache_ttl|3600|The time a CIDR match gets cached instead of looking it up on every request from same IP|
|config.use_header_instead_of_real_ip|false|Can be used to parse a header value instead of the requester's IP (nice for testing)|
|config.header_instead_of_ip|x-forwarded-ip"|The header to be parsed if config.use_header_instead_of_real_ip is enabled|
|config.fail_on_missing_lookup|false|If the request should be denied if no match is possible|
|config.fail_status_code|403|The status code to be send if match fails|
|config.fail_status_message|{ "error": "No valid IP address" }|The error message returned if match fails|
|config.fail_status_content_type|application/json|The content type if match fails|

## Example configuration (deck YAML)

```{
  "config": {
    "cache_ttl": 30,
    "default_value_if_lookup_fails": "0",
    "fail_on_missing_lookup": false,
    "fail_status_code": 403,
    "fail_status_content_type": "application/json",
    "fail_status_message": "{ \"error\": \"No valid IP address\" }",
    "header_instead_of_ip": "x-forwarded-ip",
    "header_name": "x-kong-lookup",
    "header_value": [
      "first",
      "second"
    ],
    "ip_ranges": [
      "127.0.0.1,192.168.0.0/16,::1,fe80::/32,34.182.154.0/24",
      "84.182.154.0/24"
    ],
    "use_header_instead_of_real_ip": false
  },
  "enabled": true,
  "name": "lookup-table-by-ip",
  "protocols": [
    "http",
    "https"
  ],
}```

