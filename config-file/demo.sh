#! /bin/sh -e

set -x
atdgen -t config.atd
atdgen -j -j-defaults config.atd
atdgen -v config.atd
ocamlfind ocamlopt -o config \
  config_t.mli config_t.ml config_j.mli config_j.ml config_v.mli config_v.ml \
  config.ml -package atdgen -linkpkg
./config
