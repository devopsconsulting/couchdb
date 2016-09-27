#!/bin/bash

# download and install stuff to build a debian package
apt-get install ruby ruby-dev
gem install fpm

# configure and set default configuration
./configure
sed -i'' 's/prefix, "."/prefix, "\/usr\/local\/couchdb"/' ./rel/couchdb.config
sed -i'' 's/data_dir, ".\/data"/data_dir, "\/usr\/local\/couchdb\/data"/' ./rel/couchdb.config
sed -i'' 's/view_index_dir, ".\/data"/view_index_dir, "\/usr\/local\/couchdb\/data"/' ./rel/couchdb.config
sed -i'' 's/log_file, ""/log_file, "\/usr\/local\/couchdb\/var\/log\/couchdb.log"/' ./rel/couchdb.config
sed -i'' 's/fauxton_root, ".\/share\/www"/fauxton_root, "\/usr\/local\/couchdb\/share\/www"/' ./rel/couchdb.config

# build it
make release

# create missing directories
mkdir -p ./rel/couchdb/data
mkdir -p ./rel/couchdb/log

# build a debian package
cd ./rel/couchdb/
rm *.deb 2> /dev/null
fpm -s dir -a all --name couchdb --version 2.0.0 --maintainer lars@permanentmarkers.nl -t deb --prefix /usr/local/couchdb  --deb-no-default-config-files -d esl-erlang -d openssl -d ca-certificates .
mv *.deb ../../
