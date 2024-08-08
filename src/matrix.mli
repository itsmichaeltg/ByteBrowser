open! Core

type t [@@deriving sexp_of]

type table =
  { horizontal_depth : int
  ; vertical_depth : int
  ; abs_vertical_loc : int
  }
[@@deriving sexp_of]

module Info : sig
  type t [@@deriving sexp_of]

  val create : unit -> t
  val add_exn : t -> key:string -> data:table -> unit
  val find : t -> string -> table option
end

val create : unit -> t

val get_adjacency_matrix
  :  t
  -> sort:bool
  -> show_hidden:bool
  -> origin:string
  -> max_depth:int
  -> t

val is_directory : t -> string -> bool
val is_in_directory : t -> string -> path_to_check:string -> bool
val get_extension_of_file : string -> string

val fill_info_from_matrix
  :  t
  -> info_map:Info.t
  -> current_path:string
  -> unit

val get_children : t -> string -> Core.String.Set.t option
val get_name : string -> string
val find : t -> string -> Core.String.Set.t option
val find_exn : t -> string -> Core.String.Set.t
val mem : t -> string -> bool
val set : t -> key:string -> data:Core.String.Set.t -> unit
val add_exn : t -> key:string -> data:Core.String.Set.t -> unit
val length : t -> int
val of_list : ?origin:string -> string list -> t
val to_set : t -> Core.String.Set.t
val filter : ?origin:string -> t -> search:string -> t
