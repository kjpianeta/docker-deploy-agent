FROM centos:7
MAINTAINER Kenneth Pianeta <kpianeta@cisco.com>

RUN mkdir -p /opt/cisco/deployer/var

RUN cd /tmp \
&& rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
&& rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
&& yum -y update

# System Install
RUN yum install -y wget createrepo \
  && yum groupinstall -y "Development Tools" \
  && yum install -y zlib-devel \
  bzip2-devel \
  openssl-devel \
  ncurses-devel \
  sqlite-devel \
  libstdc++ \
  libuuid \
  nss-pam-ldapd* \
  wget \
  yum-utils \
  PyYAML \
  libyaml \
  m2crypto \
  python-crypto \
  python-jinja2 \
  python-zmq

# Python Install
RUN export LANG=C.UTF-8 \
  && export PYTHON_VERSION=2.7.11 \
  && export PYTHON_PIP_VERSION=8.0.2 \
  && mkdir -p /usr/src/python \
  && wget --no-check-certificate -O /tmp/Python-2.7.tgz https://www.python.org/ftp/python/2.7/Python-2.7.tgz \
  && tar xvzf /tmp/Python-2.7.tgz --directory /tmp \
  && rm -f /tmp/Python-2.7.tgz \
  && cd /tmp/Python-2.7 \
  && ./configure --prefix=/usr/local \
  && make -j $(nproc) \
  && make altinstall \
  && ldconfig \
  && curl -SL 'https://bootstrap.pypa.io/get-pip.py' | /usr/local/bin/python2.7 \
  && /usr/local/bin/pip2.7 install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION \
  && find /usr/local \
  \( -type d -a -name test -o -name tests \) \
  -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
  -exec rm -rf '{}' + \
  && cd \
  && rm -rf /tmp/Python-2.7 \
  && export "PATH=/usr/local/bin/:${PATH}:"  \
  && echo "PATH=/usr/local/bin/:${PATH}:" > /etc/profile.d/python27-path.sh && chmod 755 /etc/profile.d/python27-path.sh

RUN curl https://bootstrap.pypa.io/get-pip.py | python && pip install --upgrade pip


RUN pip install python-novaclient \
  && pip install python-glanceclient  \
  && pip install python-cinderclient  \
  && pip install python-neutronclient  \
  && pip install python-keystoneclient  \
  && pip install python-heatclient  \
  && pip install python-openstackclient

RUN yum install -y salt-minion java-1.8.0-openjdk

RUN yum -y clean all

CMD /bin/bash
#ENTRYPOINT ["/opt/cisco/deployer/bin/docker_entry_point.sh"]

