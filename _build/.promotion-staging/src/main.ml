open! Core

module Adjacency_matrix = struct
  type t = {
    matrix : (string, string list) Hashtbl.t
  }[@@deriving sexp_of]

  let create () = {matrix = Hashtbl.create (module String)};;

  let get_files_in_dir origin : string list = Sys_unix.ls_dir origin;;

  let%expect_test "files_in_dir" = 
    print_s[%sexp (get_files_in_dir ("/home/ubuntu/jsip-final-project"):string list)];
    [%expect {|(src .git jsip_final_project.opam test README.md lib dune-project _build bin)|}]
  ;;

  let rec get_adjacency_matrix t ~origin ~max_depth = 
    match max_depth with
    | 0 -> t
    | _ -> 
      let data = get_files_in_dir origin in 
      Hashtbl.add_exn t.matrix ~key:origin ~data;
      List.fold ~init:t data ~f:(fun _ i -> 
        let new_path = String.concat [origin; "/"; i] in 
        match Sys_unix.is_directory new_path with 
      | `Yes -> get_adjacency_matrix t ~origin:new_path ~max_depth:(max_depth - 1)
      | _ -> get_adjacency_matrix t ~origin ~max_depth:0)
  ;;

  let%expect_test "adjacency_matrix" = 
    print_s[%sexp ((get_adjacency_matrix (create ()) ~origin:"/home/ubuntu/" ~max_depth:2):t)];
    [%expect {|
    ((matrix
      ((/home/ubuntu/
        (.emacs .ssh snake .local jsip-final-project .admin async-exercises
         .vscode-server tictactoe-controller.exe wiki.pdf .bashrc interstate.pdf
         .cache .vimrc .gitconfig .emacs.d .jupyter .viminfo .opam .profile
         .bash_logout command-demo .ocamlinit .lesshst game-strategies
         .Xauthority raster friends.pdf raster-1 .inputrc .ipython .dotnet
         .ipynb_checkpoints snake_demo.exe wiki-game .sudo_as_admin_successful
         .bash_history .wget-hsts))
       (/home/ubuntu//.admin (dune))
       (/home/ubuntu//.cache (motd.legal-displayed dune pip Microsoft))
       (/home/ubuntu//.dotnet (corefx))
       (/home/ubuntu//.emacs.d
        (savehist elpa ac-comphist.dat %backup%~ backups auto-save-list
         opam-user-setup.el))
       (/home/ubuntu//.ipynb_checkpoints (Untitled-checkpoint.ipynb))
       (/home/ubuntu//.ipython (profile_default))
       (/home/ubuntu//.jupyter (lab migrated jupyter_notebook_config.py))
       (/home/ubuntu//.local (lib etc bin share))
       (/home/ubuntu//.opam
        (plugins log config config.lock 4.14.1 opam-init default repo lock
         download-cache))
       (/home/ubuntu//.ssh
        (known_hosts.old known_hosts authorized_keys id_ed25519 id_ed25519.pub))
       (/home/ubuntu//.vscode-server
        (.611f9bfce64f25108829dd295f54a6894e87339d.token
         .abd2f3db4bdb28f9e95536dfa84d8479f1eb312d.log
         .74f6148eb9ea00507ec113ec51c489d6ffb4b771.token
         .74f6148eb9ea00507ec113ec51c489d6ffb4b771.pid cli
         .74f6148eb9ea00507ec113ec51c489d6ffb4b771.log
         .abd2f3db4bdb28f9e95536dfa84d8479f1eb312d.token extensions data
         .611f9bfce64f25108829dd295f54a6894e87339d.log
         .611f9bfce64f25108829dd295f54a6894e87339d.pid
         code-dc96b837cf6bb4af9cd736aa3af08cf8279f7685
         .cli.dc96b837cf6bb4af9cd736aa3af08cf8279f7685.log bin
         .abd2f3db4bdb28f9e95536dfa84d8479f1eb312d.pid))
       (/home/ubuntu//async-exercises
        (src .git README.md dune-project _build bin))
       (/home/ubuntu//command-demo
        (.ocamlformat dune dune-project _build main.mli main.ml))
       (/home/ubuntu//game-strategies
        (.git common README.md lib dune-project _build controller bin game.txt))
       (/home/ubuntu//jsip-final-project
        (src .git jsip_final_project.opam test README.md lib dune-project _build
         bin))
       (/home/ubuntu//raster
        (.ocamlformat src .git test README.md dune-project _build .gitignore less
         bin images))
       (/home/ubuntu//raster-1
        (.ocamlformat src .git test README.md dune-project _build .gitignore bin
         images))
       (/home/ubuntu//snake
        (.ocamlformat src .git Exercise09.mkd README.mkd Exercise07.mkd
         Exercise10.mkd dune-project _build LIST_FUNCTIONS.mkd .gitignore .tests
         Exercise08.mkd bin))
       (/home/ubuntu//wiki-game
        (.ocamlformat src .git .vscode web-dev wiki.pdf resources test README.md
         dune-project _build .gitignore bin images)))))
    |}]
  ;;
end

let get_name path = 
  match String.contains path '/' with
  | false -> path 
  | true -> List.last_exn (String.split path ~on:'/') ;;

let%expect_test "get_name" = 
  print_endline (get_name "/home/ubuntu/jsip-final-project");
  print_endline (get_name "dune-project"); 
  [%expect {|
    jsip-final-project
    dune-project
    |}]
;;

let print_dir map : unit = () ;;

let visualize ~max_depth ~origin = 
  let matrix = Adjacency_matrix.create () in
  Adjacency_matrix.get_adjacency_matrix ~origin ~max_depth matrix
  |> print_dir;
;;

let visualize_command = 
  let open Command.Let_syntax in
  Command.basic
    ~summary:
      "build directory tree"
    [%map_open
      let origin = flag "origin" (required string) ~doc:" the starting directory"
      and max_depth =
        flag
          "max-depth"
          (optional_with_default 10 int)
          ~doc:"INT maximum length of path to search for (default 10)"
      in
      fun () ->
        visualize ~max_depth ~origin;]
;;
 
let command =
  Command.group
    ~summary:"directory manager commands"
    ["visualize", visualize_command]
;;