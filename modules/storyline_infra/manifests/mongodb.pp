class storyline_infra::mongodb () {

	$params = lookup({"name" => "storyline_infra.mongodb",
	    "merge" => {"strategy" => "deep"}})
	$port = $params['port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_startup = $params['enabled_startup']
	$version = $params['version']

	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	user { 'mongodb':
		ensure => "present",
		managehome => true,
	}
	exec { "mongodb-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		owner => "mongodb",
		group=> "mongodb",
		require => Exec['mongodb-mkdir'],
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		owner => "mongodb",
		group=> "mongodb",
		require => Exec['mongodb-mkdir'],
	}
	package {  'mongodb':
		ensure => $version,
	} ->
	file { "/etc/mongod.conf":
		replace => true,
		content => epp('storyline_infra/mongod.epp'),
		owner => "mongodb",
		group=> "mongodb",
		notify => Service['mongodb'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/mongodb_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['mongodb'],
	}->
	service { 'mongodb':
  		ensure => $service_status,
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
