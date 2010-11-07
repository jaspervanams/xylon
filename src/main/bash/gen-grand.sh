#!/bin/sh

PROJECT_NAME=$1
GRAND_HOME=$2

TARGET_DIR=$PWD/target

BUILD_XML=$PWD/build.xml

VIZANT_ANT_SCRIPT="$GRAND_HOME/ant/grand.xml"

mkdir -p $TARGET_DIR
             
ANT_CMD="ant -f $VIZANT_ANT_SCRIPT"
ANT_PROPERTIES="$ANT_PROPERTIES -Dbasedir=$GRAND_HOME/ant/"
ANT_PROPERTIES="$ANT_PROPERTIES -Dproject.name=$PROJECT_NAME"
ANT_PROPERTIES="$ANT_PROPERTIES -Dtarget.dir=$TARGET_DIR"
ANT_PROPERTIES="$ANT_PROPERTIES -Dbuild.xml=$BUILD_XML"

echo "Executing: ant to generate vizualisation of the ant file ..."
echo $ANT_CMD $ANT_PROPERTIES
$ANT_CMD $ANT_PROPERTIES
