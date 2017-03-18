class storyline_base::firewall {
	# purge unmanaged rules
	include firewall
	resources { 'firewall':
  		purge => true,
	}
	 include storyline_base::firewall_pre
	 include storyline_base::firewall_post

	# Class['storyline_base::firewall'] {
 #  		before  => Class['storyline_base::firewall_post'],
 #  		require => Class['storyline_base::firewall_pre'],
	# }


}
