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
		wget --connect-timeout=10 $repoug/index.jar -O tmp/indexug.jar
		unzip -p tmp/indexug.jar index.xml > tmp/indexug.xml
	fi
	marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]' -v ./marketvercode tmp/indexug.xml || true)"
	apk="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname tmp/indexug.xml || xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[1]' -v ./apkname tmp/indexug.xml)"
	while ! wget --connect-timeout=10 $repoug/$apk -O bin/$apk;do sleep 1;done
	addCopy $apk $1 "$2"
}

#phh's Superuser
downloadFromFdroid me.phh.superuser

downloadFromFdroid com.bytehamster.changelog
downloadFromFdroid com.bleyl.recurrence

downloadFromFdroid org.fdroid.fdroid
downloadFromFdroid org.gdroid.gdroid

echo >> apps.mk

rm -Rf tmp
