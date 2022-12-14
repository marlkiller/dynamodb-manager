FROM nginx

RUN echo 'fuck before'
RUN ls -la
RUN echo 'fuck after'




LABEL maintainer="taydycn@gmail.com"

COPY ./dist /usr/share/nginx/html

COPY nginx_default.conf /etc/nginx/conf.d/default.conf

# ENTRYPOINT ["sh", "-c", "/usr/share/nginx/sbin/nginx -s reload"]

RUN nginx -c /etc/nginx/conf.d/default.conf

RUN nginx -s reload

RUN cat /var/log/nginx/host.access.log
RUN cat /var/log/nginx/error.log
RUN echo 'fffffffffffffffcat '