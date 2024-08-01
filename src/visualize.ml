open! Core

module Adjacency_matrix = struct
  type tree = (string, string list) Hashtbl.t [@@deriving sexp_of]
  type t = { matrix : tree } [@@deriving sexp_of]

  let create () = { matrix = Hashtbl.create (module String) }
  let is_directory t (value : string) = Hashtbl.mem t.matrix value
  let hidden str = Char.equal (String.nget str 0) '.'

  let get_name path =
    match String.contains path '/' with
    | false -> path
    | true -> List.last_exn (String.split path ~on:'/')
  ;;

  let is_directory t (value : string) =
    Hashtbl.mem t.matrix value
  ;;

  let get_children (t : tree) path = Hashtbl.find t path

  let write_and_read origin =
    let write_path = "/home/ubuntu/jsip-final-project/bin/files.txt" in
    let _ =
      Format.sprintf "ls -t %s > %s" origin write_path |> Sys_unix.command
    in
    In_channel.read_lines write_path
  ;;

  let get_files_in_dir origin ~show_hidden ~sort =
    let data =
      if not sort
      then (try Sys_unix.ls_dir origin with _ -> [])
      else write_and_read origin
    in
    if show_hidden
    then data
    else List.filter data ~f:(fun i -> hidden i |> not)
  ;;

  let rec get_adjacency_matrix t ~sort ~show_hidden ~origin ~max_depth =
    match max_depth with
    | 0 ->
      (match Sys_unix.is_directory origin with
       | `Yes -> Hashtbl.add_exn t.matrix ~key:origin ~data:[]
       | _ -> ());
      t
    | _ ->
      let data =
        List.map (get_files_in_dir origin ~show_hidden ~sort) ~f:(fun i ->
          String.concat [ origin; "/"; i ])
      in
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i ->
        match Sys_unix.is_directory i with
        | `Yes ->
          get_adjacency_matrix
            t
            ~origin:i
            ~max_depth:(max_depth - 1)
            ~show_hidden
            ~sort
        | _ ->
          get_adjacency_matrix t ~origin:i ~max_depth:0 ~show_hidden ~sort)
  ;;

  let rec get_limited_adjacency_matrix
    t
    ~sort
    ~show_hidden
    ~origin
    ~max_depth
    ~num_to_show
    =
    match max_depth with
    | 0 ->
      (match Sys_unix.is_directory origin with
       | `Yes -> Hashtbl.add_exn t.matrix ~key:origin ~data:[]
       | _ -> ());
      t
    | _ ->
      let children = get_files_in_dir origin ~show_hidden ~sort in
      let limited_children =
        List.slice children 0 (Int.min num_to_show (List.length children))
      in
      let data =
        List.map limited_children ~f:(fun i ->
          String.concat [ origin; "/"; i ])
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
            ~show_hidden
            ~sort
        | _ ->
          get_limited_adjacency_matrix
            t
            ~origin:i
            ~max_depth:0
            ~num_to_show
            ~show_hidden
            ~sort)
  ;;
end

let print_dir (tree : Adjacency_matrix.t) ~origin =
  Visualize_helper.visualize
    tree.matrix
    ~current_directory:origin
    ~path_to_be_underlined:""
;;

let visualize ~max_depth ~origin ~show_hidden ~sort =
  let matrix =
    Adjacency_matrix.create ()
    |> Adjacency_matrix.get_adjacency_matrix
         ~origin
         ~max_depth
         ~show_hidden
         ~sort
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
      and show_hidden =
        flag
          "show-hidden"
          (optional_with_default false bool)
          ~doc:"(default false)"
      and sort =
        flag "sort" (optional_with_default false bool) ~doc:"(default false)"
      in
      fun () ->
        visualize ~max_depth ~origin:(Sys_unix.getcwd ()) ~show_hidden ~sort]
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
      and show_hidden =
        flag
          "show-hidden"
          (optional_with_default false bool)
          ~doc:"(default false)"
      and sort =
        flag "sort" (optional_with_default false bool) ~doc:"(default false)"
      in
      fun () -> visualize ~max_depth ~origin ~show_hidden ~sort]
;;

let command =
  Command.group
    ~summary:"file manager commands"
    [ "pwd", pwd_visualize_command; "dir", start_visualize_command ]
;;
