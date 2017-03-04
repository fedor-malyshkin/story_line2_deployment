Puppet::Functions.create_function(:'file_content') do
  dispatch :file_content_int do
    param 'String', :some_string
  end

  def file_content_int(some_string)
	return "" unless File.file?(some_string)
	# read only first string
    return IO.readlines(some_string)[0]
  end
end
