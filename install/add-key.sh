#!/bin/bash

set -e

echo "`date` - Adicionando a chave $1" 

gpg --keyserver pgpkeys.mit.edu --recv-key  $1      
gpg -a --export $1 | apt-key add -
