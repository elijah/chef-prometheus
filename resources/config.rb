property :config_file, String, default: lazy { node['prometheus']['flags']['config.file'] }
property :config, String

default_action :create

action :create do
  with_run_context :root do
    edit_resource(:template, new_resource.config_file) do
      not_if { node['prometheus']['allow_external_config'] }

      variables[:config] ||= {}
      variables[:config].deep_merge(new_resource.config)

      action :nothing
      delayed_action :create
    end
  end
end

action :delete do
  template new_resource.config_file do
    action :delete
  end
end
