FROM debian:stretch-slim

ENV WWW_DIR /var/www
ENV WWW_USER www
ENV NSFW_DIR /opt/open_nsfw

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    caffe-cpu \
    curl \
    git \
    python3 \
    python3-dev \
    python3-numpy \
    python3-pip \
    python3-setuptools \
    python3-wheel \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${NSFW_DIR} ${WWW_DIR}
RUN git clone https://github.com/yahoo/open_nsfw.git ${NSFW_DIR}

# add user
RUN useradd -M -s /sbin/nologin ${WWW_USER}

COPY code ${NSFW_DIR}/
WORKDIR ${NSFW_DIR}
RUN cd ${NSFW_DIR} && rm -rf .git README.md
RUN echo "aiodns\naiohttp\ncchardet\nuvloop" > ${NSFW_DIR}/requirements.txt
RUN pwd
RUN ls -a ${NSFW_DIR}
RUN pip3 -V
RUN cat requirements.txt
RUN pip3 install -r requirements.txt

#clean
RUN apt-get remove -y --auto-remove git

RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove

RUN rm -rf /var/lib/apt/lists/*

VOLUME ${WWW_DIR}

EXPOSE 8080

USER ${WWW_USER}

ENTRYPOINT ["python3", "api.py"]