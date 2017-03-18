class storyline_base::firewall {


class { ['storyline_base::firewall_pre', 'storyline_base::firewall_post']: }

Firewall {
  before  => Class['storyline_base::firewall_post'],
  require => Class['storyline_base::firewall_pre'],
}

}
