open! Core
open! Terminal_size

let get_depth_space ~depth =
  List.fold (List.init depth ~f:Fn.id) ~init:"\x1b[0m" ~f:(fun acc num ->
    match num = depth - 1 with
    | true -> acc ^ "\x1b[0;48;5;17m|__"
    | false -> acc ^ "\x1b[0;48;5;17m  ")
  ^ " "
;;

let is_directory (tree : Matrix.t) (value : string) = Matrix.mem tree value
let is_hidden_file name = String.is_prefix name ~prefix:"."

let normalize_string str ~depth ~is_dir =
  let max_rows =
    match get_columns () with None -> 100 | Some size -> size - 20
  in
  let max = max_rows - String.length str - ((depth - 1) * 2) in
  let space_needed =
    List.fold (List.init max ~f:Fn.id) ~init:"" ~f:(fun acc curr ->
      acc ^ " ")
  in
  str ^ space_needed
;;

let get_color_for_file path : string list =
  let extension = Matrix.get_extension_of_file path in
  let file_extension_to_color_json =
    Yojson.Safe.from_file
      "/home/ubuntu/jsip-final-project/src/file_extension_to_color.json"
  in
  let field_val_assoc =
    file_extension_to_color_json |> Yojson.Safe.Util.to_assoc
  in
  let target_val =
    List.Assoc.find field_val_assoc extension ~equal:String.equal
  in
  let colors_as_json_objs =
    match target_val with
    | None -> []
    | Some json_obj -> Yojson.Safe.Util.to_list json_obj
  in
  let colors = List.map colors_as_json_objs ~f:Yojson.Safe.Util.to_string in
  colors
;;

let get_styles tree ~(path_to_be_underlined : string) ~(parent : string) =
  let (styles : Styles.t) = { styles = [ "0"; "48"; "5"; "17" ] } in
  (match String.equal path_to_be_underlined parent with
   | true -> styles.styles <- List.append styles.styles [ "4"; "2" ]
   | false -> ());
  (match is_directory tree parent with
   | true ->
     styles.styles <- List.append styles.styles [ "38"; "5"; "49"; "1" ]
   | false ->
     (match is_hidden_file (Matrix.get_name parent) with
      | true ->
        styles.styles <- List.append styles.styles [ "38"; "5"; "40"; "1" ]
      | false ->
        styles.styles
        <- List.append styles.styles (get_color_for_file parent)));
  styles
;;

let get_relative_directions
  ~path_to_be_underlined
  ~parent
  ~(matrix_info : Matrix.Info.t)
  =
  match String.equal path_to_be_underlined parent with
  | true -> ""
  | false ->
    let table_opt1 = Matrix.Info.find matrix_info path_to_be_underlined in
    let table_opt2 = Matrix.Info.find matrix_info parent in
    (match table_opt1, table_opt2 with
     | Some table1, Some table2 ->
       let horizontal_diff =
         Int.abs (table1.horizontal_depth - table2.horizontal_depth)
       in
       let vertical_diff =
         Int.abs (table1.vertical_depth - table2.vertical_depth)
       in
       "\x1b[3m["
       ^ Int.to_string horizontal_diff
       ^ ","
       ^ Int.to_string vertical_diff
       ^ "] \x1b[23m"
     | _ -> "")
;;

let get_formatted_tree_with_new_parent
  tree
  ~(path_to_be_underlined : string)
  ~(parent : string)
  ~(depth : int)
  ~(so_far : string)
  ~(matrix_info : Matrix.Info.t)
  =
  so_far
  ^ "\n"
  ^ get_depth_space ~depth
  ^ Styles.get_emoji_by_dir ~is_dir:(is_directory tree parent)
  ^ Printf.sprintf
      "%s"
      (Styles.apply_style
         (get_styles tree ~path_to_be_underlined ~parent)
         ~apply_to:
           (normalize_string
              (get_relative_directions
                 ~path_to_be_underlined
                 ~parent
                 ~matrix_info
               ^ Matrix.get_name parent)
              ~depth
              ~is_dir:(is_directory tree parent)))
;;

let can_show_parent
  parent
  ~path_to_be_underlined
  ~show_reduced_tree
  ~(matrix_info : Matrix.Info.t)
  ~depth
  =
  let vertical_threshold = 8 in
  let horizontal_threshold = 8 in
  match show_reduced_tree with
  | false -> true
  | true ->
    let parent_table = Matrix.Info.find matrix_info parent in
    let user_location_table =
      Matrix.Info.find matrix_info path_to_be_underlined
    in
    (match parent_table, user_location_table with
     | Some table1, Some table2 ->
       Int.abs (table1.abs_vertical_loc - table2.abs_vertical_loc)
       <= vertical_threshold
       && Int.abs (table1.horizontal_depth - table2.horizontal_depth)
          <= horizontal_threshold
     | _ -> true)
;;

let rec helper
  ~(so_far : string)
  (tree : Matrix.t)
  ~(depth : int)
  ~(parent : string)
  ~(path_to_be_underlined : string)
  ~(matrix_info : Matrix.Info.t)
  ~(show_reduced_tree : bool)
  ~(paths_to_collapse : (string, String.comparator_witness) Set.t)
  : string
  =
  match
    can_show_parent
      parent
      ~path_to_be_underlined
      ~show_reduced_tree
      ~matrix_info
      ~depth
  with
  | false -> so_far
  | true ->
    (match Matrix.find tree parent with
     | None ->
       get_formatted_tree_with_new_parent
         tree
         ~parent
         ~depth
         ~so_far
         ~path_to_be_underlined
         ~matrix_info
     | Some current_children ->
       (match Set.mem paths_to_collapse parent with
        | true ->
          get_formatted_tree_with_new_parent
            tree
            ~parent
            ~depth
            ~so_far
            ~path_to_be_underlined
            ~matrix_info
        | false ->
          let init =
            get_formatted_tree_with_new_parent
              tree
              ~parent
              ~depth
              ~so_far
              ~path_to_be_underlined
              ~matrix_info
          in
          List.fold current_children ~init ~f:(fun acc child ->
            helper
              ~so_far:acc
              tree
              ~depth:(depth + 1)
              ~parent:child
              ~path_to_be_underlined
              ~matrix_info
              ~show_reduced_tree
              ~paths_to_collapse)))
;;

let apply_outer_styles tree = Styles.apply_borders tree

let visualize
  (tree : Matrix.t)
  ~(current_directory : string)
  ~(path_to_be_underlined : string)
  ~(matrix_info : Matrix.Info.t)
  ~(show_reduced_tree : bool)
  ~(paths_to_collapse : (string, String.comparator_witness) Set.t)
  : string
  =
  let tree =
    helper
      tree
      ~matrix_info
      ~depth:1
      ~so_far:
        ("\x1b[48;5;17m"
         ^ normalize_string "\x1b[3m.\x1b[23m" ~depth:(-1) ~is_dir:false
         ^ " ")
      ~parent:current_directory
      ~path_to_be_underlined
      ~show_reduced_tree
      ~paths_to_collapse
  in
  apply_outer_styles tree ^ "\n\x1b[0m"
;;

(* apply_outer_styles tree ^ "\n\x1b[0m" *)

(* let print_dir (t : Matrix.t) ~origin = visualize t
   ~current_directory:origin ~path_to_be_underlined:"" ;;

   let matrix_visualize ~max_depth ~origin ~show_hidden ~sort = let matrix =
   Matrix.create () |> Matrix.get_adjacency_matrix ~origin ~max_depth
   ~show_hidden ~sort in print_dir ~origin matrix |> print_endline ;; *)
