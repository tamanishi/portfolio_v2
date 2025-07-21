#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Builds a Hugo site hosted on a Cloudflare Worker.
#
# The Cloudflare Worker build image already includes Go, Hugo (an old version),
# and Node js. Set the desired Dart Sass and Hugo versions below.
#
# The Cloudflare Worker automatically installs Node.js dependencies.
#------------------------------------------------------------------------------

main() {

  DART_SASS_VERSION=1.89.2
  HUGO_VERSION=0.148.0
  if [[ $(uname) == 'Darwin' ]]; then
    DART_SASS_ARCH=macos-arm64
    HUGO_ARCH=darwin-universal
  else
    DART_SASS_ARCH=linux-x64
    HUGO_ARCH=linux-amd64
  fi

  export TZ=Asia/Tokyo

  # Install Dart Sass
  echo "Installing Dart Sass v${DART_SASS_VERSION}..."
  curl -LJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-${DART_SASS_ARCH}.tar.gz"
  tar -xf "dart-sass-${DART_SASS_VERSION}-${DART_SASS_ARCH}.tar.gz"
  cp -r dart-sass/ /opt/buildhome
  rm -rf dart-sass*

  # Install Hugo
  echo "Installing Hugo v${HUGO_VERSION}..."
  curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_${HUGO_ARCH}.tar.gz
  tar -xf "hugo_extended_${HUGO_VERSION}_${HUGO_ARCH}.tar.gz"
  mv hugo /opt/buildhome
  rm LICENSE README.md hugo_extended_${HUGO_VERSION}_${HUGO_ARCH}.tar.gz

  # Set PATH
  echo "Setting the PATH environment variable..."
  export PATH=/opt/buildhome:/opt/buildhome/dart-sass:$PATH

  # Verify installed versions
  echo "Verifying installations..."
  echo Dart Sass: "$(sass --version)"
  echo Go: "$(go version)"
  echo Hugo: "$(hugo version)"
  echo Node.js: "$(node --version)"

  # https://gohugo.io/methods/page/gitinfo/#hosting-considerations
#   git fetch --recurse-submodules --unshallow
  git fetch --recurse-submodules

  # https://github.com/gohugoio/hugo/issues/9810
  git config core.quotepath false

  # Build the site.
  hugo --gc --minify

}

set -euo pipefail
main "$@"
