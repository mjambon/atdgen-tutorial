#! /bin/sh -e

set -x
cat single.json
ydump single.json
cat stream.json
ydump -c stream.json

ocamlfind ocamlopt -o prettify prettify.ml -package yojson -linkpkg
./prettify
