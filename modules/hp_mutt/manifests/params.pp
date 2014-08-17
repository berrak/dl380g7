##
## Parameters for mutt configuration
##
class hp_mutt::params {

    
    ###################################################################
    ## Very simple (plain) unsecure authentication for IMAP (change) ##
    ###################################################################
    
    $mytestpasswd = 'pass'



    ###################################################################

    # for local access to Maildir and thus remote IMAP isn't required

    $localmailspool = '~/Maildir'
    $localmailfolder = '~/Maildir'
    
    $no_imap_user = ''
    $no_imap_passwd = ''

}