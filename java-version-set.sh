##
# a tool to open a new subshell with a different version of java
# it'll just filter through available folders
# nothing special

INSTALLATION_DIR=/usr/lib/jvm

if [ $# -ne 1 ]; then
  echo "Expecting only one param for filtering the environments!"
  echo "Listing environments:"
  ls -1A --ignore="default*" $INSTALLATION_DIR
  exit 0
fi

USER_INPUT=$1
INSTALLED_JVMS=`ls -1A --ignore="default*" $INSTALLATION_DIR`
FILTERED_JAVA=(`echo "$INSTALLED_JVMS" | grep -- "$USER_INPUT"`)
INSTALLED_JVMS=(`echo "$INSTALLED_JVMS"`)

if [ ${#FILTERED_JAVA[@]} -eq 0 ]; then
  echo "Not found version $USER_INPUT in:"
  echo "${INSTALLED_JVMS[@]}"
  echo "Abort!"
  exit 0
elif [ ${#FILTERED_JAVA[@]} -gt 1 ]; then
  echo "Too many (${#FILTERED_JAVA[@]}) matches for \"$USER_INPUT\" in:"
  echo "${INSTALLED_JVMS[@]}"
  echo "Abort!"
  exit 0
fi

export SELECTED_JVM=`echo "${FILTERED_JAVA[@]}"`
export JAVA_HOME=`echo "$INSTALLATION_DIR/$SELECTED_JVM"`
export JAVA_PATH=`echo "$JAVA_HOME/bin"`
export OLDPATH=`echo $PATH`
export PATH=`echo $JAVA_PATH:$PATH`

echo "Activating $SELECTED_JVM in subshell"

# TODO: change subshell prompt
# try mktemp
exec $SHELL -i

