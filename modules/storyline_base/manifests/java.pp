class storyline_base::java () {

	$params = lookup({"name" => "storyline_base.java",
	    "merge" => {"strategy" => "deep"}})
	$version = $params['version']

# java oracle
	class { 'java':
		distribution       => 'jdk',
		version => $version,
	}

}
