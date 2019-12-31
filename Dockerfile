FROM elixir:1.9

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y \
  inotify-tools \
  postgresql-client

RUN mix local.hex --force && mix local.rebar --force

RUN mix archive.install hex phx_new 1.4.9 --force

WORKDIR /app

COPY /config/db/dev.secret.exs.example ./config/db/dev.secret.exs
COPY /config/db/test.secret.exs.example ./config/db/test.secret.exs
