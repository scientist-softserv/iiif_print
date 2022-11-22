FROM ghcr.io/scientist-softserv/dev-ops/samvera:e9200061 as hyku-base
USER root
RUN apk add --no-cache sqlite chromium-chromedriver
USER app

RUN sh -l -c " \
  git config --global --add safe.directory /app/samvera/hyrax-webapp && \
  bundle config set --global force_ruby_platform ruby"

COPY --chown=1001:101 $APP_PATH/Gemfile* /app/samvera/hyrax-webapp/
COPY --chown=1001:101 $APP_PATH/*.gemspec /app/samvera/hyrax-webapp/
COPY --chown=1001:101 $APP_PATH/lib/newspaper_works/version.rb /app/samvera/hyrax-webapp/lib/newspaper_works/
RUN bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp
