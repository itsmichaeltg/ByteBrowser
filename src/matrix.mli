open! Core

type t [@@deriving sexp_of]

val create : unit -> t

val get_adjacency_matrix
  :  t
  -> sort:bool
  -> show_hidden:bool
  -> origin:string
  -> max_depth:int
  -> t

val is_directory : t -> string -> bool
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
