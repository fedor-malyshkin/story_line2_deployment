class storyline_infra::elasticsearch () {

	$params = lookup({"name" => "storyline_infra.elasticsearch",
	    "merge" => {"strategy" => "deep"}})
	$port = $params['port']
	$bind_scope =  = $params['bind_scope']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$cluster_name = $params['cluster_name']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']

	user { 'elasticsearch':
		ensure => "present",
		managehome => true,
	}
	exec { "elasticsearch-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [$dir_bin, $dir_logs, $dir_data]:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
		require => Exec['elasticsearch-mkdir'],
	} ->
	archive { "elasticsearch-archive":
		path=> "/provision/elasticsearch-${version}.zip",
  		source=>"https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}.zip",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['move_to_no_version_dir'],
	}
	exec { "move_to_no_version_dir":
		# command => "/bin/mv /provision/elasticsearch-${version} ${dir_bin}",
		command => "/bin/mv -f -t ${dir_bin} /provision/elasticsearch-${version}/* && chown -R elasticsearch:elasticsearch ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/config/elasticsearch.yml":
		replace => true,
		content => epp('storyline_infra/elasticsearch.epp'),
		owner => "elasticsearch",
		group=> "elasticsearch",
	}->
	file { "${dir_bin}/bin/elasticsearch":
		owner => "elasticsearch",
		group=> "elasticsearch",
		mode=>"ug=rwx,o=rx",
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/elasticsearch_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['elasticsearch'],
	}->
	service { 'elasticsearch':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		start 		=> "${init_script} start",
		stop 		=> "${init_script} stop",
		status 		=> "${init_script} status",
		restart 	=> "${init_script} restart",
		hasrestart => true,
		hasstatus => true,
	}
	if $enabled_startup != true {
		exec { "disable_elasticsearch":
			command => "/bin/systemctl disable elasticsearch",
			cwd => "/",
		}
	}

}
