#!/usr/bin/expect

spawn ssh rishikesh@10.24.52.125 "python3 ~/PSC/batch_process_mipi.py"
expect "rishikesh@10.24.52.125's password:"
send "Instalife00\r"
expect eof
