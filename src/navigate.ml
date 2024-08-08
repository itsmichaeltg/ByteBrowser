open! Core
open! Spices

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
    (match Matrix.find (State.get_tree model) (State.get_parent model) with
     | Some s -> s
     | None -> String.Set.empty)
    |> String.Set.map ~f:(fun elem ->
      match String.equal (State.get_current_path model) elem with
      | true -> new_path
      | false -> elem)
  in
  let _ =
    if Set.is_empty siblings
    then ()
    else
      Matrix.set
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
  | Event.KeyDown (Left, _modifier) ->
    State.get_updated_model model ~action:(Cursor Left), Command.Noop
  | Event.KeyDown (Right, _modifier) ->
    State.get_updated_model model ~action:(Cursor Right), Command.Noop
  | Event.KeyDown (Up, _modifier) ->
    State.get_updated_model model ~action:(Cursor Up), Command.Noop
  | Event.KeyDown (Down, _modifier) ->
    State.get_updated_model model ~action:(Cursor Down), Command.Noop
  | Event.KeyDown (Enter, _modifier) ->
    State.get_updated_model model ~action:Move, Command.Noop
  | _ -> model, Command.Noop
;;

let update event (model : State.t) =
  let open Minttea in
  if State.get_is_moving model
  then move_arround event model
  else if not (State.get_is_writing model)
  then (
    match event with
    | Event.KeyDown (Left, _modifier)
    | Event.KeyDown (Down, _modifier)
    | Event.KeyDown (Right, _modifier)
    | Event.KeyDown (Up, _modifier) ->
      move_arround event model
    | Event.KeyDown (Key "1", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "1")
      , Command.Noop )
    | Event.KeyDown (Key "2", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "2")
      , Command.Noop )
    | Event.KeyDown (Key "3", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "3")
      , Command.Noop )
    | Event.KeyDown (Key "4", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "4")
      , Command.Noop )
    | Event.KeyDown (Key "5", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "5")
      , Command.Noop )
    | Event.KeyDown (Key "6", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "6")
      , Command.Noop )
    | Event.KeyDown (Key "7", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "7")
      , Command.Noop )
    | Event.KeyDown (Key "8", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "8")
      , Command.Noop )
    | Event.KeyDown (Key "9", _modifier) ->
      ( State.get_updated_model model ~action:(Update_box_dimension "9")
      , Command.Noop )
    | Event.KeyDown (Key "n", _modifier) ->
      ( State.get_updated_model model ~action:Toggle_show_relative_dirs
      , Command.Noop )
    | Event.KeyDown (Escape, _modifier) -> model, exit 0
    | Event.KeyDown (Key "a", Ctrl) ->
      State.get_updated_model model ~action:Reduce_tree, Command.Noop
    | Event.KeyDown (Key "p", Ctrl) ->
      State.get_updated_model model ~action:Preview, Command.Noop
    | Event.KeyDown (Key "d", Ctrl) ->
      State.get_updated_model model ~action:Remove, Minttea.Command.Noop
    | Event.KeyDown (Key "r", Ctrl) ->
      State.get_updated_model model ~action:Rename, Command.Noop
    | Event.KeyDown (Key "k", Ctrl) ->
      State.get_updated_model model ~action:Summarize, Command.Noop
    | Event.KeyDown (Key "h", Ctrl) ->
      State.get_updated_model model ~action:Collapse, Command.Noop
    | Event.KeyDown (Key "m", Ctrl) ->
      print_endline
        (Format.sprintf "moivng %s" (State.get_current_path model));
      State.get_updated_model model ~action:Move, Command.Noop
    | Event.KeyDown (Key "w", Ctrl) ->
      let model_with_summarization =
        State.get_updated_model model ~action:Summarize
      in
      ( State.get_updated_model model_with_summarization ~action:Query
      , Command.Noop )
    | Event.KeyDown (Key key, _modifier) ->
      ( State.get_updated_model model ~action:(Shortcut key)
      , Minttea.Command.Noop )
    | _ -> model, Minttea.Command.Noop)
  else (
    match event with
    | Event.KeyDown (Escape, _modifier) ->
      State.get_updated_model model ~action:Reset, Command.Noop
    | Event.KeyDown (Enter, _modifier) ->
      (match State.get_start_chatting model with
       | true ->
         let chat_so_far =
           State.get_query_chat model
           ^ Leaves.Text_input.current_text (State.get_text model)
         in
         let updated_chat =
           Querying.query chat_so_far ~info:(State.get_summarization model)
         in
         ( State.get_updated_model
             model
             ~action:(Save_query_chat updated_chat)
         , Command.Noop )
       | false ->
         let com, model =
           Leaves.Text_input.current_text (State.get_text model)
           |> rename ~model
         in
         let _ = Sys_unix.command com in
         State.get_model_after_writing model, Command.Noop)
    | Event.KeyDown ((Key _ | Space), _modifier)
      when State.get_start_chatting model ->
      let text = Leaves.Text_input.update (State.get_text model) event in
      State.get_model_with_new_text model text, Command.Hide_cursor
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
      ~matrix_info:(State.get_matrix_info model)
      ~show_reduced_tree:(State.get_show_reduced_tree model)
      ~paths_to_collapse:(State.get_paths_to_collapse model)
      ~box_dimension:(State.get_box_dimension model)
      ~show_relative_dirs:(State.get_show_relative_dirs model)
  in
  Format.asprintf "%s" tree
  ^
  if State.get_is_writing model
  then
    Format.asprintf "\n%s\n" @@ Leaves.Text_input.view (State.get_text model)
  else ""
;;

let get_view (model : State.t) ~origin ~max_depth =
  "\n\n"
  ^
  match State.should_preview model with
  | true -> State.get_preview model
  | false ->
    (match State.get_start_chatting model with
     | true ->
       State.get_query_chat model
       ^ Leaves.Text_input.view (State.get_text model)
     | false ->
       (match State.should_summarize model with
        | true -> State.get_summarization model
        | false -> visualize_tree model ~origin ~max_depth))
;;

let get_initial_state ~origin ~max_depth ~show_hidden ~sort : State.t =
  let tree =
    Matrix.create ()
    |> Matrix.get_adjacency_matrix
         ~origin
         ~max_depth
         ~show_hidden
         ~sort:true
  in
  let children =
    match Matrix.find tree origin with
    | None -> String.Set.empty
    | Some children -> children
  in
  let initial_path =
    match List.hd (children |> Set.to_list) with
    | None -> origin
    | Some first_child -> first_child
  in
  let matrix_info = Matrix.Info.create () in
  Matrix.fill_info_from_matrix
    tree
    ~info_map:matrix_info
    ~current_path:origin;
  State.init
    ~choices:tree
    ~matrix_info
    ~current_path:initial_path
    ~origin
    ~parent:
      (match String.equal initial_path origin with
       | true -> State.remove_last_path origin
       | false -> origin)
    ~cursor:0
    ~preview:""
    ~text:(Leaves.Text_input.make "" ~placeholder:"" ~cursor:cursor_func ())
    ~is_writing:false
    ~show_reduced_tree:false
    ~is_moving:false
    ~move_from:""
    ~summarization:""
    ~query_chat:""
    ~start_chatting:false
    ~seen_summarizations:(Map.empty (module String))
;;

let init _ =
  let open Minttea in
  Command.Hide_cursor
;;

let format_origin origin =
  String.substr_replace_first
    ~pos:(String.length origin - 1)
    origin
    ~pattern:"/"
    ~with_:""
;;

let navigate ~max_depth ~origin ~show_hidden ~sort =
  let origin = format_origin origin in
  let app =
    Minttea.app ~init ~update ~view:(get_view ~origin ~max_depth) ()
  in
  Minttea.start
    app
    ~initial_model:(get_initial_state ~origin ~max_depth ~show_hidden ~sort)
;;

let command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"file manager commands"
    [%map_open
      let origin =
        flag
          "start"
          (optional_with_default (Sys_unix.getcwd ()) string)
          ~doc:" the starting path"
      and max_depth =
        flag
          "max-depth"
          (optional_with_default 2 int)
          ~doc:"INT maximum length of path to search for (default 2)"
      and show_hidden =
        flag
          "hidden"
          (optional_with_default false bool)
          ~doc:"(default false)"
      and sort =
        flag "sort" (optional_with_default false bool) ~doc:"(default false)"
      in
      fun () -> navigate ~max_depth ~origin ~show_hidden ~sort]
;;
