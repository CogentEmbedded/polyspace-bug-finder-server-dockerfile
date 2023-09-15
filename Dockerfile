# Copyright 2022-2023 The MathWorks, Inc.

# To specify which MATLAB release to install in the container, edit the value of the MATLAB_RELEASE argument.
# Use lower case to specify the release, for example: ARG MATLAB_RELEASE=r2022b
ARG MATLAB_RELEASE=r2023b

# When you start the build stage, this Dockerfile by default uses the Ubuntu-based polyspace-deps image.
# To check the available polyspace-deps images, see: https://hub.docker.com/r/mathworks/polyspace-deps
FROM mathworks/polyspace-deps:${MATLAB_RELEASE}

# Declare the global argument to use at the current build stage
ARG MATLAB_RELEASE

# Install mpm dependencies
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install --no-install-recommends --yes \
        wget \
        unzip \
        sudo \
        ca-certificates && \
    apt-get clean && apt-get autoremove

# Run mpm to install Polyspace Bug Finder and Code Prover Server in the target location
# and delete the mpm installation afterwards
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm && \ 
    chmod +x mpm && \
    ./mpm install \
        --release=${MATLAB_RELEASE} \
        --destination=/opt/matlab \
        --products Polyspace_Bug_Finder_Server Polyspace_Code_Prover_Server && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/polyspace/bin/polyspace* /usr/local/bin/

# Add a "polyspace" user and grant sudo permission.
RUN adduser --shell /bin/bash --disabled-password --gecos "" polyspace && \
    echo "polyspace ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/polyspace && \
    chmod 0440 /etc/sudoers.d/polyspace

# One of the following 2 ways of configuring the license server to use must be
# uncommented.

ARG LICENSE_SERVER
# Specify the host and port of the machine that serves the network licenses 
# if you want to bind in the license info as an environment variable. This 
# is the preferred option for licensing. It is either possible to build with 
# something like --build-arg LICENSE_SERVER=27000@MyServerName, alternatively
# you could specify the license server directly using
#       ENV MLM_LICENSE_FILE=27000@flexlm-server-name
ENV MLM_LICENSE_FILE=$LICENSE_SERVER

# Alternatively you can put a license file into the container.
# You should fill this file out with the details of the license 
# server you want to use and uncomment the following line.
# COPY network.lic /opt/matlab/licenses/

# Set user and work directory
USER polyspace
WORKDIR /home/polyspace
CMD []
