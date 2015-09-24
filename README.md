This image is for building your Ruby dependencies. Just run it and it will update your gems and vendor your dependencies
for you.

You should use treeder/ruby to run them (way, way smaller image).

## Using

### Bundling

Bundle install:

```sh
docker run --rm -v $PWD:/app -w /app treeder/ruby bundle
```
Updating the bundle:

```sh
docker run --rm -v $PWD:/app -w /app treeder/ruby bundle update
```


### Running

TODO



That will do a `bundle update` and `bundle install --standalone`.

You can also run commands explicitly too if you'd like, for example:

```sh
docker run --rm -v $PWD:/app -w /app treeder/ruby bundle update
docker run --rm -v $PWD:/app -w /app treeder/ruby bundle install --standalone --clean
docker run --rm -v $PWD:/app -w /app treeder/bundle chmod -R a+rw .bundle
docker run --rm -v $PWD:/app -w /app treeder/bundle chmod -R a+rw bundle
```


## KNOWN ISSUES

If you're using Nokogiri, you need to use the image that has some other libs installed. MAYBE JUST MAKE
iron/ruby-bundle the default?




## Building

```sh
docker build -t treeder/ruby:latest .
```

Push:

```sh
docker push treeder/bundle
```
