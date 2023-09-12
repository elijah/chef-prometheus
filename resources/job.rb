property :scrape_interval,     String
property :scrape_timeout,      String
property :labels,              Hash
property :target,              [Array, String]
property :metrics_path,        String, default: '/metrics'
property :config_file,         String, default: lazy { node['prometheus']['flags']['config.file'] }

action :create do
  prometheus_config "job_#{new_resource.name}" do
    config_file new_resource.config_file
    config {
      'scrape_configs' => [{
        'job_name' => new_resource.name,
        'scrape_interal' => new_resource.scrape_interval,
        'scrape_timeout' => new_resource.scrape_timeout,
        'metrics_path' => new_resource.metrics_path,
        'static_configs' => [{
          'targets' => Array(new_resource.target),
          'labels' => new_resource.labels.to_h,
        }],
      }],
    }
  end
end

action :delete do
  prometheus_config "job_#{new_resource.name}" do
    action :delete
  end
end
