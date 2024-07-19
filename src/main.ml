open! Core
open! Unix

let get_files_in_dir origin :string list = [] ;;

let rec get_adjacency_matrix ~origin ~max_depth ~map = 
  match max_depth with
  | 0 -> map
  | _ -> 
    let data = get_files_in_dir origin in 
    List.fold data ~init:(String.Map.create ()) 
    ~f:(fun file -> Map.add_exn map ~key:origin ~data 
  |> get_adjacency_matrix ~origin:file ~max_depth:(max_depth - 1)); 
;;

let print_dir map : unit = () ;;

let visualize ~max_depth ~origin = 
  get_adjacency_matrix ~origin ~max_depth ~map:Map.Make(module String) 
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