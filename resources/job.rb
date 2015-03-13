default_action :create
actions :delete

attribute :name,            :kind_of => String, :name_attribute => true, :null => false
attribute :scrape_interval, :kind_of => String, :default => nil
attribute :target,          :kind_of => [Array,String]
attribute :sd_name,         :kind_of => String
attribute :metrics_path,    :kind_of => String, :default => "/metrics"