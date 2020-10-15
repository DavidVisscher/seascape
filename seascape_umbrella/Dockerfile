FROM elixir:1.10.0-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod
ARG secret_key_base=5Irhh1BBJyTQBThFQABQxdsCjds3W3+FyUvJ1P8rxuibEmgsPpc4/yX9lk35SloH
ENV SECRET_KEY_BASE=$secret_key_base

# # install mix dependencies
COPY mix.exs .
COPY mix.lock .
COPY config config
# COPY apps apps
RUN mix do deps.get, deps.compile

# build assets
# COPY apps/seascape_web/assets/package.json apps/seascape_web/assets/package-lock.json ./apps/seascape_web/assets/
RUN npm --prefix ./apps/seascape_web/assets ci --progress=false --no-audit --loglevel=error

# COPY apps/seascape_web/priv apps/seascape_web/priv
# COPY assets ./apps/seascape_web/assets
RUN npm run --prefix ./apps/seascape_web/assets deploy
WORKDIR ./apps/seascape_web
RUN mix phx.digest

WORKDIR /app

# compile and build release
# COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release web

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/web ./

ENV HOME=/app

CMD ["bin/web", "start"]