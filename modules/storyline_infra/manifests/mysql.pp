class storyline_infra::mysql () {
	include stdlib

	$certname = $trusted['certname']
	$override_options = {
	  'mysqld' => {
	    'bind-address' => '0.0.0.0',
	  }
	}

	class { '::mysql::server':
	  root_password           => 'mysqlpass',
	  remove_default_accounts => true,
	  override_options        => $override_options
	}
	mysql::db { 'metastore':
  		user     => 'hive',
  		password => 'hive',
  		host     => $certname,
	}
}
