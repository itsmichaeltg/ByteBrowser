open! Core
open! Terminal_size

type t = { mutable styles : string list } [@@deriving sexp]

let get_emoji_by_dir ~is_dir =
  ignore is_dir;
  ""
;;

(* match is_dir with true -> "📁" | false -> "" *)

let apply_style t ~apply_to =
  "\x1b["
  ^ List.fold t.styles ~init:"" ~f:(fun acc style -> acc ^ ";" ^ style)
  ^ "m"
  ^ apply_to
;;

let normalize_string str =
  let max_cols =
    match get_columns () with None -> 100 | Some size -> size - 10
  in
  let max = max_cols - String.length str in
  let space_needed =
    List.fold (List.init max ~f:Fn.id) ~init:"" ~f:(fun acc curr ->
      acc ^ " ")
  in
  str ^ space_needed
;;

let apply_borders content =
  let lines_in_content = String.split_lines content in
  let bordered_content =
    List.map lines_in_content ~f:(fun line -> "\x1b[0m>>  " ^ line ^ "\x1b[0m  <<")
  in
  List.fold bordered_content ~init:"" ~f:(fun acc line -> acc ^ "\n" ^ line)
;;

(* List.fold bordered_tree ~init:"" ~f:(fun acc line -> acc ^ "\n" ^ line) *)

let get_normalized_new_line () = "\n" ^ normalize_string "" ^ "\n"
