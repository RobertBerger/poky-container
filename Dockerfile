# Copyright (C) 2015-2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#FROM crops/yocto:ubuntu-14.04-base
FROM reliableembeddedsystems/yocto:ubuntu-14.04-base

USER root

ADD https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_useradd.sh  \
        https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_groupadd.sh \
        https://raw.githubusercontent.com/crops/extsdk-container/master/usersetup.py \
        /usr/bin/
COPY poky-entry.py poky-launch.sh /usr/bin/
COPY sudoers.usersetup /etc/

# For ubuntu, do not use dash.
RUN which dash &> /dev/null && (\
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash) || \
    echo "Skipping dash reconfigure (not applicable)"

# --> rber

# extra config files rber wants in sdk container
COPY etc/skel/gitconfig /etc/skel/.gitconfig

# /etc/skel/.vim/
# ├── ftdetect
# │   └── bitbake.vim
# ├── ftplugin
# │   └── bitbake.vim
# ├── plugin
# │   └── newbb.vim
# └── syntax
#     └── bitbake.vim
COPY etc/skel/vim/.          /etc/skel/.vim/            

# get updates
RUN apt-get update -y 
RUN apt-get upgrade -y 

# additional needed packages
RUN apt-get -y install libncursesw5-dev

# <-- rber

# --> rber repo
RUN apt-get install -y repo
# <-- rber repo

# --> rber repo
# just for testing
RUN apt-get install -y xterm
# this is actually needed for:
#   bitbake core-image-minimal -g -u taskexp
RUN apt-get install -y python3-gi gobject-introspection gir1.2-gtk-3.0
# <-- rber repo

# We remove the user because we add a new one of our own.
# The usersetup user is solely for adding a new user that has the same uid,
# as the workspace. 70 is an arbitrary *low* unused uid on debian.
RUN userdel -r yoctouser && \
    groupadd -g 70 usersetup && \
    useradd -N -m -u 70 -g 70 usersetup && \
    chmod 755 /usr/bin/usersetup.py \
        /usr/bin/poky-entry.py \
        /usr/bin/poky-launch.sh \
        /usr/bin/restrict_groupadd.sh \
        /usr/bin/restrict_useradd.sh && \
    echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

USER usersetup
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
