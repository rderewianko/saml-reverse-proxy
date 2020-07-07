FROM ubuntu:18.04

ENV DOMAIN= \
    IDP_ENTITY_ID= \
    SAML_METADATA_FILE= \
    PROXY_PATH=/ \
    PROXY_REMOTE_URL= \

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget apache2 \
        libapache2-mod-auth-mellon openssl cron && \
    apt-get clean && \
    a2enmod rewrite ssl proxy proxy_balancer proxy_http auth_mellon authn_core authz_user && \
    mkdir -p /var/log/apache2 /etc/apache2/mellon && \
    chown -R www-data:www-data /var/www/ /var/log/apache2 /etc/apache2 && \
    chmod 500 /var/www
    mkdir /etc/ssl/$DOMAIN

WORKDIR /var/log/apache2

EXPOSE 80 443


COPY etc/proxy-000-default.conf.template /tmp/

COPY mellon/mellon_create_metadata.sh /tmp/

COPY entrypoint.sh /

VOLUME [ "/var/log/apache2"]

ENTRYPOINT [ "bash", "/entrypoint.sh" ]

CMD [ "-DFOREGROUND" ]
