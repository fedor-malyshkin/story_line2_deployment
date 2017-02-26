class storyline_infra::elasticsearch (
	String $port = '9200',
	String $dir_bin = '/elasticsearch',
	String $dir_data = '/data/db/elasticsearch',
	String $dir_logs = '/data/logs/elasticsearch',
	String $cluster_name = 'elastic_storyline',
	String $version = '5.1.1',
	String $download_url_prefix = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-',
	String $download_url_suffix = '.zip') {

	user { 'elasticsearch':
		ensure => "present",
		managehome => true,
	}
	# working dir
	file { ['/data','/data/logs', $dir_logs]:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
	}
	file { ['/data/db', $dir_data]:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
	}
	archive { "archive":
		path=> "/tmp/elasticsearch${download_url_suffix}",
  		source=>"${download_url_prefix}${version}${download_url_suffix}",
  		extract       => true,
  		extract_path  => '/tmp',
  		cleanup       => true,
	}->
	file { $dir_bin:
		ensure => "directory",
		recurse => "true",
		owner => "elasticsearch",
		group=> "elasticsearch",
  		source  => "file:///tmp/elasticsearch-${version}",
	}->
	file { "${dir_bin}/config/elasticsearch.yml":
		replace => true,
		content => epp('storyline_infra/elasticsearch.epp'),
		owner => "elasticsearch",
		group=> "elasticsearch",
	}->
	file { "${dir_bin}/bin/elsticsearch":
		owner => "elasticsearch",
		group=> "elasticsearch",
		mode=>"ug=rwx,o=rx",
	}->
	file { "/etc/init.d/elasticsearch":
		replace => true,
		content => epp('storyline_infra/elasticsearch_startup.epp'),
		mode=>"ug=rwx,o=rx",
		notify => Service['elasticsearch'],
	}->
	service { 'elasticsearch':
  		ensure => 'running',
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
