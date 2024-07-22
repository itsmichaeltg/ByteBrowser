open! Core

module Adjacency_matrix = struct
  type t = {
    matrix : (string, string list) Hashtbl.t
  }[@@deriving sexp_of]

  let create () = {matrix = Hashtbl.create (module String)};;

  let get_files_in_dir origin : string list = Sys_unix.ls_dir origin;;

  let%expect_test "files_in_dir" = 
    print_s[%sexp (get_files_in_dir ("/home/ubuntu/test_dir"):string list)];
    [%expect {|
<<<<<<< HEAD
    (dir1)|}]
=======
    (src .git jsip_final_project.opam test dune-project _build .gitignore bin)|}]
>>>>>>> f1c05e977ad2608d5dfbc59ec275c2006f0d1a0d
  ;;

  let rec get_adjacency_matrix t ~origin ~max_depth = 
    match max_depth with
    | 0 -> t
    | _ -> 
      let data = List.map (get_files_in_dir origin) ~f:(fun i -> String.concat [origin; "/"; i]) in 
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i -> 
        match Sys_unix.is_directory i with 
      | `Yes -> get_adjacency_matrix t ~origin:i ~max_depth:(max_depth - 1)
      | _ -> get_adjacency_matrix t ~origin ~max_depth:0)
  ;;

  let%expect_test ("adjacency_matrix" ) = 
    print_s[%sexp ((get_adjacency_matrix (create ()) ~origin:"/home/ubuntu/test_dir" ~max_depth:10):t)];
    [%expect {|
      ((matrix
        ((/home/ubuntu/test_dir (/home/ubuntu/test_dir/dir1))
         (/home/ubuntu/test_dir/dir1 (/home/ubuntu/test_dir/dir1/dir2))
         (/home/ubuntu/test_dir/dir1/dir2 (/home/ubuntu/test_dir/dir1/dir2/dir3))
         (/home/ubuntu/test_dir/dir1/dir2/dir3
          (/home/ubuntu/test_dir/dir1/dir2/dir3/dir4))
         (/home/ubuntu/test_dir/dir1/dir2/dir3/dir4
          (/home/ubuntu/test_dir/dir1/dir2/dir3/dir4/tmp.txt))))) |}]
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

let print_dir (tree:Adjacency_matrix.t) ~origin = Visualize.visualize tree.matrix ~current_directory:origin;;

let visualize ~max_depth ~origin = 
  let matrix = Adjacency_matrix.create () |> Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth in
  print_dir ~origin matrix |> print_endline;
;;

let%expect_test "visualize" = 
  visualize ~max_depth:10 ~origin:"/home/ubuntu/test_dir";
  [%expect "
    .
    |--> test_dir
      |--> dir1
        |--> dir2
          |--> dir3
            |--> dir4
              |--> tmp.txt"]
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