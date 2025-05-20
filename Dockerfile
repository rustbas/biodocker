FROM gcc:latest AS build
WORKDIR /app

RUN apt update && \
    apt upgrade -y && \
    apt install -y libgsl-dev

RUN git clone --depth=1 --recursive https://github.com/samtools/htslib.git
RUN cd htslib && autoreconf -i && ./configure && make -j
RUN git clone --depth=1 https://github.com/samtools/bcftools.git
RUN cd bcftools && autoheader && autoconf && ./configure --enable-libgsl --enable-perl-filters

