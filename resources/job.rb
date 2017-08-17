property :name,                String, name_property: true, required: true
property :scrape_interval,     String
property :scrape_timeout,      String
property :target,              [Array, String]
property :metrics_path,        String, default: '/metrics'
property :config_file,         String, default: lazy { node['prometheus']['flags']['config.file'] }
property :source, String, default: 'prometheus'

default_action :create

action :create do
  with_run_context :root do
    edit_resource(:template, config_file) do |new_resource|
      cookbook new_resource.source
      variables[:jobs] ||= {}
      variables[:jobs][new_resource.name] ||= {}
      variables[:jobs][new_resource.name]['scrape_interval'] = new_resource.scrape_interval
      variables[:jobs][new_resource.name]['scrape_timeout'] = new_resource.scrape_timeout
      variables[:jobs][new_resource.name]['target'] = new_resource.target
      variables[:jobs][new_resource.name]['metrics_path'] = new_resource.metrics_path

      action :nothing
      delayed_action :create

      not_if { node['prometheus']['allow_external_config'] }
    end
  end
end

action :delete do
  template config_file do
    action :delete
  end
end
