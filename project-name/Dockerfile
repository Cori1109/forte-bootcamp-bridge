# ----------------------------------------------------------------------------
# Container Build Phase
#
FROM alpine:latest AS build

# Please update the project-name with the name of your project.
ARG NAME=project-name

# Update and upgrade apk.
RUN apk update && apk upgrade

# Install build dependencies.
RUN apk add --no-cache build-base git curl wget rust elixir cargo libressl-dev openssh

# Pepare build dir.
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Copy over all the needed folders and files. 
# Files can be ignored in the .dockerignore file, or can be explicitly  
# defined bellow.
COPY . .

# Install mix dependencies
RUN mix do deps.get --only prod, deps.compile

# build assets
# COPY assets/package.json assets/package-lock.json ./assets/
# RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error
# RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release ${NAME}

# ----------------------------------------------------------------------------
# Container Release Phase
#
FROM alpine:latest AS release

# Please update the project-name with the name of your project.
ARG NAME=project-name

# Set the name into the environment.
ENV NAME=$NAME

# Install dependencies
RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc curl libressl musl libffi

# Prepare running dir.
WORKDIR /app

# Create Alpine user permissions.
RUN chown nobody:nobody /app

# Set the Alpine user.
USER nobody:nobody

# Copy files from the build step.
COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/$NAME ./

# Set the home environemnt.
ENV HOME=/app

# Set the default run command on the container. 
CMD bin/${NAME} start
