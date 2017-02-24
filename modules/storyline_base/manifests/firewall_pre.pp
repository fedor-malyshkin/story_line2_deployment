class storyline_base::firewall_pre {
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
  firewall { 'Accept all outgoing':
  	chain => 'OUTPUT',
	state  => ['NEW', 'ESTABLISHED'],
    action      => 'accept',
  }->
  # iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT  /// Allow outgoing SSH connection request,
  firewall { '002.2 accept SSH':
    proto       => 'tcp',
	dport => 22,
 	chain   => 'INPUT',
	state  => ['NEW', 'ESTABLISHED'],
    action      => 'accept',
  }->
  # iptables -I INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "Allow HTTP",
  firewall { '002.2 accept 80/8080/443':
    proto       => 'tcp',
	dport => [80,8080,443],
 	chain   => 'INPUT',
	state  => ['NEW', 'ESTABLISHED'],
    action      => 'accept',
  }
}
