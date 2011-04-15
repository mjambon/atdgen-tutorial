# What is atdgen?

Atdgen is a tool that derives OCaml boilerplate code from type definitions.
Currently it provides support for:

* [JSON](http://json.org/) serialization and deserialization.
* [Biniou](http://martin.jambon.free.fr/biniou-format.txt)
  serialization and deserialization.
  Biniou is a binary format extensible like JSON but more compact
  and faster to process.
* Convenience functions for creating and validating OCaml data.

# Prerequisites

This tutorial assumes that you are using atdgen version 1.2.0 or above.
The following command tells you which version you are using:

    $ atdgen -version
    1.2.0+dev

At the time of writing, atdgen 1.2.0 has not
been officially released but the development version is available from Github.
You can fetch it using the following command:

    $ git clone git://github.com/MyLifeLabs/atdgen.git

A quick way of installing all the dependencies is via Godi.
Run `godi_console` and install atdgen 1.1.1. You can then uninstall it
but leave all its dependencies installed.

Now read the instructions in atdgen/INSTALL or just do:

    $ cd atdgen
    $ make
    $ make install

# Getting started

From now on we assume that atdgen 1.2.0 or above is installed properly.
1.2.0+dev is fine.

    $ atdgen -version
    1.2.0+dev

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
