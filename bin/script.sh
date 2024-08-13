#!/bin/bash
tmp_path="./bin/path.txt"
command="./main.exe"
for arg in "$@"
do
    if [[ $arg =~ ^-?[0-9]+$ ]]; then 
        command="${command} -max-depth $arg"
    fi
    if [[ $arg =~ ^[a-zA-Z/~_-]+$ ]]; then
        if [[ $arg = "show-hidden" ]]; then
            command="${command} -hidden true"
        else
            if [[ $arg = "sort-by-time" ]]; then
                command="${command} -sort true"
            else
                command="${command} -start $arg"
            fi
        fi
    fi
done
eval $command
reset
new_path=$(cat ${tmp_path})
len=${#new_path}
if [[ len -gt 0 ]]; then
    echo $len
fi