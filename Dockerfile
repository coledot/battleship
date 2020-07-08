FROM ruby:2.7

RUN mkdir /appdir
WORKDIR /appdir
COPY Gemfile /appdir/Gemfile
COPY Gemfile.lock /appdir/Gemfile.lock
RUN bundle install
COPY . /appdir

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD [ "rails", "server", "-b", "0.0.0.0" ]

