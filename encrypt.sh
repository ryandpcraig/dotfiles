#!/bin/bash

[[ -z "$1" ]]  && echo "Pass in a file" && exit 1

DATE=$(date +%Y%m%d_%H%M)
WD="$PWD/encrypt"

PASS_KEY="$WD/key.txt"
PRV_KEY="$WD/files-backup.pem"
PUB_KEY="$WD/files-backup-public.pem"


UNENCRYPTED_FILE="$1"
ENCRYPTED_FILE="backup_$DATE.tar.gz.dat"
ENCRYPTED_PASSKEY="$WD/enc_$DATE.key.txt"

echo -n "$(openssl rand 32)" > "$PASS_KEY"

openssl enc -aes-256-cbc -pass file:"$PASS_KEY" < "$UNENCRYPTED_FILE" > "$ENCRYPTED_FILE"
[[ $? -eq 0 ]] && echo "File written to: $ENCRYPTED_FILE" || exit 1

openssl rsautl -encrypt -pubin -inkey "$PUB_KEY" < "$PASS_KEY" >  "$ENCRYPTED_PASSKEY"
[[ $? -eq 0 ]] && echo "Passkey written to: $ENCRYPTED_PASSKEY" || exit 1

rm -f $PASS_KEY
