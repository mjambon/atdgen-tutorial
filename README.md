# What is atdgen?

Atdgen is a tool that derives OCaml boilerplate code from type definitions.
Currently it provides support for:

* [JSON](http://json.org/) serialization and deserialization.
* [Biniou](http://martin.jambon.free.fr/biniou-format.txt)
  serialization and deserialization.
  Biniou is a binary format extensible like JSON but more compact
  and faster to process.
* Convenience functions for creating and validating OCaml data.

# Getting started

We assume that you have installed a recent version of atdgen. This tutorial
assumes version 1.2.0 or above.

Type definitions are placed in a `.atd` file:

    $ cat hello.atd
    type date = {
      year : int;
      month : int;
      day : int;
    }

Our handwritten OCaml program is `hello.ml`:

    $ cat hello.ml
    open Hello_t
    let () =
      let date = { year = 1970; month = 1; day = 1 } in
      print_endline (Hello_j.string_of_date date)

We produce OCaml code from the type definitions using `atdgen`:

    $ atdgen -t hello.atd     # produces OCaml type definitions
    $ atdgen -j hello.atd     # produces OCaml code dealing with JSON

We now have `_t` and `_j` files produced by `atdgen -t` and `atdgen -j`
respectively:

    $ ls
    hello.atd  hello.ml  hello_j.ml  hello_j.mli  hello_t.ml  hello_t.mli

We compile all `.mli` and `.ml` files:

    $ ocamlfind ocamlc -c hello_t.mli -package atdgen
    $ ocamlfind ocamlc -c hello_j.mli -package atdgen
    $ ocamlfind ocamlopt -c hello_t.ml -package atdgen
    $ ocamlfind ocamlopt -c hello_j.ml -package atdgen
    $ ocamlfind ocamlopt -c hello.ml -package atdgen
    $ ocamlfind ocamlopt -o hello hello_t.cmx hello_j.cmx hello.cmx \
        -package atdgen -linkpkg

And finally we run our `hello` program:

    $ ./hello
    {"year":1970,"month":1,"day":1}


# Examples



# Advanced features
