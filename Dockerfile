ARG BUILDER_IMG=node:current-slim
FROM $BUILDER_IMG as builder

ARG BRANCH=master
ARG GIT_REPO=https://github.com/MichMich/MagicMirror.git
ARG WORKING_DIR=/opt/mm

ENV DEBIAN_FRONTEND noninteractive
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install git -qy && \
    git clone $GIT_REPO -b $BRANCH $WORKING_DIR && \
    cd $WORKING_DIR && \
    npm ci --production

FROM $BUILDER_IMG

ARG TAG=latest
ARG WORKING_DIR=/opt/mm

LABEL vendor=Smartgic.io \
    io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>"

ENV DEBIAN_FRONTEND noninteractive
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get -qy --no-install-recommends install libglib2.0-0 libnss3 libatk1.0-0 \
    libatk-bridge2.0-0 libcups2 libgtk-3-0 libgbm1 libasound2 mesa-utils libasound2-plugins && \
    mkdir -p /run/user/1000 && \
    userdel -f -r node && \
    useradd --no-log-init snow -m -s /bin/bash -d $WORKING_DIR && \
    delgroup video && \
    addgroup --gid 44 video && \
    addgroup --gid 107 render && \
    addgroup --gid 997 gpio && \
    adduser snow video && \
    adduser snow render && \
    adduser snow gpio && \
    adduser snow audio && \
    chown snow:snow /run/user/1000 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder $WORKING_DIR $WORKING_DIR

RUN chown snow:snow -R $WORKING_DIR

USER snow

WORKDIR $WORKING_DIR

CMD ["npm", "run", "start"]
