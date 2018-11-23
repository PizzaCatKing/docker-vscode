FROM ubuntu:16.04

MAINTAINER Chris Dufour "chris@cdufour.com"

ENV LANG=C.UTF-8 \
  DEBIAN_FRONTEND=noninteractive \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  VSCODE=https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
  TINI_VERSION=v0.16.1 \
  GOVERSION=1.9.1
#https://az764295.vo.msecnd.net/stable/5be4091987a98e3870d89d630eb87be6d9bafd27/code_1.5.3-1474533365_amd64.deb
#VSCode 1.5.3

ARG VCF_REF
ARG BUILD_DATE
LABEL org.label-schema.docker.dockerfile="/Dockerfile" \
  org.label-schema.license="MIT" \
  org.label-schema.name="e.g. VsCode" \
  org.label-schema.url="https://code.visualstudio.com/" \
  org.label-schema.vcs-type="e.g. Git" \
  org.label-schema.vcs-url="e.g.https://github.com/allamand/docker-vscode" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF

ARG MYUSERNAME=developer
ARG MYUID=2000
ARG MYGID=200
ENV MYUSERNAME=${MYUSERNAME} \
  MYUID=${MYUID} \
  MYGID=${MYGID}

RUN apt-get update -qq && \
  echo 'Installing OS dependencies' && \
  apt-get install -qq -y --fix-missing \
  sudo software-properties-common libxext-dev libxrender-dev libxslt1.1 \
  libgconf-2-4 libnotify4 libnspr4 libnss3 libnss3-nssdb \
  libxtst-dev libgtk2.0-0 libcanberra-gtk-module \
  libxss1 libsecret-1-0 \
  libxkbfile1 \
  git curl tree locate net-tools telnet \
  make bash-completion \
  bash-completion \
  libxkbfile1 \
  libxss1 \
  locales netcat \
  && \
  # curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && \
  # export NVM_DIR="$HOME/.nvm" && \
  # nvm ls-remote && nvm install node && \
  # npm install -g yarn && \
  echo 'Cleaning up' && \
  apt-get clean -qq -y && \
  apt-get autoclean -qq -y && \
  apt-get autoremove -qq -y &&  \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  updatedb && \
  locale-gen en_US.UTF-8

RUN echo 'Creating user: ${MYUSERNAME} wit UID $UID' && \
  mkdir -p /home/${MYUSERNAME} && \
  echo "${MYUSERNAME}:x:${MYUID}:${MYGID}:Developer,,,:/home/${MYUSERNAME}:/bin/bash" >> /etc/passwd && \
  echo "${MYUSERNAME}:x:${MYGID}:" >> /etc/group && \
  sudo echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} && \
  sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME} && \
  sudo chown ${MYUSERNAME}:${MYUSERNAME} -R /home/${MYUSERNAME} && \
  sudo chown root:root /usr/bin/sudo && \
  chmod 4755 /usr/bin/sudo && \
  # Install VSCODE
  echo 'Installing VsCode' && \
  curl -o vscode.deb -J -L "$VSCODE" && \
  dpkg -i vscode.deb && rm -f vscode.deb && \
  echo "Install OK"
ENV HOME /home/${MYUSERNAME}
ENV TERM=xterm

WORKDIR ${HOME}/workspace

ADD ./entrypoint.sh /entrypoint.sh

# Add Tini Init System
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod a+x /tini && chmod a+x /entrypoint.sh
USER ${MYUSERNAME}
ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
CMD ["vscode"]
