Puppet::Functions.create_function(:'get_first_jar_file_name') do
  dispatch :get_first_jar_file_name_int do
    param 'String', :path
  end

  def get_first_jar_file_name_int(path)
	return "" unless File::directory?(path)
	# get only first element
	# puts "#{path}/*.jar"
	# puts Dir.glob("#{path}/*.jar")
    return Dir.glob("#{path}/*.jar")[0]
  end
end
