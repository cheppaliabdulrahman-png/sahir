#!/bin/bash
set -e
set -x
# letmein.sh

wait_for_su() {
  adb kill-server
  adb wait-for-device
  tmp=`mktemp`
  while ! adb shell su -c 'whoami' > $tmp || ! grep -q root $tmp; do
    sleep 1
  done
  rm $tmp
}

# step 1 - turn off lockscreen
wait_for_su
adb shell su -c "sqlite3 /data/system/locksettings.db \"update locksettings set value=1 where name='lockscreen.disabled'\""
adb shell su -c "sqlite3 /data/system/locksettings.db \"update locksettings set value=0 where name='lockscreen.patterneverchosen'\""
adb reboot
sleep 3

# step 2 - kill the pattern+password storage files
wait_for_su
adb shell su -c 'rm /data/system/gatekeeper*'
adb reboot
sleep 3

# step 3 - turn it halfway on
wait_for_su
adb shell su -c "sqlite3 /data/system/locksettings.db \"update locksettings set value=0 where name='lockscreen.disabled'\""
adb reboot
sleep 3

# step 4 - open ADM
BROWSER=
which google-chrome >& /dev/null && BROWSER="google-chrome"
which firefox >& /dev/null && BROWSER="firefox"
if [ $BROWSER ]; then 
  $BROWSER https://www.google.com/android/devicemanager &
else
  echo "Go to https://www.google.com/android/devicemanager in a browser and set a password, BUTTHEAD"
fi

echo "nuke rules."

set +x
set +e
