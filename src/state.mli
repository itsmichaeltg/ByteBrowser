open! Core
open! Leaves

type t

val remove_last_path : string -> string
val get_updated_model_for_preview : t -> t
val get_updated_model_for_rename : t -> t
val get_updated_model_for_change_dir : t -> t
val get_updated_model_for_move : t -> t
val get_updated_model_for_remove : t -> t
val get_updated_model_for_right : t -> t
val get_updated_model_for_left : t -> t
val get_updated_model_for_up : t -> t
val get_updated_model_for_down : t -> t
val get_updated_model_for_move : t -> t
val get_path_to_preview : t -> string
val get_tree : t -> Visualize.Adjacency_matrix.tree
val get_current_path : t -> string
val get_is_writing : t -> bool
val get_text : t -> Text_input.t
val get_parent : t -> string
val get_is_moving : t -> bool
val should_preview : t -> bool
val get_model_after_writing : t -> t
val get_model_with_new_text : t -> Text_input.t -> t
val get_model_with_new_current_path : t -> string -> t

val init
  :  choices:Visualize.Adjacency_matrix.t
  -> origin:string
  -> current_path:string
  -> parent:string
  -> cursor:int
  -> path_to_preview:string
  -> text:Text_input.t
  -> is_writing:bool
  -> show_reduced_tree:bool
  -> is_moving:bool
  -> move_from:string
  -> t
