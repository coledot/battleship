FROM ruby:2.7

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install -y yarn
RUN yarn install --check-files

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

