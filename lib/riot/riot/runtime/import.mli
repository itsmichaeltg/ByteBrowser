val _get_pool : unit -> Scheduler.pool
val _get_sch : unit -> Scheduler.t
val _get_proc : Pid.t -> Process.t
val self : unit -> Pid.t

val syscall :
  ?timeout:int64 ->
  string ->
  Gluon.Interest.t ->
  Gluon.Source.t ->
  (unit -> 'a) ->
  'a

val receive :
  selector:(Message.t -> [ `select of 'msg | `skip ]) ->
  ?after:int64 ->
  ?ref:unit Ref.t ->
  unit ->
  'msg

val receive_any : ?after:int64 -> ?ref:unit Ref.t -> unit -> Message.t
val yield : unit -> unit
val random : unit -> Random.State.t
val sleep : float -> unit
val process_flag : Process.process_flag -> unit
val exit : Pid.t -> Process.exit_reason -> unit
val send : Pid.t -> Message.t -> unit

exception Invalid_destination of string

val send_by_name : name:string -> Message.t -> unit

exception Link_no_process of Pid.t

val _link : Process.t -> Process.t -> unit
val link : Pid.t -> unit

val _spawn :
  ?priority:Process.priority ->
  ?do_link:bool ->
  ?pool:Scheduler.pool ->
  ?scheduler:Scheduler.t ->
  (unit -> unit) ->
  Pid.t

val spawn : (unit -> unit) -> Pid.t
val spawn_pinned : (unit -> unit) -> Pid.t
val spawn_link : (unit -> unit) -> Pid.t
val monitor : Pid.t -> unit
val demonitor : Pid.t -> unit
val register : string -> Pid.t -> unit
val unregister : string -> unit
val where_is : string -> Pid.t option
val processes : unit -> (Pid.t * Process.t) Seq.t
val is_process_alive : Pid.t -> bool
val wait_pids : Pid.t list -> unit

module Timer : sig
  type timeout = Timeout.t
  type timer = unit Ref.t

  val _set_timer :
    Pid.t ->
    Message.t ->
    int64 ->
    [ `interval | `one_off ] ->
    (unit Ref.t, 'a) result

  val send_after : Pid.t -> Message.t -> after:int64 -> (unit Ref.t, 'a) result

  val send_interval :
    Pid.t -> Message.t -> every:int64 -> (unit Ref.t, 'a) result

  val cancel : unit Ref.t -> unit
end
