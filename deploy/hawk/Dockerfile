FROM alpine:3.7 as builder

ADD https://releases.hashicorp.com/envconsul/0.6.2/envconsul_0.6.2_linux_amd64.tgz /tmp/envconsul.tgz
RUN tar -xvzf /tmp/envconsul.tgz -C /usr/local/bin/

FROM ruby:2.4.1
RUN sed -i 's/^.*jessie-updates/#&/' /etc/apt/sources.list && apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && apt-get install -y sendmail

WORKDIR /hawk

COPY --from=builder /usr/local/bin/envconsul /usr/local/bin/

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
CMD ["rails", "s"]
