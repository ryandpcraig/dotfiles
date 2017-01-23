#!/bin/bash

[[ -z "$1" ]]  && echo "Pass in a file" && exit 1
[[ -z "$2" ]]  && echo "Pass in a key" && exit 1

DATE=$(date +%Y%m%d_%H%M)
WD="$PWD/encrypt"

PASS_KEY="$WD/key.txt"
PRV_KEY="$WD/files-backup.pem"
PUB_KEY="$WD/files-backup-public.pem"


ENCRYPTED_FILE="$1"
UNENCRYPTED_FILE="${ENCRYPTED_FILE%.*}"
ENCRYPTED_PASSKEY="$2"

openssl rsautl -decrypt -inkey "$PRV_KEY" < "$ENCRYPTED_PASSKEY" > "$PASS_KEY"
[[ $? -eq 0 ]] && echo "Pass key written to: $PASS_KEY" || exit 1
openssl enc -aes-256-cbc -d -pass file:"$PASS_KEY" < "$ENCRYPTED_FILE" > "$UNENCRYPTED_FILE"

[[ $? -eq 0 ]] && echo "File written to: $UNENCRYPTED_FILE" || exit 1
