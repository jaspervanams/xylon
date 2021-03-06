#!/bin/bash
# Type chmod +x go.sh in this folder to make it executable
# add this to your ~/.bash_profile to make it simpler to call:
# export PATH=.:$PATH

CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$PWD")
ANT_PATH=$(which ant)

function calculate.xecScriptFileName() {
    local RAW_XEC_SCRIPT_FILE=$0
    local LINKED_XEC_SCRIPT_FILE=$(readlink $RAW_XEC_SCRIPT_FILE)
    XEC_SCRIPT_FILE=$LINKED_XEC_SCRIPT_FILE
    if [ -z "$LINKED_XEC_SCRIPT_FILE" ]; then
        XEC_SCRIPT_FILE=$RAW_XEC_SCRIPT_FILE
    fi
    export XEC_HOME=$(dirname $XEC_SCRIPT_FILE)
    export XYLON_HOME="$XEC_HOME/../../.."
}

function init() {
    calculate.xecScriptFileName
}

function report.config() {
	echo "-----------------------------------------------------------------------------"
	echo "XEC"
	echo "Project name   : [$PROJECT_NAME]"
	echo "Working in     : $CURRENT_DIR"
	echo "xec home       : $XEC_HOME"
	echo "xylon home     : $XYLON_HOME"
	echo "xec version    : 1.0"
	echo "Args           : $*"
	echo "-----------------------------------------------------------------------------"
	#echo Using ant from [$ANT_PATH] in directory [$PWD] with command [$1]

	#ant -f ./build.xml -Dbasedir=$PWD -Dproject.name=$PROJECT_NAME $@
}

function report.completed() {
	#type man strftime to see full list of date formatting options.
	CURRENT_DATE=$(date "+%a %d %b %Y")
	CURRENT_TIME=$(date "+%H:%M:%S")
	echo -----------------------------------------------------------------------------
	echo XEC Complete at $CURRENT_TIME on $CURRENT_DATE.
	echo -----------------------------------------------------------------------------
	echo
}

function command.help() {
	echo "Usage: xec <command> args"
}

function command.gen() {
    local GEN_COMMAND=$1
    shift
    local ARGUMENTS=$*

    executeCommandFunction "gen $GEN_COMMAND" "gen.$GEN_COMMAND" $ARGUMENTS
}

function command.init() {
    local GEN_COMMAND=$1
    shift
    local ARGUMENTS=$*

    executeCommandFunction "init $GEN_COMMAND" "init.$GEN_COMMAND" $ARGUMENTS
}


function init.java() {
    echo "Generating a java project ..."

    echo "Initialising java-basic project in $CURRENT_DIR"

	#rm -r *
	cp -r $XEC_HOME/../project-templates/java-basic/* $CURRENT_DIR

	mv "./ide/intellij/\${project.name}" ./ide/intellij/$PROJECT_NAME
	mv "./ide/intellij/$PROJECT_NAME/\${project.name}.iml" ./ide/intellij/$PROJECT_NAME/$PROJECT_NAME.iml
	mv "./ide/intellij/$PROJECT_NAME/\${project.name}.ipr" ./ide/intellij/$PROJECT_NAME/$PROJECT_NAME.ipr

	eval sed -i .bak "'s/\\\$project\.name\\\$/$PROJECT_NAME/g'" "./ide/intellij/$PROJECT_NAME/$PROJECT_NAME.ipr"

	rm "./ide/intellij/$PROJECT_NAME/$PROJECT_NAME.ipr.bak"

	open -a /Applications/IntelliJ\ IDEA\ 9.0.3.app/ ide/intellij/$PROJECT_NAME/$PROJECT_NAME.ipr
}

function init.mvn() {
    echo -e "\nInitialising a maven project in $CURRENT_DIR ..."

    local GROUP_ID=$1
    local ARTIFACT_ID=$2
    local MVN_COMMAND="mvn archetype:create -DgroupId=$GROUP_ID -DartifactId=$ARTIFACT_ID"

    echo -e "\n$MVN_COMMAND"
    $MVN_COMMAND

}

function init.ruby() {
    echo "Use tree surgeon @ http://github.com/riethmayer/ruby-project-template"
}

function gen.moose() {
    $XEC_HOME/gen-moose.sh $PROJECT_NAME $*
}

function gen.simian() {
    $XEC_HOME/gen-simian.sh $XYLON_HOME/lib/production
}

function gen.latex() {
    mkdir -p target/latex
    pdflatex -output-directory target/latex *.tex
    open target/latex/*.pdf
}

function gen.cloc() {
    $XEC_HOME/gen-cloc.sh $XYLON_HOME/tool/cloc $*
}
function gen.treemap() {
    for SRC_DIR in $(find $CURRENT_DIR/src -name java); do
        PARENT_DIR=$(dirname $SRC_DIR)
        PARENT_NAME=$(basename $PARENT_DIR)
	    echo "Generating treemap for : $PARENT_NAME : $SRC_DIR"
	    $XEC_HOME/gen-treemap.sh $PROJECT_NAME  $XYLON_HOME/tool/checkstyle $SRC_DIR $PARENT_NAME
    done
}

function gen.vizant() {
    $XEC_HOME/gen-vizant.sh $PROJECT_NAME $XYLON_HOME/tool/vizant
}

function gen.grand() {
    $XEC_HOME/gen-grand.sh $PROJECT_NAME $XYLON_HOME/tool/grand
}

function command.build() {
   ant -logger org.apache.tools.ant.NoBannerLogger -f build.xml
}

function command.infovis() {
   cd target/treemap
   java -jar $XYLON_HOME/tool/infovis-toolkit/infovis-toolkit-trunk.jar
}



function executeCommandFunction() {
    local COMMAND=$1
    local COMMAND_FUNCTION=$2
    shift
    shift
    local ARGUMENTS=$*
	FUNCTION_EXISTS=$(type "$COMMAND_FUNCTION" 2> /dev/null | grep "is a function")
	if [ -z "$FUNCTION_EXISTS" ] ; then
		echo "Unknown command [$COMMAND]"
		command.help
		exit -1
	fi
	eval $COMMAND_FUNCTION $ARGUMENTS
}

function processCommand() {
	local COMMAND=$1
	shift
	local ARGUMENTS=$*

	echo "Executing command [$COMMAND] with arguments [$ARGUMENTS]"

	executeCommandFunction $COMMAND "command.$COMMAND" $ARGUMENTS
}


init
report.config $*
processCommand $*
report.completed



