class storyline_components::crawler () {

	$a_lot_of_params = lookup({"name" => "storyline_components",
	    "merge" => {"strategy" => "deep"}})

	$script_params = $a_lot_of_params['crawler_scripts']
	$script_version = $script_params['version']

	$params = $a_lot_of_params['crawler']
	$app_port = $params['app_port']
	$admin_port = $params['admin_port']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_bin = $params['dir_bin']
	$dir_data = $params['dir_data']
	$dir_scripts = $params['dir_scripts'] # groovy scripts
	$dir_sites_db = $params['dir_sites_db'] # temporal db with crawling status
	$mongodb_connection_url = $params['mongodb_connection_url'] # temporal db with crawling status
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

	user { 'crawler':
		ensure => "present",
		managehome => true,
	}
	exec { "crawler-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	}
	# working dirы
	file { [$dir_bin, $dir_logs, $dir_data, $dir_scripts, $dir_sites_db] :
		ensure => "directory",
		recurse => "true",
		owner => "crawler",
		group=> "crawler",
		require => Exec['crawler-mkdir'],
	}->
	file { "${dir_bin}/crawler.yaml":
		replace => true,
		content => epp('storyline_components/crawler.epp'),
		notify => Service['crawler'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_components/crawler_startup.epp'),
		mode=>"u=rw,og=r",
	}

	# update version
	if $version == "presented" {
		$jar_file = "crawler-PRESENTED.jar"
		# copy in any case
		#if $current_version != $version {
			# get artifact "/provision/artifacts" dir
			# returns file names with full path
			$file_name_presented = get_first_jar_file_name('/provision/artifacts')
			file { "${dir_bin}/${jar_file}":
				replace => true,
				ensure => file,
				owner => "crawler",
				group=> "crawler",
				source => "file://${file_name_presented}",
				notify => File["${dir_bin}/crawler.sh"],
			} ->
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
			}
		#} # if $current_version != $version {
	} else {
		$jar_file = "crawler-${version}.jar"
		if $current_version != $version {
			# get artifact from nexus
			nexus::artifact {"${dir_bin}/${jar_file}":
				gav => "ru.nlp_project.story_line2:crawler:${version}",
				repository => "releases",
				# classifier => 'all',
				output => "${dir_bin}/${jar_file}",
				timeout => 0,
				packaging  => 'jar',
				notify => File["${dir_bin}/crawler.sh"],
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
		$script_file_name_presented = get_first_jar_file_name('/provision/crawler_scripts')
		# copy in any case
		#if $current_version != $version {
		file { "${dir_bin}/script_version":
			replace => true,
			content => "${script_version}",
			notify 		  => Exec['empty_crawler_dir_scripts'],
		} ->
		exec { "empty_crawler_dir_scripts":
			command => "/bin/rm -r -f ${dir_scripts}/*",
			cwd => "/",
			refreshonly => true,
		} ->
		archive { $script_file_name_presented:
			# require			=> Exec['empty_crawler_scripts_archive'],
			# path			=> "${dir_scripts}/crawler_scripts_${version}.jar",
			# source 			=> "$script_file_name_presented",
			extract       	=> true,
			extract_path  	=> "${dir_scripts}",
			creates			=> "${dir_scripts}/ru/nlp_project/story_line2/crawler_scripts",
			cleanup       	=> false,
			notify 			=> [Service['crawler']],
		}
		# exec { "tune_crawler_dir_scripts":
		# 	command => "/bin/mv -f  ${dir_scripts}/ru/nlp_project/story_line2/crawler_scripts/* ${dir_scripts} && chown -R crawler:crawler ${dir_scripts}",
		# 	cwd => "/",
		# 	refreshonly => true,
		# }
		#} # if $current_version != $version {
	} else {
		if $script_current_version != $script_version {
			file { "${dir_bin}/script_version":
				replace => true,
				content => "${script_version}",
				notify 		  => Exec['empty_crawler_dir_scripts'],
			} 
			exec { "empty_crawler_dir_scripts":
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
				# require			=> Exec['empty_crawler_scripts_archive'],
				# path			=> "${dir_scripts}/crawler_scripts_${script_version}.jar",
				# source 			=> "$script_file_name_presented",
				extract       	=> true,
				extract_path  	=> "${dir_scripts}",
				creates			=> "${dir_scripts}/ru/nlp_project/story_line2/crawler_scripts",
				cleanup       	=> false,
				notify 			=> [Service['crawler']],
			}
			# exec { "tune_crawler_dir_scripts":
			# 	command => "/bin/mv -f  ${dir_scripts}/ru/nlp_project/story_line2/crawler_scripts/* ${dir_scripts} && chown -R crawler:crawler ${dir_scripts}",
			# 	cwd => "/",
			# 	refreshonly => true,
			# }
		} # if $current_version != $version {
	}

	file { "${dir_bin}/crawler.sh":
		replace => true,
		content => epp('storyline_components/crawler_script.epp'),
		notify => Service['crawler'],
		owner => "crawler",
		group=> "crawler",
		mode=>"u=rwx,og=rx",
	}->
	service { 'crawler':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		provider => 'systemd',
		hasrestart => true,
		hasstatus => true,
	}
}
