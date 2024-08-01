open! Core
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

let%expect_test "visualize" =
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

let%expect_test "get limited children to tree" =
  let initial_tree = Matrix.create () in
  let origin, num_to_show, max_depth =
    "/home/ubuntu/jsip-final-project", 3, 100
  in
  let result =
    Matrix.get_limited_adjacency_matrix
      initial_tree
      ~origin
      ~num_to_show
      ~max_depth
      ~sort:false
      ~show_hidden:false
  in
  print_endline
    (Visualize_helper.visualize
       result
       ~current_directory:origin
       ~path_to_be_underlined:origin);
  [%expect
    " \n\
    \ .\n\
    \ \027[0m\027[0m|__ \240\159\147\129\027[;0;4;36mjsip-final-project\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36msrc\n\
    \ \027[0m    \027[0m|__ \027[;0mpreview.ml\n\
    \ \027[0m    \027[0m|__ \027[;0mvisualize_helper.mli\n\
    \ \027[0m    \027[0m|__ \027[;0msummary.mli\n\
    \ \027[0m  \027[0m|__ \240\159\147\129\027[;0;36mtests\n\
    \ \027[0m    \027[0m|__ \240\159\147\129\027[;0;36mvisualize_helper\n\
    \ \027[0m      \027[0m|__ \027[;0mtest_visualize_helper.ml\n\
    \ \027[0m      \027[0m|__ \027[;0mdune\n\
    \ \027[0m    \027[0m|__ \240\159\147\129\027[;0;36mpreview\n\
    \ \027[0m      \027[0m|__ \027[;0mdune\n\
    \ \027[0m      \027[0m|__ \027[;0mtest_preview.ml\n\
    \ \027[0m    \027[0m|__ \240\159\147\129\027[;0;36mnavigate\n\
    \ \027[0m      \027[0m|__ \027[;0mtest_navigate.ml\n\
    \ \027[0m      \027[0m|__ \027[;0mdune\n\
    \ \027[0m  \027[0m|__ \027[;0mREADME.md\n\
    \ "]
;;
