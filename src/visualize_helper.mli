open! Core

val visualize
  :  Matrix.t
  -> current_directory:string
  -> path_to_be_underlined:string
  -> matrix_info:Matrix.Info.t
  -> show_reduced_tree:bool
  -> paths_to_collapse : (string, String.comparator_witness) Set.t
  -> show_relative_dirs : bool
  -> box_dimension : int
  -> string

(* val matrix_visualize
  :  max_depth:int
  -> origin:string
  -> show_hidden:bool
  -> sort:bool
  -> unit *)
