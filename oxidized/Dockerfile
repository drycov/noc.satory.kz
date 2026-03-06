FROM debian:trixie-slim

RUN groupadd -g 30000 -r oxidized && \
  useradd -u 30000 -r -m -d /home/oxidized -g oxidized oxidized && \
  chsh -s /bin/bash oxidized

RUN apt-get update && apt-get install -y --no-install-recommends \
    ruby ruby-dev \
    git openssh-client bash ca-certificates curl \
    build-essential pkg-config g++ \
    cmake \
    libgit2-dev \
    libffi-dev libyaml-dev zlib1g-dev libssl-dev libssh2-1-dev \
    libsqlite3-dev libicu-dev libzstd-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /home/oxidized

COPY . /home/oxidized/

RUN sed -i 's/\r$//' /home/oxidized/entrypoint.sh && \
    chmod +x /home/oxidized/entrypoint.sh && \
    mkdir -p /home/oxidized/.config/oxidized && \
    chown -R oxidized:oxidized /home/oxidized

RUN gem install bundler -N && bundle install --jobs=4 --retry=3

EXPOSE 8888

USER oxidized

ENTRYPOINT ["/home/oxidized/entrypoint.sh"]