FROM ubuntu:20.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests with Detox."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-6514223_latest.zip
ARG ANDROID_BUILD_VERSION=29
ARG ANDROID_TOOLS_VERSION=29.0.3
ARG NODE_VERSION=12.x
ARG GRADLE_VERSION=5.5

# set default environment variables
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}

ENV PATH=${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}:/usr/local/gradle-${GRADLE_VERSION}/bin:${PATH}

# Install system dependencies
RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
        apt-transport-https \
        curl \
        build-essential \
        file \
        git \
        cmake \
        openjdk-8-jdk \
        gnupg2 \
        python \
        python3-distutils \
        openssh-client \
        unzip \
        gcc \
        g++ \
        make \
    && rm -rf /var/lib/apt/lists/*;

# install nodejs packages from nodesource
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get update -qq \
    && apt-get install -qq -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-${ANDROID_BUILD_VERSION}" \
        "platform-tools" \
        "build-tools;${ANDROID_TOOLS_VERSION}" \
        "system-images;android-${ANDROID_BUILD_VERSION};google_apis_playstore;x86" \
        "system-images;android-28;google_apis_playstore;x86" \
    && rm -rf ${ANDROID_HOME}/.android

RUN curl -sS https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-all.zip -o /tmp/gradle.zip \
    && unzip -q -d /usr/local /tmp/gradle.zip \
    && rm /tmp/gradle.zip

# Create emulator Pixel_3_API_29
RUN echo "no" | avdmanager create avd --force --name  Pixel_3_API_29 --device "pixel_xl" --abi "x86" --package 'system-images;android-29;google_apis_playstore;x86'

# Intsall detox and react-native generic
RUN npm install -g detox-cli react-native-cli

