FROM alpine:3.13
ARG userId=1000
RUN apk update
RUN apk add py-pip bash curl unzip openrc
RUN adduser -u ${userId} -s /bin/bash -D awsusr
# RUN curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; unzip awscliv2.zip; ./aws/install
# RUN curl -sfL https://get.k3s.io | sh -
RUN K8SVERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt); curl -L https://storage.googleapis.com/kubernetes-release/release/${K8SVERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl; chmod a+x /usr/bin/kubectl
USER awsusr
WORKDIR /home/awsusr
RUN pip install awscli
#ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/awsusr/.local/bin
ENV AWS_PROFILE default
ENV AWS_DEFAULT_REGION eu-central-1
ENV AWS_DEFAULT_OUTPUT json
ENV AWS_SHARED_CREDENTIALS_FILE /home/awsusr/.aws/credentials
ENV AWS_CONFIG_FILE /home/awsusr/.aws/config
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
SHELL [ "/bin/bash" ]
