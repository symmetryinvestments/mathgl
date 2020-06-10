#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
mkdir -p "$SCRIPT_DIR"/dls
mkdir -p "$SCRIPT_DIR"/lib

cd "$SCRIPT_DIR"/dls

if [[ ! -d mathgl ]]; then
	if [[ ! -f mathgl-2.4.4.tar.gz  ]]; then
  		wget -nv "http://downloads.sourceforge.net/mathgl/mathgl-2.4.4.tar.gz"
	fi
	# For some reason the file is doubly zipped when downloading from a container
    # So try the normal untar process then try gunzip followed by tar
	if ! tar xzf mathgl-2.4.4.tar.gz; then
		gunzip mathgl-2.4.4.tar.gz
		tar xzf mathgl-2.4.4.tar
	fi
	mv mathgl-2.4.4 mathgl
	cd mathgl 
	mkdir -p build
	cd build
	cmake ..
	cd ../..
fi

pushd mathgl/build
make "-j$(getconf _NPROCESSORS_ONLN)" > mathgl_build_log 2>&1
mathglbuildcode=$?
if [[ ! $mathglbuildcode -eq 0 ]]; then
	echo building mathgl failed, check mathgl_build_log
	exit $mathglbuildcode
fi
cp src/lib* "$SCRIPT_DIR"/lib
