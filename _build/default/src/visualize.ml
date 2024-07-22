open! Core

let get_depth_space ~depth = List.fold (List.init depth ~f:Fn.id) ~init:"" ~f:(fun acc _ -> "-")

let get_formatted_tree_with_new_child ~(child : string) ~(depth : int) =
  Printf.sprintf "%s\n%s%s" (get_depth_space ~depth) child

let get_formatted_tree_with_new_parent ~(parent : string) ~(depth : int) ~(so_far : string) =
  Printf.sprintf "%s\n%s%s" so_far (get_depth_space ~depth) parent

let rec helper ~(so_far : string) (tree : (string, string list) Hashtbl.t) ~(depth : int) ~(parent : string) : string =
  let current_children = Hashtbl.find_exn tree parent in
  let init = get_formatted_tree_with_new_parent ~parent ~depth ~so_far in
  List.fold current_children ~init ~f:(fun acc child -> helper ~so_far:acc tree ~depth:(depth + 1) ~parent:child)

let visualize (tree : (string, string list) Hashtbl.t) ~(current_directory : string): string =
  helper tree ~depth:1 ~so_far:"." ~parent:current_directory
