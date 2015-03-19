#!/usr/bin/env bash

# generic mirage/opam setup
echo "yes" | sudo add-apt-repository ppa:avsm/ocaml42+opam12
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam 

export OPAMYES=1
opam init
opam install mirage dns
eval `opam config env`

# project specific
for dir in * ; do
  cd $dir
  mirage configure --unix
  make
  sudo make run
done