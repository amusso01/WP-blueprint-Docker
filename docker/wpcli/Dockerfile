FROM wordpress:cli-php8.3

USER root

RUN apk add --no-cache msmtp \
    && touch /etc/msmtprc \
    && chmod 666 /etc/msmtprc

COPY docker/wordpress/entrypoint-smtp.sh /usr/local/bin/entrypoint-smtp.sh
RUN chmod +x /usr/local/bin/entrypoint-smtp.sh

USER www-data

ENTRYPOINT ["entrypoint-smtp.sh"]
