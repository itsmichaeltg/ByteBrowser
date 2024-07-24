open! Core

let command =
  Command.group
    ~summary:""
    [ "visualize", Visualize.command; "navigate", Navigate.command ]
;;
