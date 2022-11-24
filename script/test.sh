#!/bin/sh

echo start rspec tests
docker-compose up -d

docker exec -it cache_store_redis bash -c "bundle install && bundle exec rspec $*"
