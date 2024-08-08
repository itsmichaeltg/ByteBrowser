(* open! Core
open! File_manager_lib

let%expect_test "summary" =
  let origin = "/home/ubuntu/jsip-final-project/src" in
  let tree = Matrix.create () |> Matrix.get_adjacency_matrix ~sort:true ~show_hidden:false ~origin ~max_depth:100 in
  let summary = Summary.generate tree origin in
  let result = Querying.query "q: what does the visualize helper do exactly?" ~info:summary in
  print_endline result;
<<<<<<< HEAD
  [%expect {|
    q: what does the visualize helper do exactly?

    The `visualize_helper.ml` file contains helper functions for visualizing the directory structure, styling, and formatting the output to present the file hierarchy visually.
    |}] *)
=======
  [%expect {||}] *)
>>>>>>> 20b2a3078370b96e8c8bde901e07696ebbaa6094
