#!/usr/bin/env bash

echo "You are connecting with User ${MYUSERNAME}"

ID=$(id -u)
#If we are root and we have give a MYUID different from default
if [ "$ID" -eq "0" ] && [ $MYUID != "" ]; then
    echo "Creating user $MYUSERNAME"
    groupadd -g $MYGID myusers || true
    useradd --uid $MYUID --gid $MYGID -s /bin/bash --home /home/$MYUSERNAME $MYUSERNAME
    echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME}
    sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME}

    echo "reset default env"
    export HOME=/home/${MYUSERNAME}
fi

if [ "$1" == "vscode" ]; then

    echo "there is NO .bashrc we just launch code -verbose -w"
    code --verbose -w

	echo "Code a rendu la main..., we Exit"
	#exec su $MYUSERNAME -c bash # give a bash
#	exec bash
else
    echo "Starting your overrided command: exec $@"
    exec $@
fi

echo "end of script"

exit 0
