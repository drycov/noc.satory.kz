
FROM debian:trixie-slim

# Создать пользователя oxidized с UID 30000
RUN groupadd -g 30000 -r oxidized && \
  useradd -u 30000 -r -m -d /home/oxidized -g oxidized oxidized && \
  chsh -s /bin/bash oxidized

# Установить необходимые пакеты
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

# Копировать исходники
COPY . /home/oxidized/

# Установить bundler и зависимости
RUN gem install bundler -N && bundle install --jobs=4 --retry=3

# Создать директорию для конфигов
RUN mkdir -p /home/oxidized/.config/oxidized && chown -R oxidized:oxidized /home/oxidized/.config/oxidized

EXPOSE 8888

# Запускать от пользователя oxidized
USER oxidized

ENTRYPOINT ["/home/oxidized/entrypoint.sh"]
