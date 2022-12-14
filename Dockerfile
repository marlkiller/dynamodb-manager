FROM nginx

RUN mkdir fuck_dir
RUN echo 'fuck before'
RUN ls -la
RUN npm install
RUN npm run build
RUN ls -la
RUN echo 'fuck after'




LABEL maintainer="taydycn@gmail.com"

COPY ./dist /usr/share/nginx/html

COPY nginx_default.conf /etc/nginx/conf.d/default.conf
