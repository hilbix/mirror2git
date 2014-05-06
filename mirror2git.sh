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

noerr()
{
errorflag=false
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

run()
{
source ./"mirror-$1.inc" || return
HERE="`readlink -e "$1"`" || return
for a in "$HERE"/*
do
        [ -d "$a" ] || continue
	[ -e "$a/.git" ] || continue

	stamp "start $a"
	( noerr; cd "$a" && "auto$1" "$a" && tellerr; )
	res=$?
	stamp "ret=$res $a"
	[ 0 = $res ] || tellerr "$a"
done
stamp end
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

