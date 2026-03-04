FROM ruby:3.2-alpine

LABEL maintainer="noc@satory.kz"

RUN apk add --no-cache \
    git \
    openssh \
    bash \
    build-base \
    libffi-dev \
    yaml-dev \
    zlib-dev \
    libssh2-dev

WORKDIR /opt/oxidized

COPY Gemfile .

RUN bundle install

COPY . /opt/oxidized

RUN mkdir -p /root/.config/oxidized

EXPOSE  8888
ENTRYPOINT ["/opt/oxidized/entrypoint.sh"]
