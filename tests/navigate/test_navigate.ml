(* open! Core
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

let%expect_test "navigate-left" =
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
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir1/child1/.gitignore");
  let model =
    { Navigate.State.choices = { matrix = mat }
    ; current_path = "/home/home_dir1/child1/.gitignore"
    ; origin = "/home"
    ; parent = "/home"
    ; cursor = 0
    ; path_to_preview = ""
    ; show_reduced_tree = false
    ; text =
      Leaves.Text_input.make
        ""
        ~placeholder:"Type something"
        ~cursor:cursor_func
        ()
  ; quitting = false
    }
  in
  let new_model = Navigate.State.get_updated_model_for_left model in
  print_endline
    (Visualize_helper.visualize
       new_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:new_model.current_path);
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
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir1");
  let model =
    { Navigate.State.choices = { matrix = mat }
    ; current_path = "/home/home_dir1"
    ; origin = "/home"
    ; parent = "/home"
    ; cursor = 0
    ; path_to_preview = ""
    ; show_reduced_tree = false
    ; text =
        Leaves.Text_input.make
          ""
          ~placeholder:"Type something"
          ~cursor:cursor_func
          ()
    ; quitting = false
    }
  in
  let new_model = Navigate.State.get_updated_model_for_right model in
  print_endline
    (Visualize_helper.visualize
       new_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:new_model.current_path);
  let newer_model = Navigate.State.get_updated_model_for_right new_model in
  print_endline
    (Visualize_helper.visualize
       newer_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:newer_model.current_path);
  let newest_model = Navigate.State.get_updated_model_for_right new_model in
  print_endline
    (Visualize_helper.visualize
       newest_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:newest_model.current_path);
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
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir2");
  let model =
    { Navigate.State.choices = { matrix = mat }
    ; current_path = "/home/home_dir2"
    ; origin = "/home"
    ; parent = "/home"
    ; cursor = 1
    ; path_to_preview = ""
    ; show_reduced_tree = false
    ; text =
        Leaves.Text_input.make
          ""
          ~placeholder:"Type something"
          ~cursor:cursor_func
          ()
    ; quitting = false
    }
  in
  let new_model = Navigate.State.get_updated_model_for_up model in
  print_endline
    (Visualize_helper.visualize
       new_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:new_model.current_path);
  let newer_model = Navigate.State.get_updated_model_for_up new_model in
  print_endline
    (Visualize_helper.visualize
       newer_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:newer_model.current_path);
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
  print_endline
    (Visualize_helper.visualize
       mat
       ~current_directory:"/home"
       ~path_to_be_underlined:"/home/home_dir1");
  let model =
    { Navigate.State.choices = { matrix = mat }
    ; current_path = "/home/home_dir1"
    ; origin = "/home"
    ; parent = "/home"
    ; cursor = 0
    ; path_to_preview = ""
    ; show_reduced_tree = false
    ; text =
        Leaves.Text_input.make
          ""
          ~placeholder:"Type something"
          ~cursor:cursor_func
          ()
    ; quitting = false
    }
  in
  let new_model = Navigate.State.get_updated_model_for_down model in
  print_endline
    (Visualize_helper.visualize
       new_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:new_model.current_path);
  let newer_model = Navigate.State.get_updated_model_for_down new_model in
  print_endline
    (Visualize_helper.visualize
       newer_model.choices.matrix
       ~current_directory:"/home"
       ~path_to_be_underlined:newer_model.current_path);
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
;; *)
