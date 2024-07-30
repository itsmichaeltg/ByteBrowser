#!/bin/bash
tmp_path="/home/ubuntu/jsip-final-project/bin/path.txt"
command="/home/ubuntu/jsip-final-project/_build/default/bin/main.exe"
if [ $# -gt 0 ]; then 
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        command="${command} -max-depth ${1}"
    else
        command="${command} -start ${1}"
    fi
    if [[ "$2" =~ ^[0-9]+$ ]]; then
        command="${command} -max-depth ${2}"
    fi
fi
if [[ "$4" =~ ^[0-9]+$ ]]; then
    command="${command} -max-depth ${4}"
fi
eval $command
reset
new_dir="cd $(cat "${tmp_path}")"
eval $new_dir