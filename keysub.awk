# 0 BEGIN
##########
BEGIN {
  FS=":"
  OFS=": "
}

# 1 parse source files 
########################
# update author
$0 ~ /.*\$Author.*\$.*/ {
  $2=author " $"
}

# update timestamp
$0 ~ /.*\$LastChangedDate.*\$.*/ {
  $0=$1
  $2=timestamp " $"
}

# update commit message
$0 ~ /.*\$LastChangeMessage.*\$.*/ {
  $2=commitmsg " $"
}

# update commit counts
$0 ~ /.*\$Rev.*\$.*/ {
  ++$2
  $2=$2 " $"
}

# print line
{
  print
}