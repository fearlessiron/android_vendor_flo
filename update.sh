#!/bin/bash
set -e

repofd="https://f-droid.org/repo/"
repoug="https://microg.org/fdroid/repo/"

addCopy() {
cat >> Android.mk <<EOF
include \$(CLEAR_VARS)
LOCAL_MODULE := $2
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := bin/$1
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_OVERRIDES_PACKAGES := $3
include \$(BUILD_PREBUILT)

EOF
echo -e "\t$2 \\" >> apps.mk
}

rm -Rf bin apps.mk
cat > Android.mk <<EOF
LOCAL_PATH := \$(my-dir)

EOF
echo -e 'PRODUCT_PACKAGES += \\' > apps.mk

mkdir -p bin
#downloadFromFdroid packageName overrides
downloadFromFdroid() {
	mkdir -p tmp
	if [ ! -f tmp/indexfd.xml ];then
		#TODO: Check security keys
		wget --connect-timeout=10 $repofd/index.jar -O tmp/indexfd.jar
		unzip -p tmp/indexfd.jar index.xml > tmp/indexfd.xml
	fi
	marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]' -v ./marketvercode tmp/indexfd.xml || true)"
	apk="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname tmp/indexfd.xml || xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[1]' -v ./apkname tmp/indexfd.xml)"
	while ! wget --connect-timeout=10 $repofd/$apk -O bin/$apk;do sleep 1;done
	addCopy $apk $1 "$2"
}

downloadFromMicroG() {
	mkdir -p tmp
	if [ ! -f tmp/indexug.xml ];then
		#TODO: Check security keys
		wget --connect-timeout=10 $repofd/index.jar -O tmp/indexug.jar
		unzip -p tmp/indexug.jar index.xml > tmp/indexug.xml
	fi
	marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]' -v ./marketvercode tmp/indexug.xml || true)"
	apk="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname tmp/indexug.xml || xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[1]' -v ./apkname tmp/indexug.xml)"
	while ! wget --connect-timeout=10 $repofd/$apk -O bin/$apk;do sleep 1;done
	addCopy $apk $1 "$2"
}

downloadFromMicroG com.google.android.gms
downloadFromMicroG com.google.android.gsf
downloadFromMicroG com.android.vending
downloadFromMicroG org.microg.gms.droidguard
downloadFromMicroG org.microg.unifiednlp

#phh's Superuser
downloadFromFdroid me.phh.superuser
#YouTube viewer
downloadFromFdroid org.schabi.newpipe
#Ciphered SMS
#downloadFromFdroid org.smssecure.smssecure "messaging"
#Navigation
downloadFromFdroid net.osmand.plus
#Web browser
#downloadFromFdroid org.mozilla.fennec_fdroid "Browser2 QuickSearchBox"
#downloadFromFdroid acr.browser.lightning "Browser2 QuickSearchBox"
#Calendar
downloadFromFdroid ws.xsoh.etar
downloadFromFdroid org.dmfs.tasks
#Public transportation
#downloadFromFdroid de.grobox.liberario
downloadFromFdroid de.schildbach.oeffi
#Pdf viewer
downloadFromFdroid com.artifex.mupdf.viewer.app
#Keyboard/IME
#downloadFromFdroid com.menny.android.anysoftkeyboard "LatinIME OpenWnn"
#Play Store download
#downloadFromFdroid com.github.yeriomin.yalpstore
#Mail client
#downloadFromFdroid com.fsck.k9 "Email"
downloadFromFdroid com.fsck.k9
#Ciphered Instant Messaging
#downloadFromFdroid im.vector.alpha
#Calendar/Contacts sync
downloadFromFdroid at.bitfire.davdroid
#Nextcloud client
downloadFromFdroid com.nextcloud.client

downloadFromFdroid com.bytehamster.changelog
downloadFromFdroid vom.simplemobiletools.notes.pro
downloadFromFdroid net.programmierecke.radiodroid2
downloadFromFdroid com.bleyl.recurrence

#TODO: Some social network?
#Facebook? Twitter? Reddit? Mastodon?
downloadFromFdroid org.fdroid.fdroid
downloadFromFdroid org.gdroid.gdroid


echo >> apps.mk

rm -Rf tmp
