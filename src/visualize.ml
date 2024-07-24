open! Core

module Adjacency_matrix = struct
  type t = { matrix : (string, string list) Hashtbl.t } [@@deriving sexp_of]

  let create () = { matrix = Hashtbl.create (module String) }
  let get_files_in_dir origin : string list =
    try Sys_unix.ls_dir origin with _ -> []
  ;;

  let%expect_test "files_in_dir" =
    print_s
      [%sexp
        (get_files_in_dir "/home/ubuntu/jsip-final-project/test_dir"
         : string list)];
    [%expect {| (dir1) |}]
  ;;

  let rec get_adjacency_matrix t ~origin ~max_depth =
    match max_depth with
    | 0 -> t
    | _ ->
      let data =
        List.map (get_files_in_dir origin) ~f:(fun i ->
          String.concat [ origin; "/"; i ])
      in
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i ->
        match Sys_unix.is_directory i with
        | `Yes -> get_adjacency_matrix t ~origin:i ~max_depth:(max_depth - 1)
        | _ -> get_adjacency_matrix t ~origin ~max_depth:0)
  ;;

  let%expect_test "adjacency_matrix" =
    print_s
      [%sexp
        (get_adjacency_matrix
           (create ())
           ~origin:"/home/ubuntu/jsip-final-project/test_dir"
           ~max_depth:10
         : t)];
    [%expect
      {|
      ((matrix
        ((/home/ubuntu/jsip-final-project/test_dir
          (/home/ubuntu/jsip-final-project/test_dir/dir1))
         (/home/ubuntu/jsip-final-project/test_dir/dir1
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2))
         (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3))
         (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4))
         (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4/tmp.txt)))))
      |}]
  ;;
end

let print_dir (tree : Adjacency_matrix.t) ~origin =
  Visualize_helper.visualize tree.matrix ~current_directory:origin ~path_to_be_underlined:""
;;

let visualize ~max_depth ~origin =
  let matrix =
    Adjacency_matrix.create ()
    |> Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
  in
  print_dir ~origin matrix |> print_endline
;;

let%expect_test "visualize" =
  visualize ~max_depth:10 ~origin:"/home/ubuntu/jsip-final-project/test_dir";
  [%expect
    " 
 .
 |__ \240\159\147\129test_dir
   |__ \240\159\147\129dir1
     |__ \240\159\147\129dir2
       |__ \240\159\147\129dir3
         |__ \240\159\147\129dir4
           |__ tmp.txt
 "]
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
