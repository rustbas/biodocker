FROM gcc:latest AS build_htslib
WORKDIR /htslib

# Building htslib (TODO: use latest tag)
RUN git clone --recursive https://github.com/samtools/htslib.git .
RUN autoreconf -i && ./configure && make -j

# Building samtools
FROM gcc:latest AS build_samtools
WORKDIR /samtools
RUN git clone https://github.com/samtools/samtools.git .
COPY --from=build_htslib /htslib/ /htslib/
RUN autoheader && \
    autoconf -Wno-syntax && \
    ./configure --with-htslib=../htslib && \
    make -j

# Result image
# TODO: build libdeflate manually
FROM gcc:latest

WORKDIR /soft
COPY --from=build_samtools /samtools/samtools .
