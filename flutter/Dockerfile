FROM debian:buster-slim
ARG sdkUrl=https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
ARG flutterUrl=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.2.3-stable.tar.xz
ENV PACKAGES="platform-tools platforms;android-31 build-tools;31.0.0"
ENV ANDROID_HOME=/home/mobiledev/android
ENV ANDROID_SDK_BINS=${ANDROID_HOME}/cmdline-tools/latest/bin

RUN apt-get update; apt-get install -yq curl unzip bash gnupg git zip xz-utils

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9; curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb; apt-get install ./zulu-repo_1.0.0-2_all.deb; apt-get update; apt-get install -yq zulu8-jdk-headless

RUN adduser --shell /bin/bash --disabled-password --uid 1000 mobiledev
RUN curl -L -o /tmp/flutter.xz ${flutterUrl}; sha256sum /tmp/flutter.xz

USER mobiledev
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:/home/mobiledev/flutter/bin:$PATH

COPY sdk-packages.txt /home/mobiledev/sdk-packages.txt
COPY installSdkStuff.sh /home/mobiledev/install.sh
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools/latest; curl -L -o /tmp/cmd.zip ${sdkUrl}; unzip -d /tmp/sdk /tmp/cmd.zip; cp -r /tmp/sdk/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest
RUN /home/mobiledev/install.sh

RUN cd ~; tar -xf /tmp/flutter.xz
# RUN flutter precache #; flutter doctor --android-licenses; flutter doctor -v
# RUN ${ANDROID_SDK_BINS}/sdkmanager --version
# RUN /usr/bin/yes | ${ANDROID_SDK_BINS}/sdkmanager --licenses
# RUN sdkmanager --install --package_file=/home/mobiledev/sdk-packages.txt

USER root
RUN rm -rf /tmp/*
RUN rm -rf /var/lib/apt/lists/* && apt-get purge   --auto-remove && apt-get clean

USER mobiledev
WORKDIR /src
SHELL [ "/bin/bash" ]
