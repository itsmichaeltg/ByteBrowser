open! Core

val visualize
  :  (string, string list) Hashtbl.t
  -> ?path_to_be_underlined:string
  -> current_directory:string
  -> string
