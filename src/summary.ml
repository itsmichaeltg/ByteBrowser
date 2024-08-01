open! Core

let path_to_read_from = "/home/ubuntu/jsip-final-project/src/completion.txt"

let path_to_script =
  "/home/ubuntu/jsip-final-project/src/summarization_script.py"
;;

let path_to_write_to =
  "/home/ubuntu/jsip-final-project/src/file_contents.txt"
;;

let rec find_paths_to_skim tree origin =
  match Hashtbl.find tree origin with
  | None -> [ origin ]
  | Some children ->
    List.fold children ~init:[] ~f:(fun acc child ->
      List.append acc (find_paths_to_skim tree child))
;;

let generate (tree : Visualize.Adjacency_matrix.tree) (origin : string) =
  let paths_to_skim = find_paths_to_skim tree origin in
  let contents_of_paths =
    List.fold paths_to_skim ~init:"" ~f:(fun acc path ->
      acc
      ^ "/n"
      ^ Printf.sprintf
          "File name: %s"
          (Visualize.Adjacency_matrix.get_name path)
      ^ Printf.sprintf
          "Contents of file: %s"
          (Preview.preview path ~num_lines:Int.max_value))
  in
  Out_channel.write_all path_to_write_to ~data:contents_of_paths;
  let command = Printf.sprintf "python3 %s" path_to_script in
  let _ = Sys_unix.command command in
  let result = In_channel.read_all path_to_read_from in
  result
;;
