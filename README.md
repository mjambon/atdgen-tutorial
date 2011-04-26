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

Now read the instructions in `atdgen/INSTALL` or just do:

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

# Inspecting and pretty-printing JSON

Input JSON data:

    $ cat single.json 
    [1234,"abcde",{"start_date":{"year":1970,"month":1,"day":1}, 
    "end_date":{"year":1980,"month":1,"day":1}}]

Pretty-printed JSON can be produced with the `ydump` command:

    $ ydump single.json 
    [
      1234,
      "abcde",
      {
        "start_date": { "year": 1970, "month": 1, "day": 1 },
        "end_date": { "year": 1980, "month": 1, "day": 1 }
      }
    ]

Multiple JSON objects separated by whitespace, typically one JSON object
per line, can also be pretty-printed with `ydump`. Input:

    $ cat stream.json 
    [1234,"abcde",{"start_date":{"year":1970,"month":1,"day":1}, 
    "end_date":{"year":1980,"month":1,"day":1}}]
    [1,"a",{}]

In this case the `-s` option is required:

    $ ydump -s stream.json 
    [
      1234,
      "abcde",
      {
        "start_date": { "year": 1970, "month": 1, "day": 1 },
        "end_date": { "year": 1980, "month": 1, "day": 1 }
      }
    ]
    [ 1, "a", {} ]

From an OCaml program, pretty-printing can be done with `Yojson.Safe.prettify`
which has the following signature:

    val prettify : string -> string

We wrote a tiny program that simply calls the `prettify` function on 
some predefined JSON data:

    $ cat prettify.ml
    let json =
    "[1234,\"abcde\",{\"start_date\":{\"year\":1970,\"month\":1,\"day\":1}, 
    \"end_date\":{\"year\":1980,\"month\":1,\"day\":1}}]"

    let () = print_endline (Yojson.Safe.prettify json)

We now compile and run prettify.ml:

    $ ocamlfind ocamlopt -o prettify prettify.ml -package atdgen -linkpkg
    $ ./prettify
    [
      1234,
      "abcde",
      {
        "start_date": { "year": 1970, "month": 1, "day": 1 },
        "end_date": { "year": 1980, "month": 1, "day": 1 }
      }
    ]

# Inspecting biniou data

Biniou is a binary format that can be displayed as text using a generic
command called `bdump`. The only practical difficulty is to recover
the original field names and variant names which are stored as 31-bit hashes.
Unhashing them is done by consulting a dictionary (list of words)
maintained by the user.

Let's first produce a sample data file `tree.dat` containing the
biniou representation of a binary tree. In the same program
we will also demonstrate how to render biniou data into text from an
OCaml program.

Here is the ATD file defining our tree type:

    $ cat tree.atd
    type tree =
        [ Empty
        | Node of (tree * int * int tree) ]

This is our OCaml program:

    $ cat tree.ml
    open Printf
    
    (* sample value *)
    let tree : Tree_t.tree =
      `Node (
        `Node (`Empty, 1, `Empty),
        2,
        `Node (
          `Node (`Empty, 3, `Empty),
          4,
          `Node (`Empty, 5, `Empty)
        )
      )
    
    let () =
      (* write sample value to file *)
      let fname = "tree.dat" in
      Ag_util.Biniou.to_file Tree_b.write_tree fname tree;
    
      (* write sample value to string *)
      let s = Tree_b.string_of_tree tree in
      printf "raw value (saved as %s):\n%S\n" fname s;
      printf "length: %i\n" (String.length s);
    
      printf "pretty-printed value (without dictionary):\n";
      print_endline (Bi_io.view s);
    
      printf "pretty-printed value (with dictionary):\n";
      let unhash = Bi_io.make_unhash ["Empty"; "Node"; "foo"; "bar" ] in
      print_endline (Bi_io.view ~unhash s)

Compilation:

    $ atdgen -t tree.atd
    $ atdgen -b tree.atd
    $ ocamlfind ocamlopt -o tree \
        tree_t.mli tree_t.ml tree_b.mli tree_b.ml tree.ml \
        -package atdgen -linkpkg

Running the program:

    $ ./tree
    raw value (saved as tree.dat):
    "\023\179\2276\"\020\003\023\179\2276\"\020\003\023\003\007\170m\017\002\023\003\007\170m\017\004\023\179\2276\"\020\003\023\179\2276\"\020\003\023\003\007\170m\017\006\023\003\007\170m\017\b\023\179\2276\"\020\003\023\003\007\170m\017\n\023\003\007\170m"
    length: 75
    pretty-printed value (without dictionary):
    <#33e33622:
       (<#33e33622: (<#0307aa6d>, 1, <#0307aa6d>)>,
        2,
        <#33e33622:
           (<#33e33622: (<#0307aa6d>, 3, <#0307aa6d>)>,
            4,
            <#33e33622: (<#0307aa6d>, 5, <#0307aa6d>)>)>)>
    pretty-printed value (with dictionary):
    <"Node":
       (<"Node": (<"Empty">, 1, <"Empty">)>,
        2,
        <"Node":
           (<"Node": (<"Empty">, 3, <"Empty">)>,
            4,
            <"Node": (<"Empty">, 5, <"Empty">)>)>)>

Now let's see how to pretty-print any biniou data from the command line.
Our sample data are now in file `tree.dat`:

    $ ls -l tree.dat
    -rw-r--r-- 1 martin martin 75 Apr 17 01:46 tree.dat

We use the command `bdump` to render our sample biniou data as text:

    $ bdump tree.dat
    <#33e33622:
       (<#33e33622: (<#0307aa6d>, 1, <#0307aa6d>)>,
        2,
        <#33e33622:
           (<#33e33622: (<#0307aa6d>, 3, <#0307aa6d>)>,
            4,
            <#33e33622: (<#0307aa6d>, 5, <#0307aa6d>)>)>)>

We got hashes for the variant names `Empty` and `Node`.
Let's add them to the dictionary:

    $ bdump -w Empty,Node tree.dat
    <"Node":
       (<"Node": (<"Empty">, 1, <"Empty">)>,
        2,
        <"Node":
           (<"Node": (<"Empty">, 3, <"Empty">)>,
            4,
            <"Node": (<"Empty">, 5, <"Empty">)>)>)>

`bdump` remembers the dictionary so we don't have to pass the 
`-w` option anymore (for this user on this machine).
The following now works:

    $ bdump tree.dat
    <"Node":
       (<"Node": (<"Empty">, 1, <"Empty">)>,
        2,
        <"Node":
           (<"Node": (<"Empty">, 3, <"Empty">)>,
            4,
            <"Node": (<"Empty">, 5, <"Empty">)>)>)>


# Optional fields and default values

Although OCaml records do not support optional fields, both the JSON
and biniou formats make it possible to omit certain fields on a
per-record basis.

For example the JSON record `{ "x": 0, "y": 0 }` can be more
compactly written as `{}` if the reader knows the default values for
the missing fields `x` and `y`. Here is the corresponding type
definition:

    type vector_v1 = { ~x: int; ~y: int }

`~x` means that field `x` supports a default value. Since we do not
specify the default value ourselves, the built-in default is used,
which is 0.

If we want the default to be something else than 0, we just have to
specify it as follows:

    type vector_v2 = {
      ~x <ocaml default="1">: int; (* default x is 1 *)
      ~y: int;                     (* default y is 0 *)
    }

It is also possible to specify optional fields without a default
value. For example, let's add an optional `z` field:

    type vector_v3 = {
      ~x: int;
      ~y: int;
      ?z: int option;
    }

The following two examples are valid JSON representations of data of
type `vector_v3`:

    { "x": 2, "y": 2, "z": 3 }  // OCaml: { x = 2; y = 2; z = Some 3 }

    { "x": 2, "y": 2 }          // OCaml: { x = 2; y = 2; z = None }

For a variety of good reasons JSON's `null` value may not be used to
indicate that a field is undefined.
Therefore the following JSON data cannot be read as a record of type
`vector_v3`:

    { "x": 2, "y": 2, "z": null }  // invalid value for field z


Note also the difference between `?z: int option` and `~z: int
option`:

    type vector_v4 = {
      ~x: int;
      ~y: int;
      ~z: int option;  (* no unwrapping of the JSON field value! *)
    }

Here are valid values of type `vector_v4`, showing that it is usually
not what is intended:

    { "x": 2, "y": 2, "z": [ "Some", 3 ] }

    { "x": 2, "y": 2, "z": "None" }

    { "x": 2, "y": 2 }


# Smooth protocol upgrades

Problem: you have a production system that uses a specific
JSON or biniou format. It may be data files or a client-server
pair. You now want to add a field to a record type or to add a case to
a variant type.

Both JSON and biniou allow extra record fields. If the
consumer does not know how to deal with the extra field, the default
behavior is to happily ignore it.


## Adding or removing an optional record field

    type before = {
      x: int;
      y: int;
    }

    type after = {
      x: int;
      y: int;
      ~z: int;
    }

* upgrade producers and consumers in any order
* converting old data is not required nor useful

## Adding a required record field

    type before = {
      x: int;
      y: int;
    }

    type after = {
      x: int;
      y: int;
      z: int;
    }

* upgrade all producers before the consumers
* converting old data requires special-purpose hand-written code

## Removing a required record field

* upgrade all consumers before the producers
* converting old data is not required but may save some storage space
  (just read and re-write each record using the new type)

## Adding a variant case

    type before = [ A | B ]

    type after = [ A | B | C ]

* upgrade all consumers before the producers
* converting old data is not required and would have no effect

## Removing a variant case

* upgrade all producers before the consumers
* converting old data requires special-purpose hand-written code

## Avoiding future problems

* In doubt, use records rather than tuples because it makes it
  possible to add or remove any field or to reorder them.
* Do not hesitate to create variant types with only one case or
  records with only one field if you think they might be extended
  later.


# Data validation

# Referring to type definitions from an other ATD file

# Integration with ocamldoc
