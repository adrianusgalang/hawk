FROM ruby:2.4.1
RUN sed -i 's/^.*jessie-updates/#&/' /etc/apt/sources.list && apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && apt-get install -y sendmail

WORKDIR /hawk

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
CMD ["rails", "s"]
