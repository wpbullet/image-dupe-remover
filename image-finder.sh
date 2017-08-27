#!/usr/bin/env bash
# Author: Mike https://guides.wp-bullet.com
# Purpose: Search for unused duplicate images

# enter path to search for dupes, cannot be absolute path!
DUPEPATH="wp-content/uploads/"

# enter path to store dupes that can be removed
DUPELOG="/tmp/dupelog"

# empty DUPELOG
cat /dev/null > "$DUPELOG"

# create dupes array after trimming empty lines
DUPESARRAY=($(fdupes --recurse "$DUPEPATH" | sed '/^$/d'))

# loop through array and search database
for DUPE in "${DUPESARRAY[@]}";
do
    # no skip columns flag, ask wp-cli channel
    echo "Searching for $DUPE"
    DUPEFIND=$(wp db search "$DUPE" --stats --allow-root | tail -1 | awk '{print $3}')

    if [ "$DUPEFIND" = 0 ]; then

        #DUPEFINDESCAPED use sed to replace / with \/ and search for that too!
#        DUPEFINDESCAPED=$(wp db search "$(echo "$DUPE" | sed 's#/#\\/#g')" --stats --allow-root | awk '{print $3}')
        DUPEFINDESCAPED=$(wp db search "${DUPE////\\/}" --stats --allow-root | tail -1 | awk '{print $3}')
        if [ "$DUPEFINDESCAPED" = 0 ]; then
            echo "$DUPE" >> "$DUPELOG"
            echo "Not in database"
        fi
    else
        echo "In database, skipping"
    fi
done

# show how much space can be saved by removing dupes
echo "$(du -sh < "$DUPELOG") can be saved"

