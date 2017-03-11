class storyline_components::crawler () {

	$a_lot_of_params = lookup({"name" => "storyline_components",
	    "merge" => {"strategy" => "deep"}})

	$nexus_repo_url = $a_lot_of_params['nexus_repo_url']

	$params = $a_lot_of_params['crawler']
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
	$version = $params['version']

	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	# при запуске на сервер - получить соотвествующее содержимое файла
	# или пусту строку - для определения дальнейших действий
	$current_version = file_content("${dir_bin}/version")

	user { 'crawler':
		ensure => "present",
		managehome => true,
	}
	exec { "crawler-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
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
		mode=>"ug=rwx,o=r",
	}

	if $version == "presented" {
		$jar_file = "crawler-PRESENTED.jar"
		# copy in any case
		#if $current_version != $version {
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
				notify => File["${dir_bin}/${jar_file}"],
			}
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
			}
		#} # if $current_version != $version {
	} else {
		$jar_file = "crawler-${version}.jar"
		if $current_version != $version {
			file { "${dir_bin}/version":
				replace => true,
				content => "${version}",
				notify => Nexus::Artifact["${dir_bin}/crawler-${version}.jar"],
			}

			# Initialize Nexus
			class {'nexus':
				url => $nexus_repo_url
			}

			# get artifact from nexus
			nexus::artifact {"${dir_bin}/${jar_file}":
				gav => "ru.nlp_project.story_line2:crawler:${version}",
				repository => "releases",
				output => "${dir_bin}/${jar_file}",
				packaging  => 'jar',
				notify => File["${dir_bin}/crawler.sh"],
			}
		} # if $current_version != $version {
	}

	file { "${dir_bin}/crawler.sh":
		replace => true,
		content => epp('storyline_components/crawler_script.epp'),
		notify => Service['crawler'],
		mode=>"ug=rwx,o=rx",
	}->
	service { 'crawler':
  		ensure => $service_status,
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
