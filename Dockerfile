FROM ruby:2.3-alpine

RUN apk add --no-cache --update bash

# Create application directory and set it as the WORKDIR.
ENV APP_HOME /code
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY . $APP_HOME

RUN apk add --no-cache --update --virtual .gem-builddeps make gcc libc-dev ruby-json \
    && gem install -N oj -v 2.15.0 \
    && gem install -N json -v 2.1.0 \
    && apk del .gem-builddeps

RUN bundle install --system --binstubs
