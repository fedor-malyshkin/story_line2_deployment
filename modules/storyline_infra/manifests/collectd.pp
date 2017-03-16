class storyline_infra::collectd () {
	include stdlib

	$params = lookup({"name" => "storyline_infra.collectd",
	    "merge" => {"strategy" => "deep"}})
	$server_port = $params['server_port']
	$server_address = $params['server_address']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']

	exec { "collectd-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		require => Exec['collectd-mkdir'],
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		require => Exec['collectd-mkdir'],
	}
	package {  'collectd':
		# 	ensure => $version,
		ensure => "present",
	} ->
	file { "/etc/collectd/collectd.conf":
		replace => true,
		content => epp('storyline_infra/collectd.epp'),
		notify => Service['collectd'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/collectd_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['collectd'],
	}->
	service { 'collectd':
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
		exec { "disable_collectd":
			command => "/bin/systemctl disable collectd & /bin/systemctl disable collectd.service",
			cwd => "/",
		}
	}
}
