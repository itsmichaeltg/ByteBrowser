open! Core
open! File_manager_lib

let%expect_test "summary" =
  let origin = "/home/ubuntu/jsip-final-project/src" in
  let tree = Visualize.Adjacency_matrix.create () |> Visualize.Adjacency_matrix.get_adjacency_matrix ~sort:true ~show_hidden:false ~origin ~max_depth:100 in
  let summary = Summary.generate tree.matrix origin in
  let result = Querying.query "q: what does the visualize helper do exactly?" ~info:summary in
  print_endline result;
  [%expect {||}]