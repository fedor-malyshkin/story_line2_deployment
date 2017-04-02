class storyline_infra::mongodb () {

	$params = lookup({"name" => "storyline_infra.mongodb",
	    "merge" => {"strategy" => "deep"}})
	$port = $params['port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_auth = $params['enabled_auth']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']

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
		exec { "disable_mongodb":
			command => "/bin/systemctl disable mongodb",
			cwd => "/",
		}
	}
	logrotate::rule { 'apache':
  		path          => "${dir_logs}/*.log",
  		rotate        => 5,
		copytruncate	=> true,
		dateext			=> true,
  		size          => '10M',
  		dateext    => 'day',
	}
}
