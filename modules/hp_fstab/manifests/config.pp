##
## Define to copy fstab to host
##
## This class manage the system 'fstab' file. Place a host specific file
## in the source directory prefixed with output of 'blkid'.+ hostname'+"."+"fstab"
## like so:
##      '064b4f90-9c73-49ea-8734-9b62bfd55471.carbon.fstab
## and a master CSV file ('fstab_sda1_uuid.csv') containing the sda1 disk 
## UUID like so: 'carbon,"064b4f90-9c73-49ea-8734-9b62bfd55471"' one row for
## each host name and UUID #. In the case sda is not available (maybe other
## operating - Win32 OS is installed there), use then the UUID for the /.
##
## Sample use:
##    class { hp_fstab::config : fstabhost => 'hphome' }
##
class hp_fstab::config ( $fstabhost='', $source = 'UNSET' ) {
   
	
	$server_source = $source ? {
		'UNSET' => "puppet:///modules/hp_fstab/fstab_sda1_uuid.csv",
		default => $source,
	}
	
	$serverpath = '/etc/puppet/files/fstab_sda1_uuid.csv'

	file { "$serverpath" : 
		 source => $server_source,
		  owner => 'root',
		  group => 'root',
	}
	
    # Look up UUID for hosts sda1 (normally /boot) partition (avoids using wrong fstab)

    $fstab_uuid_sda1 = extlookup( "$fstabhost", "FSTAB_UNCOPIED_TO_PUPPET_MASTER" )
    
    if $fstab_uuid_sda1 == 'FSTAB_UNCOPIED_TO_PUPPET_MASTER' {
        notify{"Host fstab: Lowest partition (normally sda1) uuid for ($fstabhost) is ($fstab_uuid_sda1)" : }
    }
    
	# This will ensure we use the correct disk data and not corrupt fstab
	
	if $fstab_uuid_sda1 != 'FSTAB_UNCOPIED_TO_PUPPET_MASTER'  {
		
        # If UUID from grep does not match on target host, Puppet will not touch existing fstab.
		# We always use sda1 unless its occupied by some other operating system (e.g. win32).
		# If so, use the lowest partition available, e.g. sda5 as identification for fstab file.
        
        exec { 'Verifying_disk_UUID_match_fstab_data' :
                command => "/bin/grep -w '$fstab_uuid_sda1' '/etc/fstab'",
			  subscribe => File["$serverpath"],
			refreshonly => true,	
        }
        
		file { '/etc/fstab':
			 source => "puppet:///modules/hp_fstab/${fstab_uuid_sda1}.${fstabhost}.fstab",
			  owner => 'root',
			  group => 'root',
			   mode => '644',
            require => Exec['Verifying_disk_UUID_match_fstab_data'],
		  subscribe => File["$serverpath"],
		}
		
    }

}