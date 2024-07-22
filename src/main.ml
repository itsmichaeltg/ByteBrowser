open! Core

module Adjacency_matrix = struct
  type t = {
    matrix : (string, string list) Hashtbl.t
  }[@@deriving sexp_of]

  let create () = {matrix = Hashtbl.create (module String)};;

  let get_files_in_dir origin : string list = [] ;;

  let rec get_adjacency_matrix ~origin ~max_depth ~matrix = 
    match max_depth with
    | 0 -> matrix
    | _ -> 
      let data = get_files_in_dir origin in 
      Hashtbl.add_exn ~key:origin ~data 
  ;;
end

let print_dir map : unit = () ;;

let visualize ~max_depth ~origin = 

  get_adjacency_matrix ~origin ~max_depth ~matrix:
  |> print_dir;
;;

let visualize_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:
      "build directory tree"
    [%map_open
      let origin = flag "origin" (required string) ~doc:" the starting directory"
      and max_depth =
        flag
          "max-depth"
          (optional_with_default 10 int)
          ~doc:"INT maximum length of path to search for (default 10)"
      in
      fun () ->
        visualize ~max_depth ~origin ~output_file ~how_to_fetch ();]
;;
 
let command =
  Command.group
    ~summary:"directory manager commands"
    ["visualize", visualize_command]
;;