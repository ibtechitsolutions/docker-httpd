FROM httpd:2.4

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["bash","/docker-entrypoint.sh"]
CMD ["httpd-foreground"]
