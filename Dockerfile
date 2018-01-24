FROM ruby:2.2.9-alpine
MAINTAINER Shahriar Boroujerdin

RUN apk update && \
    apk add net-tools

# Install gems
ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

# Upload source
COPY . $APP_HOME

# Start server
ENV PORT 9105
EXPOSE 9105
CMD ["ruby", "git_exporter.rb"]
