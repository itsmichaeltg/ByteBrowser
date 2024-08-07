open! Core

let path_to_write_to = "/home/ubuntu/jsip-final-project/bin/code_to_be_highlighted.txt"
let path_to_script = "/home/ubuntu/jsip-final-project/src/syntax_highlighting_script.py"
let path_to_read_from = "/home/ubuntu/jsip-final-project/bin/highlighted_code.txt"

let apply_syntax_highlight (lines : string list) path =
  Out_channel.write_lines path_to_write_to lines;
  let file_name = Matrix.get_name path in
  let _ = Sys_unix.command ("python3 " ^ path_to_script ^ " " ^ file_name) in
  In_channel.read_lines path_to_read_from

let apply_bg line = "\x1b[0;48;5;23m" ^ line
(* let transform_line line = Styles.normalize_string line |> apply_bg *)

let get_lines path ~num_lines =
  let lst = List.append [ "" ] (In_channel.read_lines path) in
  let relevant_lines = List.slice lst 0 (min num_lines (List.length lst)) in
  List.map relevant_lines ~f:Styles.normalize_string
;;

let apply_styles_to_title title = "\x1b[0;22;3;4;48;5;23;38;5;118m" ^ title

let get_title path =
  apply_styles_to_title
    (Styles.normalize_string ("viewing " ^ Matrix.get_name path))
;;

let apply_outer_styles path ~content =
  (* let extension = Matrix.get_extension_of_file path in *)
  Styles.apply_borders (get_title path)
  ^ Styles.apply_borders content
  ^ "\x1b[0m"
  ^ "\n"
;;

let concat_lines lines = String.concat lines ~sep:"\n"

let preview path ~num_lines =
  let lines = get_lines path ~num_lines in
  let formatted_lines = apply_syntax_highlight lines path in
  let concatted_lines = concat_lines formatted_lines in
  apply_outer_styles path ~content:concatted_lines
;;
