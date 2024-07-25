open! Core

module State = struct
  type t =
    { choices : Visualize.Adjacency_matrix.t
    ; current_path : string
    ; origin : string
    ; parent : string
    ; cursor : int
    }
  [@@deriving sexp_of]

  type dir =
    | UP
    | DOWN

  let get_idx_by_dir t ~dir =
    match dir with UP -> (t.cursor - 1) % (Hashtbl.find_exn t.choices.matrix t.parent |> List.length) | DOWN -> (t.cursor + 1) % (Hashtbl.find_exn t.choices.matrix t.parent |> List.length)
  ;;

  let is_directory (tree : (string, string list) Hashtbl.t) (value : string) =
    Hashtbl.mem tree value
  ;;

  let remove_last_path current_path =
    let str_lst = String.split current_path ~on:'/' in
    List.foldi str_lst ~init:[] ~f:(fun idx new_lst elem ->
      match idx = List.length str_lst - 1 with
      | true -> new_lst
      | false -> new_lst @ [ elem ])
    |> String.concat ~sep:"/"
  ;;

  let handle_up_and_down t ~dir =
    let cursor = get_idx_by_dir t ~dir in
    let current_path = List.nth_exn (Hashtbl.find_exn t.choices.matrix t.parent) cursor in
    let tmp_model = {t with cursor} in
    {tmp_model with current_path}
  ;;

  let get_updated_model_for_right t =
    let current_path =
      try Hashtbl.find_exn t.choices.matrix t.current_path with
      | _ -> [ t.current_path ]
    in
    let current_path = List.hd_exn current_path in
    let parent = if String.equal t.current_path current_path then
      t.parent
    else
      t.current_path in
    let tmp_model = {t with parent} in
    { tmp_model with current_path }
  ;;

  let get_updated_model_for_left t =
    let current_path, parent =
      match String.equal t.current_path t.origin with
      | true -> t.current_path, t.parent
      | false -> remove_last_path t.current_path, t.current_path
    in
    let tmp_model = {t with parent} in
    { tmp_model with current_path }
  ;;

  let get_updated_model_for_up t = handle_up_and_down t ~dir:UP
  let get_updated_model_for_down t = handle_up_and_down t ~dir:DOWN
end

let update event (model : State.t) =
  let open Minttea in
  match event with
  | Event.KeyDown ((Key "q" | Escape), _modifier) ->
    Event.pp Format.std_formatter event;
    Format.pp_print_flush Format.std_formatter ();
    model, Command.Quit
  | Event.KeyDown (Left, _modifier) ->
    State.get_updated_model_for_left model, Command.Noop
  | Event.KeyDown (Right, _modifier) ->
    State.get_updated_model_for_right model, Command.Noop
  | Event.KeyDown (Up, _modifier) ->
    State.get_updated_model_for_up model, Command.Noop
  | Event.KeyDown (Down, _modifier) ->
    State.get_updated_model_for_down model, Command.Noop
  | Event.KeyDown (Enter, _modifier) ->
    Sys_unix.chdir model.current_path;
    model, Command.Quit
  | _ -> model, Command.Noop
;;

let get_view (model : State.t) ~origin =
  let options =
    Visualize_helper.visualize
      model.choices.matrix
      ~current_directory:origin
      ~path_to_be_underlined:model.current_path
  in
  Format.sprintf {|Press q or Esc to quit.\n%s|} options
;;

let get_initial_state ~origin ~max_depth : State.t =
  { choices =
      Visualize.Adjacency_matrix.create ()
      |> Visualize.Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
  ; current_path = origin
  ; origin
  ; parent = origin
  ; cursor = 0
  }
;;

let init _model =
  let open Minttea in
  Command.Noop
;;

let navigate ~max_depth ~origin =
  let app = Minttea.app ~init ~update ~view:(get_view ~origin) () in
  Minttea.start app ~initial_model:(get_initial_state ~origin ~max_depth)
;;

let pwd_navigate_command =
  let open Core.Command.Let_syntax in
  Core.Command.basic
    ~summary:"starts at the current working directory"
    [%map_open
      let max_depth =
        flag
          "max-depth"
          (optional_with_default 3 int)
          ~doc:"INT maximum length of path to search for (default 10)"
      in
      fun () -> navigate ~max_depth ~origin:(Sys_unix.getcwd ())]
;;

let start_navigate_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"starts at a given path"
    [%map_open
      let origin = flag "start" (required string) ~doc:" the starting path"
      and max_depth =
        flag
          "max-depth"
          (optional_with_default 3 int)
          ~doc:"INT maximum length of path to search for (default 10)"
      in
      fun () -> navigate ~max_depth ~origin]
;;

let command =
  Core.Command.group
    ~summary:"file manager commands"
    [ "pwd", pwd_navigate_command; "dir", start_navigate_command ]
;;
