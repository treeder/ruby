FROM iron/ruby-bundle

RUN apk update && apk upgrade

# Clean APK cache
RUN rm -rf /var/cache/apk/*

ADD ruby.sh /scripts/
ADD main.rb /scripts/
# ADD lib/* /scripts/lib/ # for sub docker file (see go one)

WORKDIR /app

ENTRYPOINT ["ruby", "/scripts/main.rb"]
