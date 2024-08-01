open! Core

(* TODO: add a way to highlight two places *)

module Styling = struct
  type t = { mutable styles : string list }

  let get_emoji_by_dir ~is_dir =
    match is_dir with true -> "📁" | false -> ""
  ;;

  let apply_style t ~apply_to ~is_dir =
    "\x1b["
    ^ List.fold t.styles ~init:"" ~f:(fun acc style -> acc ^ ";" ^ style)
    ^ "m"
    ^ apply_to
  ;;
end

let get_depth_space ~depth =
  List.fold (List.init depth ~f:Fn.id) ~init:"\x1b[0m" ~f:(fun acc num ->
    match num = depth - 1 with
    | true -> acc ^ "\x1b[0m|__"
    | false -> acc ^ "  ")
  ^ " "
;;

let is_directory (tree : (string, string list) Hashtbl.t) (value : string) =
  Hashtbl.mem tree value
;;

let is_hidden_file name = String.is_prefix name ~prefix:"."

let get_name path =
  match String.contains path '/' with
  | false -> path
  | true -> List.last_exn (String.split path ~on:'/')
;;

let%expect_test "get_name" =
  print_endline (get_name "/home/ubuntu/jsip-final-project");
  print_endline (get_name "dune-project");
  [%expect {|
  jsip-final-project
  dune-project
  |}]
;;

let get_styles tree ~(path_to_be_underlined : string) ~(parent : string) =
  let (styles : Styling.t) = { styles = [ "0" ] } in
  (match String.equal path_to_be_underlined parent with
   | true -> styles.styles <- List.append styles.styles [ "4" ]
   | false -> ());
  (match is_directory tree parent with
   | true -> styles.styles <- List.append styles.styles [ "36" ]
   | false ->
     (match is_hidden_file (get_name parent) with
      | true -> styles.styles <- List.append styles.styles [ "35" ]
      | false -> ()));
  styles
;;

let get_formatted_tree_with_new_parent
  tree
  ~(path_to_be_underlined : string)
  ~(parent : string)
  ~(depth : int)
  ~(so_far : string)
  =
  so_far
  ^ "\n"
  ^ get_depth_space ~depth
  ^ Styling.get_emoji_by_dir ~is_dir:(is_directory tree parent)
  ^ Printf.sprintf
      "%s"
      (Styling.apply_style
         (get_styles tree ~path_to_be_underlined ~parent)
         ~apply_to:(get_name parent)
         ~is_dir:(is_directory tree parent))
;;

let rec helper
  ~(so_far : string)
  (tree : (string, string list) Hashtbl.t)
  ~(depth : int)
  ~(parent : string)
  ~(path_to_be_underlined : string)
  : string
  =
  match Hashtbl.find tree parent with
  | None ->
    get_formatted_tree_with_new_parent
      tree
      ~parent
      ~depth
      ~so_far
      ~path_to_be_underlined
  | Some current_children ->
    let init = get_formatted_tree_with_new_parent
          tree
          ~parent
          ~depth
          ~so_far
          ~path_to_be_underlined
    in
    List.fold current_children ~init ~f:(fun acc child ->
      helper
        ~so_far:acc
        tree
        ~depth:(depth + 1)
        ~parent:child
        ~path_to_be_underlined)
;;

let visualize
  (tree : (string, string list) Hashtbl.t)
  ~(current_directory : string)
  ~(path_to_be_underlined : string)
  : string
  =
  helper
    tree
    ~depth:1
    ~so_far:"."
    ~parent:current_directory
    ~path_to_be_underlined
;;
