open! Core

let path_to_write_prompt_to =
  Sys_unix.home_directory () ^ "/ByteBrowser//bin/query_prompt.txt"
;;

let path_to_script = Sys_unix.home_directory () ^ "/ByteBrowser//src/querying_script.py"
let path_to_write_info_to = Sys_unix.home_directory () ^ "/ByteBrowser//bin/query_info.txt"
let path_to_read_from = Sys_unix.home_directory () ^ "/ByteBrowser//bin/query_answer.txt"

let path_to_write_to_for_viewing =
  Sys_unix.home_directory () ^ "/ByteBrowser//bin/code_to_be_highlighted.txt"
;;

let path_to_highlighting_script =
  Sys_unix.home_directory () ^ "/ByteBrowser//src/syntax_highlighting_script.py"
;;

let path_to_read_from_for_viewing =
  Sys_unix.home_directory () ^ "/ByteBrowser//bin/highlighted_code.txt"
;;

let path_to_write_file_name_to =
  Sys_unix.home_directory () ^ "/ByteBrowser//bin/path_to_preview.txt"
;;

let apply_syntax_highlight str =
  Out_channel.write_all path_to_write_file_name_to ~data:"";
  Out_channel.write_all path_to_write_to_for_viewing ~data:str;
  let _ = Sys_unix.command ("python3 " ^ path_to_highlighting_script) in
  let highlighted_string =
    In_channel.read_all path_to_read_from_for_viewing
  in
  Sys_unix.remove path_to_read_from_for_viewing;
  Sys_unix.remove path_to_write_file_name_to;
  Sys_unix.remove path_to_write_to_for_viewing;
  highlighted_string
;;

let query chat_so_far ~info =
  let full_prompt = chat_so_far ^ "\n\n" in
  Out_channel.write_all path_to_write_prompt_to ~data:"";
  Out_channel.write_all path_to_write_prompt_to ~data:full_prompt;
  Out_channel.write_all path_to_write_info_to ~data:"";
  Out_channel.write_all path_to_write_info_to ~data:info;
  let command = Printf.sprintf "python3 %s" path_to_script in
  let _ = Sys_unix.command command in
  let result = In_channel.read_all path_to_read_from in
  Sys_unix.remove path_to_read_from;
  Sys_unix.remove path_to_write_info_to;
  Sys_unix.remove path_to_write_prompt_to;
  full_prompt ^ apply_syntax_highlight result ^ "\n"
;;
