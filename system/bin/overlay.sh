#!/system/bin/sh
#
# overlay script - by AlienMind
# 
# Intended to be run at flash time, this script
# will overlay some folders from sdcard to system and/or data
# partitions
#
# This way ROM users can customize their flashes to add
# custom apps, animations or whatever from the very beginning
#
# This is extracted from icetool overlay option,
# available on https://github.com/alienmind-org/BlackICE/blob/master/system/bin/icetool
#

# Device dependent paths
# OVERLAY_DIR is the directory (when in RECOVERY) where the files will be copied from

# DesireHD / Inspire4G
#SYSTEM_DEV=/dev/block/mmcblk0p25
#DATA_DEV=/dev/block/mmcblk0p26
#OVERLAY_DIR=/sdcard

# Nexus 4
SYSTEM_DEV=/dev/block/platform/msm_sdcc.1/by-name/system
DATA_DEV=/dev/block/platform/msm_sdcc.1/by-name/userdata
OVERLAY_DIR=/data/media/0/overlay 

###
#
# Overlay - Copy custom content from sdcard
Overlay() {
  local DST="$1"
  local SRC="$2"

  if [ "$DST" = "/system" ]; then
    DEV=/dev/block/mmcblk0p25
  elif [ "$DST" = "/data" ]; then
    DEV=/dev/block/mmcblk0p26
  else
    die "overlay: Invalid destination $DST"
  fi

  if [ ! -d "$SRC" ]; then
    die "overlay: Invalid source $SRC"
  fi

  # We try both methods for mounting
  mount $DEV $DST &>/dev/null
  mount -o remount,rw $DEV $DST

  # Copy
  cp -av $SRC/* $DST/

  #
  #umount $DST
}


# Fix possible permission issues with overlayed files
# These are only common fixes, some other custom fix may be added
FixPerms() {
  chmod 644 /system/app/* /data/app/*
  chmod 755 /system/etc/init.d/*
}

########

# Test if some folders are ready to be copied over
[ -d "$OVERLAY_DIR/system" ] && \
  Overlay /system "$OVERLAY_DIR/system"
  
[ -d "$OVERLAY_DIR/data" ] && \
  Overlay /data "$OVERLAY_DIR/data"

# Add possible .tar.gz overlays
# It is done now that we have /system and /data mounted
for i in $OVERLAY_DIR/*.tar.gz $OVERLAY_DIR/*.tgz ; do
   tar -C / -xzvf $i
done

# Custom permission fix
if [ -f "$OVERLAY_DIR/fixperms.sh" ]; then
  sh "$OVERLAY_DIR"/fixperms.sh 
else
  # Fix common known permission problems
  FixPerms
fi

exit 0
