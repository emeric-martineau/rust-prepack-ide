#!/bin/sh

groupadd -g ${USERNAME_TO_RUN_GID} ${USERNAME_TO_RUN}
useradd -u ${USERNAME_TO_RUN_UID} -g ${USERNAME_TO_RUN_GID} ${USERNAME_TO_RUN}

chown ${USERNAME_TO_RUN}:${USERNAME_TO_RUN} /home/${USERNAME_TO_RUN}/

# Add current user to sudo
usermod -aG sudo ${USERNAME_TO_RUN}
echo "" >> /etc/sudoers
echo "${USERNAME_TO_RUN} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

cd /home/${USERNAME_TO_RUN}/
exec runuser -u ${USERNAME_TO_RUN} -- "$@"
