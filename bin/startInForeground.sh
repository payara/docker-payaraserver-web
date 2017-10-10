#!/bin/sh
##########################################################################################################
#
# This script is to execute Payara Server in foreground, mainly in a docker environment. 
# It allows to avoid running 2 instances of JVM, which happens with the start-domain --verbose command.
#
# Usage:
#   Running 
#        startInForeground.sh <arguments>
#   is equivalent to running
#        asadmin start-domain <arguments>
#
# It's possible to use any arguments of the start-domain command as arguments to startInForeground.sh
#
##########################################################################################################

AS_ADMIN_PATH=`dirname $0`/asadmin

# The following command gets the command line to be executed by start-domain
# - print the command line to the server with --dry-run, each argument on a separate line
# - remove -read-string argument
# - surround each line except with parenthesis to allow spaces in paths
# - remove lines before and after the command line and squash commands on a single line

COMMAND=`"$AS_ADMIN_PATH" start-domain --dry-run $@ | sed -n -e '/-read-stdin/d' -e 's/^\(.\)/"\1/' -e 's/\(.\)$/\1"/' -e '2,/^$/p'`

echo Executing Payara Server with the following command line:
echo $COMMAND
echo

# Run the server in foreground:

eval $COMMAND
