# syntax=docker/dockerfile:1.4

FROM perl:5.36-bullseye
LABEL maintainer="Harry Liksanin <Harry.Liksanin@yandex.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=vsc
ARG PASSWORD=Passw0rd!
ARG GIT_NAME=example
ARG GIT_EMAIL=example@example.com
ARG VSC_VERSION
ENV VSC_URL_DOWNLOAD=https://update.code.visualstudio.com/commit:${VSC_VERSION}/server-linux-x64/stable
ENV VSC_DIR=~/.vscode-server/bin/${VSC_VERSION}
ENV VSC_SERVER=~/.vscode-server/bin/${VSC_VERSION}/bin/code-server

RUN <<EOT bash
# In order not to work under the root user
useradd -m -s /bin/bash -g root ${USER}
echo "root:${PASSWORD}" | chpasswd
echo "${USER}:${PASSWORD}" | chpasswd

# In the wsl settings, you need to specify the default user (otherwise it will run under root)
cat >/etc/wsl.conf <<EOF
[user]
default=${USER}

[automount]
root = /
EOF

echo "alias json='json_pp -json_opt pretty,canonical'" >>/home/${USER}/.bashrc
EOT

# Install the necessary software
RUN true \
    && apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
        locales-all \
        mlocate \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && true

# Install perl dependencies
RUN <<EOT bash
# Perl Language Server, needed for the fractalboy.pls plugin
cpanm --notest --quiet PLS

cpanm --notest --quiet \
    JSON::XS
EOT

# Install mlocate with custom PRUNEPATHS (usually adding paths from Windows /c /d to exceptions is a good idea)
RUN <<EOT bash
apt-get install -y --no-install-recommends mlocate

cat >/etc/updatedb.conf <<EOF
PRUNE_BIND_MOUNTS="yes"
# PRUNENAMES=".git .bzr .hg .svn"
PRUNEPATHS="/c /d /tmp /var/spool /media /var/lib/os-prober /var/lib/ceph"
PRUNEFS="NFS afs autofs binfmt_misc ceph cgroup cgroup2 cifs coda configfs curlftpfs debugfs devfs devpts devtmpfs ecryptfs ftpfs fuse.ceph fuse.glusterfs fuse.gvfsd-fuse fuse.mfs fuse.rozofs fuse.sshfs fusectl fusesmb hugetlbfs iso9660 lustre lustre_lite mfs mqueue ncpfs nfs nfs4 ocfs ocfs2 proc pstore rpc_pipefs securityfs shfs smbfs sysfs tmpfs tracefs udev udf usbfs"
EOF

updatedb
EOT

USER ${USER}

# Install the code editor and plugins
RUN <<EOT bash
mkdir -p ${VSC_DIR} && cd ${VSC_DIR}
curl --location --max-redirs 2 --output vscode-server.tar.gz ${VSC_URL_DOWNLOAD}
tar -xvzf vscode-server.tar.gz --strip-components 1

# Perl Language Server
$VSC_SERVER --install-extension FractalBoy.pls

$VSC_SERVER --install-extension jorol.perl-completions
$VSC_SERVER --install-extension ratismal.copy-filename-from-menu
$VSC_SERVER --install-extension bierner.markdown-checkbox
$VSC_SERVER --install-extension dbankier.vscode-quick-select
$VSC_SERVER --install-extension formulahendry.code-runner
$VSC_SERVER --install-extension humao.rest-client
$VSC_SERVER --install-extension alefragnani.Bookmarks
$VSC_SERVER --install-extension ms-vscode.live-server
$VSC_SERVER --install-extension EditorConfig.EditorConfig
$VSC_SERVER --install-extension donjayamanne.githistory

EOT

RUN <<EOT
cat >~/.gitconfig <<EOF
[user]
    name = ${GIT_NAME}
    email = ${GIT_EMAIL}
[core]
    editor = code --wait
    excludesFile = ~/.gitignore
EOF

cat >~/.gitignore <<EOF
.vscode/
.pls_cache/
EOF

EOT

COPY --chown=${USER} data/user-settings/settings.json /home/${USER}/.vscode-server/data/Machine/settings.json
COPY --chown=${USER} data/user-settings/.perltidyrc /home/${USER}/.perltidyrc
