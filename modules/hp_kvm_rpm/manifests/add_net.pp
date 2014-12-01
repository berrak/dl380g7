##
## This class manage KVM
##
define hp_kvm_rpm::add_net ( $routednet_name,
                             $routednet_active,
                             $routed_br_name,
                             $routed_host_if,
                             $routed_uuid )
{

    include hp_kvm_rpm
    
	# create new ROUTED subnet 40 network - see templates
    if ( $routednet_active == 'true' ) {
        
        file { "/etc/libvirt/qemu/networks/$routednet_name.xml":
            content =>  template( "hp_kvm_rpm/$routednet_name.xml.erb" ),
              owner => 'root',
              group => 'root',
               mode => '0600',
        }
        
        # start network and make it persistent
        exec { "Create_new_network_$routednet_name" :
                   path => '/root/bin:/bin:/sbin:/usr/bin:/usr/sbin',
                command => "virsh net-define /etc/libvirt/qemu/networks/$routednet_name.xml && virsh net-start $routednet_name && virsh net-autostart $routednet_name",
            refreshonly => 'true',
              subscribe => File["/etc/libvirt/qemu/networks/$routednet_name.xml"],
                require => File["/etc/libvirt/qemu/networks/$routednet_name.xml"],
                 unless => "virsh net-list | grep $routednet_name",
        }
    }
    
}
