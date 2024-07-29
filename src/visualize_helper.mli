open! Core

val visualize
  :  (string, string list) Hashtbl.t
  -> current_directory:string
  -> path_to_be_underlined:string
  -> string

val get_name : string -> string
