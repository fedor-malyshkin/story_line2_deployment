class storyline_base::firewall {
	# purge unmanaged rules
	resources { 'firewall':
  		purge => true,
	}

	Firewall {
  		before  => Class['storyline_base::firewall_post'],
  		require => Class['storyline_base::firewall_pre'],
	}
	class { 'firewall': }
}
