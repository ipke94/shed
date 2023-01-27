# Uncomment to add custom CA certs from "certs" folder from another image.
# hadolint ignore=DL3007
# FROM <registry_url>/ca-certs:latest as ca-certs
FROM debian:bullseye-slim

# Uncomment to place custom CA certs. Change source path if needed.
# COPY --from=ca-certs certs/ /usr/local/share/ca-certificates/

# Install dependent packages and update CA certs
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        ca-certificates \
        git \
        curl \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

# Install oc cli
RUN curl -fsSLO https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
    && tar -xzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
    && ln -s /openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /bin/oc 

# helm and helm-push plugin to create releases
ENV VERIFY_CHECKSUM false
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && helm plugin install https://github.com/chartmuseum/helm-push
