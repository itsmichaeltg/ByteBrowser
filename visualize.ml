(* open! Core

module Visualize = struct
  let run () =

end


let create_command_from_run_function run =
  Command.async
  ~summary:""
  [%map_open.Command
  let () = return ()]

let command =
  Command.group
  ~summary:"visualizing directory structure"
  [
    "visualize", create_command_from_run_function Visualize.run
  ] *)

print_endline "hello world"