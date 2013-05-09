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

Serializing abstract types that come with their own `to_string` and `of_string`
-------------------------------------------------------------------------------

```ocaml
(*
  atdgen -t ex.atd
  atdgen -j -j-std ex.atd
  ocamlfind opt -c -package atdgen ex_t.mli ex_t.ml ex_j.mli ex_j.ml
*)
type calendar =
    string wrap <ocaml module="Calendar"
                       (* t="t" is implied *)
                       wrap="Calendar.of_string"
                       unwrap="Calendar.to_string">

type has_calendar_t = {
  c : calendar;
}
```

produces the following OCaml type definitions:

```ocaml
type calendar = Calendar.t
type has_calendar_t = { c: calendar }
```

When converting to JSON, a value of type `calendar` is converted
(unwrapped) into an OCaml string using the supplied function
`Calendar.to_string`. Conversely, when reading from JSON, an OCaml
string is parsed (wrapped) into a `calendar` using the supplied function
`Calendar.of_string`.
