class storyline_infra::grafana () {
	include stdlib

	$params = lookup({"name" => "storyline_infra.grafana",
	    "merge" => {"strategy" => "deep"}})
	$port = $params['port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']

	user { 'grafana':
		ensure => "present",
		managehome => true,
	}
	exec { "grafana-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		owner => "grafana",
		group=> "grafana",
		require => Exec['grafana-mkdir'],
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		owner => "grafana",
		group=> "grafana",
		require => Exec['grafana-mkdir'],
	}
	# see by "gpg --verify keyfile"
	apt::key { 'grafana-key':
		id => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
		source  => 'https://packagecloud.io/gpg.key',
	} ->
	# deb https://packagecloud.io/grafana/stable/debian/ jessie main
	apt::source { 'grafana-repo':
		comment  => 'grafana repo',
		location => "https://packagecloud.io/grafana/stable/debian/",
		release => "jessie",
		repos    => 'main',
		include  => {
	   		'deb' => true,
		},
	} ->
	package {  'grafana':
	 	ensure => 'present',
	}
	file { '/etc/init.d/grafana-server':
		ensure => 'absent',
	} ->
	file { '/etc/grafana':
		ensure => "directory",
	} ->
	file { "/etc/grafana/grafana.ini":
	 	replace => true,
	 	content => epp('storyline_infra/grafana.epp'),
	 	owner => "grafana",
	 	group=> "grafana",
	 	notify => Service['grafana'],
	} ->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/grafana_startup.epp'),
		mode=>"ug=rw,o=r",
		notify => Service['grafana'],
	}->
	service { 'grafana':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		start 		=> "systemctl start grafana",
		stop 		=> "systemctl stop grafana",
		status 		=> "systemctl status grafana",
		restart 	=> "systemctl restart grafana",
		hasrestart => true,
		hasstatus => true,
	}
	if $enabled_startup != true {
		exec { "disable_grafana":
			command => "/bin/systemctl disable grafana",
			cwd => "/",
		}
	}

}
