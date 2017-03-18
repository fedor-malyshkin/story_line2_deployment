class storyline_base::firewall_post {
	firewall { '997 drop all':
	  proto  => 'all',
	  action => 'drop',
	  before => undef,
	}->
	# ? iptables -A INPUT -j REJECT -m comment --comment "Reject all incoming"
	firewall { '998 Drop all incoming':
	  chain   => 'INPUT',
	  proto  => 'all',
	  action => 'drop',
	}->
	# ? iptables -A FORWARD -j REJECT -m comment --comment "Reject all forwarded"
	firewall { '999 Drop all forwarded':
	  proto  => 'all',
	  chain   => 'FORWARD',
	  action => 'drop',
	}
}
