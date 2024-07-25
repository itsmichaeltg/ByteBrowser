open! Core

let preview file ~num_lines =
  let lines_to_show = List.slice (In_channel.read_lines file) 0 num_lines in
  String.concat lines_to_show ~sep:"\n"
;;
