#!/bin/bash
tmp_path="/home/ubuntu/jsip-final-project/bin/path.txt"
command="/home/ubuntu/jsip-final-project/_build/default/bin/main.exe"
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
echo > $tmp_path
if [[ len -gt 0 ]]; then
    if test -d $new_path; then
        eval "cd ${new_path}"
    else 
        eval "vim ${new_path}"
    fi
fi