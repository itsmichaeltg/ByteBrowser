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
    [%expect {| (dir0 dir1 dir5) |}]
  ;;

  let format_str ~origin i =
    match String.equal (List.last_exn (String.split origin ~on:'/')) "" with
    | true -> String.concat [ origin; i ]
    | false -> String.concat [ origin; "/"; i ]
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
        List.map (get_files_in_dir origin) ~f:(fun i -> format_str ~origin i)
      in
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i ->
        match Sys_unix.is_directory i with
        | `Yes -> get_adjacency_matrix t ~origin:i ~max_depth:(max_depth - 1)
        | _ -> get_adjacency_matrix t ~origin:i ~max_depth:0)
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
          (/home/ubuntu/jsip-final-project/test_dir/dir0
           /home/ubuntu/jsip-final-project/test_dir/dir1
           /home/ubuntu/jsip-final-project/test_dir/dir5))
         (/home/ubuntu/jsip-final-project/test_dir/dir0 ())
         (/home/ubuntu/jsip-final-project/test_dir/dir1
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2))
         (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3))
         (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4))
         (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4
          (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4/tmp.txt))
         (/home/ubuntu/jsip-final-project/test_dir/dir5 ()))))
      |}]
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

let%expect_test "visualize" =
  visualize ~max_depth:10 ~origin:"/home/ubuntu/jsip-final-project/test_dir";
  [%expect
    " \n\
    \ .\n\
    \ \027[0m\027[0m|__ \240\159\147\129\027[;0;36mtest_dir\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mdir0\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mdir1\n\
    \ \027[0m    \027[0m|__ \240\159\147\129\027[;0;36mdir2\n\
    \ \027[0m      \027[0m|__ \240\159\147\129\027[;0;36mdir3\n\
    \ \027[0m        \027[0m|__ \240\159\147\129\027[;0;36mdir4\n\
    \ \027[0m          \027[0m|__ \027[;0mtmp.txt\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mdir5\n\
    \ "]
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
