#!/bin/bash
/home/ubuntu/jsip-final-project/_build/default/bin/main.exe
new_dir=$(cat /home/ubuntu/jsip-final-project/bin/path.txt)
cd $new_dir
$SHELL
