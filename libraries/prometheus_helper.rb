
def generate_flags
  config = ''
  if Gem::Version.new(node['prometheus']['version']) < Gem::Version.new('2.0.0-alpha.0')
    # Generate cli opts for prometheus 1.x
    node['prometheus']['flags'].each do |flag_key, flag_value|
      config += "-#{flag_key}=#{flag_value} " if flag_value != ''
    end
  else
    # Generate cli opts for prometheus 2.x & hopefully beyond if there are no changes
    node['prometheus']['v2_cli_opts'].each do |opt_key, opt_value|
      config += "--#{opt_key}=#{opt_value} " if opt_value != ''
    end
    node['prometheus']['v2_cli_flags'].each do |opt_flag|
      config += "--#{opt_flag} " if opt_flag != ''
    end
  end
  config
end
