# Static site for 2143 Labs (labs.2143.me).
#
# Serves whatever is in this repo at the doc root. nginx-unprivileged runs as
# uid 101 on :8080 with its pid and temp files under /tmp, so the deployment in
# 2143-k8s can run it non-root with a read-only root filesystem.
FROM nginxinc/nginx-unprivileged:1.31.6-alpine

# The site sits behind a TLS-terminating Gateway that forwards to :8080, so
# nginx does not know its public scheme or port. With absolute_redirect on (the
# default), a directory redirect such as /store -> /store/ is emitted as
# http://host:8080/store/ — a plaintext downgrade to a port that is not
# publicly reachable, so the browser hangs until it times out. Turning it off
# makes nginx emit a relative Location, which resolves against the public
# origin instead.
#
# Written here rather than copied from the repo: everything in the repo is
# published at the doc root, and this must not be. /etc/nginx/conf.d is
# writable by uid 101 and included from the http block, so no USER change is
# needed.
RUN printf 'absolute_redirect off;\n' > /etc/nginx/conf.d/00-absolute-redirect.conf

COPY --chown=101:101 . /usr/share/nginx/html
