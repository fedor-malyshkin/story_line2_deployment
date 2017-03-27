class storyline_infra::collectd () {
	include stdlib

	$params = lookup({"name" => "storyline_infra.collectd",
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
# storm db
	$enabled_storm = $params['enabled_storm']
	$storm_ui_url = $params['storm_ui_url']
	# elasticsearch
	$enabled_elasticsearch = $params['enabled_elasticsearch']

	exec { "collectd-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		require => Exec['collectd-mkdir'],
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		require => Exec['collectd-mkdir'],
	}
	package {  'collectd':
		# 	ensure => $version,
		ensure => "present",
	} ->
	file { "/etc/collectd/collectd.conf":
		replace => true,
		content => epp('storyline_infra/collectd.epp'),
		notify => Service['collectd'],
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/collectd_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['collectd'],
	}->
	service { 'collectd':
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
		exec { "disable_collectd":
			command => "/bin/systemctl disable collectd & /bin/systemctl disable collectd.service",
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
		file { "/usr/share/collectd/mongodb":
			ensure => "directory",
		}->
		file { "/usr/share/collectd/mongodb.py":
			replace => true,
			content => epp('storyline_infra/collectd_mongodb_py.epp'),
		}->
		file { "/usr/share/collectd/mongodb/types.db":
			replace => true,
			content => epp('storyline_infra/collectd_mongodb_types_db.epp'),
		}->
		file { "/etc/collectd/collectd.conf.d/mongodb.conf":
			replace => true,
			content => epp('storyline_infra/collectd_mongodb_conf.epp'),
			notify => Service['collectd'],
		}
	} # if $enabled_mongodb {
	# https://github.com/srotya/storm-collectd
	if $enabled_storm {
		file { "/usr/share/collectd/java/storm-collectd.jar":
			replace => true,
			ensure => file,
			source => "puppet:///modules/storyline_infra/storm-collectd.jar",
		}->
		file { "/etc/collectd/collectd.conf.d/storm.conf":
			replace => true,
			content => epp('storyline_infra/collectd_storm_conf.epp'),
			notify => Service['collectd'],
		}
	} # if $enabled_mongodb {
	# https://github.com/signalfx/integrations/tree/master/collectd-elasticsearch
	# https://github.com/signalfx/collectd-elasticsearch
	if $enabled_elasticsearch {
		file { "/usr/share/collectd/elasticsearch.py":
			replace => true,
			content => epp('storyline_infra/collectd_elasticsearch_py.epp'),
		}->
		file { "/etc/collectd/collectd.conf.d/elasticsearch.conf":
			replace => true,
			content => epp('storyline_infra/collectd_elasticsearch_conf.epp'),
			notify => Service['collectd'],
		}
	} # if $enabled_mongodb {
}
