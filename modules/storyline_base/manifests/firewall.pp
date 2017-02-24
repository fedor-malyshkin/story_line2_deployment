class storyline_base::firewall {

Firewall {
  before  => Class['server_firewall::post'],
  require => Class['server_firewall::pre'],
}

class { ['storyline_base::firewall_pre', 'storyline_base::firewall_post']: }

}
