(* open! Core
open! File_manager_lib

let%expect_test "adjacency_matrix" =
  print_s
    [%sexp
      (Matrix.get_adjacency_matrix
         (Matrix.create ())
         ~origin:"/home/ubuntu/jsip-final-project/test_dir"
         ~max_depth:10
         ~sort:false
         ~show_hidden:false
       : Matrix.t)];
  [%expect
    {|
      ((/home/ubuntu/jsip-final-project/test_dir
        (/home/ubuntu/jsip-final-project/test_dir/dir0
         /home/ubuntu/jsip-final-project/test_dir/dir1
         /home/ubuntu/jsip-final-project/test_dir/dir5))
       (/home/ubuntu/jsip-final-project/test_dir/dir0 ())
       (/home/ubuntu/jsip-final-project/test_dir/dir1
        (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2))
       (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2
        (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3))
       (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3
        (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4))
       (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4
        (/home/ubuntu/jsip-final-project/test_dir/dir1/dir2/dir3/dir4/tmp.txt))
       (/home/ubuntu/jsip-final-project/test_dir/dir5 ()))
    |}]
;;

(* let%expect_test "visualize" =
  Visualize_helper.matrix_visualize
    ~max_depth:10
    ~origin:"/home/ubuntu/jsip-final-project/test_dir"
    ~show_hidden:false
    ~sort:false;
  [%expect
    " \n\
    \ .\n\
    \ \027[0m\027[0m|__ \240\159\147\129\027[;0;36mtest_dir\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mdir0\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mdir1\n\
    \ \027[0m    \027[0m|__ \240\159\147\129\027[;0;36mdir2\n\
    \ \027[0m      \027[0m|__ \240\159\147\129\027[;0;36mdir3\n\
    \ \027[0m        \027[0m|__ \240\159\147\129\027[;0;36mdir4\n\
    \ \027[0m          \027[0m|__ \027[;0mtmp.txt\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mdir5\n\
    \ "]
;;
*)
*)