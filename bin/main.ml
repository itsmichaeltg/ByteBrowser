(* open! Core

let () = Command_unix.run File_manager_lib.command *)
open Minttea

type model =
  { (* the choices that will be used and whether they are selected or
       unselected *)
    choices : (string * [ `selected | `unselected ]) list
  ; (* the current position of the cursor *)
    cursor : int
  }

let initial_model =
  { cursor = 0
  ; choices =
      [ "/home/ubuntu/jsip-final-project/", `unselected
      ; "/home/ubuntu/", `unselected
      ; "/home/ubuntu/jsip-final-project/test_dir/", `unselected
      ]
  }
;;

let init _model = Command.Noop

let update event model =
  match event with
  (* if we press `q` or the escape key, we exit *)
  | Event.KeyDown ((Key "q" | Escape), _modifier) -> model, Command.Quit
  (* if we press up or `k`, we move up in the list *)
  | Event.KeyDown ((Up | Key "k"), _modifier) ->
    let cursor =
      if model.cursor = 0
      then List.length model.choices - 1
      else model.cursor - 1
    in
    { model with cursor }, Command.Noop
  (* if we press down or `j`, we move down in the list *)
  | Event.KeyDown ((Down | Key "j"), _modifier) ->
    let cursor =
      if model.cursor = List.length model.choices - 1
      then 0
      else model.cursor + 1
    in
    { model with cursor }, Command.Noop
  (* when we press enter or space we toggle the item in the list that the
     cursor points to *)
  | Event.KeyDown ((Enter | Space), _modifier) ->
    let toggle status =
      match status with `selected -> `unselected | `unselected -> `selected
    in
    let choices =
      List.mapi
        (fun idx (name, status) ->
          let status =
            if idx = model.cursor then toggle status else status
          in
          name, status)
        model.choices
    in
    let str, _ = (List.nth model.choices model.cursor) in
    let file = Out_channel.open_text "bin/path.txt" in
    Out_channel.output_string file str;
    Out_channel.flush file;
    Out_channel.close file;
    { model with choices }, Command.Quit
  (* for all other events, we do nothing *)
  | _ -> model, Command.Noop
;;

let view model =
  (* we create our options by mapping over them *)
  let options =
    model.choices
    |> List.mapi (fun idx (name, checked) ->
      let cursor = if model.cursor = idx then ">" else " " in
      let checked = if checked = `selected then "x" else " " in
      Format.sprintf "%s [%s] %s" cursor checked name)
    |> String.concat "\n"
  in
  (* and we send the UI for rendering! *)
  Format.sprintf
    {|    
%s
    
Press q to quit.
    
      |}
    options
;;

let app = Minttea.app ~init ~update ~view ()
let () = Minttea.start app ~initial_model