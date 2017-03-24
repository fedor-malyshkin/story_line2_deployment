class storyline_components {
	$a_lot_of_params = lookup({"name" => "storyline_components",
	    "merge" => {"strategy" => "deep"}})

	$nexus_repo_url = $a_lot_of_params['nexus_repo_url']
	# Initialize Nexus
	class {'nexus':
		url => $nexus_repo_url
	}
}
