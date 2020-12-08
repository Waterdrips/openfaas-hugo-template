FROM --platform=${TARGETPLATFORM:-linux/amd64} openfaas/of-watchdog:0.8.0 AS watchdog
FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine:3.12 AS build

ARG BUILDPLATFORM
ARG TARGETPLATFORM

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
COPY getflavor.sh /usr/bin/getflavor.sh
RUN chmod +x /usr/bin/fwatchdog
RUN chmod +x /usr/bin/getflavor.sh

RUN apk update && apk add py-pygments ca-certificates bash git && rm -rf /var/cache/apk/*

ENV HUGO_VERSION 0.76.5
ENV FLAVOR Linux-ARM
RUN export FLAVOR=$('/bin/sh -c "source /usr/bin/getflavor.sh $BUILDPLATFORM"')
ENV HUGO_BINARY hugo_${HUGO_VERSION}_${FLAVOR}
ENV HUGO_ENV=production

RUN mkdir /usr/local/hugo
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz /usr/local/hugo/
RUN tar xzf /usr/local/hugo/${HUGO_BINARY}.tar.gz -C /usr/local/hugo/ \
	&& ln -s /usr/local/hugo/hugo /usr/local/bin/hugo \
	&& rm /usr/local/hugo/${HUGO_BINARY}.tar.gz

WORKDIR /home/app
COPY ./function .

RUN ["hugo", "--gc", "--minify"]

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:3.12 AS runtime

WORKDIR /home/app

COPY --from=build /home/app/public public
COPY --from=build /usr/bin/fwatchdog .

ENV mode="static"
ENV static_path="/home/app/public"

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["./fwatchdog"]
