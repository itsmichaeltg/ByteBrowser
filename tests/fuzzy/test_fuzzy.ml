open! Core
open! File_manager_lib

let print t = 
  Visualize_helper.visualize
t
~current_directory:"/home/ubuntu/jsip-final-project"
~path_to_be_underlined:"/home/ubuntu/jsip-final-project"
~matrix_info:(Matrix.Info.create ())
~show_reduced_tree:false
~paths_to_collapse:String.Set.empty
~show_relative_dirs:false
~box_dimension:5
~show_hidden_files:false
|> print_endline;;
let%expect_test "fzf" =
  let t =
    Matrix.get_adjacency_matrix
      (Matrix.create ())
      ~sort:false
      ~show_hidden:false
      ~origin:"/home/ubuntu/jsip-final-project"
      ~max_depth:1
  in
  print t;
  let t = t |> Matrix.filter ~search:"test" in
  print t;
  [%expect {|
    [0m>>  [48;5;17m[3m.[23m                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m|__ [;0;48;5;17;4;2;38;5;49;1mjsip-final-project                                                                                  [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;124mREADME.md                                                                                         [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1m_build                                                                                            [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17mbb                                                                                                [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mbin                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17mdemo.cast                                                                                         [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mdemos                                                                                             [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17mdune-project                                                                                      [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;130mfile_manager_lib.opam                                                                             [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mlib                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;124mlog.txt                                                                                           [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1msrc                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mtest_dir                                                                                          [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mtests                                                                                             [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17mtmp                                                                                               [0m  <<
    [0m

    [0m>>  [48;5;17m[3m.[23m                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m|__ [;0;48;5;17;4;2;38;5;49;1mjsip-final-project                                                                                  [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mtest_dir                                                                                          [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mtests                                                                                             [0m  <<
    [0m
    |}]
;;

let%expect_test "vt" =
  let mat = Matrix.t_of_sexp
    (Sexp.of_string
       {|((/home/ubuntu/jsip-final-project(/home/ubuntu/jsip-final-project/file_manager_lib.opam /home/ubuntu/jsip-final-project/lib))(/home/ubuntu/jsip-final-project/lib(/home/ubuntu/jsip-final-project/lib/minttea /home/ubuntu/jsip-final-project/lib/riot /home/ubuntu/jsip-final-project/lib/terminal_size))(/home/ubuntu/jsip-final-project/lib/minttea())(/home/ubuntu/jsip-final-project/lib/riot())(/home/ubuntu/jsip-final-project/lib/terminal_size()))|}) in
       Visualize_helper.visualize
       mat
       ~current_directory:"/home/ubuntu/jsip-final-project"
       ~path_to_be_underlined:"/home/ubuntu/jsip-final-project"
       ~matrix_info:(Matrix.Info.create ())
       ~show_reduced_tree:false
        ~paths_to_collapse:String.Set.empty
        ~show_relative_dirs:false
        ~box_dimension:5
        ~show_hidden_files:false |> print_endline;
  [%expect {|
    [0m>>  [48;5;17m[3m.[23m                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m|__ [;0;48;5;17;4;2;38;5;49;1mjsip-final-project                                                                                  [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;130mfile_manager_lib.opam                                                                             [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mlib                                                                                               [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mminttea                                                                                         [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mriot                                                                                            [0m  <<
    [0m>>  [0m[0;48;5;17m  [0;48;5;17m  [0;48;5;17m|__ [;0;48;5;17;38;5;49;1mterminal_size                                                                                   [0m  <<
    [0m
    |}]     
;;