open! Core

<<<<<<< HEAD
let get_depth_space ~depth = List.fold (List.init depth ~f:Fn.id) ~init:"|" ~f:(fun acc _ -> acc ^ "--") ^ "> "
=======
let get_depth_space ~depth = List.fold (List.init depth ~f:Fn.id) ~init:"" ~f:(fun acc _ -> "-")

let get_formatted_tree_with_new_child ~(child : string) ~(depth : int) =
  Printf.sprintf "%s\n%s%s" (get_depth_space ~depth) child
>>>>>>> 9c3933f0b3197f4adb8bbcb4bdb49f9eae5195f9

let get_formatted_tree_with_new_parent ~(parent : string) ~(depth : int) ~(so_far : string) =
  Printf.sprintf "%s\n%s%s" so_far (get_depth_space ~depth) parent

let rec helper ~(so_far : string) (tree : (string, string list) Hashtbl.t) ~(depth : int) ~(parent : string) : string =
<<<<<<< HEAD
  match Hashtbl.find tree parent  with
  | None -> get_formatted_tree_with_new_parent ~parent ~depth ~so_far
  | Some current_children ->
    let init = get_formatted_tree_with_new_parent ~parent ~depth ~so_far in
    List.fold current_children ~init:("\n\n" ^ init) ~f:(fun acc child -> helper ~so_far:acc tree ~depth:(depth + 1) ~parent:child)

let visualize (tree : (string, string list) Hashtbl.t) ~(current_directory : string) : string =
   helper tree ~depth:1 ~so_far:"." ~parent:current_directory

let%expect_test "visualize" =
  let mat = Hashtbl.create (module String) in
  Hashtbl.add_exn mat ~key:"home" ~data:["home_dir1"; "home_dir2"];
  Hashtbl.add_exn mat ~key:"home_dir1" ~data:["child1"; "child2"];
  Hashtbl.add_exn mat ~key:"home_dir2" ~data:[];
  let res = visualize mat ~current_directory:"home" in
  print_endline res
=======
  let current_children = Hashtbl.find_exn tree parent in
  let init = get_formatted_tree_with_new_parent ~parent ~depth ~so_far in
  List.fold current_children ~init ~f:(fun acc child -> helper ~so_far:acc tree ~depth:(depth + 1) ~parent:child)

let visualize (tree : (string, string list) Hashtbl.t) ~(current_directory : string): string =
  helper tree ~depth:1 ~so_far:"." ~parent:current_directory
>>>>>>> 9c3933f0b3197f4adb8bbcb4bdb49f9eae5195f9
