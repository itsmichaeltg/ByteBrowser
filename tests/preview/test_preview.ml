open! Core
open! File_manager_lib

let%expect_test "preview" =
  let file = "/home/ubuntu/jsip-final-project/bin/main.ml" in
  let num_lines = 100 in
  print_endline (Preview.preview file ~num_lines);
  [%expect {|
    [0m>>  [0;22;3;4;48;5;23;38;5;118mviewing main.ml                                                                                     [0m  <<
    [0m>>  [38;5;15m                                                                                                    [39m[0m  <<
    [0m>>  [38;5;81mopen[39m[38;5;204m![39m[38;5;15m [39m[38;5;148mCore[39m[38;5;15m                                                                                          [39m[0m  <<
    [0m>>  [38;5;81mopen[39m[38;5;204m![39m[38;5;15m [39m[38;5;148mFile_manager_lib[39m[38;5;15m                                                                              [39m[0m  <<
    [0m>>  [38;5;15m                                                                                                    [39m[0m  <<
    [0m>>  [38;5;81mlet[39m[38;5;15m [39m[38;5;15m()[39m[38;5;15m [39m[38;5;204m=[39m[38;5;15m [39m[38;5;15mCommand_unix[39m[38;5;15m.[39m[38;5;15mrun[39m[38;5;15m [39m[38;5;15mNavigate[39m[38;5;15m.[39m[38;5;15mcommand[39m[38;5;15m                                                          [39m[0m  <<[0m
    |}]
;;
