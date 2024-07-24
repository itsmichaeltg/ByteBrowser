type modifier = No_modifier | Ctrl

type key =
  | Up
  | Down
  | Left
  | Right
  | Space
  | Escape
  | Backspace
  | Enter
  | Key of string

val key_to_string : key -> string

type t =
  | KeyDown of key * modifier
  | Timer of unit Riot.Ref.t
  | Frame of Ptime.t
  | Custom of Riot.Message.t

val pp : Format.formatter -> t -> unit
