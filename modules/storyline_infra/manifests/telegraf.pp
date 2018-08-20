class storyline_infra::telegraf () {
	include stdlib

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
	apt::key { 'influxdb-key':
		id => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
		source  => 'https://repos.influxdata.com/influxdb.key',
	} ->
	# echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	apt::source { 'influxdb-repo':
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
		mode=>"ug=rwx,o=r",
		notify => Service['telegraf'],
	}->
	service { 'telegraf':
  		ensure => $enabled_running,
		enable    => $enabled_startup,
		start 		=> "systemctl start telegraf",
		stop 		=> "systemctl stop telegraf",
		status 		=> "systemctl status telegraf",
		restart 	=> "systemctl restart telegraf",
		hasrestart => true,
		hasstatus => true,
	}
	if $enabled_startup != true {
		exec { "disable_telegraf":
			command => "/bin/systemctl disable telegraf & /bin/systemctl disable telegraf.service",
			cwd => "/",
		}
	}
	if $enabled_mongodb {
		package {  'python-pip':
			ensure => "present",
		} ->
		exec { "install-pymongo":
			command => "/usr/bin/python -m pip install pymongo",
			cwd => "/",
			unless => '/usr/bin/python -m pip show pymongo',
		} ->
		file { "/usr/share/telegraf/mongodb":
			ensure => "directory",
		}->
		file { "/usr/share/telegraf/mongodb.py":
			replace => true,
			content => epp('storyline_infra/telegraf_mongodb_py.epp'),
		}->
		file { "/usr/share/telegraf/mongodb/types.db":
			replace => true,
			content => epp('storyline_infra/telegraf_mongodb_types_db.epp'),
		}->
		file { "/etc/telegraf/telegraf.conf.d/mongodb.conf":
			replace => true,
			content => epp('storyline_infra/telegraf_mongodb_conf.epp'),
			notify => Service['telegraf'],
		}
	} # if $enabled_mongodb {
	# https://github.com/signalfx/integrations/tree/master/telegraf-elasticsearch
	# https://github.com/signalfx/telegraf-elasticsearch
	if $enabled_elasticsearch {
		file { "/usr/share/telegraf/elasticsearch.py":
			replace => true,
			content => epp('storyline_infra/telegraf_elasticsearch_py.epp'),
		}->
		file { "/etc/telegraf/telegraf.conf.d/elasticsearch.conf":
			replace => true,
			content => epp('storyline_infra/telegraf_elasticsearch_conf.epp'),
			notify => Service['telegraf'],
		}
	} # if $enabled_mongodb {
}
