#!/bin/bash

INCLUDE="$PWD/include.lst"
EXCLUDE="$PWD/exclude.lst"
function backupFiles() {
  rsync -aP  --files-from="$INCLUDE" --exclude-from="$EXCLUDE" / files/
}

function backupPPAs() {
  # Get list of PPAs
  echo '#!/bin/bash' > restore-ppas.sh
  echo '#!/bin/bash' > restore-repos.sh
  for APT in `find /etc/apt/ -name \*.list`; do
      grep -Po "(?<=^deb\s).*?(?=#|$)" $APT | while read ENTRY ; do
          HOST=`echo $ENTRY | cut -d/ -f3`
          USER=`echo $ENTRY | cut -d/ -f4`
          PPA=`echo $ENTRY | cut -d/ -f5`
          if [ "ppa.launchpad.net" = "$HOST" ]; then
              echo "sudo apt-add-repository ppa:$USER/$PPA" >> restore-ppas.sh
          else
              echo "sudo apt-add-repository \'${ENTRY}\'" >> restore-repos.sh
          fi
      done
  done
}

function backupPackages() {
  # Get list of installed packages
  apt-mark showauto > files/pkgs_auto.lst
  apt-mark showmanual > files/pkgs_manual.lst
}

function backupAll() {
  backupFiles
  backupPPAs
  tar -cvzf "backup_$(date +%Y%m%d_%H%M).tar.gz" files/ restore* config.sh
}

function restorePackages() {
  sudo apt-get update
  cat files/pkgs_manual.lst | tr '\n' '  ' | xargs sudo apt-get install -y
  sudo apt-mark auto $(cat files/pkgs_auto.lst)
  sudo apt-mark manual $(cat files/pkgs_manual.lst)
}

function restoreRepos() {
  bash restore-repos.sh
  bash restore-ppas.sh
}

function restoreDotfiles() {
  bash install.sh dotfiles
}

function restoreAll() {
  restoreRepos
  restorePackages
}

case "$1" in
  "files" )
    backupFiles
    ;;
  "ppas | repos" )
    backupPPAs
    ;;
  "restore" )
    restoreAll
    ;;
  *)
    backupAll
    ;;
esac
