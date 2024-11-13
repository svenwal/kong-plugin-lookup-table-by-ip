return {
  name = "lookup-table-by-ip",
  fields = {
    { config = {
        type = "record",
        fields = {
                { use_header_instead_of_real_ip = { type = "boolean",required = false, default = false}, },
                { header_instead_of_ip = { type = "string",required = false,  default = "x-forwarded-ip"}, },
                { header_name = { type = "string",required = true,  default = "x-kong-lookup"}, },
                { default_value_if_lookup_fails = { type = "string",required = true,  default = "0"}, },
		{ ip_ranges = { type = "array", required = true, default = {"application/xml"}, elements = { type = "string"}, }, },
		{ header_value = { type = "array", required = true, default = {"application/xml"}, elements = { type = "string"}, }, },
                { fail_on_missing_lookup = { type = "boolean",required = false, default = false}, },
        },
      },
    },
  },
  entity_checks = {
    -- Add any checks here if needed
  },
}
