type t

(** Create a new list component *)
val make
  :  string list
  -> ?cursor:string
  -> ?style_selected:Spices.style
  -> ?style_unselected:Spices.style
  -> ?max_height:int
  -> unit
  -> t

(** Only show elements that contain a given substring *)
val show_string_contains : t -> string -> t

(** Show elements matching a predicate *)
val show_pred : t -> (int -> string -> bool) -> t

(** Clear filtering *)
val show_all : t -> t

(** Update the component based on events *)
val update : Minttea.Event.t -> t -> t

(** Produce the view as a string *)
val view : t -> string

(** Return the selected elements of the list *)
val get_selection : t -> string list

(** Append more elements at the end of the list *)
val append : t -> string list -> t

(** Permanently remove elements not verifying the predicate *)
val filter : t -> (int -> string -> bool) -> t
