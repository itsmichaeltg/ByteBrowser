open! Core

let path_to_write_prompt_to = "/home/ubuntu/jsip-final-project/bin/query_prompt.txt"
let path_to_script = "/home/ubuntu/jsip-final-project/src/querying_script.py"
let path_to_write_info_to = "/home/ubuntu/jsip-final-project/bin/query_info.txt"
let path_to_read_from =
  "/home/ubuntu/jsip-final-project/bin/query_answer.txt"
;;

let query chat_so_far ~question ~info =
  let full_prompt = chat_so_far ^ "/n" ^ "q: " ^ question ^ "\n" ^ "a: " in
  Out_channel.write_all path_to_write_prompt_to ~data:"";
  Out_channel.write_all path_to_write_prompt_to ~data:full_prompt;
  Out_channel.write_all path_to_write_info_to ~data:"";
  Out_channel.write_all path_to_write_info_to ~data:info;
  let command = Printf.sprintf "python3 %s" path_to_script in
  let _ = Sys_unix.command command in
  let result = In_channel.read_all path_to_read_from in
  full_prompt ^ result
;;
