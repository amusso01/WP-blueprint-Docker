FROM wordpress:php8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends msmtp msmtp-mta ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && touch /etc/msmtprc \
    && chmod 666 /etc/msmtprc

# Drop Hello Dolly, Akismet, and all bundled Twenty* themes from the WordPress source tree.
# Bind-mounted wp-content/themes would otherwise receive those copies on first start.
RUN rm -f /usr/src/wordpress/wp-content/plugins/hello.php \
    && rm -rf /usr/src/wordpress/wp-content/plugins/akismet \
    && rm -rf /usr/src/wordpress/wp-content/themes/twenty*

COPY docker/wordpress/entrypoint-smtp.sh /usr/local/bin/entrypoint-smtp.sh
RUN chmod +x /usr/local/bin/entrypoint-smtp.sh

ENTRYPOINT ["entrypoint-smtp.sh"]
CMD ["apache2-foreground"]
