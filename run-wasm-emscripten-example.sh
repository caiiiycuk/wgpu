#!/usr/bin/env bash

set -e

set -- hello-triangle
echo "Compiling..."
EMMAKEN_CFLAGS="-g -s ERROR_ON_UNDEFINED_SYMBOLS=0 --no-entry -s FULL_ES3=1" cargo build --example $1 --target wasm32-unknown-emscripten

mkdir -p target/wasm-examples/$1/
cp target/wasm32-unknown-emscripten/debug/examples/* target/wasm-examples/$1
cat wasm-resources/index.em.template.html | sed "s/{{example}}/$1/g" > target/wasm-examples/$1/index.html

# Find a serving tool to host the example
SERVE_CMD=""
SERVE_ARGS=""
if which basic-http-server; then
    SERVE_CMD="basic-http-server"
    SERVE_ARGS="target/wasm-examples/$1 -a 127.0.0.1:1234"
elif which miniserve && python3 -m http.server --help > /dev/null; then
    SERVE_CMD="miniserve"
    SERVE_ARGS="target/wasm-examples/$1 -p 1234 --index index.html"
elif python3 -m http.server --help > /dev/null; then
    SERVE_CMD="python3"
    SERVE_ARGS="-m http.server --directory target/wasm-examples/$1 1234"
fi

# Exit if we couldn't find a tool to serve the example with
if [ "$SERVE_CMD" = "" ]; then
    echo "Couldn't find a utility to use to serve the example web page. You can serve the `target/wasm-examples/$1` folder yourself using any simple static http file server."
fi

echo "Serving example with $SERVE_CMD at http://localhost:1234"
$SERVE_CMD $SERVE_ARGS
