open! Core
open! Leaves
open! Leaves.Cursor

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

type t =
  { choices : Visualize.Adjacency_matrix.t
  ; current_path : string
  ; origin : string
  ; parent : string
  ; cursor : int
  ; path_to_preview : string
  ; text : Text_input.t
  ; is_writing : bool
  ; show_reduced_tree : bool
  ; move_from : string
  ; is_moving : bool
  }

type dir =
  | UP
  | DOWN

let should_preview t =
  String.length t.path_to_preview > 0
  && not
       (Visualize.Adjacency_matrix.is_directory t.choices t.path_to_preview)
;;

let get_is_moving t = t.is_moving
let get_tree t = t.choices.matrix
let get_current_path t = t.current_path
let get_text t = t.text
let get_parent t = t.parent
let get_is_writing t = t.is_writing
let get_path_to_preview t = t.path_to_preview
let get_model_after_writing t = { t with is_writing = false }
let get_model_with_new_text t new_text = { t with text = new_text }

let get_model_with_new_current_path t new_current_path =
  { t with current_path = new_current_path }
;;

let get_updated_model_for_move t =
  { t with is_moving = true; move_from = t.current_path }
;;

let remove_last_path current_path =
  let str_lst = String.split current_path ~on:'/' in
  List.foldi str_lst ~init:[] ~f:(fun idx new_lst elem ->
    match idx = List.length str_lst - 1 with
    | true -> new_lst
    | false -> new_lst @ [ elem ])
  |> String.concat ~sep:"/"
;;

let init
  ~choices
  ~origin
  ~current_path
  ~parent
  ~cursor
  ~path_to_preview
  ~text
  ~is_writing
  ~show_reduced_tree
  ~is_moving
  ~move_from
  =
  { choices
  ; current_path
  ; origin
  ; parent
  ; cursor
  ; path_to_preview
  ; text
  ; is_writing
  ; show_reduced_tree
  ; is_moving
  ; move_from
  }
;;

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

let get_updated_model_for_preview t =
  match t.path_to_preview with
  | "" -> { t with path_to_preview = t.current_path }
  | _ -> { t with path_to_preview = "" }
;;

let get_updated_model_for_rename t =
  let is_writing = true in
  let text =
    Leaves.Text_input.make "" ~placeholder:"" ~cursor:cursor_func ()
  in
  { t with is_writing; text }
;;

let remove_helper t ~parent ~child =
  let siblings =
    (match Hashtbl.find t.choices.matrix parent with
     | Some lst -> lst
     | None -> [])
    |> List.filter ~f:(fun elem -> String.equal child elem |> not)
  in
  match siblings with
  | [] -> ()
  | _ -> Hashtbl.set t.choices.matrix ~key:parent ~data:siblings
;;

let get_updated_model_for_change_dir t =
  Out_channel.write_all write_path ~data:t.current_path;
  t
;;

let get_updated_model_for_move t =
  match Visualize.Adjacency_matrix.is_directory t.choices t.current_path with
  | true ->
    remove_helper t ~parent:(remove_last_path t.move_from) ~child:t.move_from;
    Hashtbl.set
      t.choices.matrix
      ~key:t.current_path
      ~data:
        (Hashtbl.find_exn t.choices.matrix t.current_path
         @ [ String.concat
               [ t.current_path; "/"; Visualize_helper.get_name t.move_from ]
           ]);
    let _ =
      Format.sprintf {|mv %s %s|} t.move_from t.current_path
      |> Sys_unix.command
    in
    let move_from = "" in
    let is_moving = false in
    { t with move_from; is_moving }
  | false -> t
;;

let get_updated_model_for_remove t =
  remove_helper t ~parent:t.parent ~child:t.current_path;
  let _ = Format.sprintf {|rm -rf %s|} t.current_path |> Sys_unix.command in
  t
;;

let get_idx t ~parent ~current_path =
  if String.equal t.parent current_path |> not
  then
    Hashtbl.find_exn t.choices.matrix parent
    |> List.foldi ~init:0 ~f:(fun idx acc elem ->
      if String.equal elem current_path then idx else acc)
  else 0
;;

let get_updated_model_for_shortcut t ~key =
  let current_path =
    Hashtbl.find_exn t.choices.matrix t.parent
    |> List.fold_until
         ~init:None
         ~finish:(fun str -> str)
         ~f:(fun str i ->
           if String.equal
                (String.get (Visualize_helper.get_name i) 0 |> String.of_char)
                key
              && String.equal t.current_path i |> not
           then Stop (Some i)
           else Continue None)
  in
  match current_path with
  | Some current_path ->
    let cursor = get_idx t ~parent:t.parent ~current_path in
    { t with cursor; current_path }
  | None -> t
;;

let handle_up_and_down t ~dir =
  let cursor = get_idx_by_dir t ~dir in
  let current_path =
    try List.nth_exn (Hashtbl.find_exn t.choices.matrix t.parent) cursor with
    | _ -> t.current_path
  in
  let tmp_model = { t with cursor } in
  { tmp_model with current_path }
;;

let get_updated_model_for_right t =
  let current_path =
    try Hashtbl.find_exn t.choices.matrix t.current_path with _ -> []
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

let get_updated_model_for_left t =
  let current_path, parent, cursor =
    match String.equal t.current_path t.origin with
    | true -> t.current_path, t.parent, t.cursor
    | false ->
      let current_path, parent =
        remove_last_path t.current_path, remove_last_path t.parent
      in
      current_path, parent, get_idx t ~parent ~current_path
  in
  { t with cursor; parent; current_path }
;;

let get_updated_model_for_up t = handle_up_and_down t ~dir:UP
let get_updated_model_for_down t = handle_up_and_down t ~dir:DOWN
(* let get_updated_model_for_reduced_tree t = match t.show_reduced_tree with
   | true -> { t with show_reduced_tree = false; choices = t.full_choices } |
   false -> { t with show_reduced_tree = true ; choices = t.reduced_choices
   (* ; current_path = t.origin *) } *)
