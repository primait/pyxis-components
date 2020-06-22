FROM node:10

RUN \
  apt-get update \
  && apt-get install -qqy apt-transport-https \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get -qqy install yarn \
  && rm -rf /var/lib/apt/lists/* \
  && yarn --version \
  && chown node:node /usr/local/bin

USER node
