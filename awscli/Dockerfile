FROM ubuntu:21.04
ARG userId=1000
ENV DEBIAN_FRONTEND=noninteractive
ENV AWS_PROFILE default
ENV AWS_DEFAULT_REGION eu-central-1
ENV AWS_DEFAULT_OUTPUT json
ENV AWS_SHARED_CREDENTIALS_FILE /home/awsusr/.aws/credentials
ENV AWS_CONFIG_FILE /home/awsusr/.aws/config
ENV KUBECONFIG /home/awsusr/.kube/config

RUN apt-get update; apt-get --yes install bash curl unzip
RUN useradd -u ${userId} -s /bin/bash -r awsusr
RUN curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; unzip awscliv2.zip; ./aws/install
RUN K8SVERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt); curl -L https://storage.googleapis.com/kubernetes-release/release/${K8SVERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl; chmod a+x /usr/bin/kubectl

USER awsusr
WORKDIR /home/awsusr
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
SHELL [ "/bin/bash" ]
