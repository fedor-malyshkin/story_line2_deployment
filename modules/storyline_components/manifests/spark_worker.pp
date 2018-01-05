class storyline_components::spark_worker () {
	$params = lookup({"name" => "storyline_components.spark_worker",
	    "merge" => {"strategy" => "deep"}})

	$topology_version = $params['version']
	$version = $params['apache_storm_version']
	$ui_port = $params['ui_port']
	$nimbus_port = $params['nimbus_port']
	$logviewer_port = $params['logviewer_port']
	$drpc_port = $params['drpc_port']
	$ui_pid_file = $params['ui_pid_file']
	$supervisor_slot_ports = $params['supervisor_slot_ports']
	$dir_data = $params['dir_data']
	$dir_bin = $params['dir_bin']
	$dir_logs = $params['dir_logs']
	$zookeeper_hosts = $params['zookeeper_hosts']
	$zookeeper_port = $params['zookeeper_port']
	$nimbus_seeds = $params['nimbus_seeds']
	$drpc_servers = $params['drpc_servers']
	$influxdb_host = $params['influxdb_host']
	$influxdb_port = $params['influxdb_port']
	$influxdb_db = $params['influxdb_db']
	$influxdb_user = $params['influxdb_user']
	$influxdb_password = $params['influxdb_password']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
 	# config params
	$mongodb_connection_url = $params['mongodb_connection_url']
	$elasticsearch_host = $params['elasticsearch_host']
	$elasticsearch_port = $params['elasticsearch_port']
	$configuration_url_prefix = $params['configuration_url_prefix']

	$certname = $trusted['certname']
	# при запуске на сервер - получить соотвествующее содержимое файла
	# или пусту строку - для определения дальнейших действий
	$current_topology_version = file_content("${dir_bin}/topology_version")
	$dir_topo = '/server_storm_topology'


	$nginx_params = lookup({"name" => "storyline_infra.nginx",
		"merge" => {"strategy" => "deep"}})
	# topology_configuration на этом узле
	$enabled_topology_configuration = $nginx_params['enabled_topology_configuration']
	# crawler_scripts
	$crawler_params = lookup({"name" => "storyline_components.crawler_scripts",
		"merge" => {"strategy" => "deep"}})
	$script_version = $crawler_params['version']
	$script_current_version = file_content("${dir_bin}/script_version")

	include storyline_components

	user { 'server_storm':
		ensure => "present",
		managehome => true,
	}
	exec { "storm-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	}
	# working dirы
	file { [$dir_bin, $dir_logs, $dir_data, $dir_topo] :
		ensure => "directory",
		recurse => "true",
		owner => "server_storm",
		group=> "server_storm",
		require => Exec['storm-mkdir'],
	}->
	archive { "server_storm-archive":
		path=> "/provision/apache-storm-${version}.zip",
  		source=>"http://apache-mirror.rbc.ru/pub/apache/storm/apache-storm-${version}/apache-storm-${version}.zip",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['server_storm_move_to_no_version_dir'],
	}
	exec { "server_storm_move_to_no_version_dir":
		command => "/bin/mv -f -t ${dir_bin} /provision/apache-storm-${version}/* && chown -R server_storm:server_storm ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/conf/storm.yaml":
		replace => true,
		owner => "server_storm",
		group=> "server_storm",
		content => epp('storyline_components/storm.epp'),
		notify => Service['server_storm_nimbus', 'server_storm_supervisor', 'server_storm_drpc'],
	}
	['ui','nimbus','supervisor','logviewer', 'drpc'].each |String $service| {
		service { "server_storm_${service}":
			ensure => $enabled_running,
			enable    => $enabled_startup,
			start 		=> "/etc/init.d/server_storm_${service} start",
			stop 		=> "/etc/init.d/server_storm_${service} stop",
			status 		=> "/etc/init.d/server_storm_${service} status",
			restart 	=> "/etc/init.d/server_storm_${service} restart",
			hasrestart => true,
			hasstatus => true,
		}
		file { "/etc/init.d/server_storm_${service}":
			replace => true,
			owner => "server_storm",
			group=> "server_storm",
			content => epp("storyline_components/${service}_startup.epp"),
			mode=>"ug=rwx,o=r",
 		}
		file { "${dir_bin}/server_storm_${service}.sh":
			replace => true,
			owner => "server_storm",
			group=> "server_storm",
			content => epp("storyline_components/${service}_script.epp"),
			mode=>"u=rwx,og=rx",
		}
	}

	# update version
	if $topology_version == "presented" {
		$jar_file = "server_storm-PRESENTED.jar"
		$jar_file_provision = get_first_jar_file_name('/provision/artifacts')
		$full_path_jar_file = "${dir_topo}/${jar_file}"
		# get artifact "/provision/artifacts" dir
		# returns file names with full path
		file { $full_path_jar_file:
			replace => true,
			ensure => file,
			owner => "server_storm",
			group=> "server_storm",
			source => "file://${jar_file_provision}",
			# notify => Exec['deploy-topology'],
		}
		# copy in any case
		#if $current_version != $version {
		#} # if $current_version != $version {
	} else {
		$jar_file = "server_storm-${version}-all.jar"
		$full_path_jar_file = "${dir_topo}/${jar_file}"
		if $current_topology_version != $topology_version {
			# get artifact from nexus
			nexus::artifact { $full_path_jar_file:
				gav => "ru.nlp_project.story_line2:server_storm:${topology_version}",
				repository => "releases",
				classifier => 'all',
				output => $full_path_jar_file,
				packaging  => 'jar',
				# notify => Exec['deploy-topology'],
			}
		} # if $current_version != $version {
	}
# 	exec{ 'deploy-topology':
# 		command => "${dir_bin}/bin/storm deploy ${full_path_jar_file}",
# #		creates => $dir_bin,
# 		cwd => "/",
# #		onlyif => "/usr/bin/test ! -d $dir_bin",
# 	} ->
# 	file { "${dir_bin}/version":
# 		replace => true,
# 		content => "${topology_version}",
# 	}

	if $enabled_topology_configuration {
		file { "${dir_bin}/topology":
			ensure => "directory",
			recurse => "true",
			owner => "server_storm",
			group=> "server_storm",
			require => File[ $dir_bin],
		}
		# scripts
		# update script version
		if $script_version == "presented" {
			# get artifact from "/provision/crawler_scripts" dir
			# returns file names with full path
			$script_file_name_presented = get_first_jar_file_name('/provision/crawler_scripts')
			$script_name = "server_storm_scripts.jar"
			$script_full_path = "${dir_bin}/topology/${script_name}"
			# copy in any case
			file { $script_full_path:
				replace => true,
				ensure => file,
				owner => "server_storm",
				group=> "server_storm",
				source => "file://${file_name_presented}",
			}
			#} # if $current_version != $version {
		} else {
			$script_name = "server_storm_scripts_${script_version}.jar"
			if $script_current_version != $script_version {
				file { "${dir_bin}/script_version":
					replace => true,
					owner => "server_storm",
					group=> "server_storm",
					content => "${script_version}",
				}
				$script_full_path = "${dir_bin}/topology/${script_name}"
				# get artifact from nexus
				nexus::artifact { $script_full_path:
					gav => "ru.nlp_project.story_line2:crawler_scripts:${script_version}",
					repository => "releases",
					output => $script_full_path,
					packaging  => 'jar',
				}
			} # if $current_version != $version {
		}
		file { "${dir_bin}/topology/server_storm.yaml":
			replace => true,
			owner => "server_storm",
			group=> "server_storm",
			content => epp('storyline_components/server_storm_config.epp'),
		}
	}
}
