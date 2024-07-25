open! Core

module State : sig
    type t =
      { choices : Visualize.Adjacency_matrix.t
      ; current_path : string
      ; origin : string
      }
    [@@deriving sexp_of]
  
    type dir =
      | UP
      | DOWN
  
    val get_idx_by_dir : int -> dir:dir -> int
  
    val is_directory : (string, string list) Hashtbl.t -> string -> bool
  
    val remove_last_path : string -> string
  
    val get_parent_of_current_path : t -> string
  
    val get_updated_model_for_right : t -> t

    val get_updated_model_for_left : t -> t
  
    val get_updated_model_for_up : t -> t

    val get_updated_model_for_down : t -> t
  end

val command : Command.t
