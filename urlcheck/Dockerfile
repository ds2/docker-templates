FROM rust:latest as builder
WORKDIR /usr/src
COPY src ./src
COPY Cargo.toml Cargo.lock ./
RUN cargo install --path .

FROM debian:buster-slim
RUN apt-get clean; apt-get update && apt-get install -y bash ca-certificates openssl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/urlcheck /usr/local/bin/urlcheck
COPY opsgenie.sh /opsgenie.sh
ENV ON_EACH_FAIL="/opsgenie.sh"
# ENV OPSGEN_APIKEY="12345"
# ENV OPSGEN_TEAM_NAME="My Team Name"
# ENV OPSGEN_PRIO="P1"
ENV URL_TIMEOUT=10
ENV RUST_LOG=info
#ENV CSV_FILE=/data/urls.csv
USER 1000
CMD ["/usr/local/bin/urlcheck"]
