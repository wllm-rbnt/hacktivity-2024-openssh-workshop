FROM debian:bookworm-slim
LABEL org.opencontainers.image.authors="Hiroki Takeyama"

# APT cache update
RUN apt update

# SSH client & tools
RUN apt install -y tzdata openssh-server openssh-client iproute2 iputils-ping vim-nox nano rsync sudo less inetutils-telnetd endlessh tmux x11-utils x11-apps curl apache2;

# Create user
RUN useradd -m user -s /bin/bash -G sudo

# Make telnetd actually work
RUN chmod u+s /usr/bin/login

# sshd
RUN mkdir /var/run/sshd

# APT cleanup
RUN apt clean

COPY entry_point.sh /usr/local/bin/entry_point.sh
RUN chmod +x /usr/local/bin/entry_point.sh

COPY bashrc.user /home/user/.bashrc
COPY bashrc.root /root/.bashrc
COPY keys/* /etc/ssh/
RUN chmod 400 /etc/ssh/*key

ENV TZ Europe/Luxembourg

ENV ROOT_PASSWORD root
ENV USER_PASSWORD user

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD /etc/init.d/apache2 start ; /usr/bin/endlessh -d 1000 & /usr/sbin/inetutils-inetd ; /usr/sbin/sshd -D -e
