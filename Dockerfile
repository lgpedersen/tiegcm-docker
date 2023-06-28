FROM debian as esmf

ARG ESMF_VER=8.3.1

RUN apt-get update && \
    apt-get install -y \
            gcc \
            g++ \
            gfortran \
            make \
            libopenmpi-dev \
            perl \
            tcsh \
            libnetcdf-dev \
            libnetcdff-dev \
            python3 \
            patch && \
    apt-get clean

COPY esmf-build-vars.sh /tmp/
COPY esmf-${ESMF_VER}.tar.gz /tmp/

WORKDIR /tmp
RUN tar -xf esmf-${ESMF_VER}.tar.gz
RUN bash -c "cd /tmp/esmf-${ESMF_VER}; source ../esmf-build-vars.sh; make -j$(nproc) && make install"

FROM debian as build

RUN apt-get update && \
    apt-get install -y \
            gcc \
            g++ \
            gfortran \
            make \
            libopenmpi-dev \
            perl \
            tcsh \
            libnetcdf-dev \
            libnetcdff-dev \
            python3 \
            patch && \
    apt-get clean

COPY --from=0 /usr/local/ /usr/local/
COPY --chown=1000:1000 tiegcm2.0.tar.gz /opt/tiegcm/
COPY --chown=1000:1000 tiegcm2.0.patch /opt/tiegcm/

RUN sh -c "ln -sf /usr/bin/make /usr/local/bin/gmake"
RUN useradd -m -s /bin/bash tiegcm
WORKDIR /home/tiegcm
USER tiegcm

VOLUME /home/tiegcm

COPY start-tiegcm /opt/tiegcm/
CMD [ "/opt/tiegcm/start-tiegcm" ]
