# shell scripting
# This script will read a CSV file that contains 20 new Linux users
# This script will create each user on the server and add to an existing group called developer
# This script will first check for the existence of the user on the system, before it will attempt to create
# The user that is being created also must have a default home folder
# Each user should have a .ssh folder within its HOME folder. If it does not exist, then it will be created
# For each user's SSH configuration, we will create an authotized_keys file and add the below public key.

#!/bin/bash
userfile=$(cat names.csv)
PASSWORD=password

# To ensure the user running this script has sudo privilage.
    if [ $(id -u) -eq 0 ]; then

# Reading the CSV file
    for user in $userfile;
    do 
        echo $user 
    if id "$user" &>/dev/null
    then    
        echo "User Exist"
    else

# This will create a new user and add it to this directory then add the user to a group
    useradd -m -d /home/$user -s /bin/bash -g developer $user
    echo "New User Created"
    echo

# This will switch user and create an .ssh folder in the user home folder
    su - -c "mkdir ~/.ssh" $user
    echo ".ssh directory created for the new user"
    echo

# We need to set the user permission for the ssh dir
    su - -c "chmod 700 ~/.ssh" $user
    echo "user permission for .ssh directory set"
    echo 

# This will create an authorized_key file
    su - -c "touch ~/.ssh/authorized_keys" $user
    echo "Authorized Key File Created"
    echo

# We need to set permission (read and write) for the key file
    su- -c "chmod 600 ~/.ssh/authorized_keys" $user
    echo "user permission for the Authorized key file set"
    echo

# we need to create and set public key for the users in the server.
    cp -R "/root/onboard/id_rsa.pub" "/home/$user/.ssh/authorized_keys"
    echo "Copyied the public key to New User Account on the server"
    echo 
    echo
    echo "USER CREATED"

# Generate a Password. This means echo PASSWORD, come to a new line, echo password again. This is because sudp passwd require a password and confirm password.
    sudo echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "$user"
    # password expires after 5 logins
    sudo passwd -x 5 $user
                fi
            done
        else
    echo "Only Admin Can Onboard A User"
    fi 
