#!/bin/bash
flag=`cat flag.txt`
admin_secret='Qy9W1MpHlbATrLqDDBPP'
captcha_secret='CAPTCHA_SECRET'
captcha_public='CAPTCHA_PUBLIC'
chall_url='https://baby-csp.web.jctf.pro/'

cd private/challenge
rm -rf src-docker && mkdir src-docker
cp src/* src-docker/

sed -i "s/CTF_FLAG/$flag/g" src-docker/secrets.php
sed -i "s/CTF_ADMIN_SECRET/$admin_secret/g" src-docker/secrets.php 
sed -i "s/CTF_CAPTCHA_SITE_KEY/$captcha_public/g" src-docker/secrets.php 
sed -i "s/CTF_CAPTCHA_PRIVATE_KEY/$captcha_secret/g" src-docker/secrets.php 
sed -i "s#CTF_CHALL_URL#$chall_url#g" src-docker/secrets.php 

cp Dockerfile src-docker/Dockerfile

chmod -w src-docker/*
cd ../..

docker-compose -p web_baby-csp -f docker-compose.yml rm --force --stop
docker-compose -p web_baby-csp -f docker-compose.yml build
docker-compose -p web_baby-csp -f docker-compose.yml up -d