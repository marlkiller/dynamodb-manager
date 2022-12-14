FROM nginx

RUN echo 'fuck before'
RUN ls -la
RUN echo 'fuck after'




LABEL maintainer="taydycn@gmail.com"

COPY ./dist /usr/share/nginx/html



COPY nginx_default.conf /etc/nginx/conf.d/default.conf
# COPY nginx_default.conf /etc/nginx/nginx.conf
RUN cat  /etc/nginx/conf.d/default.conf
# ENTRYPOINT ["sh", "-c", "/usr/share/nginx/sbin/nginx -s reload"]

# RUN nohup nginx -c /etc/nginx/nginx.conf &

# RUN nginx -s reload

RUN echo 'fffffffffffffffcat '