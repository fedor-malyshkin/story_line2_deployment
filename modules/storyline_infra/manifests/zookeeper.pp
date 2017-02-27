class storyline_infra::zookeeper (
	String $port = '2181',
	String $pid_file = '/data/db/zookeeper/zookeeper_server.pid',
	String $init_script = '/etc/init.d/zookeeper',
	String $dir_bin = '/zookeeper',
	String $dir_data = '/data/db/zookeeper',
	String $dir_logs = '/data/logs/zookeeper',
	Boolean $enabled_startup = false,
	String $version = '3.4.8',) {

	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	user { 'zookeeper':
		ensure => "present",
		managehome => true,
	}
	exec { "zookeeper-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		owner => "zookeeper",
		group=> "zookeeper",
		require => Exec['zookeeper-mkdir'],
	}
	file { $dir_data:
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
  		cleanup       => true,
	}->
	exec { "zookeeper-move_to_no_version_dir":
		command => "/bin/mv /provision/zookeeper-${version} ${dir_bin}",
		creates => $dir_bin,
		cwd => "/",
		onlyif => "/usr/bin/test ! -d $dir_bin",
	} ->
	file { $dir_bin:
		ensure => "directory",
		recurse => "true",
		owner => "zookeeper",
		group=> "zookeeper",
	}->
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
		mode=>"ug=rwx,o=rx",
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/zookeeper_startup.epp'),
		mode=>"ug=rwx,o=rx",
		notify => Service['zookeeper'],
	}->
	service { 'zookeeper':
  		ensure => $service_status,
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
