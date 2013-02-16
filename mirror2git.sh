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

run()
{
source ./"mirror-$1.inc" || return
HERE="`readlink -e "$1"`" || return
for a in "$HERE"/*
do
        [ -d "$a" ] || continue
	[ -e "$a/.git" ] || continue

	stamp "start $a"
	( cd "$a" && "auto$1" "$a"; )
	stamp "ret=$? $a"
done
stamp end
}

for v in [a-z]*
do
	[ -d "$v" ] || continue
	[ -x "mirror-$v.inc" ] || continue
	(
	out "mirror-$v.sh start"
	run "$v"
	out "mirror-$v.sh ret=$?"
	) >> "LOG/mirror-$v.log" 2>&1
done

