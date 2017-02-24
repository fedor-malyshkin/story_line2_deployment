# create ssh server and configure it
class storyline_base::ssh {

	class { 'ssh':
	require => User['srv_oper'],
	storeconfigs_enabled => false,
	validate_sshd_file => true,
	server_options => {
		#Privilege Separation is turned on for security
		'UsePrivilegeSeparation' => 'yes',
		# Authentication:
		'LoginGraceTime' => '120',
		'PermitRootLogin' => 'no',
		'StrictModes' =>  'yes',
		'RSAAuthentication' =>  'no',
		'PubkeyAuthentication' => 'yes',
		# AuthorizedKeysFile      %h/.ssh/authorized_keys
		# Don't read the user's ~/.rhosts and ~/.shosts files
		'IgnoreRhosts' =>  'yes',
		# For this to work you will also need host keys in /etc/ssh_known_hosts
		'RhostsRSAAuthentication' => 'no',
		# similar for protocol version 2
		'HostbasedAuthentication' => 'no',
		# Uncomment if you don't trust ~/.ssh/known_hosts for RhostsRSAAuthentication
		'IgnoreUserKnownHosts' => 'yes',
		# To enable empty passwords, change to yes (NOT RECOMMENDED)
		'PermitEmptyPasswords' => 'no',
		# Change to yes to enable challenge-response passwords (beware issues with
		# some PAM modules and threads)
		'ChallengeResponseAuthentication' => 'no',
		# Change to no to disable tunnelled clear text passwords
		'PasswordAuthentication' => 'no',
		'X11Forwarding' => 'no',
		'X11DisplayOffset' => '10',
		'PrintMotd' => 'no',
		'PrintLastLog' => 'yes',
		'TCPKeepAlive' => 'yes',
		# Set this to 'yes' to enable PAM authentication, account processing,
		# and session processing. If this is enabled, PAM authentication will
		# be allowed through the ChallengeResponseAuthentication and
		# PasswordAuthentication.  Depending on your PAM configuration,
		# PAM authentication via ChallengeResponseAuthentication may bypass
		# the setting of "PermitRootLogin without-password".
		# If you just want the PAM account and session checks to run without
		# PAM authentication, then enable this but set PasswordAuthentication
		# and ChallengeResponseAuthentication to 'no'.
		'UsePAM' => 'yes',
		'AllowTcpForwarding' => 'no',
		'Port'                   => [22],
		'HostKey' => ['/etc/ssh/ssh_host_ed25519_key', '/etc/ssh/ssh_host_rsa_key'],
		},
		client_options => {
			},
			users_client_options => {
				'srv_oper' => {
					ensure => present,
					options => {
						'HashKnownHosts' => 'no'
					},
				},
			},
		}

}
