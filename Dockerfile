FROM ruby:2.4.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && apt-get install -y sendmail

WORKDIR /hawk

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
CMD ["rails", "s"]
