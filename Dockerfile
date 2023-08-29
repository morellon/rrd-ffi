FROM registry.terreactive.ch/dockerhub/ruby:2.5.1

ARG no_proxy="gitlab.terreactive.ch,gitlab,dis.terreactive.ch,dis,localhost"
ARG http_proxy="http://wsa.terreactive.ch:3128"
ARG https_proxy="http://wsa.terreactive.ch:3128"

RUN \
  echo 'deb http://archive.debian.org/debian stretch main' >/etc/apt/sources.list && \
  apt-get update -y && \
  apt-get install -y ca-certificates \
  wget dpkg-dev \
  build-essential \
  openssh-client \
  librrd-dev \
  libpq-dev \
  postgresql-client && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# install terreActive certs
ADD http://dis.terreactive.ch/files/ta-issuingca1.crt /usr/local/share/ca-certificates/ta-issuingca1.crt
ADD http://dis.terreactive.ch/files/ta-rootca.crt /usr/local/share/ca-certificates/ta-rootca.crt
RUN update-ca-certificates

WORKDIR  /usr/share/taclom/rrd-ffi

COPY ./Gemfile ./rrd-ffi.gemspec ./Rakefile ./VERSION ./
# RUN bundle config mirror.https://rubygems.org https://packages.terreactive.ch/repository/rubygems-proxy/
RUN ruby -v
RUN which ruby

RUN gem install bundler --no-ri --no-rdoc -v 1.16.5
RUN bundle --version

RUN bundle config path gems
RUN bundle _1.16.5_ install

COPY lib/ lib/
RUN gem build rrd-ffi.gemspec

COPY spec/ spec/

CMD bundle exec rspec -c spec
