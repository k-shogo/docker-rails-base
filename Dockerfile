FROM dockerfile/ubuntu

# Install packages for building ruby
RUN \
  apt-get update && \
  apt-get install -y --force-yes build-essential curl git zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev && \
  apt-get clean

# Install rbenv and ruby-build
RUN \
  git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && \
  git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
  /root/.rbenv/plugins/ruby-build/install.sh && \
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
  echo 'eval "$(rbenv init -)"' >> .bashrc
ENV PATH /root/.rbenv/bin:$PATH

# Install ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./ruby-versions.txt /root/ruby-versions.txt
RUN xargs -L 1 rbenv install < /root/ruby-versions.txt

# Install Bundler for each version of ruby
RUN \
  echo 'gem: --no-rdoc --no-ri' >> /.gemrc && \
  bash -l -c 'for v in $(cat /root/ruby-versions.txt); do rbenv global $v; gem install bundler; done'

# install sqlite3
RUN apt-get install -y sqlite3 libsqlite3-dev

# Install Node.js and npm
RUN \
  apt-get install -y software-properties-common && \
  apt-get update && \
  add-apt-repository -y ppa:chris-lea/node.js && \
  echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y nodejs

