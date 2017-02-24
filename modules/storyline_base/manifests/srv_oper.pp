# create 'srv_oper' user

class storyline_base::srv_oper {

	user { 'srv_oper':
		ensure => "present",
		managehome => true,
	 	home => '/home/srv_oper',
	 	shell => '/bin/bash',
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
