class storyline_infra::nginx () {

	$params = lookup({"name" => "storyline_infra.nginx",
	    "merge" => {"strategy" => "deep"}})
	$reverse_port = $params['reverse_port']
	$reverse_url = $params['reverse_url']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_cache = $params['dir_cache']
	$dir_logs = $params['dir_logs']
	$version = $params['version']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	# topology_configuration
	$enabled_topology_configuration = $params['enabled_topology_configuration']
	$topology_configuration_port = $params['topology_configuration_port']

	user { 'nginx':
		ensure => "present",
		managehome => true,
	}
	exec { "nginx-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [ $dir_logs, $dir_data, $dir_cache ] :
		ensure => "directory",
		recurse => "true",
		owner => "nginx",
		group=> "nginx",
		require => Exec['nginx-mkdir'],
	}
	# see by "gpg --verify keyfile"
	apt::key { 'nginx-key':
		id => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62',
		source  => 'http://nginx.org/keys/nginx_signing.key',
	} ->
	# deb http://nginx.org/packages/ubuntu/ xenial nginx
	apt::source { 'nginx-repo':
		comment  => 'nginx repo',
		location => "http://nginx.org/packages/ubuntu/",
		release => "xenial",
		repos    => "nginx",
		include  => {
	   		'deb' => true,
			'deb-src' => true,
		},
	} ->
	package {  'nginx':
		ensure => $version,
		# notify => Exec['disable_nginx'],
	} ->
	file { "/etc/nginx/nginx.conf":
		replace => true,
		content => epp('storyline_infra/nginx.epp'),
		owner => "nginx",
		group=> "nginx",
		notify => Service['nginx'],
	}->
	file { "/etc/nginx/conf.d/default.conf":
		replace => true,
		content => epp('storyline_infra/nginx_default.epp'),
		owner => "nginx",
		group=> "nginx",
		notify => Service['nginx'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/nginx_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['nginx'],
	}->
	service { 'nginx':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		start 		=> "${init_script} start",
		stop 		=> "${init_script} stop",
		status 		=> "${init_script} status",
		restart 	=> "${init_script} restart",
		hasrestart => true,
		hasstatus => true,
	}
	if $enabled_topology_configuration {
		file { "/etc/nginx/conf.d/topology.conf":
			replace => true,
			content => epp('storyline_infra/nginx_topology.epp'),
			mode=>"ug=rwx,o=r",
			notify => Service['nginx'],
		}
	}
	if $enabled_startup != true {
		exec { "disable_nginx":
			require => Package['nginx'],
			command => "/bin/systemctl disable nginx",
			cwd => "/",
		}
	}

}
