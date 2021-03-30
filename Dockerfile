# https://hub.docker.com/_/elixir/
FROM elixir:1.11-alpine


RUN apk update && \
    apk add alpine-sdk coreutils && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new --force

WORKDIR /opt
COPY . /opt

RUN mix do deps.get, deps.compile, compile