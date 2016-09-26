# Build this with 'docker build -t couchdb-with-search:dev .'

FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive

ENV MAVEN_VERSION 3.3.9

ENV DEBIAN_FRONTEND noninteractive

# Ceate a couchdb user and set it's home directory in /usr/local/src
RUN groupadd -r couchdb && useradd -d /usr/local/src/couchdb -g couchdb couchdb

# Download dependencies and needed stuff to compile couchdb
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential libmozjs185-dev \
    libnspr4 libnspr4-0d libnspr4-dev libcurl4-openssl-dev libicu-dev \
    openssl curl ca-certificates git pkg-config \
    apt-transport-https python wget \
    python-sphinx texlive-base texinfo texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra # needed to build the docs

# Install some java stuff
RUN apt-get install -y --no-install-recommends openjdk-7-jdk
RUN apt-get install -y --no-install-recommends procps
RUN apt-get install -y --no-install-recommends libwxgtk3.0.0

# Use correct erlang
RUN wget http://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_18.1-1~debian~jessie_amd64.deb
RUN dpkg -i esl-erlang_18.1-1~debian~jessie_amd64.deb

# Install Maven
RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/local/ \
  && mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/apache-maven \
  && ln -s /usr/local/apache-maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/local/apache-maven

# Install clouseau and the dependencies
RUN cd /usr/local/src \
 && git clone https://github.com/cloudant-labs/clouseau \
 && cd /usr/local/src/clouseau \
 && mvn -Dmaven.test.skip=true install

# Install nodejs for the admin
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get update -y && apt-get install -y nodejs \
  && npm install -g npm && npm install -g grunt-cli

# Checkout CouchDB with search support
RUN cd /usr/local/src \
 && git clone https://github.com/devopsconsulting/couchdb \
 && cd couchdb \
 && git checkout 2.0-with-search

# We don't to be so strict for simple testing.
# RUN cd /usr/local/src/couchdb && sed -i'' '/require_otp_vsn/d' rebar.config.script

# Expose CouchDB to the outside world
RUN cd /usr/local/src/couchdb && sed -i'' 's/bind_address = 127.0.0.1/bind_address = 0.0.0.0/' /usr/local/src/couchdb/rel/overlay/etc/default.ini

# Build CouchDB
RUN cd /usr/local/src/couchdb && ./configure \
  && make \
  && chmod +x /usr/local/src/couchdb/dev/run \
  && chown -R couchdb:couchdb /usr/local/src/couchdb

# Expose some useful ports
EXPOSE 5984 15984 25984 35984 15986 25986 35986
