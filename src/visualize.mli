open! Core

module Adjacency_matrix : sig
    type t = { matrix : (string, string list) Hashtbl.t }
    val create : unit -> t
    val get_adjacency_matrix : t -> origin:string -> max_depth:int -> t
end

val command : Command.t
