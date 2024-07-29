#!/bin/bash
tmp_path="/home/ubuntu/jsip-final-project/bin/path.txt"
command="/home/ubuntu/jsip-final-project/_build/default/bin/main.exe ${1} ${2}"
if [ "$2" = "dir" ]; then 
    command="${command} -start ${4}"
    if [[ "$6" =~ ^[0-9]+$ ]]; then
        command="${command} -max-depth ${6}"
    fi
fi
if [[ "$4" =~ ^[0-9]+$ ]]; then
    command="${command} -max-depth ${4}"
fi
eval $command