FROM python:latest
MAINTAINER Nathan Faucett "nathanfaucett@gmail.com"

# Install runner
COPY runner /home/runner/runner
RUN chmod +x /home/runner/runner

WORKDIR /home/runner/
ENTRYPOINT "/home/runner/runner"
CMD ["/home/runner/runner"]
