class storyline_base::firewall_post {
	firewall { '999 drop all':
	  proto  => 'all',
	  action => 'drop',
	  before => undef,
	}->
	# ? iptables -A INPUT -j REJECT -m comment --comment "Reject all incoming"
	firewall { '999 Reject all incoming':
	  chain   => 'INPUT',
	  proto  => 'all',
	  action => 'drop',
	  action => 'reject',
	}->
	# ? iptables -A FORWARD -j REJECT -m comment --comment "Reject all forwarded"
	firewall { '999 Reject all forwarded':
	  proto  => 'all',
	  chain   => 'FORWARD',
	  action => 'reject',
	}
}
