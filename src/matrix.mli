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
val get_children : t -> string -> string list option
val get_name : string -> string
val get_extension_of_file : string -> string

val fill_info_from_matrix
  :  t
  -> info_map:Info.t
  -> current_path:string
  -> unit

val get_limited_adjacency_matrix
  :  t
  -> sort:bool
  -> show_hidden:bool
  -> origin:string
  -> max_depth:int
  -> num_to_show:int
  -> t

val find : t -> string -> string list option
val find_exn : t -> string -> string list
val mem : t -> string -> bool
val set : t -> key:string -> data:string list -> unit
val add_exn : t -> key:string -> data:string list -> unit
