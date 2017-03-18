class storyline_base::firewall_pre {

	$params = lookup({"name" => "storyline_base.firewall",
	    "merge" => {"strategy" => "deep"}})
	$incommming_port_all = $params['incommming_port_all']
	$incommming_port_project = $params['incommming_port_project']
	$host_project = $params['host_project']

  Firewall {
    require => undef,
  }
   # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  # iptables -A OUTPUT -j ACCEPT -m comment --comment "Accept all outgoing"
  firewall { '003 Accept all outgoing':
  	chain => 'OUTPUT',
	state  => ['NEW', 'RELATED', 'ESTABLISHED'],
    action      => 'accept',
  }->  
  # iptables -A OUTPUT -j ACCEPT -m comment --comment "Accept all outgoing"
  firewall { '004 Accept all established':
  	chain => 'INPUT',
	ctstate  => ['RELATED', 'ESTABLISHED'],
    action      => 'accept',
  }->
  # iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT  /// Allow outgoing SSH connection request,
  firewall { '005 accept SSH':
    proto       => 'tcp',
	dport => 222,
 	chain   => 'INPUT',
	state  => ['NEW', 'ESTABLISHED'],
    action      => 'accept',
  }->
  # iptables -I INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "Allow HTTP",
  firewall { '006 all incomming to specific ports':
    proto       => 'tcp',
	dport => $incommming_port_all,
 	chain   => 'INPUT',
    action      => 'accept',
  } ->
  firewall { '007 all incomming to specific ports for projects servers':
	proto       => 'tcp',
  	dport => $incommming_port_project,
	source => $host_project,
  	chain   => 'INPUT',
	action      => 'accept',
  }

}
