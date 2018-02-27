
The x2 key pairs here:

vbox_id_rsa.*   -   for the VirtualBox
admin_id_rsa.*  -   for Deployer R-Pi (psi)

The bootstrap-deployer.sh script will decrypt the right file for the host
it is executing to, saving/decrypting to ~/.ssh/id_rsa
