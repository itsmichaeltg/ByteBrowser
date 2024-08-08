open! Core
open! File_manager_lib

let%expect_test "visualize" =
  let mat = Matrix.create () in
  Matrix.add_exn mat ~key:"/home" ~data:[ "home_dir1"; "home_dir2" ];
  Matrix.add_exn mat ~key:"home_dir1" ~data:[ "child1"; "child2.ml" ];
  Matrix.add_exn mat ~key:"home_dir2" ~data:["file1"; "file2"];
  Matrix.add_exn mat ~key:"child1" ~data:[ ".gitignore"; "blah.py" ];
  let info = Matrix.Info.create () in
  Matrix.fill_info_from_matrix mat ~info_map:info ~current_path:"/home";
  print_s [%message (info : Matrix.Info.t)];