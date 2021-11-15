#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset -o noclobber

rm --recursive --force output
cp --recursive site output

VM=$(mktemp)
curl -sS -- "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json" >| "$VM"

for FEED in json rss; do
for REL in releases snapshots; do
	TITLE="Minecraft Releases"
	if [[ $REL = snapshots ]]; then
		TITLE+=" & Snapshots"
	fi
	< "$VM" > output/versions/"$REL"."$FEED" jq -r \
		"include \"./functions\"; $REL | ${FEED}feed(\"$TITLE\")"
done
done
