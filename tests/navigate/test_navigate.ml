open! Core
open! File_manager_lib

let cursor_func =
  Leaves.Cursor.make
    ~style:
      Spices.(
        default
        |> bg (Spices.color "#77e5b7")
        |> fg (Spices.color "#FFFFFF")
        |> bold true)
    ()
;;

let get_tree () =
  let mat = Hashtbl.create (module String) in
  Hashtbl.add_exn
    mat
    ~key:"/home"
    ~data:[ "/home/home_dir1"; "/home/home_dir2" ];
  Hashtbl.add_exn
    mat
    ~key:"/home/home_dir1"
    ~data:[ "/home/home_dir1/child1"; "/home/home_dir1/child2" ];
  Hashtbl.add_exn mat ~key:"/home/home_dir2" ~data:[];
  Hashtbl.add_exn
    mat
    ~key:"/home/home_dir1/child1"
    ~data:[ "/home/home_dir1/child1/.gitignore" ];
  mat
;;

let get_init_model ~choices ~current_path ~cursor =
  State.init
    ~choices
    ~current_path
    ~origin:"/home"
    ~parent:"/home"
    ~cursor
    ~path_to_preview:""
    ~text:
      (Leaves.Text_input.make
         ""
         ~placeholder:"Type something"
         ~cursor:cursor_func
         ())
    ~is_writing:false
    ~show_reduced_tree:false
    ~is_moving:false
    ~move_from:""
;;

let%expect_test "navigate-left" =
  let mat = get_tree () in
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir1/child1/.gitignore");
  let model =
    get_init_model
      ~choices:{ matrix = mat }
      ~current_path:"/home/home_dir1/child1/.gitignore"
      ~cursor:0
  in
  let new_model = State.get_updated_model_for_left model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree new_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path new_model));
  [%expect
    {|
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;4;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;4;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    |}]
;;

let%expect_test "navigate-right" =
  let mat = get_tree () in
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir1");
  let model =
    get_init_model
      ~choices:{ matrix = mat }
      ~current_path:"/home/home_dir1"
      ~cursor:0
  in
  let new_model = State.get_updated_model_for_right model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree new_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path new_model));
  let newer_model = State.get_updated_model_for_right new_model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree newer_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path newer_model));
  let newest_model = State.get_updated_model_for_right new_model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree newest_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path newest_model));
  [%expect
    {|
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;4;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;4;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;4;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;4;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    |}]
;;

let%expect_test "navigate-up" =
  let mat = get_tree () in
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir2");
  let model =
    get_init_model
      ~choices:{ matrix = mat }
      ~current_path:"/home/home_dir2"
      ~cursor:1
  in
  let new_model = State.get_updated_model_for_up model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree new_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path new_model));
  let newer_model = State.get_updated_model_for_up new_model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree newer_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path newer_model));
  [%expect
    {|
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;4;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;4;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;4;36mhome_dir2
    |}]
;;

let%expect_test "navigate-down" =
  let mat = get_tree () in
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir1");
  let model =
    get_init_model
      ~choices:{ matrix = mat }
      ~current_path:"/home/home_dir1"
      ~cursor:0
  in
  let new_model = State.get_updated_model_for_down model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree new_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path new_model));
  let newer_model = State.get_updated_model_for_down new_model in
  print_endline
    (Visualize_helper.visualize
       (State.get_tree newer_model)
       ~current_directory:"/home"
       ~path_to_be_underlined:(State.get_current_path newer_model));
  [%expect
    {|
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;4;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;4;36mhome_dir2
    .
    [0m[0m|__ 📁[;0;36mhome
    [0m  [0m|__ 📁[;0;4;36mhome_dir1
    [0m    [0m|__ 📁[;0;36mchild1
    [0m      [0m|__ [;0;35m.gitignore
    [0m    [0m|__ [;0mchild2
    [0m  [0m|__ 📁[;0;36mhome_dir2
    |}]
;;
