FROM armhf/debian:stretch

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update;
RUN apt-get install -y openssh-client openssl bash bsdutils pgp pass rsync;

RUN groupadd -r admin && \
  useradd -r -g admin -d /home/admin -s /bin/bash admin && \
  mkdir /home/admin/ && \
  chmod 750 /home/admin/ && \
  chown -v admin:admin /home/admin/

RUN mkdir -pv /home/admin/.ssh/my-ssh-ca && \
  chmod 700 /home/admin/.ssh/ && \
  mkdir /home/admin/.gnupg && \
  chmod 700 /home/admin/.gnupg && \
  mkdir -pv /home/admin/.password-store && \
  chmod 700 /home/admin/.password-store

ADD ./local_data/ssh/my-ssh-ca/ca /home/admin/.ssh/my-ssh-ca/ca
ADD ./local_data/ssh/my-ssh-ca/ca.pub /home/admin/.ssh/my-ssh-ca/ca.pub
ADD ./local_data/pgp/ /home/admin/.gnupg/
COPY ./vagrantvm/dotfiles/password-store/ /home/admin/.password-store/

RUN chown admin:admin -Rv /home/admin/

USER admin

RUN ssh-keygen -P "" -C "admin docker" -f ~/.ssh/id_rsa -t rsa

WORKDIR /home/admin

ENTRYPOINT ["/bin/bash"]
