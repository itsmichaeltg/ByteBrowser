open! Core
open! File_manager_lib

let%expect_test "navigate-left" =
  let file = "/home/ubuntu/jsip-final-project/bin/main.ml" in
  let num_lines = 5 in
  print_endline (Preview.preview file ~num_lines);
  [%expect
    {|
    |}]
;;
