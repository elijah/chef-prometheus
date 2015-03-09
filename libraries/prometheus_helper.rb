
def generate_flags
  config = ''
  node['prometheus']['flags'].each do |flag_key, flag_value|
    unless flag_value == ''
      config += "-#{flag_key}=#{flag_value} "
    end
  end
  config
end
