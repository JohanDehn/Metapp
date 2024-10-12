# Use the official Elixir image from the Docker Hub
FROM elixir:latest

# Install Hex package manager
RUN mix local.hex --force

# Install Rebar (build tool for Erlang)
RUN mix local.rebar --force

# Set the working directory inside the container
WORKDIR /app

# Copy the mix.exs and mix.lock files to the container
COPY mix.exs ./
COPY mix.lock ./

# Fetch the dependencies
RUN mix deps.get

# Copy the rest of the application code to the container
COPY . .

# Compile the application
RUN mix compile

# Expose the port the app runs on
EXPOSE 4000

# Start the application

CMD ["mix", "phx.server"]
