open! Core

type comm =
  | Init
  | Snap
  | Restore

let rec find_init_dir init_dir =
  if String.equal init_dir ""
  then
    failwith
      "fatal: not a snapshot repository (or any of the parent directories)";
  let exists =
    init_dir
    |> Sys_unix.ls_dir
    |> List.exists ~f:(fun i -> String.equal i ".snapshots")
  in
  if exists then init_dir else find_init_dir init_dir
;;

let take_snapshot filename ~message =
  let init_dir = find_init_dir (Sys_unix.getcwd ()) in
  let file_path = init_dir ^ "/" ^ filename in
  let snapshot_name =
    Matrix.get_name filename
    ^ "--"
    ^ String.substr_replace_all
        ~pattern:" "
        ~with_:"-"
        (Time_ns_unix.to_string (Time_ns_unix.now ()))
  in
  let snapshot_path = init_dir ^ "/.snapshots/" ^ snapshot_name in
  let _ =
    Format.sprintf "cp %s %s" file_path snapshot_path |> Sys_unix.command
  in
  let snapshot, log_path =
    ( Format.sprintf "%s message: %s" snapshot_name message
    , Format.sprintf "%s/log.txt" init_dir )
  in
  let _ =
    Format.sprintf
      "echo %s | cat - %s > tmp && mv tmp %s"
      snapshot
      log_path
      log_path
    |> Sys_unix.command
  in
  ()
;;

let format_str s =
  match String.get s (String.length s - 1) with
  | '-' -> String.slice s 0 (String.length s - 1)
  | _ -> s
;;

let get_name snapshot_name =
  let str, _ =
    String.fold_until
      snapshot_name
      ~init:("", false)
      ~f:(fun (s, b) i ->
        match i with
        | '-' ->
          if b
          then Stop (format_str s, true)
          else Continue (s ^ String.of_char i, true)
        | _ -> Continue (s ^ String.of_char i, false))
      ~finish:(fun (s, _) -> s, false)
  in
  str
;;

let get_last_log filename ~init_dir =
  In_channel.read_lines (init_dir ^ "/log.txt")
  |> List.fold_until
       ~init:""
       ~f:(fun _ i ->
         if String.equal (get_name i) filename then Stop i else Continue "")
       ~finish:(fun s -> s)
  |> String.split ~on:' '
  |> List.hd_exn
;;

let restore ?snapshot_name filename =
  let init_dir = find_init_dir (Sys_unix.getcwd ()) in
  let snapshot_name =
    match snapshot_name with
    | Some str -> str
    | None -> get_last_log ~init_dir (Matrix.get_name filename)
  in
  let snapshot_path = init_dir ^ "/.snapshots/" ^ snapshot_name in
  let file_path = init_dir ^ "/" ^ filename in
  let _ =
    Format.sprintf "cp %s %s" snapshot_path file_path |> Sys_unix.command
  in
  ()
;;

let init () =
  let curr_path = Sys_unix.getcwd () in
  let _ =
    Format.sprintf "mkdir %s/.snapshots" curr_path |> Sys_unix.command
  in
  let _ = Format.sprintf "touch %s/log.txt" curr_path |> Sys_unix.command in
  ()
;;

let snap_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"takes a snapshot of a given file"
    [%map_open
      let message = flag "-message" (required string) ~doc:"snapshot note"
      and filename = anon ("filename" %: string) in
      fun () -> take_snapshot filename ~message]
;;

let restore_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"restores a specfic (or the last by default) commit"
    [%map_open
      let filename = anon ("file" %: string)
      and snapshot_name =
        flag "commit" (optional string) ~doc:"commit name from log.txt"
      in
      fun () ->
        match snapshot_name with
        | Some str -> restore filename ~snapshot_name:str
        | None -> restore filename]
;;

let init_command =
  Command.basic
    ~summary:"initializes a repo"
    (Command.Param.return (fun () -> init ()))
;;

let command =
  Command.group
    ~summary:"snapshot commands"
    [ "snap", snap_command
    ; "restore", restore_command
    ; "init", init_command
    ]
;;
