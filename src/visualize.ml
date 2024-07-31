open! Core

module Adjacency_matrix = struct
  type tree = (string, string list) Hashtbl.t [@@deriving sexp_of]
  type t = { matrix : tree } [@@deriving sexp_of]

  let create () = { matrix = Hashtbl.create (module String) }

  let is_directory t (value : string) =
    Hashtbl.mem t.matrix value
  ;;

  let get_files_in_dir origin : string list =
    try Sys_unix.ls_dir origin with _ -> []
  ;;

  let rec get_adjacency_matrix t ~origin ~max_depth =
    match max_depth with
    | 0 ->
      (match Sys_unix.is_directory origin with
       | `Yes -> Hashtbl.add_exn t.matrix ~key:origin ~data:[]
       | _ -> ());
      t
    | _ ->
      let data =
        List.map (get_files_in_dir origin) ~f:(fun i -> String.concat [ origin; "/"; i ])
      in
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i ->
        match Sys_unix.is_directory i with
        | `Yes -> get_adjacency_matrix t ~origin:i ~max_depth:(max_depth - 1)
        | _ -> get_adjacency_matrix t ~origin:i ~max_depth:0)
  ;;

  let rec get_limited_adjacency_matrix t ~origin ~max_depth ~num_to_show =
    match max_depth with
    | 0 ->
      (match Sys_unix.is_directory origin with
       | `Yes -> Hashtbl.add_exn t.matrix ~key:origin ~data:[]
       | _ -> ());
      t
    | _ ->
      let children = get_files_in_dir origin in
      let limited_children =
        List.slice children 0 (Int.min num_to_show (List.length children))
      in
      let data =
        List.map limited_children ~f:(fun i -> String.concat [ origin; "/"; i ])
      in
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i ->
        match Sys_unix.is_directory i with
        | `Yes ->
          get_limited_adjacency_matrix
            t
            ~origin:i
            ~max_depth:(max_depth - 1)
            ~num_to_show
        | _ ->
          get_limited_adjacency_matrix t ~origin:i ~max_depth:0 ~num_to_show)
  ;;
end

let print_dir (tree : Adjacency_matrix.t) ~origin =
  Visualize_helper.visualize
    tree.matrix
    ~current_directory:origin
    ~path_to_be_underlined:""
;;

let visualize ~max_depth ~origin =
  let matrix =
    Adjacency_matrix.create ()
    |> Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
  in
  print_dir ~origin matrix |> print_endline
;;

let pwd_visualize_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"starts at the current working directory"
    [%map_open
      let max_depth =
        flag
          "max-depth"
          (optional_with_default 3 int)
          ~doc:"INT maximum length of path to search for (default 10)"
      in
      fun () -> visualize ~max_depth ~origin:(Sys_unix.getcwd ())]
;;

let start_visualize_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"starts at a given path"
    [%map_open
      let origin = flag "start" (required string) ~doc:" the starting path"
      and max_depth =
        flag
          "max-depth"
          (optional_with_default 3 int)
          ~doc:"INT maximum length of path to search for (default 10)"
      in
      fun () -> visualize ~max_depth ~origin]
;;

let command =
  Command.group
    ~summary:"file manager commands"
    [ "pwd", pwd_visualize_command; "dir", start_visualize_command ]
;;
