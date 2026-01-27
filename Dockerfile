FROM ruby:2.7-buster

ARG BUNDLE_SAGEONEGEMS__JFROG__IO

ENV APP_HOME=/usr/src/app/
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# Cache the Gemfiles
COPY cache_store_redis.gemspec \
     Gemfile \
     $APP_HOME

COPY . $APP_HOME

ENV BUNDLER_VERSION=2.1.4
RUN bundle install

CMD ["./container_loop.sh"]

