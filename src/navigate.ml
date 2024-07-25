open! Core

let write_path = "/home/ubuntu/jsip-final-project/bin/path.txt"

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
    match dir with
    | UP ->
      (try
         (t.cursor - 1)
         % (Hashtbl.find_exn t.choices.matrix t.parent |> List.length)
       with
       | _ -> 0)
    | DOWN ->
      (try
         (t.cursor + 1)
         % (Hashtbl.find_exn t.choices.matrix t.parent |> List.length)
       with
       | _ -> 0)
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
    let current_path =
      try
        List.nth_exn (Hashtbl.find_exn t.choices.matrix t.parent) cursor
      with
      | _ -> t.current_path
    in
    let tmp_model = { t with cursor } in
    { tmp_model with current_path }
  ;;

  let get_updated_model_for_right t =
    let current_path =
      try Hashtbl.find_exn t.choices.matrix t.current_path with
      | _ -> [ t.current_path ]
    in
    if current_path |> List.is_empty
    then t
    else (
      let current_path = List.hd_exn current_path in
      let parent =
        if String.equal t.current_path current_path
        then t.parent
        else t.current_path
      in
      let tmp_model = { t with parent } in
      { tmp_model with current_path })
  ;;

  let get_updated_model_for_left t =
    let current_path, parent =
      match String.equal t.current_path t.origin with
      | true -> t.current_path, t.parent
      | false -> remove_last_path t.current_path, remove_last_path t.parent
    in
    let tmp_model = { t with parent } in
    { tmp_model with current_path }
  ;;

  let get_updated_model_for_up t = handle_up_and_down t ~dir:UP
  let get_updated_model_for_down t = handle_up_and_down t ~dir:DOWN
end

let change_dir data = Out_channel.write_all write_path ~data

let%expect_test "write_to_path.txt" =
  change_dir "Hello World!";
  print_endline (In_channel.read_all write_path);
  [%expect {|Hello World!|}]
;;

let update event (model : State.t) =
  let open Minttea in
  match event with
  | Event.KeyDown (Left, _modifier) ->
    State.get_updated_model_for_left model, Command.Noop
  | Event.KeyDown (Right, _modifier) ->
    State.get_updated_model_for_right model, Command.Noop
  | Event.KeyDown (Up, _modifier) ->
    State.get_updated_model_for_up model, Command.Noop
  | Event.KeyDown (Down, _modifier) ->
    State.get_updated_model_for_down model, Command.Noop
  | Event.KeyDown (Enter, _modifier) ->
    change_dir model.current_path;
    model, Command.Quit
  | _ -> model, Minttea.Command.Noop
;;

let get_view (model : State.t) ~origin =
  let options =
    Visualize_helper.visualize
      model.choices.matrix
      ~current_directory:origin
      ~path_to_be_underlined:model.current_path
  in
  "\x1b[0mPress ^C to quit\n" ^ Format.sprintf {|%s|} options
;;

let get_initial_state ~origin ~max_depth : State.t =
  { choices =
      Visualize.Adjacency_matrix.create ()
      |> Visualize.Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
  ; current_path = origin
  ; origin
  ; parent = State.remove_last_path origin
  ; cursor = 0
  }
;;

let init _model =
  let open Minttea in
  Command.Noop
;;

let navigate ~max_depth ~origin =
  let app = Minttea.app ~init ~update ~view:(get_view ~origin:"/home/ubuntu/jsip-final-project") () in
  Minttea.start app ~initial_model:(get_initial_state ~origin:"/home/ubuntu/jsip-final-project" ~max_depth:100)
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
