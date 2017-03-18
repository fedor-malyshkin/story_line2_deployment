class storyline_base::firewall {
	# purge unmanaged rules
	include firewall
	resources { 'firewall':
  		purge => true,
	}
	Class['storyline_base::firewall'] {
  		before  => Class['storyline_base::firewall_post'],
  		require => Class['storyline_base::firewall_pre'],
	}
	

}
