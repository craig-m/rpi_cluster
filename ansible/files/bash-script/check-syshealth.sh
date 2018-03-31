#!/usr/bin/env bats
# check this R-Pi node is OK

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "started check-syshealth.sh";

# OS env -----------------------------------------------------------------------

@test "Test we get 'root' from 'sudo id' command" {
  run bash -c "sudo id | grep root -o | head -n1"
  [ "$output" = "root" ]
  [ "$status" -eq 0 ]
}

@test "No shells without a tty" {
  shellsnotty=$(/usr/bin/sudo ps -ef | awk '$6=="?"&&$8~/^(\/bin\/)?(ba|da|z|k|c|tc)*sh-?/{print}' | wc -l | grep "0")
}

@test "no bad pcaps" {
  actpcaps=$(/usr/bin/sudo ss -f link -n -l -p | grep -v -e 'dhcpcd' | grep -v -e "Address:Port" | wc -l)
  [ "$output" = "0" ]
}

@test "sshd config ok" {
  run bash -c "/usr/bin/sudo sshd -t -f /etc/ssh/sshd_config"
}

@test "No network services running under Pi user" {
  run bash -c "/usr/bin/sudo ss -lp | grep 'users:((\"pi\"' | wc -l"
  [ "$output" = "0" ]
}


# nagios monitoring plugins ----------------------------------------------------

@test "disk usage" {
  run bash -c "/usr/lib/nagios/plugins/check_disk -w 20% -c 10% /dev/mmcblk0p2 -e"
}

@test "process count" {
  run bash -c "/usr/lib/nagios/plugins/check_procs"
  [ "$status" -eq 0 ]
}

@test "user count" {
  run bash -c "/usr/lib/nagios/plugins/check_users -w 10 -c 15"
}

@test "load avg" {
  run bash -c "/usr/lib/nagios/plugins/check_load -w 0.8,0.7,0.6 -c 0.9,0.8,0.7*"
}

@test "check host local" {
  run bash -c "/usr/lib/nagios/plugins/check_host localhost"
}

@test "check host google.com" {
  run bash -c "/usr/lib/nagios/plugins/check_host google.com"
}

@test "check host google.com.au" {
  run bash -c "/usr/lib/nagios/plugins/check_host google.com.au"
}

@test "check http google.com" {
  run bash -c "/usr/lib/nagios/plugins/check_http -H google.com -p 80"
}

@test "swap use" {
  run bash -c "/usr/lib/nagios/plugins/check_swap -av -w 70% -c 60%"
}

@test "ssh up" {
  run bash -c "/usr/lib/nagios/plugins/check_ssh -p 22 localhost"
}

@test "syslog fileage" {
  run bash -c "/usr/lib/nagios/plugins/check_file_age /var/log/syslog -w 1200"
}


rpilogit "finished check-syshealth.sh";

# EOF
