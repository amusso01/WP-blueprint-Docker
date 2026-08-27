FROM wordpress:php8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends msmtp msmtp-mta ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && touch /etc/msmtprc \
    && chmod 666 /etc/msmtprc

COPY docker/wordpress/entrypoint-smtp.sh /usr/local/bin/entrypoint-smtp.sh
RUN chmod +x /usr/local/bin/entrypoint-smtp.sh

ENTRYPOINT ["entrypoint-smtp.sh"]
CMD ["apache2-foreground"]
