##
## This class manage iptables and fail2ban
## 
class hp_iptables_fail2ban::config ( $puppetserver_hostname = '',
                            $fail2ban_trusted_ip = '',
                            $fail2ban_apache = 'false',
                            $fail2ban_modsec = 'false',
                            $fail2ban_postfix = 'false',
) {

    include hp_iptables_fail2ban

    $mydomain = $::domain
	$myhostname = $::hostname
    
    if ( $::operatingsystem == 'Debian' ) {
    
    
		# this is the puppet server itself
		if ( $::hostname == $puppetserver_hostname ) {
		
            file { "/root/bin/fw.${puppetserver_hostname}" :
                 source => "puppet:///modules/hp_iptables_fail2ban/fw.${puppetserver_hostname}",
                  owner => 'root',
                  group => 'root',
                   mode => '0700',
                require => File['/root/bin'],
                 notify => Exec["/bin/sh /root/bin/fw.${puppetserver_hostname}"],
            }		
		
			exec { "/bin/sh /root/bin/fw.${puppetserver_hostname}":
				refreshonly => true,
				require => File["/root/bin/fw.${puppetserver_hostname}"],
					notify => Service['fail2ban'],
			}
		
		# this is VM guest
		} else {
		
            file { "/root/bin/fw.vm-deb" :
                 source => "puppet:///modules/hp_iptables_fail2ban/fw.vm-deb",
                  owner => 'root',
                  group => 'root',
                   mode => '0700',
                require => File['/root/bin'],
                 notify => Exec["/bin/sh /root/bin/fw.vm-deb"],
            }		
		
			exec { "/bin/sh /root/bin/fw.vm-deb":
				refreshonly => true,
					notify => Service['fail2ban'],
			}
		
		}
    
		file { '/etc/fail2ban/jail.local':
			   content =>  template( "hp_iptables_fail2ban/jail.local.deb.erb" ),
				 owner => 'root',
				 group => 'root',
				  mode => '0640',
			   require => Package['fail2ban'],
				notify => Service['fail2ban'],
		}

		file { '/etc/rc.local' :
			source => "puppet:///modules/hp_iptables_fail2ban/rc.local",
			 owner => 'root',
			 group => 'root',
			  mode => '0700',
		   require => Package['iptables'],
		}
    
		file { "/root/bin/fw.clear" :
			 source => "puppet:///modules/hp_iptables_fail2ban/fw.clear-deb",
			  owner => 'root',
			  group => 'root',
			   mode => '0700',
			require => File['/root/bin'],
		}	
    
    
    } elsif ( $::operatingsystem == 'OracleLinux' ) {

   
		# this is the puppet server itself
		if ( $::hostname == $puppetserver_hostname ) {
		
            file { "/root/bin/fw.${puppetserver_hostname}" :
                 source => "puppet:///modules/hp_iptables_fail2ban/fw.${puppetserver_hostname}",
                  owner => 'root',
                  group => 'root',
                   mode => '0700',
                require => File['/root/bin'],
                 notify => Exec["/bin/sh /root/bin/fw.${puppetserver_hostname}"],
            }		
		
			exec { "/bin/sh /root/bin/fw.${puppetserver_hostname}":
				refreshonly => true,
				require => File["/root/bin/fw.${puppetserver_hostname}"],
					notify => Service['fail2ban'],
			}
		
		# this is VM guest
		} else {
		
            file { "/root/bin/fw.vm-rpm" :
                 source => "puppet:///modules/hp_iptables_fail2ban/fw.vm-rpm",
                  owner => 'root',
                  group => 'root',
                   mode => '0700',
                require => File['/root/bin'],
                 notify => Exec["/bin/sh /root/bin/fw.vm-rpm"],
            }		
		
			exec { "/bin/sh /root/bin/fw.vm-rpm":
				refreshonly => true,
					notify => Service['fail2ban'],
			}
		
		}
    
		file { '/etc/fail2ban/jail.local':
			   content =>  template( "hp_iptables_fail2ban/jail.local.rpm.erb" ),
				 owner => 'root',
				 group => 'root',
				  mode => '0640',
			   require => Package['fail2ban'],
				notify => Service['fail2ban'],
		}
    
		file { "/root/bin/fw.clear" :
			 source => "puppet:///modules/hp_iptables_fail2ban/fw.clear-rpm",
			  owner => 'root',
			  group => 'root',
			   mode => '0700',
			require => File['/root/bin'],
		}
		
		# configuration for iptables
		file { '/etc/sysconfig/iptables-config' :
			source => "puppet:///modules/hp_iptables_fail2ban/iptables-config-rpm",
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		   require => Package['iptables'],
			notify => Service['iptables'],
		}		
 

    } else {
    
		fail("FAIL: Unknown operatingsystem ($::operatingsystem). Aborting...")
    
    }

}
