class storyline_base::firewall {

Firewall {
  before  => Class['storyline_base::firewall_post'],
  require => Class['storyline_base::firewall_pre'],
}

class { ['storyline_base::firewall_pre', 'storyline_base::firewall_post']: }

}
