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
# RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /root/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc

RUN rbenv install ${ruby_ver}; \
    rbenv global ${ruby_ver}
RUN rbenv global; \
    rbenv rehash
RUN source /root/.bashrc; \
    gem update --system;

# RUN mkdir /root/9syoku
COPY . /root/
# COPY Gemfile /root/9syoku/Gemfile
# COPY Gemfile.lock /root/9syoku/Gemfile.lock
# RUN rbenv exec gem install bundler
WORKDIR /root/9syoku
RUN rbenv exec bundle install
# RUN rbenv exec bundle exec rails db:create && rbenv exec bundle exec rails db:migrate

# CMD rbenv exec bundle exec rails s -p 3000 -b 0.0.0.0
# COPY . /root/9syoku
