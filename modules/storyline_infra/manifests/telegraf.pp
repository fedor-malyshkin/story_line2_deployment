class storyline_infra::telegraf () {
	include stdlib
	include apt


	$params = lookup({"name" => "storyline_infra.telegraf",
	    "merge" => {"strategy" => "deep"}})
	$server_port = $params['server_port']
	$server_address = $params['server_address']
	$pid_file = $params['pid_file']
	$init_script = $params['init_script']
	$dir_data = $params['dir_data']
	$dir_logs = $params['dir_logs']
	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']
	$version = $params['version']
	$dist_name = $facts['os']['name']
# mongo db
	$enabled_mongodb = $params['enabled_mongodb']
	$mongodb_user = $params['mongodb_user']
	$mongodb_password = $params['mongodb_password']
	# elasticsearch
	$enabled_elasticsearch = $params['enabled_elasticsearch']
	$elasticsearch_host = $params['elasticsearch_host']
	$elasticsearch_port = $params['elasticsearch_port']
	$elasticsearch_cluster = $params['elasticsearch_cluster']

	exec { "telegraf-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		require => Exec['telegraf-mkdir'],
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		require => Exec['telegraf-mkdir'],
	}
	# see by "gpg --verify keyfile"
	apt::key { 'telegraf-key':
		id => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
		source  => 'https://repos.influxdata.com/influxdb.key',
	} ->
	# echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	apt::source { 'telegraf-repo':
		comment  => 'influxdb repo',
		location => "https://repos.influxdata.com/${downcase($dist_name)}",
		release => "${facts['os']['distro']['codename']}",
		repos    => 'stable',
		include  => {
			'deb' => true,
		},
	} ->
	package {  'telegraf':
		# 	ensure => $version,
		ensure => "present",
	} ->
	file { "/etc/telegraf/telegraf.conf":
		replace => true,
		content => epp('storyline_infra/telegraf.epp'),
		notify => Service['telegraf'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/telegraf_startup.epp'),
		mode=>"ug=rw,o=r",
		notify => Service['telegraf'],
	}->
	file { "${dir_data}/telegraf.sh":
		replace => true,
		content => epp('storyline_infra/telegraf_script.epp'),
		notify => Service['telegraf'],
		owner => "telegraf",
		group=> "telegraf",
		mode=>"u=rwx,og=rx",
	}->
	service { 'telegraf':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		provider => 'systemd',
		hasrestart => true,
		hasstatus => true,
	}
}
