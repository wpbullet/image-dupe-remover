#!/usr/bin/env bash

# enter path to search for dupes
DUPEPATH=""
# enter path to store dupes that can be removed
DUPELOG="/tmp/dupelog"

# create dupes array after trimming empty lines
DUPESARRAY=($(fdupes --recurse "$DUPEPATH" | sed '/^$/d'))

# loop through array and search database
for DUPE in ${DUPESARRAY[@]};
do
    # no skip columns flag, ask wp-cli channel
    echo "Searching for $DUPE"
    DUPEFIND=$(wp db search "$DUPE" --stats --allow-root | tail -1 | awk '{print $3}')

    if [ "$DUPEFIND" = 0 ]; then

        #DUPEFINDESCAPED use sed to replace / with \/ and search for that too!
        DUPEFINDESCAPED=$(wp db search $(echo "$DUPE" | sed 's#/#\\/#g') --stats --allow-root | awk '{print $3}')

        if [ "$DUPEFINDESCAPED" = 0 ]; then
            echo $DUPE >> /tmp/herp
            echo "Not in database"
        fi
    else
        echo "In database, skipping"
    fi
done

# show how much can be saved
echo $(du -sh < "$DUPELOG") can be saved
