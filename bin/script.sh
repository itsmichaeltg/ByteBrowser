#!/bin/bash
/home/ubuntu/jsip-final-project/_build/default/bin/main.exe
new_dir=$(cat ./bin/path.txt)
echo "Bash Out:"
echo $new_dir
cd /home/ubuntu/
$SHELL
