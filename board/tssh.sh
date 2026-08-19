#!/usr/bin/expect
set timeout -1
set files [glob *.bin]
spawn scp {*}$files rishikesh@10.24.52.125:~/PSC/frames/
expect "rishikesh@10.24.52.125's password:"
send "Instalife00\r"
expect eof

