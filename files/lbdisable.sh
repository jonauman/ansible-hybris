#!/bin/bash

#set -x

if [ $# -lt 4 ]
then
  echo "Usage: $0 <load balancer> <host> <proto (http|https)> <Disable|Enable>"
  exit 1
fi

proto=$3
value=$4

nonce=`wget -q -O - http://$1/balancer-manager | gawk '/nonce/{s=index($0,"nonce");a=substr($0,s+6);b=index(a,"\"");print substr(a,1,b-1);}' | head -n 1`

ip=`awk -v p=$2 '{if ($2==p) print $1}' /etc/hosts`

echo $nonce $ip $2

command="$proto://$1/balancer-manager?dw="$value"&w=ajp%3A%2F%2F"$ip"%3A8009&b=ecomcluster&nonce="$nonce

if [ $proto == "http" ]
then
  wget -O - $command > /dev/null
fi

if [ $proto == "https" ]
then
  wget --no-check-certificate -O - $command > /dev/null
fi

