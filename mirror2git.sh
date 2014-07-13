#!/bin/bash
#
# Add this to crontab like
# 1 1 * * * mirror2git/mirror2git.sh

cd "`dirname "$0"`" || exit

# Be nice to remotes, do not hit them the same time each day
sleep $[RANDOM%1024]

out()
{
OUT="`date +%Y%m%d-%H%M%S` $*" 
echo "$OUT" >&2
echo "$OUT" >> LOG/mirror2git.log
}

stamp()
{
echo "`date +%Y%m%d-%H%M%S` $*" 
}

x()
{
timeout 1h "$@"
ret=$?
[ 0 = "$ret" ] || stamp "$ret: $*"
return $ret
}

e()
{
x "$@" || { sleep 60; x "$@"; } || err "$*"
}

noerr()
{
errorflag=false
errortext=
}
noerr

err()
{
errortext="$errortext $?:$*"
errorflag=:
}

tellerr()
{
! $errorflag
}

showerr()
{
tellerr && return
echo "ERROR: $errortext"
}

# Inform my monitoring:
# monitor timeout status service subservice text
monitor()
{
ok="$2"
case "$2" in
OK|WARN|ERR)	;;
0)		ok=OK;;
*)		ok=ERR;;	# TODO: degrade first time error into warning
esac
echo "$ok ${5:-$ok}" >> "/tmp/poststat.ok.${1:-3600}.$3.$4"
}

run()
{
source ./"mirror-$1.inc" || return
HERE="`readlink -e "$1"`" || return
repos=
for a in "$HERE"/*
do
        [ -d "$a" ] || continue
	[ -e "$a/.git" ] || continue

	stamp "start $a"
	( noerr; cd "$a" && "auto$1" "$a" && tellerr; )
	res=$?
	stamp "ret=$res $a"
	[ 0 = $res ] || err "$a"
	repos="$repos $res:${a##*/}"
done
tellerr
stamp end $?
tellerr
monitor 99999 "$?" mirror "$1" "$repos"
tellerr
}

exec 3>&2

for v in [a-z]*
do
	[ -d "$v" ] || continue
	[ -x "mirror-$v.inc" ] || continue
	(
	out "mirror-$v.sh start"
	run "$v"
	out "mirror-$v.sh ret=$?$errortext"
	showerr "$v" >&3	# put into cron output
	) >> "LOG/mirror-$v.log" 2>&1
done
out finish 2>/dev/null

