class storyline_infra::jmxtrans () {

	$params = lookup({"name" => "storyline_infra.jmxtrans",
	    "merge" => {"strategy" => "deep"}})
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']
	$certname = $trusted['certname']

	user { 'jmxtrans':
		ensure => "present",
		managehome => true,
	}
	exec { "jmxtrans-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [$dir_bin, $dir_logs, $dir_data]:
		ensure => "directory",
		recurse => "true",
		owner => "jmxtrans",
		group=> "jmxtrans",
		require => Exec['jmxtrans-mkdir'],
	} ->
	file { "${dir_data}/conf":
		ensure => "directory",
		recurse => "true",
		owner => "jmxtrans",
		group=> "jmxtrans",
	} ->
	archive { "jmxtrans-archive":
		path=> "/provision/jmxtrans-${version}.tar.gz",
  		source=> "http://central.maven.org/maven2/org/jmxtrans/jmxtrans/${version}/jmxtrans-${version}-dist.tar.gz",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['jmxtrans_move_to_no_version_dir'],
	} ->
	exec { "jmxtrans_move_to_no_version_dir":
		#command => "/bin/mv /provision/jmxtrans-${version} ${dir_bin}",
		command => "/bin/mv -f -t ${dir_bin} /provision/jmxtrans-${version}/*  && chown -R jmxtrans:jmxtrans ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/jmxtrans.conf":
		replace => true,
		content => epp('storyline_infra/jmxtrans.epp'),
		notify => Service['jmxtrans'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/jmxtrans_startup.epp'),
		mode=>"u=rw,og=r",
		notify => Service['jmxtrans'],
	}->
	service { 'jmxtrans':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		provider => 'systemd',
		hasrestart => true,
		hasstatus => true,
	}
}
