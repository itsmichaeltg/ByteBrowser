open! Core

module State = struct
  type t = { choices : Visualize.Adjacency_matrix.t ; current_path : string; origin : string } [@@deriving sexp_of]

  let init ~origin ~max_depth = 
    { choices = Visualize.Adjacency_matrix.create () 
      |> Visualize.Adjacency_matrix.get_adjacency_matrix 
      ~origin ~max_depth
      ; current_path = origin
      ; origin = origin}
  ;;
end

let view model =
  let options = Visualize_helper.visualize model.choices ~current_directory:origin ~path_to_be_underlined:model.current_path in
  Format.sprintf {|Press q or Esc to quit.\n%s|} options
;;

let update event model = 
  match even with
  | Event.KeyDown ((Key "q" | Escape), _modifier) -> (model, Command.Quit)
  | Event.KeyDown ((Left), _modifier) ->  
    let current_path = 
      match Hashtbl.find_opt model.choices with 
      | Some lst -> List.hd_exn lst
      | None -> model.current_path
    in
    ({ model with current_path}, Command.Noop)
  | Event.KeyDown ((Right), _modifier) ->
    let current_path = 
      match List.(String.split current_path ~sep:'/') with 
      | Some lst -> 
      | None -> model.current_path
    in
    ({ model with current_path}, Command.Noop)
  | Event.KeyDown ((Enter), _modifier) -> Sys_unix.chdir model.current_path
      
;;
let navigate ~max_depth ~origin = ()

let pwd_navigate_command =
  let open Command.Let_syntax in
  Command.basic
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
  Command.group
    ~summary:"file manager commands"
    [ "pwd", pwd_navigate_command; "dir", start_navigate_command ]
;;
