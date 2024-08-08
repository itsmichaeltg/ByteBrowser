open! Core

type t = { mutable styles : string list } [@@deriving sexp]

val get_emoji_by_dir : is_dir:bool -> string
val apply_style : t -> apply_to:string -> string
val get_normalized_new_line : unit -> string
val normalize_string : string -> string
val apply_borders : string -> string
