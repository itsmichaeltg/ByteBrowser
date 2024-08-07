open! Core

type t [@@deriving sexp_of]
type matrix_info [@@deriving sexp_of]

val create : unit -> t
val create_matrix_info : unit -> matrix_info

val get_adjacency_matrix
  :  t
  -> sort:bool
  -> show_hidden:bool
  -> origin:string
  -> max_depth:int
  -> t

val is_directory : t -> string -> bool
val get_children : t -> string -> string list option
val get_name : string -> string
val get_extension_of_file : string -> string

val add_matrix_info
  :  t
  -> info_map:matrix_info
  -> current_path:string
  -> horizontal_depth:int
  -> vertical_depth:int
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
