node default {
	include storyline_base::ntp
	include storyline_base::srv_oper
	include storyline_base::ssh
	include storyline_infra::jenkins

	/*
	resources { 'firewall':
	  purge => true,
	}

	class { 'firewall': }
	*/


}
