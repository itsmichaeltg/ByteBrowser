open! Core

let write_path = "/home/ubuntu/jsip-final-project/bin/path.txt"

let cursor_func =
  Leaves.Cursor.make
    ~style:
      Spices.(
        default
        |> bg (Spices.color "#77e5b7")
        |> fg (Spices.color "#FFFFFF")
        |> bold true)
    ()
;;

module State = struct
  type t =
    { choices : Visualize.Adjacency_matrix.t
    ; current_path : string
    ; origin : string
    ; parent : string
    ; cursor : int
    ; path_to_preview : string
    ; text : Leaves.Text_input.t
    ; quitting : bool
    }

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

  let get_updated_model_for_preview t =
    match t.path_to_preview with
    | "" -> { t with path_to_preview = t.current_path }
    | _ -> { t with path_to_preview = "" }
  ;;

  let get_updated_model_for_rename t =
    let quitting = true in
    let text =
      Leaves.Text_input.make "" ~placeholder:"" ~cursor:cursor_func ()
    in
    { t with quitting; text }
  ;;

  let get_updated_model_for_remove t =
    let siblings =
      (match Hashtbl.find t.choices.matrix t.parent with
       | Some lst -> lst
       | None -> [])
      |> List.filter ~f:(fun elem -> String.equal t.current_path elem |> not)
    in
    let _ =
      match siblings with
      | [] -> ()
      | _ -> Hashtbl.set t.choices.matrix ~key:t.parent ~data:siblings
    in
    let _ =
      Format.sprintf {|rm -rf %s|} t.current_path |> Sys_unix.command
    in
    t
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
      { t with current_path; cursor = 0; parent })
  ;;

  let get_idx t ~parent ~current_path =
    match Hashtbl.find t.choices.matrix parent with
    | Some lst ->
      List.foldi ~init:None lst ~f:(fun idx acc elem ->
        if String.equal elem current_path then Some idx else acc)
    | None -> None
  ;;

  let get_updated_model_for_left t =
    match String.equal t.current_path t.origin with
    | true -> t
    | false ->
      let current_path, parent =
        remove_last_path t.current_path, remove_last_path t.parent
      in
      (match get_idx t ~parent ~current_path with
       | Some idx ->
         print_s [%message (idx : int)];
         { t with parent; cursor = idx; current_path }
       | None -> { t with parent; current_path })
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

let rename ~(model : State.t) new_name =
  let new_path =
    String.concat
      [ State.remove_last_path model.current_path; "/"; new_name ]
  in
  let siblings =
    (match Hashtbl.find model.choices.matrix model.parent with
     | Some lst -> lst
     | None -> [])
    |> List.map ~f:(fun elem ->
      match String.equal model.current_path elem with
      | true -> new_path
      | false -> elem)
  in
  let _ =
    match siblings with
    | [] -> ()
    | _ -> Hashtbl.set model.choices.matrix ~key:model.parent ~data:siblings
  in
  Format.sprintf {|mv %s %s|} model.current_path new_path
;;

let valid s =
  String.fold ~init:true s ~f:(fun acc ch ->
    match Char.is_alphanum ch with
    | true -> acc
    | false -> (match ch with '.' | '_' | '-' -> true | _ -> false))
;;

let update event (model : State.t) =
  let open Minttea in
  if model.quitting |> not
  then (
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
      model, Command.Noop
    | Event.KeyDown (Key "p", _modifier) ->
      State.get_updated_model_for_preview model, Command.Noop
    | Event.KeyDown (Key "d", Ctrl) ->
      State.get_updated_model_for_remove model, Minttea.Command.Noop
    | Event.KeyDown (Key "r", Ctrl) ->
      State.get_updated_model_for_rename model, Command.Noop
    | _ -> model, Minttea.Command.Noop)
  else (
    match event with
    | Event.KeyDown (Escape, _modifier) ->
      State.get_updated_model_for_rename model, Command.Noop
    | Event.KeyDown (Enter, _modifier) ->
      let _ =
        Leaves.Text_input.current_text model.text
        |> rename ~model
        |> Sys_unix.command
      in
      State.get_updated_model_for_rename model, Command.Noop
    | Event.KeyDown (Key s, _modifier) when valid s ->
      let text = Leaves.Text_input.update model.text event in
      { model with text }, Command.Noop
    | Event.KeyDown (Backspace, _modifier)
    | Event.KeyDown (Left, _modifier)
    | Event.KeyDown (Right, _modifier) ->
      let text = Leaves.Text_input.update model.text event in
      { model with text }, Command.Noop
    | _ -> model, Command.Noop)
;;

let get_view (model : State.t) ~origin =
  match String.length model.path_to_preview > 0 with
  | true ->
    (match State.is_directory model.choices.matrix model.path_to_preview with
     | true -> ""
     | false -> Preview.preview model.path_to_preview ~num_lines:5)
  | false ->
    let options =
      Visualize_helper.visualize
        model.choices.matrix
        ~current_directory:origin
        ~path_to_be_underlined:model.current_path
    in
    "\x1b[0mPress ^C to quit\n"
    ^ Format.sprintf {|%s|} options
    ^
    if model.quitting
    then Format.sprintf "\n%s\n" @@ Leaves.Text_input.view model.text
    else ""
;;

let get_initial_state ~origin ~max_depth : State.t =
  { choices =
      Visualize.Adjacency_matrix.create ()
      |> Visualize.Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
  ; current_path = origin
  ; origin
  ; parent = State.remove_last_path origin
  ; cursor = 0
  ; path_to_preview = ""
  ; text = Leaves.Text_input.make "" ~placeholder:"" ~cursor:cursor_func ()
  ; quitting = false
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
