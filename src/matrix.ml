open! Core

type t = (string, String.Set.t) Hashtbl.t [@@deriving sexp_of]

type table =
  { horizontal_depth : int
  ; vertical_depth : int
  ; abs_vertical_loc : int
  }
[@@deriving sexp_of]

module Info = struct
  type t = (string, table) Hashtbl.t [@@deriving sexp_of]

  let create () = Hashtbl.create (module String)
  let add_exn (t : t) ~key ~data = Hashtbl.add_exn t ~key ~data
  let find (t : t) key = Hashtbl.find t key
end

let find (t : t) b = Hashtbl.find t b
let find_exn (t : t) b = Hashtbl.find_exn t b
let mem (t : t) a = Hashtbl.mem t a
let set (t : t) ~key ~data = Hashtbl.set t ~key ~data
let create () = Hashtbl.create (module String)
let is_directory t (value : string) = mem t value
let hidden str = Char.equal (String.nget str 0) '.'
let add_exn (t : t) ~key ~data = Hashtbl.add_exn t ~key ~data
let length (t : t) = Hashtbl.length t

let get_name path =
  match String.contains path '/' with
  | false -> path
  | true -> List.last_exn (String.split path ~on:'/')
;;

let remove_last_path current_path =
  let str_lst = String.split current_path ~on:'/' in
  List.foldi str_lst ~init:[] ~f:(fun idx new_lst elem ->
    match idx = List.length str_lst - 1 with
    | true -> new_lst
    | false -> new_lst @ [ elem ])
  |> String.concat ~sep:"/"
;;

let get_extension_of_file path =
  let file_name = get_name path in
  String.fold
    (String.rev file_name)
    ~init:("", true)
    ~f:(fun (acc, should_add_char) char ->
      match should_add_char with
      | false -> acc, false
      | true ->
        (match Char.equal char '.' with
         | true -> acc, false
         | false -> acc ^ Char.to_string char, true))
  |> fst
  |> String.rev
;;

let is_directory t (value : string) = mem t value
let get_children t path = find t path

let write_and_read origin =
  let write_path = "/home/ubuntu/jsip-final-project/bin/files.txt" in
  let _ =
    Format.sprintf "ls -t %s > %s" origin write_path |> Sys_unix.command
  in
  In_channel.read_lines write_path
;;

let rec is_in_directory t path ~path_to_check =
  match get_children t path with
  | None -> String.equal path path_to_check
  | Some children ->
    Set.fold children ~init:false ~f:(fun prev_primary_decision child_path ->
      match prev_primary_decision with
      | true -> true
      | false -> is_in_directory t path ~path_to_check)
;;

let get_files_in_dir origin ~show_hidden ~sort =
  let data =
    if not sort
    then (try Sys_unix.ls_dir origin with _ -> [])
    else write_and_read origin
  in
  let data = data |> String.Set.of_list in
  if show_hidden then data else Set.filter data ~f:(fun i -> hidden i |> not)
;;

let rec get_adjacency_matrix t ~sort ~show_hidden ~origin ~max_depth =
  match max_depth with
  | 0 ->
    (match Sys_unix.is_directory origin with
     | `Yes -> add_exn t ~key:origin ~data:String.Set.empty
     | _ -> ());
    t
  | _ ->
    let data =
      String.Set.map
        (get_files_in_dir origin ~show_hidden ~sort)
        ~f:(fun i -> String.concat [ origin; "/"; i ])
    in
    add_exn t ~key:origin ~data;
    Set.fold ~init:t data ~f:(fun _ i ->
      match Sys_unix.is_directory i with
      | `Yes ->
        get_adjacency_matrix
          t
          ~origin:i
          ~max_depth:(max_depth - 1)
          ~show_hidden
          ~sort
      | _ -> get_adjacency_matrix t ~origin:i ~max_depth:0 ~show_hidden ~sort)
;;

let rec helper
  t
  ~(info_map : Info.t)
  ~current_path
  ~horizontal_depth
  ~vertical_depth
  ~abs_vertical_loc
  =
  Info.add_exn
    info_map
    ~key:current_path
    ~data:{ horizontal_depth; vertical_depth; abs_vertical_loc };
  match get_children t current_path with
  | None -> 1
  | Some children_paths ->
    let list_of_children_paths = Set.to_list children_paths in
    1
    + List.foldi
        list_of_children_paths
        ~init:0
        ~f:(fun idx count_prev_sub_branches child_path ->
          count_prev_sub_branches
          + helper
              t
              ~info_map
              ~current_path:child_path
              ~horizontal_depth:(horizontal_depth + 1)
              ~abs_vertical_loc:
                (abs_vertical_loc + count_prev_sub_branches + 1)
              ~vertical_depth:(vertical_depth + idx + 1))
;;

let rec fill_info_from_matrix t ~(info_map : Info.t) ~current_path =
  let _ =
    helper
      t
      ~info_map:(info_map : Info.t)
      ~current_path
      ~horizontal_depth:0
      ~vertical_depth:0
      ~abs_vertical_loc:0
  in
  ()
;;

let fold t ~f ~init = Hashtbl.fold t ~init ~f

let to_set t =
  fold
    t
    ~init:(Set.empty (module String))
    ~f:(fun ~key ~data acc -> Set.union data (Set.add acc key))
;;

let add_to_matrix map ~parent ~child =
  let data =
    match find map parent with Some s -> s | None -> String.Set.empty
  in
  set map ~key:parent ~data:(Set.add data child);
  match Sys_unix.is_directory child with
  | `Yes ->
    let child_data =
      match find map child with Some s -> s | None -> String.Set.empty
    in
    set map ~key:parent ~data:child_data
  | _ -> ()
;;

let rec add_parent_path ?(origin = "") map ~path =
  let parent = remove_last_path path in
  if String.equal origin parent || String.equal parent "/"
  then add_to_matrix map ~parent ~child:path
  else (
    add_to_matrix map ~parent ~child:path;
    add_parent_path map ~origin ~path:parent)
;;

let of_list ?origin lst =
  let map = create () in
  List.iter lst ~f:(fun path -> add_parent_path map ?origin ~path);
  map
;;

let filter ?origin t ~search =
  let s =
    to_set t |> Set.to_list
    |> List.filter ~f:(fun str -> Fuzzy.fuzzy_find (get_name str) search)
  in
  s |> of_list ?origin
;;
