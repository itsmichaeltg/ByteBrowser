open! Core
open! File_manager_lib

let%expect_test "preview" =
  let file = "/home/ubuntu/jsip-final-project/bin/main.ml" in
  let num_lines = 100 in
  print_endline (Preview.preview file ~num_lines);
  [%expect {|
    [;0;48;5;129mviewing main.ml

    [0m>>open! Core                                                                                          [0m<<
    [0m>>open! File_manager_lib                                                                              [0m<<
    [0m>>                                                                                                    [0m<<
    [0m>>let () = Command_unix.run Navigate.command                                                          [0m<<[0m
    |}]
;;
