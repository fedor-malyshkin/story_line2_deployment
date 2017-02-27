class storyline_infra::elasticsearch (
	String $port = '9200',
	String $pid_file = '/data/logs/elasticsearch/elasticsearch.pid',
	String $init_script = '/etc/init.d/elasticsearch',
	String $dir_bin = '/elasticsearch',
	String $dir_data = '/data/db/elasticsearch',
	String $dir_logs = '/data/logs/elasticsearch',
	String $cluster_name = 'elastic_storyline',
	Boolean $enabled_startup = false,
	String $version = '5.1.1',) {

	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	user { 'elasticsearch':
		ensure => "present",
		managehome => true,
	}
	exec { "elasticsearch-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
	} ->
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
		require => Exec['elasticsearch-mkdir'],
	} ->
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
		require => Exec['elasticsearch-mkdir'],
	}
	archive { "elasticsearch-archive":
		path=> "/provision/elasticsearch-${version}.zip",
  		source=>"https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}.zip",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => true,
	}->
	exec { "elasticsearch-move_to_no_version_dir":
		command => "/bin/mv /provision/elasticsearch-${version} ${dir_bin}",
		creates => $dir_bin,
		cwd => "/",
		onlyif => "/usr/bin/test ! -d $dir_bin",
	} ->
	file { $dir_bin:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
	}->
	file { "${dir_bin}/config/elasticsearch.yml":
		replace => true,
		content => epp('storyline_infra/elasticsearch.epp'),
		owner => "elasticsearch",
		group=> "elasticsearch",
	}->
	file { "${dir_bin}/bin/elasticsearch":
		owner => "elasticsearch",
		group=> "elasticsearch",
		mode=>"ug=rwx,o=rx",
	}->
	file { $init_script:
		replace => true,
		content => epp('storyline_infra/elasticsearch_startup.epp'),
		mode=>"ug=rwx,o=r",
		notify => Service['elasticsearch'],
	}->
	service { 'elasticsearch':
  		ensure => $service_status,
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
