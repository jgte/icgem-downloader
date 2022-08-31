#!/bin/bash -ue

if [ $# -eq 0 ]
then
  $BASH_SOURCE help
  exit
fi

DIR=$(cd $(dirname $BASH_SOURCE);pwd)

ECHO=
URL="http://icgem.gfz-potsdam.de"
for arg in $@
do
  case $arg in
  help|h|-h|--help)
    echo "usage: $BASH_SOURCE [optional arguments] <source> [<another source> ...]"
    echo
    echo "Source can take the value of:"
    grep ') #source' $BASH_SOURCE \
      | grep -v grep \
      | grep -v sed \
      | sed 's:) #source:#:g' \
      | column -t -s\#
    echo
    echo "Optional arguments are:"
    grep ') #' $BASH_SOURCE \
      | grep -v grep \
      | grep -v sed \
      | grep -v ') #source' \
      | sed 's:) #:#:g' \
      | column -t -s\#
    exit
  ;;
  -x) # turn on -x bash option
    set -x
  ;;
  echo) # show which commands would have been run but don't actually do anything
    ECHO=echo
  ;;
  url=*) # define the base URL, defaults to http://icgem.gfz-potsdam.de
    URL=${arg/url=}
  ;;
  swarm) #source
    OUT_DIR="$DIR/$arg"
    [ -d "$OUT_DIR" ] || mkdir -p "$OUT_DIR"
    for i in $(
      wget -q -O - $URL/series/02_COST-G/Swarm/40x40 | awk -F\" '/getseries\/02_COST-G\/Swarm\/40x40\/.*\.gfc/ {print $2}'
    ); do
      OUT="$OUT_DIR/$(basename $i)"
      [ -s "$OUT" ] && continue
      $ECHO wget -nc $URL/$i -O $OUT -o $OUT.log && echo "Downloaded $OUT" || echo "Failed to download $OUT"
    done
  ;;
  esac
done