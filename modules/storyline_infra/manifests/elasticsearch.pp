class storyline_infra::elasticsearch (
	String $port = '9200',
	String $pid_file = '/data/logs/elasticsearch/elasticsearch.pid',
	String $init_script = '/etc/init.d/elasticsearch',
	String $dir_bin = '/elasticsearch',
	String $dir_data = '/data/db/elasticsearch',
	String $dir_logs = '/data/logs/elasticsearch',
	String $cluster_name = 'elastic_storyline',
	Boolean $enabled_startup = false,
	String $version = '5.1.1',
	String $download_url_prefix = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-',
	String $download_url_suffix = '.zip') {

	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	user { 'elasticsearch':
		ensure => "present",
		managehome => true,
	}
	# working dir
	file { $dir_logs:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
	}
	file { $dir_data:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
	}
	archive { "archive":
		path=> "/provision/elasticsearch${download_url_suffix}",
  		source=>"${download_url_prefix}${version}${download_url_suffix}",
  		extract       => true,
  		extract_path  => '/',
  		cleanup       => true,
	}->
	exec { "move_to_no_version_dir":
		command => "/bin/mv /elasticsearch-${version} ${dir_bin}",
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
		mode=>"ug=rwx,o=rx",
		notify => Service['elasticsearch'],
	}->
	service { 'elasticsearch':
  		ensure => $service_status,
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
