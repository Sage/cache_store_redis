#!/bin/sh

echo 'Setup starting.....'
docker-compose rm

cd ../

echo 'Build Ruby docker image'
docker build --rm -t sageone/testrunner .

echo 'Build JRuby docker image'
docker build --rm -f Dockerfile-jruby -t sageone/testrunner_jruby .

echo 'Setup complete'
