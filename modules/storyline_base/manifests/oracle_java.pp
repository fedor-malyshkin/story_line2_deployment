class storyline_base::oracle_java (String $version = '8') {

# java oracle
	class { 'oracle_java':
  		version => $version,
		type    => 'jdk',
		format       => 'tar.gz',
    	install_path => '/opt/java',
		add_alternative => true,
		add_system_env => true,
	}

}
