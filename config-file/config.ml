let param_template = {
  Config_v.name = "foo";
  key = "0123456789abcdef"
}

let config_template =
  Config_v.create_config ~title:"" ~credentials: [param_template] ()

let make_json_template () =
  (* thanks to the -j-defaults flag passed to atdgen, even default
     fields will be printed out *)
  let compact_json = Config_j.string_of_config config_template in
  Yojson.Safe.prettify compact_json

let () = print_endline (make_json_template ())
