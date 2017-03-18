class storyline_base::firewall {
	# purge unmanaged rules
	resources { 'firewall':
  		purge => true,
	}

 	class { ['storyline_base::firewall_pre', 'storyline_base::firewall_post']: }
	Firewall {
  		before  => Class['storyline_base::firewall_post'],
  		require => Class['storyline_base::firewall_pre'],
	}
	class { 'firewall': }
}
