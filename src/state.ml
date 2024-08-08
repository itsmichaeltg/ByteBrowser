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
  { choices : Matrix.t
  ; matrix_info : Matrix.Info.t
  ; current_path : string
  ; origin : string
  ; parent : string
  ; cursor : int
  ; preview : string
  ; text : Text_input.t
  ; is_writing : bool
  ; show_reduced_tree : bool
  ; move_from : string
  ; is_moving : bool
  ; summarization : string
  ; query_chat : string
  ; start_chatting : bool
  ; seen_summarizations : (string, string, String.comparator_witness) Map.t
  ; is_loading : bool
  ; loading_spinner : Sprite.t
  ; fzf : Matrix.t
  ; paths_to_collapse : (string, String.comparator_witness) Set.t
  ; box_dimention : int
  ; show_relative_dirs : bool
  ; show_hidden_files : bool
  }

type dir =
  | Up
  | Down
  | Left
  | Right

type action =
  | Cursor of dir
  | Shortcut of string
  | Preview
  | Rename
  | Cd
  | Remove
  | Move
  | Summarize
  | Query
  | Save_query_chat of string
  | Reset
  | Reduce_tree
  | Collapse
  | Update_box_dimension of string
  | Toggle_show_relative_dirs
  | Toggle_show_hidden_files

let blank_text =
  Leaves.Text_input.make
    ""
    ~placeholder:"type your question"
    ~cursor:cursor_func
    ()
;;

let should_preview t =
  String.length t.preview > 0
  && not (Matrix.is_directory t.choices t.current_path)
;;

let should_summarize t = String.length t.summarization > 0
let get_summarization t = t.summarization
let get_show_reduced_tree t = t.show_reduced_tree
let get_query_chat t = t.query_chat
let get_start_chatting t = t.start_chatting
let get_is_moving t = t.is_moving
let get_tree t = t.choices
let get_is_loading t = t.is_loading
let get_current_path t = t.current_path
let get_box_dimension t = t.box_dimention
let get_show_relative_dirs t = t.show_relative_dirs
let get_show_hidden_files t = t.show_hidden_files
let get_text t = t.text
let get_parent t = t.parent
let get_is_writing t = t.is_writing
let get_preview t = t.preview
let get_model_after_writing t = { t with is_writing = false }
let get_model_with_new_text t new_text = { t with text = new_text }
let get_matrix_info t = t.matrix_info
let get_paths_to_collapse t = t.paths_to_collapse

let get_updated_model_for_toggle_show_relative_dirs t =
  { t with show_relative_dirs = not t.show_relative_dirs }
;;

let get_updated_model_for_toggle_show_hidden_files t =
  { t with show_hidden_files = not t.show_hidden_files }
;;

let get_updated_model_for_summarize t =
  match String.is_empty t.summarization with
  | true ->
    (match Map.find t.seen_summarizations t.current_path with
     | None ->
       let new_summarization =
         Summary.generate (get_tree t) t.current_path
       in
       let new_seen_summarizations =
         Map.add_exn
           t.seen_summarizations
           ~key:t.current_path
           ~data:new_summarization
       in
       { t with
         summarization = new_summarization
       ; seen_summarizations = new_seen_summarizations
       ; is_loading = false
       }
     | Some existing_summarization ->
       { t with summarization = existing_summarization; is_loading = false })
  | false -> { t with summarization = ""; is_loading = false }
;;

let get_updated_model_for_query t =
  match t.is_writing with
  | true ->
    { t with is_writing = false; text = blank_text; start_chatting = false }
  | false ->
    { t with is_writing = true; text = blank_text; start_chatting = true }
;;

let get_updated_model_for_save_query_chat t ~chat =
  { t with query_chat = chat; text = blank_text }
;;

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
  ~preview
  ~text
  ~is_writing
  ~show_reduced_tree
  ~is_moving
  ~move_from
  ~summarization
  ~query_chat
  ~start_chatting
  ~seen_summarizations
  ~matrix_info
  =
  { choices
  ; current_path
  ; origin
  ; parent
  ; cursor
  ; preview
  ; text
  ; is_writing
  ; show_reduced_tree
  ; is_moving
  ; move_from
  ; summarization
  ; query_chat
  ; start_chatting
  ; seen_summarizations
  ; is_loading = false
  ; loading_spinner = Spinner.dot
  ; fzf = Matrix.create ()
  ; matrix_info
  ; paths_to_collapse = Set.empty (module String)
  ; box_dimention = 5
  ; show_relative_dirs = false
  ; show_hidden_files = false
  }
;;

let get_idx_by_dir t ~dir =
  match dir with
  | Up ->
    (try
       (t.cursor - 1) % (Matrix.find_exn t.choices t.parent |> Set.length)
     with
     | _ -> 0)
  | Down ->
    (try
       (t.cursor + 1) % (Matrix.find_exn t.choices t.parent |> Set.length)
     with
     | _ -> 0)
  | _ -> 0
;;

let get_updated_model_for_preview t =
  match t.preview with
  | "" ->
    { t with
      preview =
        Preview.preview_with_styles t.current_path ~num_lines:Int.max_value
    }
  | _ -> { t with preview = "" }
;;

let get_updated_model_for_rename t =
  let is_writing = true in
  let text =
    Leaves.Text_input.make "" ~placeholder:"" ~cursor:cursor_func ()
  in
  { t with is_writing; text }
;;

let remove_helper t ~parent ~child =
  let siblings : String.Set.t =
    Set.remove
      (match Matrix.find t.choices parent with
       | Some s -> s
       | None -> String.Set.empty)
      child
  in
  if Set.is_empty siblings
  then ()
  else Matrix.set t.choices ~key:parent ~data:siblings
;;

let get_updated_model_for_change_dir t =
  Out_channel.write_all write_path ~data:t.current_path;
  t
;;

let get_updated_model_for_move t =
  match Matrix.is_directory t.choices t.current_path with
  | true ->
    remove_helper t ~parent:(remove_last_path t.move_from) ~child:t.move_from;
    Matrix.set
      t.choices
      ~key:t.current_path
      ~data:
        (Set.add
           (Matrix.find_exn t.choices t.current_path)
           (String.concat
              [ t.current_path; "/"; Matrix.get_name t.move_from ]));
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
  match Matrix.find t.choices parent with
  | Some lst ->
    List.foldi (lst |> Set.to_list) ~init:0 ~f:(fun idx acc elem ->
      if String.equal elem current_path then idx else acc)
  | None -> 0
;;

let starts_with str ~key =
  String.equal (String.get (Matrix.get_name str) 0 |> String.of_char) key
;;

let get_first_str t ~key =
  Matrix.find_exn t.choices t.parent
  |> Set.fold_until
       ~init:None
       ~finish:(fun str -> str)
       ~f:(fun str i ->
         if String.equal
              (String.get (Matrix.get_name i) 0 |> String.of_char)
              key
         then Stop (Some i)
         else Continue None)
;;

let get_updated_model_for_shortcut t ~key =
  let siblings = Matrix.find t.choices t.parent in
  match siblings with
  | Some lst ->
    let current_path =
      lst
      |> Set.fold_until
           ~init:(None, false)
           ~finish:(fun (str, b) ->
             match str, b with
             | None, true -> get_first_str t ~key
             | _ -> str)
           ~f:(fun (str, old_path_seen) i ->
             if String.equal t.current_path i
                || starts_with t.current_path ~key |> not
             then Continue (str, true)
             else if starts_with i ~key && old_path_seen
             then Stop (Some i)
             else Continue (None, old_path_seen))
    in
    (match current_path with
     | Some current_path ->
       let cursor = get_idx t ~parent:t.parent ~current_path in
       { t with cursor; current_path }
     | None -> t)
  | None -> t
;;

let handle_up_and_down t ~dir =
  let cursor = get_idx_by_dir t ~dir in
  let current_path =
    try
      List.nth_exn (Matrix.find_exn t.choices t.parent |> Set.to_list) cursor
    with
    | _ -> t.current_path
  in
  let tmp_model = { t with cursor } in
  { tmp_model with current_path }
;;

let get_updated_model_for_right t =
  let current_path =
    try Matrix.find_exn t.choices t.current_path with _ -> String.Set.empty
  in
  if current_path |> Set.is_empty
  then t
  else (
    let current_path = List.hd_exn (current_path |> Set.to_list) in
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

let get_updated_model_for_up t = handle_up_and_down t ~dir:Up
let get_updated_model_for_down t = handle_up_and_down t ~dir:Down

let get_updated_model_for_dir t d =
  match d with
  | Left -> get_updated_model_for_left t
  | Right -> get_updated_model_for_right t
  | Up -> get_updated_model_for_up t
  | Down -> get_updated_model_for_down t
;;

let get_updated_model_for_reset t =
  { t with
    is_writing = false
  ; start_chatting = false
  ; summarization = ""
  ; query_chat = ""
  }
;;

let get_updated_model_for_reduce_tree t =
  { t with show_reduced_tree = not t.show_reduced_tree }
;;

let get_updated_model_for_collapse t =
  match Set.mem t.paths_to_collapse t.current_path with
  | true -> { t with paths_to_collapse = Set.remove t.paths_to_collapse t.current_path }
  | false -> { t with paths_to_collapse = Set.add t.paths_to_collapse t.current_path }
;;

let number_to_int number =
  match number with
  | "1" -> 1
  | "2" -> 2
  | "3" -> 3
  | "4" -> 4
  | "5" -> 5
  | "6" -> 6
  | "7" -> 7
  | "8" -> 8
  | "9" -> 9
  | _ -> 5
;;

let get_updated_model_for_updating_box_dimensions t ~number =
  { t with box_dimention = number_to_int number }
;;

let get_updated_model t ~(action : action) =
  match action with
  | Preview -> get_updated_model_for_preview t
  | Move -> get_updated_model_for_move t
  | Cursor d -> get_updated_model_for_dir t d
  | Rename -> get_updated_model_for_rename t
  | Cd -> get_updated_model_for_change_dir t
  | Remove -> get_updated_model_for_remove t
  | Shortcut key -> get_updated_model_for_shortcut t ~key
  | Summarize -> get_updated_model_for_summarize t
  | Query -> get_updated_model_for_query t
  | Save_query_chat chat -> get_updated_model_for_save_query_chat t ~chat
  | Reset -> get_updated_model_for_reset t
  | Reduce_tree -> get_updated_model_for_reduce_tree t
  | Collapse -> get_updated_model_for_collapse t
  | Update_box_dimension number ->
    get_updated_model_for_updating_box_dimensions t ~number
  | Toggle_show_relative_dirs ->
    get_updated_model_for_toggle_show_relative_dirs t
  | Toggle_show_hidden_files ->
    get_updated_model_for_toggle_show_hidden_files t
;;
