open! Core

module Adjacency_matrix = struct
  type t = {
    matrix : (string, string list) Hashtbl.t
  }[@@deriving sexp_of]

  let create () = {matrix = Hashtbl.create (module String)};;

  let get_files_in_dir origin : string list = Sys_unix.ls_dir origin;;

  let%expect_test "files_in_dir" = 
    print_s[%sexp (get_files_in_dir ("/home/ubuntu/jsip-final-project"):string list)];
    [%expect {|(src .git jsip_final_project.opam test README.md lib dune-project _build bin)|}]
  ;;

  let rec get_adjacency_matrix t ~origin ~max_depth = 
    match max_depth with
    | 0 -> t
    | _ -> 
      let data = get_files_in_dir origin in 
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i -> 
        let new_path = String.concat [origin; "/"; i] in 
        match Sys_unix.is_directory new_path with 
      | `Yes -> get_adjacency_matrix t ~origin:new_path ~max_depth:(max_depth - 1)
      | _ -> get_adjacency_matrix t ~origin ~max_depth:0)
  ;;

  let%expect_test ("adjacency_matrix" [@tags "disabled"]) = 
    print_s[%sexp ((get_adjacency_matrix (create ()) ~origin:"/home/ubuntu/jsip-final-project" ~max_depth:2):t)];
    [%expect {|
    ((matrix
      ((/home/ubuntu/jsip-final-project
        (src .git jsip_final_project.opam test README.md lib dune-project _build
         bin))
       (/home/ubuntu/jsip-final-project/.git
        (COMMIT_EDITMSG index description HEAD config branches ORIG_HEAD hooks
         logs info objects FETCH_HEAD refs packed-refs))
       (/home/ubuntu/jsip-final-project/_build
        (.promotion-staging log install .lock default .digest-db .to-promote .db
         .sandbox .actions .filesystem-clock))
       (/home/ubuntu/jsip-final-project/bin (dune main.ml))
       (/home/ubuntu/jsip-final-project/lib (dune))
       (/home/ubuntu/jsip-final-project/src (dune main.mli main.ml))
       (/home/ubuntu/jsip-final-project/test (dune test_jsip_final_project.ml)))))
    |}]
  ;;
end

let get_name path = 
  match String.contains path '/' with
  | false -> path 
  | true -> List.last_exn (String.split path ~on:'/') ;;

let%expect_test "get_name" = 
  print_endline (get_name "/home/ubuntu/jsip-final-project");
  print_endline (get_name "dune-project"); 
  [%expect {|
    jsip-final-project
    dune-project
    |}]
;;

let print_dir map : unit = () ;;

let visualize ~max_depth ~origin = 
  let matrix = Adjacency_matrix.create () in
  Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth matrix
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
        visualize ~max_depth ~origin:(Sys_unix.getcwd ());]
;;
 
let command =
  Command.group
    ~summary:"directory manager commands"
    ["visualize", visualize_command]
;;