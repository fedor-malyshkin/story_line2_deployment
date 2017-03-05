# create 'srv_oper' user

class storyline_base::srv_oper {

	class { 'sudo': }

	user { 'srv_oper':
		ensure => "present",
		managehome => true,
	 	home => '/home/srv_oper',
	 	shell => '/bin/bash',
		groups => ['sudo'],
	}

	sudo::conf { 'admins':
   		ensure  => present,
   		content => '%admin ALL=(ALL) ALL',
   	}

	sudo::conf { 'srv_oper':
		require => User['srv_oper'],
		priority => 10,
  		content  => 'srv_oper ALL=(ALL) NOPASSWD: ALL',
	}

/*
	file { 'srv_oper_ssh_dir':
		path => '/home/srv_oper/.ssh',
		ensure => "directory",
		recurse => "true",
		owner => "srv_oper",
		group=> "srv_oper",
	}
*/
}
