class storyline_components::spark () {
	$params = lookup({"name" => "storyline_components.spark",
	    "merge" => {"strategy" => "deep"}})

	$version = $params['version']
	$dir_data = $params['dir_data']
	$dir_bin = $params['dir_bin']
	$dir_logs = $params['dir_logs']
	# executors
	$executor_local_ip = $::serverip
	$executor_data_dir =  $params['executor_data_dir']
	# master
	$master_port =  $params['master_port']
	$master_webui_port =  $params['master_webui_port']
	# worker
	$worker_master_url =  $params['worker_master_url']
	$worker_cores =  $params['worker_cores']
	$worker_memory =  $params['worker_memory']
	$worker_port =  $params['worker_port']
	$worker_webui_port =  $params['worker_webui_port']
	$worker_dir =  $params['worker_dir']
	# daemon
	$daemon_memory =  $params['daemon_memory']
	# spark it self
	$spark_public_dns = $trusted['certname']
	$spark_pid_dir =  $params['spark_pid_dir']

	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']

	$certname = $trusted['certname']

	user { 'spark':
		ensure => "present",
		managehome => true,
	}
	exec { "spark-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dirы
	file { [$dir_bin, $dir_logs, $dir_data, $executor_data_dir, $worker_dir] :
		ensure => "directory",
		recurse => "true",
		owner => "spark",
		group => "spark",
		require => Exec['spark-mkdir'],
	} ->
	archive { "server_spark-archive":
		path=> "/provision/apache-spark-${version}.tgz",
  		source=>"http://apache-mirror.rbc.ru/pub/apache/spark/spark-${version}/spark-${version}-bin-hadoop2.7.tgz",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['spark_move_to_no_version_dir'],
	} ->
	exec { "spark_move_to_no_version_dir":
		command => "/bin/mv -f -t ${dir_bin} /provision/spark-${version}-bin-hadoop2.7/* && chown -R spark:spark ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/conf/spark-env.sh":
		replace => true,
		owner => "spark",
		group => "spark",
		mode=>"u=rwx,og=rx",
		content => epp('storyline_components/spark-env.sh.epp'),
		notify => Service['spark_master', 'spark_worker'],
	}
	['master','worker'].each |String $service| {
		service { "spark_${service}":
			ensure => $enabled_running,
			enable    => $enabled_startup,
			start 		=> "/etc/init.d/spark_${service} start",
			stop 		=> "/etc/init.d/spark_${service} stop",
			status 		=> "/etc/init.d/spark_${service} status",
			restart 	=> "/etc/init.d/spark_${service} restart",
			hasrestart => true,
			hasstatus => true,
		} ->
		file { "/etc/init.d/spark_${service}":
			replace => true,
			owner => "spark",
			group => "spark",
			content => epp("storyline_components/spark_${service}_startup.epp"),
			mode=>"ug=rwx,o=r",
 		} ->
		file { "${dir_bin}/spark_${service}.sh":
			replace => true,
			owner => "spark",
			group => "spark",
			content => epp("storyline_components/spark_${service}_script.epp"),
			mode=>"u=rwx,og=rx",
		}
	}
}
