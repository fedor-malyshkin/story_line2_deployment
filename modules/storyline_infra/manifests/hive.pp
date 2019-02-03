class storyline_infra::hive () {
	include stdlib

	$params = lookup({"name" => "storyline_infra.hive",
	    "merge" => {"strategy" => "deep"}})
	$version = $params['version']
	$dir_pids = $params['dir_pids']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']

	$metastore_hostname = $params['metastore_hostname']
	$metastore_jdbc_driver = $params['metastore_jdbc_driver']
	$metastore_jdbc_url = $params['metastore_jdbc_url']
	$metastore_user = $params['metastore_user']
	$metastore_password = $params['metastore_password']

	$hive_warehouse = $params['hive_warehouse']
	$hive_scratchdir = $params['hive_scratchdir']

	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']

	$hadoop_params = lookup({"name" => "storyline_infra.hadoop",
	    "merge" => {"strategy" => "deep"}})
	$hadoop_dir_bin = $hadoop_params['dir_bin']
	$hadoop_java_home = $hadoop_params['java_home']

	$certname = $trusted['certname']

	user { 'hive':
		ensure => "present",
		managehome => true,
	}
	exec { "hive-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [$dir_bin, $dir_logs, $dir_data]:
		ensure => "directory",
		recurse => "true",
		owner => "hive",
		group=> "hive",
		require => Exec['hive-mkdir'],
	}
	archive { "hive-archive":
		path=> "/provision/hive-${version}.tar.gz",
  		source=> "http://apache-mirror.rbc.ru/pub/apache/hive/hive-${version}/apache-hive-${version}-bin.tar.gz",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['hive_move_to_no_version_dir'],
	}
	exec { "hive_move_to_no_version_dir":
		#command => "/bin/mv /provision/hive-${version} ${dir_bin}",
		command => "/bin/mv -f -t ${dir_bin} /provision/apache-hive-${version}-bin/*  && chown -R hive:hive ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/conf/hive-site.xml":
		replace => true,
		content => epp('storyline_infra/hive-site.epp'),
		owner => "hive",
		group=> "hive",
	}->
	file { "${dir_bin}/conf/hive-env.sh":
		replace => true,
		content => epp('storyline_infra/hive-env.epp'),
		owner => "hive",
		group=> "hive",
	}->
	file { "${dir_bin}/conf/hive-log4j2.properties":
		replace => true,
		content => epp('storyline_infra/hive-log4j2.epp'),
		owner => "hive",
		group=> "hive",
	}->
	file {  "${dir_bin}/lib/mysql-connector-java.jar":
      ensure  => file,
      owner   => 'hive',
      group   => 'hive',
      mode    => '555',
      source  => 'puppet:///modules/storyline_infra/mysql-connector-java.jar',
    }
	['server2','metastore'].each |String $service| {
		file { "/etc/systemd/system/hive_${service}.service":
			replace => true,
			owner => "hive",
			group => "hive",
			content => epp("storyline_infra/hive_${service}_startup.epp"),
			mode=>"ug=rw,o=r",
 		} ->
		file { "${dir_bin}/hive_${service}.sh":
			replace => true,
			owner => "hive",
			group => "hive",
			content => epp("storyline_infra/hive_${service}_script.epp"),
			mode=>"ug=rwx,o=r",
		} ->
		service { "hive_${service}":
			ensure => $enabled_running,
			enable    => $enabled_startup,
			provider => 'systemd',
			hasrestart => true,
			hasstatus => true,
		}
	}
}
