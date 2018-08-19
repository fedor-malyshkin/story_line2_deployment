class storyline_base::oracle_java (String $version = '8') {

# java oracle
	class { 'oracle_java':
		type    => 'jdk',
		format       => 'tar.gz',
		download_url => 'http://repo.nlp-project.ru:8082/nexus/service/local/repositories/releases/content/ru/nlp_project/story_line2/jdk/8u181',
	    filename     => 'jdk-8u181-x64.tar.gz',
    	install_path => '/opt/java',
		check_checksum => false,
		add_alternative => true,
		add_system_env => true,
	}

}
