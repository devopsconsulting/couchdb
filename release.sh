#!/bin/bash

./configure
sed -i'' 's/prefix, "."/prefix, "\/usr\/local\/couchdb"/' ./rel/couchdb.config
sed -i'' 's/data_dir, ".\/data"/data_dir, "\/usr\/local\/couchdb\/data"/' ./rel/couchdb.config
sed -i'' 's/view_index_dir, ".\/data"/view_index_dir, "\/usr\/local\/couchdb\/data"/' ./rel/couchdb.config
sed -i'' 's/log_file, ""/log_file, "\/usr\/local\/couchdb\/var\/log\/couchdb.log"/' ./rel/couchdb.config
sed -i'' 's/fauxton_root, ".\/share\/www"/fauxton_root, "\/usr\/local\/couchdb\/share\/www"/' ./rel/couchdb.config

make release

mkdir -p ./rel/couchdb/data
