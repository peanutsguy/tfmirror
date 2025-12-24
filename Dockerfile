FROM nginx:stable
LABEL org.opencontainers.image.source="https://github.com/peanutsguy/tfmirror"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget gpg python3-minimal lsb-release

RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && cat /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && apt-get install -y terraform
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ADD terraform_providers.py /app/terraform_providers.py
ADD 00-mirror-terraform.sh /docker-entrypoint.d/00-mirror-terraform.sh
ADD nginx.conf /etc/nginx/nginx.conf
RUN chmod +x /docker-entrypoint.d/00-mirror-terraform.sh