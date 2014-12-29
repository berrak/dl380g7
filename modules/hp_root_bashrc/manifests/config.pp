##
## This class customize root's .bashrc
##
class hp_root_bashrc::config {

    $ostype = $::operatingsystem	
	
	if $ostype == 'Debian' {
	 
		file { '/root/.bashrc':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_deb',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		}
	
		# This file contains all customization for root
		file { '/root/.bashrc_root':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_root_deb',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
			require => File['/root/.bashrc'],
		}
		
		# if .bash_root changes, source it
		exec { 'deb_source_changes_due_to_changes_in_bashrc_root':
			   path => '/bin:/sbin:/usr/bin:/usr/sbin',
			command => 'source /root/.bashrc_root',
			subscribe => File['/root/.bashrc_root'],
			refreshonly => true,
		}	
	
	} elsif $ostype == 'OracleLinux' {
	
		file { '/root/.bash_profile':
			source => 'puppet:///modules/hp_root_bashrc/bash_profile_rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		}
	
		file { '/root/.bashrc':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		   require => File['/root/.bash_profile'],
		}
	
		# This file contains all customization for root
		file { '/root/.bashrc_root':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_root_rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		   require => File['/root/.bash_profile'],
		}	
	
	} else {
		fail("FAIL: Unknown $ostype distribution. Aborting...")
	}	

}
