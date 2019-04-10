FROM debian:stretch-slim

MAINTAINER kakuilan kakuilan@163.com

ENV WWW_DIR=/var/www \
    WWW_USER=www \
    NSFW_DIR=/opt/open_nsfw

# make dir,add user
RUN mkdir -p ${NSFW_DIR} ${WWW_DIR} \
  && chmod -R a+rw ${WWW_DIR} \
  && useradd -M -s /sbin/nologin ${WWW_USER}

# update source
WORKDIR ${NSFW_DIR}
RUN echo "deb http://mirrors.163.com/debian/ stretch main non-free contrib\ndeb http://mirrors.163.com/debian/ stretch-updates main non-free contrib\ndeb http://mirrors.163.com/debian/ stretch-backports main non-free contrib\ndeb-src http://mirrors.163.com/debian/ stretch main non-free contrib\ndeb-src http://mirrors.163.com/debian/ stretch-updates main non-free contrib\ndeb-src http://mirrors.163.com/debian/ stretch-backports main non-free contrib\ndeb http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib\ndeb-src http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib" > /etc/apt/sources.list \

# install package
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    caffe-cpu \
    git \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-numpy \
    python3-wheel \

# clone repertory
  && git clone https://github.com/kakuilan/nsfwapi_docker.git ${NSFW_DIR} \
  && cd ${NSFW_DIR} && rm -rf .git .gitignore Dockerfile LICENSE README.md \
  && echo "aiodns\naiohttp\ncchardet\nuvloop" > ${NSFW_DIR}/requirements.txt \
  && pip3 install -r requirements.txt \

# remove package
  && apt-get remove -y make cpp cpp-6 g++ g++-6 gcc gcc-6 git git-man gnome-icon-theme python3-pip python3-setuptools \

# clean cache
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && cat /dev/null > /var/log/btmp \
  && cat /dev/null > /var/log/debug \
  && cat /dev/null > /var/log/faillog \
  && cat /dev/null > /var/log/lastlog \
  && cat /dev/null > /var/log/messages \
  && cat /dev/null > /var/log/syslog \
  && cat /dev/null > /var/log/wtmp \
  && rm -rf /run/log/journal/* \
  && rm -rf /tmp/systemd-private-* \
  && rm -rf /tmp/*.cache \
  && rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* \
  && rm -rf /var/backups/* \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/cache/debconf/* \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/log/apt* \
  && rm -rf /var/log/installer* \
  && rm -rf /var/log/*.log \
  && rm -rf /var/tmp/systemd-private*

VOLUME ${WWW_DIR}

EXPOSE 8080

USER ${WWW_USER}

ENTRYPOINT ["python3", "api.py"]
