class storyline_components::storm () {
	$params = lookup({"name" => "storyline_components.storm",
	    "merge" => {"strategy" => "deep"}})

	$topology_version = $params['topology_version']
	$version = $params['version']
	$storm_ui_port = $params['storm_ui_port']
	$storm_nimbus_port = $params['storm_nimbus_port']
	$storm_logviewer_port = $params['storm_logviewer_port']
	$storm_drpc_port = $params['storm_drpc_port']
	$storm_supervisor_slot_ports = $params['storm_supervisor_slot_ports']
	$dir_data = $params['dir_data']
	$dir_bin = $params['dir_bin']
	$dir_logs = $params['dir_logs']
	$zookeeper_hosts = $params['zookeeper_hosts']
	$zookeeper_port = $params['zookeeper_port']
	$storm_nimbus_seeds = $params['storm_nimbus_seeds']
	$storm_drpc_servers = $params['storm_drpc_servers']
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

	user { 'storm':
		ensure => "present",
		managehome => true,
	}
	exec { "storm-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dirы
	file { [$dir_bin, $dir_logs, $dir_data, $dir_topo] :
		ensure => "directory",
		recurse => "true",
		owner => "storm",
		group => "storm",
		require => Exec['storm-mkdir'],
	} ->
	archive { "server_storm-archive":
		path=> "/provision/apache-storm-${version}.zip",
  		source=>"http://apache-mirror.rbc.ru/pub/apache/storm/apache-storm-${version}/apache-storm-${version}.zip",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['storm_move_to_no_version_dir'],
	} ->
	exec { "storm_move_to_no_version_dir":
		command => "/bin/mv -f -t ${dir_bin} /provision/apache-storm-${version}/* && chown -R storm:storm ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/conf/storm.yaml":
		replace => true,
		owner => "storm",
		group => "storm",
		content => epp('storyline_components/storm.epp'),
		notify => Service['storm_nimbus', 'storm_supervisor', 'storm_drpc'],
	}
	['ui','nimbus','supervisor','logviewer', 'drpc'].each |String $service| {
		service { "storm_${service}":
			ensure => $enabled_running,
			enable    => $enabled_startup,
			start 		=> "/etc/init.d/storm_${service} start",
			stop 		=> "/etc/init.d/storm_${service} stop",
			status 		=> "/etc/init.d/storm_${service} status",
			restart 	=> "/etc/init.d/storm_${service} restart",
			hasrestart => true,
			hasstatus => true,
		} ->
		file { "/etc/init.d/storm_${service}":
			replace => true,
			owner => "storm",
			group => "storm",
			content => epp("storyline_components/storm_${service}_startup.epp"),
			mode=>"ug=rwx,o=r",
 		} ->
		file { "${dir_bin}/storm_${service}.sh":
			replace => true,
			owner => "storm",
			group => "storm",
			content => epp("storyline_components/storm_${service}_script.epp"),
			mode=>"u=rwx,og=rx",
		}
	}

	# update version
	# if $topology_version == "presented" {
	# 	$jar_file = "server_storm-PRESENTED.jar"
	# 	$jar_file_provision = get_first_jar_file_name('/provision/artifacts')
	# 	$full_path_jar_file = "${dir_topo}/${jar_file}"
	# 	# get artifact "/provision/artifacts" dir
	# 	# returns file names with full path
	# 	file { $full_path_jar_file:
	# 		replace => true,
	# 		ensure => file,
	# 		owner => "storm",
	# 		group => "storm",
	# 		source => "file://${jar_file_provision}",
	# 		# notify => Exec['deploy-topology'],
	# 	}
	# 	# copy in any case
	# 	#if $current_version != $version {
	# 	#} # if $current_version != $version {
	# } else {
	# 	$jar_file = "server_storm-${topology_version}-all.jar"
	# 	$full_path_jar_file = "${dir_topo}/${jar_file}"
	# 	if $current_topology_version != $topology_version {
	# 		# get artifact from nexus
	# 		nexus::artifact { $full_path_jar_file:
	# 			gav => "ru.nlp_project.story_line2:server_storm:${topology_version}",
	# 			repository => "releases",
	# 			classifier => 'all',
	# 			output => $full_path_jar_file,
	# 			packaging  => 'jar',
	# 			# notify => Exec['deploy-topology'],
	# 		}
	# 	} # if $current_version != $version {
	# }
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
			owner => "storm",
			group => "storm",
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
				owner => "storm",
				group => "storm",
				source => "file://${file_name_presented}",
			}
			#} # if $current_version != $version {
		} else {
			$script_name = "server_storm_scripts_${script_version}.jar"
			if $script_current_version != $script_version {
				file { "${dir_bin}/script_version":
					replace => true,
					owner => "storm",
					group => "storm",
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
			owner => "storm",
			group => "storm",
			content => epp('storyline_components/server_storm_config.epp'),
		}
	}
}