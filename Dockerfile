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
# this is __NOT__ what is used ;)
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

# key which is known to gitpod
COPY etc/skel/ssh/.          /etc/skel/.ssh/

# get updates
RUN apt-get update -y 
RUN apt-get upgrade -y 

# additional needed packages
RUN apt-get -y install libncursesw5-dev

# <-- rber

# --> rber gcc-9
RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common 
#python-software-properties
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y && apt-get update
RUN apt-get install -y gcc g++ gcc-9 g++-9
#RUN update-alternatives --remove-all gcc
 # --> libstdc++ 
 # we need a libstdc++6 for this to work:
 #   build/tmp/sysroots-uninative/x86_64-linux/usr/lib/libstdc++.so.6: version `GLIBCXX_3.4.26' not found 
 #   required by build/tmp/work/x86_64-linux/cmake-native/3.12.2-r0/build/Bootstrap.cmk/cmake 
 # RUN apt-get upgrade -y libstdc++6
 # fix? https://www.yoctoproject.org/pipermail/yocto/2019-April/044995.html
 #      https://www.yoctoproject.org/pipermail/yocto/2016-November/033134.html
 # <-- libstdc++
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9
RUN gcc -v
# <-- rber gcc-9

# --> rber repo
RUN apt-get install -y repo
# <-- rber repo

# --> rber gui
# just for testing
RUN apt-get install -y xterm
# this is actually needed for:
#   bitbake core-image-minimal -g -u taskexp
RUN apt-get install -y python3-gi gobject-introspection gir1.2-gtk-3.0
# <-- rber gui

# --> rber skopeo and friends
# usr/local/bin/
# ├── convertSHA.sh
# ├── skopeo
# └── terrier

RUN apt-get install -y jq curl
COPY usr/local/bin/skopeo          /usr/local/bin/skopeo
COPY usr/local/bin/terrier         /usr/local/bin/terrier
COPY usr/local/bin/convertSHA.sh   /usr/local/bin/convertSHA.sh
COPY etc/containers/policy.json    /etc/containers/policy.json
# <-- rber skopeo and friends

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
