open! Core

let preview file ~num_lines =
  let lst = In_channel.read_lines file in
  let lines_to_show = List.slice lst 0 (min num_lines (List.length lst)) in
  String.concat lines_to_show ~sep:"\n"
;;
