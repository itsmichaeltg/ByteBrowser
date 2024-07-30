open! Core

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

let rename ~(model : State.t) new_name =
  let new_path =
    String.concat
      [ State.remove_last_path (State.get_current_path model)
      ; "/"
      ; new_name
      ]
  in
  let siblings =
    (match Hashtbl.find (State.get_tree model) (State.get_parent model) with
     | Some lst -> lst
     | None -> [])
    |> List.map ~f:(fun elem ->
      match String.equal (State.get_current_path model) elem with
      | true -> new_path
      | false -> elem)
  in
  let _ =
    match siblings with
    | [] -> ()
    | _ ->
      Hashtbl.set
        (State.get_tree model)
        ~key:(State.get_parent model)
        ~data:siblings
  in
  ( Format.sprintf {|mv %s %s|} (State.get_current_path model) new_path
  , State.get_model_with_new_current_path
      model
      (String.concat [ State.get_parent model; "/"; new_name ]) )
;;

let valid s =
  String.fold ~init:true s ~f:(fun acc ch ->
    match Char.is_alphanum ch with
    | true -> acc
    | false -> (match ch with '.' | '_' | '-' -> true | _ -> false))
;;

let move_arround event (model : State.t) =
  let open Minttea in
  match event with
  | Event.KeyDown ((Left | Key "h"), _modifier) ->
    State.get_updated_model_for_left model, Command.Noop
  | Event.KeyDown ((Right | Key "l"), _modifier) ->
    State.get_updated_model_for_right model, Command.Noop
  | Event.KeyDown ((Up | Key "k"), _modifier) ->
    State.get_updated_model_for_up model, Command.Noop
  | Event.KeyDown ((Down | Key "j"), _modifier) ->
    State.get_updated_model_for_down model, Command.Noop
  | Event.KeyDown (Enter, _modifier) ->
    State.get_updated_model_for_move model, Command.Noop
  | _ -> model, Command.Noop
;;

let update event (model : State.t) =
  let open Minttea in
  if State.get_is_moving model
  then move_arround event model
<<<<<<< HEAD
  else if not (State.get_is_writing model)
=======
  else if model.writing |> not
>>>>>>> 3d7e36f6d9003da881099e2bbaf80386c3671ca9
  then (
    match event with
    | Event.KeyDown (Left, _modifier)
    | Event.KeyDown (Down, _modifier)
    | Event.KeyDown (Right, _modifier)
    | Event.KeyDown (Up, _modifier) ->
      move_arround event model
    | Event.KeyDown (Enter, _modifier) ->
<<<<<<< HEAD
      print_endline (Format.sprintf "cd %s" (State.get_current_path model));
      State.get_updated_model_for_change_dir model, Command.Noop
=======
      State.get_updated_model_for_change_dir model, exit 0
>>>>>>> 3d7e36f6d9003da881099e2bbaf80386c3671ca9
    | Event.KeyDown (Key "p", _modifier) ->
      State.get_updated_model_for_preview model, Command.Noop
    (* | Event.KeyDown (Key "v", _modifier) ->
       State.get_updated_model_for_reduced_tree model, Command.Noop *)
    | Event.KeyDown (Key "d", Ctrl) ->
      State.get_updated_model_for_remove model, Minttea.Command.Noop
    | Event.KeyDown (Key "r", _modifier) ->
      State.get_updated_model_for_rename model, Command.Noop
    | Event.KeyDown (Key "m", _modifier) ->
      print_endline
        (Format.sprintf "moivng %s" (State.get_current_path model));
      State.get_updated_model_for_move model, Command.Noop
    | _ -> model, Minttea.Command.Noop)
  else (
    match event with
    | Event.KeyDown (Escape, _modifier) ->
      State.get_updated_model_for_rename model, Command.Noop
    | Event.KeyDown (Enter, _modifier) ->
      let com, model =
        Leaves.Text_input.current_text (State.get_text model)
        |> rename ~model
      in
      let _ = Sys_unix.command com in
<<<<<<< HEAD
      State.get_model_after_writing model, Command.Noop
=======
      let model = { model with writing = false } in
      model, Command.Noop
>>>>>>> 3d7e36f6d9003da881099e2bbaf80386c3671ca9
    | Event.KeyDown (Key s, _modifier) when valid s ->
      let text = Leaves.Text_input.update (State.get_text model) event in
      State.get_model_with_new_text model text, Command.Noop
    | Event.KeyDown (Backspace, _modifier)
    | Event.KeyDown (Left, _modifier)
    | Event.KeyDown (Right, _modifier) ->
      let text = Leaves.Text_input.update (State.get_text model) event in
      State.get_model_with_new_text model text, Command.Noop
    | _ -> model, Command.Noop)
;;

let visualize_tree (model : State.t) ~origin ~max_depth =
  let tree =
    Visualize_helper.visualize
      (State.get_tree model)
      ~current_directory:origin
      ~path_to_be_underlined:(State.get_current_path model)
  in
  "\n\n\x1b[0mPress ^C to quit\n"
  ^ Format.sprintf {|%s|} tree
  ^
<<<<<<< HEAD
  if State.get_is_writing model
  then
    Format.sprintf "\n%s\n" @@ Leaves.Text_input.view (State.get_text model)
=======
  if model.writing
  then Format.sprintf "\n%s\n" @@ Leaves.Text_input.view model.text
>>>>>>> 3d7e36f6d9003da881099e2bbaf80386c3671ca9
  else ""
;;

let get_view (model : State.t) ~origin ~max_depth =
  match State.should_preview model with
  | true ->
<<<<<<< HEAD
    Preview.preview
      (State.get_path_to_preview model)
      ~num_lines:Int.max_value
=======
    (match State.is_directory model.choices.matrix model.path_to_preview with
     | true -> ""
     | false ->
       Preview.preview model.path_to_preview ~num_lines:Int.max_value)
>>>>>>> 3d7e36f6d9003da881099e2bbaf80386c3671ca9
  | false -> visualize_tree model ~origin ~max_depth
;;

let get_initial_state ~origin ~max_depth : State.t =
  let tree =
    Visualize.Adjacency_matrix.create ()
    |> Visualize.Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
  in
  let children =
    match Hashtbl.find tree.matrix origin with
    | None -> []
    | Some children -> children
  in
  let initial_path =
    match List.hd children with
    | None -> origin
    | Some first_child -> first_child
  in
  State.init
    ~choices:tree
    ~current_path:initial_path
    ~origin
    ~parent:
      (match String.equal initial_path origin with
       | true -> State.remove_last_path origin
       | false -> origin)
<<<<<<< HEAD
    ~cursor:0
    ~path_to_preview:""
    ~text:(Leaves.Text_input.make
    ""
    ~placeholder:""
    ~cursor:cursor_func
    ())
    ~is_writing:false
    ~show_reduced_tree:false
    ~is_moving:false
    ~move_from:""
=======
  ; cursor = 0
  ; path_to_preview = ""
  ; text = Leaves.Text_input.make "" ~placeholder:"" ~cursor:cursor_func ()
  ; writing = false
  ; show_reduced_tree = false
  ; reduced_choices = limited_tree
  ; full_choices = full_tree
  ; moving = false
  ; move_from = ""
  }
>>>>>>> 3d7e36f6d9003da881099e2bbaf80386c3671ca9
;;

let init _model =
  let open Minttea in
  Command.Noop
;;

let navigate ~max_depth ~origin =
  let app =
    Minttea.app ~init ~update ~view:(get_view ~origin ~max_depth) ()
  in
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
          ~doc:"INT maximum length of path to search for (default 3)"
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
