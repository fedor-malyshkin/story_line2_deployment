class storyline_infra::influxdb () {
	include stdlib

	$params = lookup({"name" => "storyline_infra.influxdb",
	    "merge" => {"strategy" => "deep"}})
	$port_http = $params['port_http']
	$port_rpc = $params['port_rpc']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_auth = $params['enabled_auth']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']

	$dist_name = $facts['os']['name']

	user { 'influxdb':
		ensure => "present",
		managehome => true,
	}
	exec { "influxdb-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		owner => "influxdb",
		group=> "influxdb",
		require => Exec['influxdb-mkdir'],
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		owner => "influxdb",
		group=> "influxdb",
		require => Exec['influxdb-mkdir'],
	}
	# see by "gpg --verify keyfile"
	apt::key { 'influxdb-key':
		id => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
		source  => 'https://repos.influxdata.com/influxdb.key',
	} ->
	# echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	apt::source { 'influxdb-repo':
		comment  => 'influxdb repo',
		location => "https://repos.influxdata.com/${downcase($dist_name)}",
		release => "${facts['os']['distro']['codename']}",
		repos    => 'stable',
		include  => {
	   		'deb' => true,
		},
	} ->
	package {  'influxdb':
	 	ensure => $version,
	} ->
	file { "/etc/influxdb/influxdb.conf":
		replace => true,
		content => epp('storyline_infra/influxdb.epp'),
		owner => "influxdb",
		group=> "influxdb",
		notify => Service['influxdb'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/influxdb_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['influxdb'],
	}->
	service { 'influxdb':
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
		exec { "disable_influxdb":
			command => "/bin/systemctl disable influxdb",
			cwd => "/",
		}
	}
	logrotate::rule { 'influxdb':
  		path			=> "${dir_logs}/*.log",
  		rotate      	=> 10,
		missingok		=> true,
		copytruncate	=> true,
		dateext			=> true,
  		size          	=> '10M',
  		rotate_every    => 'day',
	}
}
