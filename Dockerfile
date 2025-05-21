FROM ubuntu:22.04 AS builder

RUN apt update && apt upgrade -y

RUN apt install --assume-yes \
    cmake git build-essential autoconf

WORKDIR /usr/src/libdelfate
RUN git clone https://github.com/ebiggers/libdeflate.git .
RUN cmake -B build && cd build && make -j && make install && ldconfig

# Building htslib (TODO: use latest tag)
WORKDIR /usr/src/htslib
RUN git clone --depth=1 --recursive https://github.com/samtools/htslib.git .
RUN apt install --assume-yes \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl3-gnutls-dev \
    libncurses5-dev \
    libgsl0-dev \
    libperl-dev
RUN autoreconf -i && ./configure && make -j && make install && ldconfig

# Building samtools
WORKDIR /usr/src/samtools
RUN git clone https://github.com/samtools/samtools.git .
RUN autoheader && \
    autoconf -Wno-syntax && \
    ./configure &&\
    make -j

WORKDIR /usr/src/bcftools
RUN git clone --depth=1 https://github.com/samtools/bcftools.git .
RUN autoheader && \
    autoconf && \
    ./configure --enable-libgsl --enable-perl-filters && \
    make -j

WORKDIR /usr/src/vcftools
RUN git clone https://github.com/vcftools/vcftools.git .
RUN apt install -y pkg-config
RUN ./autogen.sh && ./configure && make -j

# Result image
# TODO: build libdeflate manually
FROM ubuntu:22.04
RUN apt update && apt upgrade -y
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/src/samtools/samtools /soft/samtools
COPY --from=builder /usr/src/bcftools/bcftools /soft/bcftools
RUN ldconfig
RUN apt install --assume-yes --no-install-recommends\
    libgsl0-dev \
    libperl-dev \
    libcurl3-gnutls-dev

#     zlib1g-dev \
#     libbz2-dev \
#     liblzma-dev \
#     libncurses5-dev \

WORKDIR /soft
