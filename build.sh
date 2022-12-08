#!/bin/bash

EXE_NAME=jagfim
VERSION=`cat ./Version`
DIST_DIR=Distribution

eval `grep ^ZIPFILE = package/make_package.sh`
eval `grep ^PACKAGE= package/make_package.sh`

jfrog rt dl cfr-generic-releases/site-trust/*/${ZIPFILE} --sort-by=created --sort-order=desc --limit=1 --flat

pushd package
make_package.sh $VERSION
popd


if [ ! -d $DIST_DIR ]
then
    echo "Making Distribution directory..."
    mkdir $DIST_DIR
fi

echo "Copying to Distribution directory..."
mv package/build/${PACKAGE}_${VERSION}_all.deb ${DIST_DIR}/${PACKAGE}.deb_${VERSION}

echo "Success"