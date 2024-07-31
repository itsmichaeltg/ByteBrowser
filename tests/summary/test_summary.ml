open! Core
open! File_manager_lib

(* let%expect_test "summary" =
  let origin = "/home/ubuntu/jsip-final-project/src" in
  let tree = Visualize.Adjacency_matrix.create () |> Visualize.Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth:100 in
  let result = Summary.generate tree.matrix origin in
  print_endline result;
  [%expect {||}] *)