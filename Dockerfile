FROM centos:6
MAINTAINER Marijn Giesen <marijn@studio-donder.nl>

# Install repositories, update system and install software
RUN yum -y install --setopt=tsflags=nodocs http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
    sed -i -e '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo; \
    yum -y update --setopt=tsflags=nodocs; \
    yum -y --setopt=tsflags=nodocs install mysql-server python-pip; \
    rm -rf /var/cache/yum/*; \
    yum clean all

# Configure software
RUN pip install pip --upgrade && pip install setuptools --upgrade && pip install supervisor; \
    rm -rf /tmp/*; \
    echo "NETWORKING=yes" > /etc/sysconfig/network; \
    mkdir -p /data/{bootstrap,db,log}; mkdir -p /etc/service-config

COPY etc/service-config /etc/service-config
COPY bootstrap/start_container /usr/bin/start_container

RUN ln -sf /etc/service-config/supervisor/supervisord.conf /etc/supervisord.conf && \
    ln -sf /etc/service-config/mysql/my.cnf /etc/my.cnf; \
    ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime; \
    chmod 700 /usr/bin/start_container

EXPOSE 3306

CMD ["/usr/bin/start_container", "db"]
