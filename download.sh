#!/bin/bash -ue

if [ $# -eq 0 ]
then
  $BASH_SOURCE help
  exit
fi

DIR=$(cd $(dirname $BASH_SOURCE);pwd)

ECHO=
for arg in $@
do
  case $arg in
  help|h|-h|--help)
    echo "usage: $BASH_SOURCE <souce>"
    echo
    echo "Source is one of:"
    grep ') #' $BASH_SOURCE \
      | grep -v grep \
      | sed 's:)::g' \
      | column -t -s\#
    exit
  ;;
  -x) # turn on -x bash option
    set -x
  ;;
  echo) # show which commands would have been run but don't actually do anything
    ECHO=echo
  ;;
  swarm) #
    URL="http://icgem.gfz-potsdam.de"
    OUT_DIR="$DIR/$arg"
    [ -d "$OUT_DIR" ] || mkdir -p "$OUT_DIR"
    for i in $(
      wget -q -O - $URL/series/02_COST-G/Swarm/40x40 | awk -F\" '/getseries\/02_COST-G\/Swarm\/40x40\/.*\.gfc/ {print $2}'
    ); do
      OUT="$OUT_DIR/$(basename $i)"
      [ -s "$OUT" ] && continue
      $ECHO wget -nc $URL/$i -O $OUT -o $OUT.log
      echo "Downloaded $OUT"
    done
  ;;
  esac
done