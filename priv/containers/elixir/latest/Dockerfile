FROM elixir:latest
MAINTAINER Nathan Faucett "nathanfaucett@gmail.com"

# Install code_runner
COPY code_runner /home/code_runner/code_runner
RUN chmod +x /home/code_runner/code_runner

WORKDIR /home/code_runner/
ENTRYPOINT "/home/code_runner/code_runner"
CMD ["/home/code_runner/code_runner"]