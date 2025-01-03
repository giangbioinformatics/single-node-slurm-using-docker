FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
# Install necessary packages
RUN apt-get update && apt-get install -y \
    munge \
    slurm-wlm \
    slurm-wlm-basic-plugins \
    slurmdbd \
    mariadb-server \
    mariadb-client \
    build-essential \
    vim \
    curl \
    wget \
    git \
    openssh-server \
    fuse \
    net-tools \
    python3 python3-dev python3-pip python3-venv \
    && apt-get clean

# Create user for the cluster, simulate the normal user will access to a resource
RUN useradd -m -s /bin/bash river && echo "river:password" | chpasswd
COPY .ssh/id_rsa.pub /home/river/.ssh/authorized_keys
RUN chown -R river:river /home/river/.ssh
RUN chmod 700 /home/river/.ssh/authorized_keys

# Install and configure river-utils, `source ~/.river.sh` for the existing micromamba setup and useful tools
USER river
WORKDIR /home/river
RUN curl -Ls https://raw.githubusercontent.com/giangbioinformatics/river-utils/dev/base.sh -o /tmp/base.sh && \
    bash /tmp/base.sh $HOME dev
USER root
# Setup SSH server, allow for user to login via ssh
RUN mkdir -p /run/sshd

# Setup SLURM munge for authentication, allows nodes in HPC communication using encrypted secret
RUN mkdir -p /etc/munge /var/log/munge /var/lib/munge /etc/slurm /var/spool/slurmd
RUN chown -R munge:munge /etc/munge /var/log/munge /var/lib/munge \
    && chmod 0700 /etc/munge /var/log/munge /var/lib/munge
RUN /usr/sbin/create-munge-key

# Copy configuration files for slurm configuration
# For all slurm nodes
COPY slurm.conf /etc/slurm-llnl/slurm.conf
# For controller nodes use sql database to store likes job information, users, groups,...use the slurmctld to manage slurm cluster
# Connect mysql via password, host and port in config file
COPY slurmdbd.conf /etc/slurm-llnl/slurmdbd.conf
RUN mkdir -p /var/log/slurm

# Setup MySQL
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Start MariaDB and initialize the SLURM database
RUN service mysql start && \
    mysql -e "CREATE DATABASE slurm_acct_db;" && \
    mysql -e "CREATE USER 'slurm'@'localhost' IDENTIFIED BY 'slurm';" && \
    mysql -e "GRANT ALL PRIVILEGES ON slurm_acct_db.* TO 'slurm'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Expose necessary ports
EXPOSE 22 6817 6818 3306

# Copy MySQL configuration, allow high performance processing for SQL
COPY my.cnf /etc/mysql/my.cnf

# add system user slurm, this user allows the correct user to manage slurm settings, better than using root or sudo user only
RUN usermod -s /bin/bash slurm

# Start services, add new cluster and new user
RUN bash -c "\
    /etc/init.d/munge start && \
    service mysql start && \
    /usr/sbin/sshd && \
    slurmdbd && \
    slurmctld && \
    sleep 10 && \
    sacctmgr -i add cluster localcluster && \
    sacctmgr -i --quiet add account river Cluster=localcluster && \
    sacctmgr -i --quiet add user river account=river DefaultAccount=root"
# This one will automatically launched when you start docker service    
CMD ["bash", "-c", "/etc/init.d/munge start && \
    service mysql start && \
    /usr/sbin/sshd && \
    slurmdbd && \
    slurmctld && \
    slurmd -D"]
