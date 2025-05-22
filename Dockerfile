FROM ubuntu:22.04 AS builder
RUN apt update && apt upgrade -y
RUN apt install --assume-yes \
    cmake git build-essential autoconf pkg-config


#######################
# Building libdeflate #
#######################
# Version: v1.24
# Date: 2025-05-11
# Repo: https://github.com/ebiggers/libdeflate

WORKDIR /usr/src/libdelfate
RUN git clone https://github.com/ebiggers/libdeflate.git .
# Checkout to latest release according to
# https://stackoverflow.com/questions/17414104/git-checkout-latest-tag
RUN git fetch --tags && \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN cmake -B build && cd build && make -j && make install && ldconfig


###################
# Building htslib #
###################
# Version: v1.21
# Date: 2004-09-12
# Repo: https://github.com/samtools/htslib

WORKDIR /usr/src/htslib
RUN git clone --depth=1 --recursive https://github.com/samtools/htslib.git .
# Checkout to latest release according to
# https://stackoverflow.com/questions/17414104/git-checkout-latest-tag
RUN git fetch --tags && \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN apt install --assume-yes \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl3-gnutls-dev \
    libncurses5-dev \
    libgsl0-dev \
    libperl-dev
RUN autoreconf -i && ./configure && make -j && make install && ldconfig


#####################
# Building samtools #
#####################
# Version: v1.21
# Date: 2024-09-12
# Repo: https://github.com/samtools/samtools

WORKDIR /usr/src/samtools
RUN git clone https://github.com/samtools/samtools.git .
# Checkout to latest release according to
# https://stackoverflow.com/questions/17414104/git-checkout-latest-tag
RUN git fetch --tags && \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN autoheader && \
    autoconf -Wno-syntax && \
    ./configure &&\
    make -j


#####################
# Building bcftools #
#####################
# Version: v1.21
# Date: 2024-09-12
# Repo: https://github.com/samtools/bcftools

WORKDIR /usr/src/bcftools
RUN git clone --depth=1 https://github.com/samtools/bcftools.git .
# Checkout to latest release according to
# https://stackoverflow.com/questions/17414104/git-checkout-latest-tag
RUN git fetch --tags && \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN autoheader && \
    autoconf && \
    ./configure --enable-libgsl --enable-perl-filters && \
    make -j


#####################
# Building vcftools #
#####################
# Version: v0.1.17
# Date: 2025-05-15
# Repo: https://github.com/vcftools/vcftools

WORKDIR /usr/src/vcftools
RUN git clone https://github.com/vcftools/vcftools.git .

# Checkout to latest release according to
# https://stackoverflow.com/questions/17414104/git-checkout-latest-tag
RUN git fetch --tags && \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN ./autogen.sh && ./configure && make -j


################
# Result image #
################

FROM ubuntu:22.04 AS biodocker
RUN apt update && apt upgrade -y

##########################
# Libraries installation #
##########################

COPY --from=builder /usr/local /usr/local
RUN ldconfig
RUN apt install --assume-yes --no-install-recommends\
    libgsl0-dev \
    libperl-dev \
    libcurl3-gnutls-dev

#########################
# Samtools installation #
#########################

COPY --from=builder /usr/src/samtools/samtools /soft/samtools_v1_21/samtools
ENV SAMTOOLS=/soft/samtools_v1_21/samtools
ENV PATH="$PATH:/soft/samtools_v1_21"


#########################
# Samtools installation #
#########################

COPY --from=builder /usr/src/bcftools/bcftools /soft/bcftools_v1_21/bcftools
ENV BCFTOOLS=/soft/bcftools_v1_21/bcftools
ENV PATH="$PATH:/soft/bcftools_v1_21"


#########################
# Samtools installation #
#########################

COPY --from=builder /usr/src/vcftools/src/cpp/vcftools /soft/vcftools_v0_1_17/vcftools
ENV VCFTOOLS=/soft/vcftools_v0_1_17/vcftools
ENV PATH="$PATH:/soft/vcftools_v0_1_17"

WORKDIR /soft
ENV SOFT=/soft
