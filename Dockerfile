FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get upgrade -y
RUN apt-get install --assume-yes                                               \
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
RUN git fetch --tags &&                                                        \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
# TODO: use workdir
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
RUN git fetch --tags &&                                                        \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN apt-get install --assume-yes                                               \
    zlib1g-dev                                                                 \
    libbz2-dev                                                                 \
    liblzma-dev                                                                \
    libcurl3-gnutls-dev                                                        \
    libncurses5-dev                                                            \
    libgsl0-dev                                                                \
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
RUN git fetch --tags &&                                                        \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN autoheader &&                                                              \
    autoconf -Wno-syntax &&                                                    \
    ./configure &&                                                             \
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
RUN git fetch --tags &&                                                        \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN autoheader &&                                                              \
    autoconf &&                                                                \
    ./configure --enable-libgsl --enable-perl-filters &&                       \
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
RUN git fetch --tags &&                                                        \
    latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1)") && \
    git checkout $latestTag && echo $latestTag > VERSION.txt
RUN ./autogen.sh && ./configure && make -j


################
# Result image #
################

FROM ubuntu:22.04 AS biodocker
RUN apt-get update && apt-get upgrade -y

##########################
# Libraries installation #
##########################

COPY --from=builder /usr/local /usr/local
RUN ldconfig

# Install dependencies and clean up after that
# According to
# https://github.com/hadolint/hadolint/wiki/DL3009
RUN apt-get install --assume-yes --no-install-recommends                       \
    libgsl0-dev                                                                \
    libperl-dev                                                                \
    libcurl3-gnutls-dev                                                        \
    python3                                                                    \
    pip && apt-get clean &&                                                    \
    rm -rf /var/lib/apt/lists/*

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


##############################
# Python script installation #
##############################

WORKDIR /python-pipeline
COPY ./src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./src/main.py .

COPY ./src/preprocess_script.sh .
COPY ./src/entrypoint.sh .

CMD  [ "bash" ]
# CMD [ "./entrypoint.sh" ]
