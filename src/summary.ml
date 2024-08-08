open! Core

let path_to_read_from = "/home/ubuntu/jsip-final-project/bin/completion.txt"

let path_to_script =
  "/home/ubuntu/jsip-final-project/src/summarization_script.py"
;;

let path_to_write_to =
  "/home/ubuntu/jsip-final-project/bin/file_contents.txt"
;;

let path_to_write_to_for_viewing =
  "/home/ubuntu/jsip-final-project/bin/code_to_be_highlighted.txt"
;;

let path_to_highlighting_script =
  "/home/ubuntu/jsip-final-project/src/syntax_highlighting_script.py"
;;

let path_to_read_from_for_viewing =
  "/home/ubuntu/jsip-final-project/bin/highlighted_code.txt"
;;

let path_to_write_file_name_to =
  "/home/ubuntu/jsip-final-project/bin/path_to_preview.txt"
;;

let rec find_paths_to_skim tree origin =
  match Matrix.find tree origin with
  | None -> [ origin ]
  | Some children ->
    List.fold children ~init:[] ~f:(fun acc child ->
      List.append acc (find_paths_to_skim tree child))
;;

let generate_summary (tree : Matrix.t) (origin : string) =
  let paths_to_skim = find_paths_to_skim tree origin in
  let contents_of_paths =
    List.fold paths_to_skim ~init:"" ~f:(fun acc path ->
      acc
      ^ "/n"
      ^ Printf.sprintf "File name: %s" (Matrix.get_name path)
      ^ Printf.sprintf
          "Contents of file: %s"
          (Preview.preview_without_styles path ~num_lines:Int.max_value))
  in
  Out_channel.write_all path_to_write_to ~data:"";
  Out_channel.write_all path_to_write_to ~data:contents_of_paths;
  let command = Printf.sprintf "python3 %s" path_to_script in
  let _ = Sys_unix.command command in
  let result = In_channel.read_all path_to_read_from in
  Sys_unix.remove path_to_read_from;
  Sys_unix.remove path_to_write_to;
  result
;;

let apply_syntax_highlight summary =
  Out_channel.write_all path_to_write_file_name_to ~data:"";
  Out_channel.write_all path_to_write_to_for_viewing ~data:summary;
  let _ = Sys_unix.command ("python3 " ^ path_to_highlighting_script) in
  let highlighted_summary = In_channel.read_all path_to_read_from_for_viewing in
  Sys_unix.remove path_to_read_from_for_viewing;
  Sys_unix.remove path_to_write_file_name_to;
  Sys_unix.remove path_to_write_to_for_viewing;
  highlighted_summary
;;

let apply_styles_to_title title = "\x1b[0;22;3;4;48;5;23;38;5;118m" ^ title ^ "\x1b[0m\n"

let get_title path =
  apply_styles_to_title
    (Styles.normalize_string ("summarizing " ^ Matrix.get_name path))
;;

let generate (tree : Matrix.t) (origin : string) =
  let summary = generate_summary tree origin in
  let title = get_title origin in
  apply_styles_to_title title ^ apply_syntax_highlight summary