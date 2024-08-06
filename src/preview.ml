open! Core

let apply_syntax_highlight lines = lines

let get_lines path ~num_lines =
  let lst = In_channel.read_lines path in
  let relevant_lines = List.slice lst 0 (min num_lines (List.length lst)) in
  List.map relevant_lines ~f:Styles.normalize_string
;;

let get_title path =
  Styles.normalize_string ("viewing " ^ Matrix.get_name path)
;;

let apply_outer_styles path ~content =
  (* let extension = Matrix.get_extension_of_file path in *)
  let styles = { Styles.styles = [ "0"; "48"; "5"; "129" ] } in
  let title = get_title path in
  let space_between_title_and_content = Styles.get_normalized_new_line () in
  let content_with_colors =
    Styles.apply_style
      styles
      ~apply_to:(title ^ space_between_title_and_content ^ content)
  in
  Styles.apply_borders content_with_colors ^ "\x1b[0m" ^ "\n"
;;

let concat_lines lines = String.concat lines ~sep:"\n"

let preview path ~num_lines =
  let lines = get_lines path ~num_lines in
  let formatted_lines = apply_syntax_highlight lines in
  let concatted_lines = concat_lines formatted_lines in
  apply_outer_styles path ~content:concatted_lines
;;
