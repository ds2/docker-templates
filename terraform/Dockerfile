FROM alpine:3.18.5
ARG terraformUrl110=https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_linux_amd64.zip
ARG terraformUrl015=https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip
ARG terraformUrl014=https://releases.hashicorp.com/terraform/0.14.11/terraform_0.14.11_linux_amd64.zip
ARG terraformUrl013=https://releases.hashicorp.com/terraform/0.13.7/terraform_0.13.7_linux_amd64.zip
ARG terraformUrl012=https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
ARG gcloudSdkUrl=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-324.0.0-linux-x86_64.tar.gz
ARG tfsecUrl=https://github.com/tfsec/tfsec/releases/download/v0.39.30/tfsec-linux-amd64
ARG awsCliUrl=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
ARG TFUSER=tfuser
ARG TFUSERID=1000

ENV TIMEZONE=Europe/Berlin
ENV TF_DATA_DIR=/tf-data
ENV TF_LOG_PATH=/tf-logs/terraform.log
#ENV TF_INPUT=0
#ENV TF_IN_AUTOMATION=true

# Initial setup
RUN apk update
RUN apk upgrade; apk add curl tzdata zsh py3-pip less openssl jq tar git perl zip
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime; echo "${TIMEZONE}" >  /etc/timezone
RUN mkdir /keys; chmod 0777 /keys
RUN curl -o /tmp/tf12.zip -L ${terraformUrl012}; mkdir /opt/tf012/; unzip -d /opt/tf012 /tmp/tf12.zip
RUN curl -o /tmp/tf13.zip -L ${terraformUrl013}; mkdir /opt/tf013/; unzip -d /opt/tf013 /tmp/tf13.zip
RUN curl -o /tmp/tf14.zip -L ${terraformUrl014}; mkdir /opt/tf014/; unzip -d /opt/tf014 /tmp/tf14.zip
RUN curl -o /tmp/tf15.zip -L ${terraformUrl015}; mkdir /opt/tf015/; unzip -d /opt/tf015 /tmp/tf15.zip
RUN curl -o /tmp/tf110.zip -L ${terraformUrl110}; mkdir /opt/tf110/; unzip -d /opt/tf110 /tmp/tf110.zip
RUN mkdir /opt/tfsec/; curl -o /opt/tfsec/tfsec -L ${tfsecUrl}
ENV TF12BIN=/opt/tf012/terraform
ENV TF13BIN=/opt/tf013/terraform
ENV TF14BIN=/opt/tf014/terraform
ENV TF15BIN=/opt/tf015/terraform
ENV TF110BIN=/opt/tf110/terraform

# add TF User
RUN adduser -s /bin/zsh -D -u ${TFUSERID} ${TFUSER}
COPY zshrc_template.txt /home/${TFUSER}/.zshrc

WORKDIR /tmp

# AWS
RUN apk add --no-cache aws-cli
RUN mkdir -p /opt/awsv2
RUN curl "${awsCliUrl}" -o "/tmp/awscliv2.zip"; unzip /tmp/awscliv2.zip; ./aws/install -b /opt/awsv2
RUN aws --version

# GCloud
RUN curl -o /tmp/gcloud.tgz ${gcloudSdkUrl}
RUN tar -xzf /tmp/gcloud.tgz

# Azure
RUN apk add --virtual .build-deps rust cargo python3-dev gcc make openssl-dev libffi-dev musl-dev linux-headers; apk add libintl icu-libs libc6-compat
RUN pip3 install wheel
RUN pip3 install azure-cli
RUN apk del .build-deps
RUN az --version


# Final setup
RUN rm /tmp/*.zip
RUN mkdir /tf /tf-logs ${TF_DATA_DIR}; chmod 0777 /tf ${TF_DATA_DIR} /tf-logs; touch /tf/install_here_your_tf_files.tf
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
USER ${TFUSER}
WORKDIR /tf
CMD [ "/bin/zsh" ]
