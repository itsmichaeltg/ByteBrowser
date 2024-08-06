open! Core
open! Terminal_size
open! Yojson.Basic.Util

module Styling = struct
  type t = { mutable styles : string list } [@@deriving sexp]

  let get_emoji_by_dir ~is_dir =
    ignore is_dir;
    ""
  ;;

  (* match is_dir with true -> "📁" | false -> "" *)

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
    | true -> acc ^ "\x1b[0;48;5;17m|__"
    | false -> acc ^ "\x1b[0;48;5;17m  ")
  ^ " "
;;

let is_directory (tree : Matrix.t) (value : string) = Matrix.mem tree value
let is_hidden_file name = String.is_prefix name ~prefix:"."

let normalize_string str ~depth ~is_dir =
  let max_rows =
    match get_columns () with None -> 100 | Some size -> size - 5
  in
  let max = max_rows - String.length str - ((depth - 1) * 2) in
  let space_needed =
    List.fold (List.init max ~f:Fn.id) ~init:"" ~f:(fun acc curr ->
      acc ^ " ")
  in
  str ^ space_needed
;;

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

let get_color_for_file name : string list =
  let extension =
    String.fold
      (String.rev name)
      ~init:("", true)
      ~f:(fun (acc, should_add_char) char ->
        match should_add_char with
        | false -> acc, false
        | true ->
          (match Char.equal char '.' with
           | true -> acc, false
           | false -> acc ^ Char.to_string char, true))
    |> fst
    |> String.rev
  in
  let file_extension_to_color_json =
    Yojson.Safe.from_file
      "/home/ubuntu/jsip-final-project/src/file_extension_to_color.json"
  in
  let field_val_assoc =
    file_extension_to_color_json |> Yojson.Safe.Util.to_assoc
  in
  let target_val =
    List.Assoc.find field_val_assoc extension ~equal:String.equal
  in
  let colors_as_json_objs =
    match target_val with
    | None -> []
    | Some json_obj -> Yojson.Safe.Util.to_list json_obj
  in
  let colors = List.map colors_as_json_objs ~f:Yojson.Safe.Util.to_string in
  colors
;;

let get_styles tree ~(path_to_be_underlined : string) ~(parent : string) =
  let (styles : Styling.t) = { styles = [ "0"; "48"; "5"; "17" ] } in
  (match String.equal path_to_be_underlined parent with
   | true -> styles.styles <- List.append styles.styles [ "4"; "2" ]
   | false -> ());
  (match is_directory tree parent with
   | true ->
     styles.styles <- List.append styles.styles [ "38"; "5"; "49"; "1" ]
   | false ->
     (match is_hidden_file (get_name parent) with
      | true ->
        styles.styles <- List.append styles.styles [ "38"; "5"; "40"; "1" ]
      | false ->
        styles.styles
        <- List.append styles.styles (get_color_for_file (get_name parent))));
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
         ~apply_to:
           (normalize_string
              (get_name parent)
              ~depth
              ~is_dir:(is_directory tree parent))
         ~is_dir:(is_directory tree parent))
;;

let rec helper
  ~(so_far : string)
  (tree : Matrix.t)
  ~(depth : int)
  ~(parent : string)
  ~(path_to_be_underlined : string)
  : string
  =
  match Matrix.find tree parent with
  | None ->
    get_formatted_tree_with_new_parent
      tree
      ~parent
      ~depth
      ~so_far
      ~path_to_be_underlined
  | Some current_children ->
    let init =
      get_formatted_tree_with_new_parent
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

let apply_borders tree =
  let lines_in_tree = String.split_lines tree in
  let bordered_tree =
    List.map lines_in_tree ~f:(fun line -> "\x1b[0m>>" ^ line ^ "\x1b[0m<<")
  in
  List.fold bordered_tree ~init:"" ~f:(fun acc line -> acc ^ "\n" ^ line)
;;

let apply_outer_styles tree = tree

let visualize
  (tree : Matrix.t)
  ~(current_directory : string)
  ~(path_to_be_underlined : string)
  : string
  =
  let tree =
    helper
      tree
      ~depth:1
      ~so_far:
        ("\x1b[48;5;17m" ^ normalize_string "." ~depth:(-1) ~is_dir:false)
      ~parent:current_directory
      ~path_to_be_underlined
  in
  apply_outer_styles tree ^ "\n\x1b[0m"
;;

(* apply_outer_styles tree ^ "\n\x1b[0m" *)

let print_dir (t : Matrix.t) ~origin =
  visualize t ~current_directory:origin ~path_to_be_underlined:""
;;

let matrix_visualize ~max_depth ~origin ~show_hidden ~sort =
  let matrix =
    Matrix.create ()
    |> Matrix.get_adjacency_matrix ~origin ~max_depth ~show_hidden ~sort
  in
  print_dir ~origin matrix |> print_endline
;;
