# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t flightreservation_ruby_on_rails .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name flightreservation_ruby_on_rails flightreservation_ruby_on_rails

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.2
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG DATABASE_HOST
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages in a single stage
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="production"

# Throw-away build stage to reduce size of final image
FROM base AS build
COPY Gemfile Gemfile.lock ./

# Install packages needed to build gems, including MySQL development libraries and MariaDB client libraries
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config default-libmysqlclient-dev libmariadb3 libmariadb-dev && \
    ln -sf /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/libmariadb.so.3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Add the library path to the runtime environment
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu"

# Install application gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile assets for production without requiring database credentials
RUN RAILS_ENV=assets_precompile SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Audit installed libraries in the build stage
RUN dpkg-query -L libmariadb3 > /tmp/dependencies.txt

# Final stage for app image
FROM base

# Install rsync for robust file copying
RUN apt-get update -qq && apt-get install --no-install-recommends -y rsync && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy audited dependencies from the build stage
COPY --from=build /tmp/dependencies.txt /tmp/dependencies.txt
RUN cat /tmp/dependencies.txt | grep -v '/$' | while read -r file; do \
    if [ -e "$file" ]; then rsync -R "$file" /; fi; \
  done

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Ensure the MariaDB client library is properly linked
RUN ln -sf /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/libmariadb.so.3

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
