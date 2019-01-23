#!/bin/sh

echo 'Setup starting.....'
docker-compose rm

cd ../

echo 'Build Ruby docker image'
docker build --rm -t sageone/testrunner .

echo 'Setup complete'
