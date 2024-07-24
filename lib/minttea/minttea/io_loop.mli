type Riot.Message.t += Input of Event.t

val translate : string -> Event.key
val loop : Riot.Pid.t -> 'a
val run : Riot.Pid.t -> unit
