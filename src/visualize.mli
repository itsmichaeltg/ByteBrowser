open! Core

module Adjacency_matrix : sig
  type tree = (string, string list) Hashtbl.t
  type t = { matrix : tree } [@@deriving sexp_of]
  val create : unit -> t
  val get_adjacency_matrix : t -> origin:string -> max_depth:int -> t
  val get_files_in_dir : string -> string list
  val is_directory : t -> string -> bool
  val get_children : tree -> string -> string list option
  val get_name : string -> string
  val get_limited_adjacency_matrix
    :  t
    -> origin:string
    -> max_depth:int
    -> num_to_show:int
    -> t
end

val visualize : max_depth:int -> origin:string -> unit
val command : Command.t
