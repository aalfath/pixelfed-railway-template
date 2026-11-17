# Redis for Pixelfed (cache and queues), pinned by version and digest.
FROM redis:8.10.3-alpine@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3

COPY --chmod=0755 start.sh /usr/local/bin/railway-redis.sh

CMD ["/usr/local/bin/railway-redis.sh"]
