open! Core
open! Leaves

type t

type dir =
  | Up
  | Down
  | Left
  | Right

type action =
  | Cursor of dir
  | Shortcut of string
  | Preview
  | Rename
  | Cd
  | Remove
  | Move

val get_updated_model : t -> action:action -> t
val remove_last_path : string -> string
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
