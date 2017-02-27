class storyline_infra::mongodb (
	String $port = '27017',
	String $pid_file = '/data/logs/mongodb/mongodb.pid',
	String $init_script = '/etc/init.d/mongodb',
	String $dir_data = '/data/db/mongodb',
	String $dir_logs = '/data/logs/mongodb',
	Boolean $enabled_startup = false,) {

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
		ensure => 'present',
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
