# Get NVM
FROM curlimages/curl AS nvm
ENV  NVM_VERSION=v0.40.1
RUN curl --silent -o /tmp/nvm.sh https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh

FROM curlimages/curl AS mongosh
ENV MONGOSH_VERSION=2.2.3
ENV MONGO_ARCH=arm64
WORKDIR /mongosh
RUN curl --silent -o /mongosh/mongosh.tgz https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${MONGO_ARCH}.tgz
RUN tar -zxvf /mongosh/mongosh.tgz 
RUN rm -rf /mongosh/mongosh.tgz 


# Code server starts here
FROM ghcr.io/coder/code-server:4.95.1-39

# Node config
ENV NVM_DIR=/home/coder/.nvm
ENV NODE_VERSION=23.1.0

### Root section
USER root
# Install packages

#apt-get update
RUN apt-get update && apt-get install -y curl zip unzip
# RUN  apt-get update && apt-get install -y default-jdk gnugpg
RUN rm /bin/sh && ln -s /bin/bash /bin/sh


# Install NVM script 
COPY --from=nvm /tmp/nvm.sh /tmp/nvm.sh
RUN chown -R coder:coder /tmp/nvm.sh  && chmod +x /tmp/nvm.sh

# Install mongosh
COPY --from=mongosh /mongosh/ /usr/share/mongosh/
RUN ln -s /usr/share/mongosh/bin/* /usr/local/bin/



### User space operations
USER coder
WORKDIR /home/coder

RUN curl -s "https://get.sdkman.io" | bash
# this SHELL command is needed to allow using source
SHELL ["/bin/bash", "-c"]  
RUN source "/root/.sdkman/bin/sdkman-init.sh"   \
                && sdk install java  \
                && sdk install quarkus
# Install NVM for user
RUN /tmp/nvm.sh && rm -f /tmp/nvm.sh 
# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH





