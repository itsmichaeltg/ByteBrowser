open! Core
open Minttea

module State = struct
  type t =
    { choices : Visualize.Adjacency_matrix.t
    ; current_path : string
    ; origin : string
    }
  [@@deriving sexp_of]

  let init ~origin ~max_depth =
    { choices =
        Visualize.Adjacency_matrix.create ()
        |> Visualize.Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth
    ; current_path = origin
    ; origin
    }
  ;;
end

let init _model = Command.Noop 

let view (model : State.t) = 
  let options =
    Visualize_helper.visualize
      model.choices.matrix
      ~current_directory:model.origin
      ~path_to_be_underlined:model.current_path
  in
  Format.sprintf {|Press q or Esc to quit.\n%s|} options
;;

let remove_last_path current_path =
  let str_lst = String.split current_path ~on:'/' in
  List.foldi str_lst ~init:[] ~f:(fun idx new_lst elem ->
    match idx = List.length str_lst - 1 with
    | true -> new_lst
    | false -> new_lst @ [ elem ])
  |> String.concat ~sep:"/"
;;

let update event (model : State.t) =
  Event.pp Format.std_formatter event;
  match event with
  | Event.KeyDown ((Key "q" | Escape), _modifier) -> print_endline "q"; (model, Minttea.Command.Quit)
  (* | Event.KeyDown (Left | Key "h", _modifier) ->
    let current_path =
      try Hashtbl.find_exn model.choices.matrix model.current_path with
      | _ -> [ model.current_path ]
    in
    let current_path = List.hd_exn current_path in
    print_endline "left";
    { model with current_path }, Minttea.Command.Noop
  | Event.KeyDown (Right | Key "l", _modifier) ->
    let current_path =
      let new_path = remove_last_path model.current_path in
      match
        String.equal new_path model.origin || String.equal new_path ""
      with
      | false -> model.current_path
      | true -> new_path
    in
    print_endline "right";
    { model with current_path }, Minttea.Command.Noop
  | Event.KeyDown (Enter, _modifier) ->
    Sys_unix.chdir model.current_path;
    print_endline "enter";
    model, Minttea.Command.Quit *)
  | _ -> model, Minttea.Command.Noop
;;

let navigate ~max_depth ~origin = 
  let initial_model = State.init ~origin ~max_depth in
  let app = Minttea.app ~init ~update ~view () in
  Minttea.start app ~initial_model
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
  let open Core.Command.Let_syntax in
  Core.Command.basic
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
