open! Core
open! File_manager_lib

let%expect_test "preview" =
  let file = "/home/ubuntu/jsip-final-project/bin/main.ml" in
  let num_lines = 100 in
  print_endline (Preview.preview file ~num_lines);
  [%expect
    {|
    open! Core
    open! File_manager_lib

    let () = Command_unix.run File_manager.command
    |}]
;;
