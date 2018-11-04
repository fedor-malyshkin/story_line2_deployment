class storyline_infra::kafka () {

	$params = lookup({"name" => "storyline_infra.kafka",
	    "merge" => {"strategy" => "deep"}})
	$plaintext_port = $params['plaintext_port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$cluster = $params['cluster']
	$zookeeper_urls = $params['zookeeper_urls']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']
	$jmx_port = $params['jmx_port']
	$certname = $trusted['certname']
	$broker_id = $cluster[$certname]

	user { 'kafka':
		ensure => "present",
		managehome => true,
	}
	exec { "kafka-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [$dir_bin, $dir_logs, $dir_data]:
		ensure => "directory",
		recurse => "true",
		owner => "kafka",
		group=> "kafka",
		require => Exec['kafka-mkdir'],
	} ->
	archive { "kafka-archive":
		path=> "/provision/kafka_2.11-${version}.tar.gz",
  		source=> "http://apache-mirror.rbc.ru/pub/apache/kafka/2.0.0/kafka_2.11-${version}.tgz",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['kafka_move_to_no_version_dir'],
	} ->
	exec { "kafka_move_to_no_version_dir":
		#command => "/bin/mv /provision/kafka-${version} ${dir_bin}",
		command => "/bin/mv -f -t ${dir_bin} /provision/kafka_2.11-${version}/*  && chown -R kafka:kafka ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/config/server.properties":
		replace => true,
		content => epp('storyline_infra/kafka.epp'),
		owner => "kafka",
		group=> "kafka",
	}->
	file { "/data/db/jmxtrans/conf/kafka.json":
		replace => true,
		content => epp('storyline_infra/kafka_jmx.epp'),
		notify => Service['jmxtrans'],
		owner => "jmxtrans",
		group=> "jmxtrans",
		mode=>"u=rwx,og=rx",
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/kafka_startup.epp'),
		mode=>"u=rw,og=r",
		notify => Service['kafka'],
	}->
	file { "${dir_data}/kafka.sh":
		replace => true,
		content => epp('storyline_infra/kafka_script.epp'),
		notify => Service['kafka'],
		owner => "kafka",
		group=> "kafka",
		mode=>"u=rwx,og=rx",
	}->
	service { 'kafka':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		provider => 'systemd',
		hasrestart => true,
		hasstatus => true,
	}
}
