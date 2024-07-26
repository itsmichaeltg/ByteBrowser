open! Core

module Adjacency_matrix : sig
  type t = { matrix : (string, string list) Hashtbl.t } [@@deriving sexp_of]

  val create : unit -> t
  val get_adjacency_matrix : t -> origin:string -> max_depth:int -> t
  val get_files_in_dir : string -> string list

  val get_limited_adjacency_matrix
    :  t
    -> origin:string
    -> max_depth:int
    -> num_to_show:int
    -> t
end

val visualize : max_depth:int -> origin:string -> unit
val command : Command.t
