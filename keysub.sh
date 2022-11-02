#!/bin/bash

# 0 -- functions/methods
#########################
# <Function description>
function get_timestamp () {
  date    # change this to get a custom timestamp
}

# 1 -- Variable declarations
#############################
# input file for mapping
file=".keysub.cnf"
timestamp=$(get_timestamp)


# 2 -- Argument parsing and flag checks
########################################

# Parsing flag-list
while getopts ":f:m:a" opt;
do
  case $opt in
    f) file=${OPTARG}
       ;;
    a) echo 'Warning, keyword substitution will be incomplete when invoked'
       echo 'with the -a flag. The commit message will not be substituted into'
       echo 'source files. Use -m "message" for full substitutions.'
       echo -e 'Would you like to continue [y/n]? \c'
       read answer
       [[ ${answer} =~ [Yy] ]] || exit 3
       unset answer
       type="commit_a"
       break
       ;;
    m) type="commit_m"
       commitmsg=${OPTARG}
       break
       ;;
   \?) break
       ;;
  esac
done
shift $(($OPTIND - 1))

# check file for typing
if [[ ! -f ${file} ]]
then
  echo 'No valid config file found.'
  exit 1
fi

# check if commit type was supplied
if [[ -z ${type} ]]
then
  echo 'No commit parameters/flags supplied...'
  exit 2
fi

# 3 -- write config file
#########################
sed "
  /timestamp:/ {
    s/\(timestamp:\).*/\1${timestamp}/
  }
  /commitmsg:/ {
    s/\(commitmsg:\).*/\1${commitmsg:-default commit message}/
  }
" ${file} > tmp

mv tmp ${file}

# 4 -- get remaining tags
##########################
author=$(grep 'author' ${file} | cut -f1 -d':' --complement)


# 5 -- get files ready to commit
#################################
git status -s | grep '^[MARCU]' | cut -c1-3 --complement > tmplist

# 6 -- invoke awk and perform substitution
###########################################
# beware to change path to your location of the awk script
for item in $(cat tmplist)
do
  echo ${item}
  awk -v "commitmsg=${commitmsg}" -v "author=${author}" \
      -v "timestamp=${timestamp}" -f "${HOME}/lib/awk/keysub.awk" ${item} \
      > tmpfile
  mv tmpfile ${item}
done
rm tmplist

# 5 -- invoke git commit
#########################
case ${type} in
  "commit_m") git commit -m "${commitmsg}" "$@"
              ;;
  "commit_a") git commit -a "$@"
              ;;
esac

# exit using success code
exit 0