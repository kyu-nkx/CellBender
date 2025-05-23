# Start from nvidia-docker image with drivers pre-installed to use a GPU
FROM nvcr.io/nvidia/cuda:11.7.1-base-ubuntu18.04

# Specify a certain commit of CellBender via branch, tag, or sha
ARG GIT_SHA

LABEL maintainer="Stephen Fleming <sfleming@broadinstitute.org>"
ENV DOCKER=true \
    CONDA_AUTO_UPDATE_CONDA=false \
    CONDA_DIR="/opt/conda" \
    GCLOUD_DIR="/opt/gcloud" \
    GOOGLE_CLOUD_CLI_VERSION="397.0.0" \
    GIT_SHA=$GIT_SHA
ENV PATH="$CONDA_DIR/bin:$GCLOUD_DIR/google-cloud-sdk/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates sudo git \
 && apt-get clean \
 && sudo rm -rf /var/lib/apt/lists/* \
# get miniconda
 && curl -so $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py37_23.1.0-1-Linux-x86_64.sh \
 && chmod +x $HOME/miniconda.sh \
 && $HOME/miniconda.sh -b -p $CONDA_DIR \
 && rm $HOME/miniconda.sh \
# get gsutil
 && mkdir -p $GCLOUD_DIR \
 && curl -so $HOME/google-cloud-cli.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_CLI_VERSION}-linux-x86_64.tar.gz \
 && tar -xzf $HOME/google-cloud-cli.tar.gz -C $GCLOUD_DIR \
 && .$GCLOUD_DIR/google-cloud-sdk/install.sh --usage-reporting false \
 && rm $HOME/google-cloud-cli.tar.gz \
# get compiled crcmod for gsutil
 && conda install -y -c conda-forge crcmod \
# install cellbender and its dependencies
 && yes | pip install --no-cache-dir -U git@github.com:kyu-nkx/CellBender.git \
 && conda clean -yaf \
 && sudo rm -rf ~/.cache/pip
