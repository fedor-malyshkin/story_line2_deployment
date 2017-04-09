class storyline_infra::zookeeper () {

	$params = lookup({"name" => "storyline_infra.zookeeper",
	    "merge" => {"strategy" => "deep"}})
	$port = $params['port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$ensemble = $params['ensemble']
	$leader_port = $params['leader_port']
	$election_port = $params['election_port']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']
	$certname = $trusted['certname']

	user { 'zookeeper':
		ensure => "present",
		managehome => true,
	}
	exec { "zookeeper-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [$dir_bin, $dir_logs, $dir_data]:
		ensure => "directory",
		recurse => "true",
		owner => "zookeeper",
		group=> "zookeeper",
		require => Exec['zookeeper-mkdir'],
	}
	archive { "zookeeper-archive":
		path=> "/provision/zookeeper-${version}.tar.gz",
  		source=> "http://apache-mirror.rbc.ru/pub/apache/zookeeper/zookeeper-${version}/zookeeper-${version}.tar.gz",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['zookeeper_move_to_no_version_dir'],
	}
	exec { "zookeeper_move_to_no_version_dir":
		#command => "/bin/mv /provision/zookeeper-${version} ${dir_bin}",
		command => "/bin/mv -f -t ${dir_bin} /provision/zookeeper-${version}/*  && chown -R zookeeper:zookeeper ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/conf/zoo.cfg":
		replace => true,
		content => epp('storyline_infra/zoo.epp'),
		owner => "zookeeper",
		group=> "zookeeper",
	}->
	file { "${dir_bin}/conf/log4j.properties":
		replace => true,
		content => epp('storyline_infra/zoo_log4j'),
		owner => "zookeeper",
		group=> "zookeeper",
	}->
	file { "${dir_bin}/bin/zkServer.sh":
		owner => "zookeeper",
		group=> "zookeeper",
		mode=>"u=rwx,og=rx",
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/zookeeper_startup.epp'),
		mode=>"u=rwx,og=r",
		notify => Service['zookeeper'],
	}->
	service { 'zookeeper':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		start 		=> "${init_script} start",
		stop 		=> "${init_script} stop",
		status 		=> "${init_script} status",
		restart 	=> "${init_script} restart",
		hasrestart => true,
		hasstatus => true,
	}
	if $ensemble {
		file { "${dir_data}/myid":
			replace => true,
			content => $ensemble[$certname],
			owner => "zookeeper",
			group=> "zookeeper",
			mode=>"u=rw,og=r",
			notify => Service['zookeeper'],
		}
	}
	if $enabled_startup != true {
		exec { "disable_zookeeper":
			command => "/bin/systemctl disable zookeeper",
			cwd => "/",
		}
	}

}
