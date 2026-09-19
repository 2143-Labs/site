# Static site for 2143 Labs (labs.2143.me).
#
# Serves whatever is in this repo at the doc root. nginx-unprivileged runs as
# uid 101 on :8080 with its pid and temp files under /tmp, so the deployment in
# 2143-k8s can run it non-root with a read-only root filesystem.
FROM nginxinc/nginx-unprivileged:1.31.6-alpine

COPY --chown=101:101 . /usr/share/nginx/html
