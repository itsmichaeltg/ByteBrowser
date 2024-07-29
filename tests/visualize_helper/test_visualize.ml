open! Core
open! File_manager_lib

let%expect_test "visualize" =
  let mat = Hashtbl.create (module String) in
  Hashtbl.add_exn mat ~key:"home" ~data:[ "home_dir1"; "home_dir2" ];
  Hashtbl.add_exn mat ~key:"home_dir1" ~data:[ "child1"; "child2" ];
  Hashtbl.add_exn mat ~key:"home_dir2" ~data:[];
  Hashtbl.add_exn mat ~key:"child1" ~data:[ ".gitignore"; "blah" ];
  let res =
    Visualize_helper.visualize
      mat
      ~current_directory:"home"
      ~path_to_be_underlined:".gitignore"
  in
  print_endline res;
  [%expect
    {|
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;4;35m.gitignore
    [0m      [0m|__ [;0mblah
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    |}]
;;

let%expect_test "path_to_be_underlined" =
  let mat = Hashtbl.create (module String) in
  Hashtbl.add_exn mat ~key:"home" ~data:[ "home_dir1"; "home_dir2" ];
  Hashtbl.add_exn mat ~key:"home_dir1" ~data:[ "child1"; "child2" ];
  Hashtbl.add_exn mat ~key:"home_dir2" ~data:[];
  Hashtbl.add_exn mat ~key:"child1" ~data:[ ".gitignore"; "blah" ];
  let res =
    Visualize_helper.visualize
      mat
      ~current_directory:"home"
      ~path_to_be_underlined:"home_dir1"
  in
  print_endline res;
  [%expect
    {|
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;4;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m      [0m|__ [;0mblah
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    |}]
;;