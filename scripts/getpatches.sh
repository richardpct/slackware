#!/bin/sh

# =================================================
# getpatches.sh is a script which downloads patches
# for Slackware64 Linux version 14.X
# =================================================

set -e -u

VERSION=14.2
MIRROR=http://slackware.mirrors.tds.net/pub/slackware
PATCHES=$MIRROR/slackware64-$VERSION/patches
LOCALDIR=$HOME/slackware/slackware64-$VERSION/patches

[ -d $LOCALDIR/packages ] || mkdir -p $LOCALDIR/packages

cd $LOCALDIR

rm -f CHECKSUMS.md5 CHECKSUMS.md5.asc
wget $PATCHES/{CHECKSUMS.md5,CHECKSUMS.md5.asc}
gpg --verify CHECKSUMS.md5.asc CHECKSUMS.md5

grep " \+\./[^/]\+$" CHECKSUMS.md5 | while read ; do
  if ! echo "$REPLY" | md5sum -c > /dev/null 2>&1 ; then
    rm -f ${REPLY#*./}
    wget $PATCHES/${REPLY#*./}
  fi
done

PACKAGES=$(awk '/ +\.\/packages\/[^/]+$/{print $2}' CHECKSUMS.md5)

find ./packages -type f -maxdepth 1 | while read ; do
  if ! echo "$PACKAGES" | grep "$REPLY$" > /dev/null ; then
    rm $REPLY
  fi
done

grep " \+\./packages/[^/]\+$" CHECKSUMS.md5 | while read ; do
  cd $LOCALDIR
  if ! echo "$REPLY" | md5sum -c > /dev/null 2>&1 ; then
    rm -f ${REPLY#*./}
    cd packages
    wget $PATCHES/${REPLY#*./}
  fi
done

grep -v " \+\./.\+/.\+/" CHECKSUMS.md5 | grep "\./" | md5sum -c

cd packages

for i in *.txz ; do
  gpg --verify $i.asc $i
done

cat << EOF
  -----------------------------------------
 | the patches are downloaded successfully |
  -----------------------------------------
EOF

