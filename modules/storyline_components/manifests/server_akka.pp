class storyline_components::server_akka () {

	$a_lot_of_params = lookup({"name" => "storyline_components",
	    "merge" => {"strategy" => "deep"}})

	$script_params = $a_lot_of_params['crawler_scripts']
	$script_version = $script_params['version']

	$params = $a_lot_of_params['server_akka']
	$app_port = $params['app_port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_scripts = $params['dir_scripts'] # groovy scripts
	$elasticsearch_host = $params['elasticsearch_host']
	$elasticsearch_port = $params['elasticsearch_port']
	$hive_connection_url = $params['hive_connection_url'] # temporal db with crawling status
	$kafka_connection_url = $params['kafka_connection_url'] # temporal db with crawling status
	$dir_logs = $params['dir_logs']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']

	$certname = $trusted['certname']
	$influxdb_host = $params['influxdb_host']
	$influxdb_port = $params['influxdb_port']
	$influxdb_db = $params['influxdb_db']
	$influxdb_user = $params['influxdb_user']
	$influxdb_password = $params['influxdb_password']

	# Java memory settings
	$jvm_start_memory_mb  = $params['jvm_start_memory_mb']
	$jvm_max_memory_mb  = $params['jvm_max_memory_mb']

	# при запуске на сервер - получить соотвествующее содержимое файла
	# или пусту строку - для определения дальнейших действий
	$current_version = file_content("${dir_bin}/version")
	$script_current_version = file_content("${dir_bin}/script_version")

	include storyline_components

	user { 'server_akka':
		ensure => "present",
		managehome => true,
	}
	exec { "server_akka-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	}
	# working dirы
	file { [$dir_bin, $dir_logs, $dir_data,  $dir_scripts ] :
		ensure => "directory",
		recurse => "true",
		owner => "server_akka",
		group=> "server_akka",
		require => Exec['server_akka-mkdir'],
	}->
	file { "${dir_bin}/server_akka.conf":
		replace => true,
		content => epp('storyline_components/server_akka.epp'),
		notify => Service['server_akka'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_components/server_akka_startup.epp'),
		mode=>"u=rw,og=r",
	}

	# update version
	if $version == "presented" {
		$jar_file = "server_akka-PRESENTED.jar"
		# copy in any case
		#if $current_version != $version {
			# get artifact "/provision/artifacts" dir
			# returns file names with full path
			$file_name_presented = get_first_jar_file_name('/provision/artifacts')
			file { "${dir_bin}/${jar_file}":
				replace => true,
				ensure => file,
				owner => "server_akka",
				group=> "server_akka",
				source => "file://${file_name_presented}",
				notify => File["${dir_bin}/server_akka.sh"],
			} ->
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
			}
		#} # if $current_version != $version {
	} else {
		$jar_file = "server_akka-${version}.jar"
		if $current_version != $version {
			# get artifact from nexus
			nexus::artifact {"${dir_bin}/${jar_file}":
				gav => "ru.nlp_project.story_line2:server_akka:${version}",
				repository => "releases",
				classifier => 'all',
				output => "${dir_bin}/${jar_file}",
				timeout => 0,
				packaging  => 'jar',
				notify => File["${dir_bin}/server_akka.sh"],
			} ->
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
			}
		} # if $current_version != $version {
	}


	# update script version
	if $script_version == "presented" {
		# get artifact from "/provision/crawler_scripts" dir
		# returns file names with full path
		$script_file_name_presented = get_first_jar_file_name('/provision/server_akka_scripts')
		# copy in any case
		#if $current_version != $version {
		file { "${dir_bin}/script_version":
			replace => true,
			content => "${script_version}",
			notify 		  => Exec['empty_server_akka_dir_scripts'],
		} ->
		exec { "empty_server_akka_dir_scripts":
			command => "/bin/rm -r -f ${dir_scripts}/*",
			cwd => "/",
			refreshonly => true,
		} ->
		archive { $script_file_name_presented:
			extract       	=> true,
			extract_path  	=> "${dir_scripts}",
			creates			=> "${dir_scripts}/ru/nlp_project/story_line2/crawler_scripts",
			cleanup       	=> false,
			notify 			=> [Service['server_akka']],
		}
		#} # if $current_version != $version {
	} else {
		if $script_current_version != $script_version {
			file { "${dir_bin}/script_version":
				replace => true,
				content => "${script_version}",
				notify 		  => Exec['empty_server_akka_dir_scripts'],
			}
			exec { "empty_server_akka_dir_scripts":
				require => File["${dir_scripts}"],
				command => "/bin/rm -f -r ${dir_scripts}/*",
				cwd => "/",
				refreshonly => true,
			} ->
			# get artifact from nexus
			nexus::artifact {"${dir_scripts}/crawler_scripts_${script_version}.jar":
				gav => "ru.nlp_project.story_line2:crawler_scripts:${script_version}",
				repository => "releases",
				timeout => 0,
				output => "${dir_scripts}/crawler_scripts_${script_version}.jar",
				packaging  => 'jar',
			}->
			archive { "${dir_scripts}/crawler_scripts_${script_version}.jar":
				extract       	=> true,
				extract_path  	=> "${dir_scripts}",
				creates			=> "${dir_scripts}/ru/nlp_project/story_line2/crawler_scripts",
				cleanup       	=> false,
				notify 			=> [Service['server_akka']],
			}
		} # if $current_version != $version {
	}
	file { "${dir_bin}/server_akka.sh":
		replace => true,
		content => epp('storyline_components/server_akka_script.epp'),
		notify => Service['server_akka'],
		owner => "server_akka",
		group=> "server_akka",
		mode=>"u=rwx,og=rx",
	}->
	service { 'server_akka':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		provider => 'systemd',
		hasrestart => true,
		hasstatus => true,
	}
}
