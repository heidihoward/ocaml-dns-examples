#!/usr/bin/env bash


for dir in * ; do
  cd $dir
  mirage configure --unix
  make
done