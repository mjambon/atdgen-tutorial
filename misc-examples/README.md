Atdgen examples
===============

Examples accumulate here, typically based on questions asked by
users, pending their integration into a better organized document.

Serialization of type defined in an external library
----------------------------------------------------

```ocaml
(*
  atdgen -t ext.atd
  atdgen -j -j-std ext.atd
  ocamlfind opt -c -package atdgen ext_t.mli ext_t.ml ext_j.mli ext_j.ml
*)
type status_t <ocaml predef module="Unix" t="process_status"> =
  [ WEXITED of int
  | WSIGNALED of int
  | WSTOPPED of int ] <ocaml repr="classic">
```

This produces JSON serialization code (`_j` files) and the following
type re-definition:

```ocaml
type status_t = Unix.process_status =
    WEXITED of int
  | WSIGNALED of int
  | WSTOPPED of int
```
