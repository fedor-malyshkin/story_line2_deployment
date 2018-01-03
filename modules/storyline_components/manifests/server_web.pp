class storyline_components::server_web () {

	$params = lookup({"name" => "storyline_components.server_web",
	    "merge" => {"strategy" => "deep"}})

	$version = $params['version']
	$app_port = $params['app_port']
	$admin_port = $params['admin_port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$drpc_port  = $params['drpc_port']
	$drpc_host = $params['drpc_host']

	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']

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

	include storyline_components

	user { 'server_web':
		ensure => "present",
		managehome => true,
	}
	exec { "server_web-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	}
	# working dirы
	file { [$dir_bin, $dir_logs, $dir_data] :
		ensure => "directory",
		recurse => "true",
		owner => "server_web",
		group=> "server_web",
		require => Exec['server_web-mkdir'],
	}->
	file { "${dir_bin}/server_web.yaml":
		replace => true,
		content => epp('storyline_components/server_web.epp'),
		notify => Service['server_web'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_components/server_web_startup.epp'),
		mode=>"ug=rwx,o=r",
	}

	# update version
	if $version == "presented" {
		$jar_file = "server_web-PRESENTED.jar"
		# copy in any case
		#if $current_version != $version {
			# get artifact "/provision/artifacts" dir
			# returns file names with full path
			$file_name_presented = get_first_jar_file_name('/provision/artifacts')
			file { "${dir_bin}/${jar_file}":
				replace => true,
				ensure => file,
				owner => "server_web",
				group=> "server_web",
				source => "file://${file_name_presented}",
				notify => File["${dir_bin}/server_web.sh"],
			} ->
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
			}

		#} # if $current_version != $version {
	} else {
		$jar_file = "server_web-${version}.jar"
		if $current_version != $version {
			# get artifact from nexus
			nexus::artifact {"${dir_bin}/${jar_file}":
				gav => "ru.nlp_project.story_line2:server_web:${version}",
				repository => "releases",
				# classifier => 'all',
				output => "${dir_bin}/${jar_file}",
				packaging  => 'jar',
				notify => File["${dir_bin}/server_web.sh"],
			} ->
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
			}
		} # if $current_version != $version {
	}
	file { "${dir_bin}/server_web.sh":
		replace => true,
		content => epp('storyline_components/server_web_script.epp'),
		notify => Service['server_web'],
		owner => "server_web",
		group=> "server_web",
		mode=>"u=rwx,og=rx",
	}->
	service { 'server_web':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		start 		=> "${init_script} start",
		stop 		=> "${init_script} stop",
		status 		=> "${init_script} status",
		restart 	=> "${init_script} restart",
		hasrestart => true,
		hasstatus => true,
	}
	if $enabled_startup != true {
		exec { "disable_server_web":
			command => "/bin/systemctl disable server_web",
			cwd => "/",
		}
	}
}
