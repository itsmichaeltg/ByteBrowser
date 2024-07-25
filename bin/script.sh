#!/usr/bin/expect
spawn bash
expect "$ "
send "echo 'hello world'"
interact
