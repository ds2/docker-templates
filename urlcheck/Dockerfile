FROM rust:latest as build
WORKDIR /usr/src/myapp
COPY src/* src/
COPY Cargo.* ./
RUN cargo install --path .
RUN find .

#FROM alpine:latest
#COPY --from=builder /usr/local/cargo/bin/urlcheck /usr/local/bin/urlcheck
COPY opsgenie.sh /opsgenie.sh
RUN chmod a+x /opsgenie.sh
ENV ON_EACH_FAIL="/opsgenie.sh"
ENV RUST_LOG=info
CMD ["urlcheck"]
