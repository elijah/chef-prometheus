
def generate_flags
  config = ''
  node['prometheus']['flags'].each do |flag_key, flag_value|
    config += "-#{flag_key}=#{flag_value} " if flag_value != ''
  end
  config
end
