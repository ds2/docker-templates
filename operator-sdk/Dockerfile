FROM golang:latest
ARG tagName=v1.9.0
RUN export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) && \
    export OS=$(uname | awk '{print tolower($0)}') && \
    export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/${tagName} && \
    echo "Will use this url to download the sdk binary: ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}" && \
    curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH} && \
    chmod +x operator-sdk_${OS}_${ARCH} && mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
RUN apt-get update; apt-get install -y lsb-release
RUN curl -fsSL https://download.docker.com/linux/debian/gpg > /tmp/gpg.key; apt-key add /tmp/gpg.key
RUN echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update; apt-get install -y docker-ce-cli containerd.io
RUN rm -rf /var/lib/apt/lists/* && apt-get purge   --auto-remove && apt-get clean
