# To test this script before building an image:
# docker run --rm -v $PWD:/app -w /app treeder/go-dind sh go.sh version

set -e

cmd="$1"
# echo "Args: $*"
if [ "$#" -lt 1 ]
then
    echo "No command provided."
    exit 1
fi

# Pass in: $# MIN_ARGS
validate () {
  if [ "$1" -lt $2 ]
  then
      echo "No command provided."
      exit 1
  fi
}
vendor () {
  # nokogiri hack... ugly...
  bundle config build.nokogiri --use-system-libraries
  if [ "$1" ]; then
    # for example if user passed in bundle update
    bundle $1
  else
    bundle install --standalone --clean
  fi
  chmod -R a+rw .bundle
  chmod -R a+rw bundle
}
build () {
  # echo "build: $1 $2"
  go build $1
  cp app $2
  chmod a+rwx $wd/app
}

case "$1" in
  bundle)  echo "Vendoring dependencies..."
      vendor $2
      ;;
  vendor)  echo "Vendoring dependencies..."
      vendor $2
      ;;
  build)  echo  "Building..."
      build "-o app" $wd
      ;;
  cross)  echo  "Cross compiling..."
      for GOOS in darwin linux windows; do
        for GOARCH in 386 amd64; do
        echo "Building $GOOS-$GOARCH"
        export GOOS=$GOOS
        export GOARCH=$GOARCH
        go build -o bin/app-$GOOS-$GOARCH
        done
      done
      cp -r bin $wd
      chmod -R a+rw $wd/bin
#      ls -al $wd/bin
      ;;
  static) echo  "Building static binary..."
      CGO_ENABLED=0 go build -a --installsuffix cgo --ldflags="-s" -o static
      cp static $wd
      chmod a+rwx $wd/static
      ;;
  remote) echo  "Building binary from $2"
      validate $# 2
      userwd=$wd
      cd
      git clone $2 repo
      cd repo
      wd=$PWD
      # Need to redo some initial setup here:
      cp -r * $p
      cd $p
      vendor $p $wd
      build "-o app" $wd
      cp $wd/app $userwd
      chmod a+rwx $userwd/app
      ;;
  image) echo  "Building Docker image '$2'..."
      validate $# 2
      ls -al /usr/bin/docker
      cp -r ./* /tmp/app
      cp /scripts/lib/Dockerfile /tmp/app
      cd /tmp/app
      /usr/bin/docker version
      /usr/bin/docker build -t $2 .
      # perhaps an alternative to this would be to do dind, replace the FROM with treeder/go-dind for example:
#      cp /scripts/lib/Dockerfile $p
#      /usr/bin/dockerlaunch /usr/bin/docker -d -D &
#      sleep 3
#      docker build -t $2 .
      ;;
  version)
      go version
      ;;
  *) echo "Invalid command, see https://github.com/treeder/dockers/tree/master/go for reference."
      ;;
esac
exit 0
