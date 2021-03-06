OUTFILE="$(echo "$IDP_ENTITY_ID" | sed 's/[^0-9A-Za-z.]/_/g' | sed 's/__*/_/g')"
if [ ! -f "/etc/apache2/mellon/${OUTFILE}.key" ] || [ ! -f "/etc/apache2/mellon/${OUTFILE}.cert" ] || [ ! -f "/etc/apache2/mellon/${OUTFILE}.xml" ]; then
    cd /etc/apache2/mellon
    bash /tmp/mellon_create_metadata.sh "${IDP_ENTITY_ID}" "${SCHEME}://${DOMAIN}/mellon"
fi

if [ ! -f "/etc/apache2/mellon/idp-metadata.xml" ]; then
    /tmp/ -O /etc/apache2/mellon/idp-metadata.xml
fi

sed -e "s|&DOMAIN&|${DOMAIN}|g" /tmp/certbot-000-default.conf.template > /etc/apache2/sites-available/000-default.conf


service cron start

REWRITE_ENGINE=On
REWRITE_RULE="RewriteRule ^/$ ${PROXY_PATH} [R,L]"
if [ "${PROXY_PATH}" == "/" ]; then
    REWRITE_ENGINE=Off
    REWRITE_RULE=
fi

sed -e "s|&OUTFILE&|${OUTFILE}|g" \
    -e "s|&DOMAIN&|${DOMAIN}|g" \
    -e "s|&PROXY_PATH&|${PROXY_PATH}|g" \
    -e "s|&PROXY_REMOTE_URL&|${PROXY_REMOTE_URL}|g" \
    -e "s|&REWRITE_ENGINE&|${REWRITE_ENGINE}|g" \
    -e "s|&REWRITE_RULE&|${REWRITE_RULE}|g" \
    /tmp/proxy-000-default.conf.template > /etc/apache2/sites-available/000-default.conf

apachectl $@
