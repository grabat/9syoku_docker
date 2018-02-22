FROM library/amazonlinux

ENV ruby_ver="2.5.0"

RUN yum -y update && yum -y install epel-release
RUN yum -y install git \
      make \
      autoconf \
      curl \
      wget \
      gcc-c++ \
      glibc-headers \
      openssl-devel \
      readline \
      libyaml-devel \
      readline-devel \
      zlib \
      zlib-devel \
      bzip2
RUN yum -y install postgresql-server \
                   postgresql \
                   postgresql-devel \
                   libffi-devel
RUN wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
RUN yum -y install yarn
RUN yum clean all

RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc

RUN rbenv install ${ruby_ver}; \
    rbenv global ${ruby_ver}
RUN rbenv global; \
    rbenv rehash
RUN source /root/.bashrc; gem update --system;

RUN mkdir /root/.ssh
RUN touch /root/.ssh/id_rsa
COPY ./id_rsa /root/.ssh/
COPY ./id_rsa.pub /root/.ssh/
RUN ssh-keyscan -H 'github.com' >> ~/.ssh/known_hosts
WORKDIR /root
RUN git clone git@github.com:kikeda1104/9syoku.git

WORKDIR 9syoku
RUN rbenv exec bundle install
COPY ./secrets.yml.key config/
COPY ./database.yml config/
# RUN rbenv exec bundle exec rails db:create && rbenv exec bundle exec rails db:migrate
RUN rbenv exec bundle exec rails db:migrate

EXPOSE 3000
CMD ["rbenv", "exec", "bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
