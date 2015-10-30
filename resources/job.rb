default_action :create
actions :delete

attribute :name,                 kind_of: String, name_attribute: true, required: true
attribute :scrape_interval,      kind_of: String
attribute :scrape_timeout,       kind_of: String
attribute :target,               kind_of: [Array, String]
attribute :metrics_path,         kind_of: String, default: '/metrics'
attribute :consul_sd_server,     kind_of: String, default: nil
attribute :consul_sd_services,   kind_of: [Array, String]
attribute :consul_sd_datacenter, kind_of: String, default: nil
