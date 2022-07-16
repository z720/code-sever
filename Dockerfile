FROM curlimages/curl as nvm
ENV  NVM_VERSION=v0.39.1
RUN curl --silent -o /tmp/nvm.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh


FROM codercom/code-server:4.5.0

ENV NVM_DIR /home/coder/.nvm
ENV NODE_VERSION 18.6.0

# Install script 
USER root
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
COPY --from=nvm /tmp/nvm.sh /tmp/nvm.sh
RUN chown -R coder:coder /tmp/nvm.sh  && chmod +x /tmp/nvm.sh


USER coder
WORKDIR /home/coder
# Install NVM
RUN /tmp/nvm.sh \
    && rm -f /tmp/nvm.sh 
# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
# COPY --from=node /usr/lib /usr/lib
# COPY --from=node /usr/local/share /usr/local/share
# COPY --from=node /usr/local/lib /usr/local/lib
# COPY --from=node /usr/local/include /usr/local/include
# COPY --from=node /usr/local/bin /usr/local/bin

