#!/bin/bash
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
# If the first argument to this script starts with --passwordfile= it should specify the path to the 
# password file that contains the master password. Passwodfile can be also set using PASSWORD_FILE 
# environment variable. Alternatively, master password can be set using AS_ADMIN_MASTERPASSWORD environment 
# variable.
#
# By default, this script executes the asadmin tool which is found in the same directory. 
# The AS_ADMIN_PATH environment variable can be used to specify an alternative path to the asadmin tool.
#
##########################################################################################################

if [ -z "$AS_ADMIN_PATH" ]
  then
    AS_ADMIN_PATH=`dirname $0`/asadmin
fi

if echo "$1" | grep -e '--passwordfile=' > /dev/null
  then
    PASSWORD_FILE=`echo "$1" | sed 's/--passwordfile=//'`
    PASSWORD_FILE_ARG="$1"
    shift 1
fi

# The following command gets the command line to be executed by start-domain
# - print the command line to the server with --dry-run, each argument on a separate line
# - remove -read-string argument
# - surround each line except with parenthesis to allow spaces in paths
# - remove lines before and after the command line and squash commands on a single line

OUTPUT=`"$AS_ADMIN_PATH" start-domain "$PASSWORD_FILE_ARG" --dry-run "$@"`
STATUS=$?
if [ "$STATUS" -ne 0 ]
  then
    echo ERROR: $OUTPUT >&2
    exit 1
fi

COMMAND=`echo "$OUTPUT" | sed -n -e '2,/^$/p'`

echo Executing Payara Server with the following command line:
echo $COMMAND
echo

# Run the server in foreground - read master password from variable or file or use the default "changeit" password

set +x
if test "$AS_ADMIN_MASTERPASSWORD"x = x -a -f "$PASSWORD_FILE"
  then
    source "$PASSWORD_FILE"
fi
if test "$AS_ADMIN_MASTERPASSWORD"x = x
  then
    AS_ADMIN_MASTERPASSWORD=changeit
fi
echo "AS_ADMIN_MASTERPASSWORD=$AS_ADMIN_MASTERPASSWORD" > /tmp/masterpwdfile
exec $COMMAND < /tmp/masterpwdfile


