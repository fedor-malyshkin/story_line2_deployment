class storyline_base::java () {

# java oracle
	class { 'java':
		version    => '8',
		distribution       => 'jdk',
	}

}
