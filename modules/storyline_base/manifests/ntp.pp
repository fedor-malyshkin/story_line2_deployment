class storyline_base::ntp {
	class { 'ntp':
		servers => ['nist-time-server.eoni.com','nist1-lv.ustiming.org','ntp-nist.ldsbc.edu'],
		service_enable      => true,
		service_ensure => 'running',
	}
}
