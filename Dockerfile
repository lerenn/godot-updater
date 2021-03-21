FROM ubuntu:20.04

# Install dependencies
###############################################################################

# Update lists
RUN apt update

# Install dependencies for Editor
RUN DEBIAN_FRONTEND='noninteractive' apt install -y \
	build-essential scons pkg-config libx11-dev libxcursor-dev \
	libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev \
	libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm

# Install dependencies for Web
RUN DEBIAN_FRONTEND='noninteractive' apt install -y git scons python3 && \
	git clone https://github.com/emscripten-core/emsdk.git /usr/src/emsdk && \
	cd /usr/src/emsdk && ./emsdk install latest && ./emsdk activate latest

# Install dependencies for Android
RUN DEBIAN_FRONTEND='noninteractive' apt install -y scons python3 wget \
	gradle openjdk-8-jdk
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip && \
	unzip commandlinetools-linux-6200805_latest.zip && rm commandlinetools-linux-6200805_latest.zip && \
	mkdir -p /opt/android-sdk && mv tools /opt/android-sdk/
RUN	wget https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip && \
	unzip android-ndk-r21b-linux-x86_64.zip && rm android-ndk-r21b-linux-x86_64.zip && \
	mkdir -p /opt/android-sdk && mv android-ndk-r21b /opt/android-sdk/ndk-bundle

# Set variables for Android
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_NDK_ROOT /opt/android-sdk/ndk-bundle/

# Accept licenses and install gradle
RUN yes | /opt/android-sdk/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses && \
	gradle

# Prepare for source code and compilation
###############################################################################

# Make the recipient a volume
VOLUME /godot

# Prepare branch number
ENV GODOT_BRANCH 3.2
ENV PLATFORM x11

# Volume for output results
VOLUME /output

# Copy scripts 
###############################################################################

# Copy docker specific scripts
COPY docker /docker

# Copy godot-compiler script 
COPY godot-compiler.sh /docker/scripts

# Command file 
CMD ["bash", "docker/scripts/entrypoint.sh"]