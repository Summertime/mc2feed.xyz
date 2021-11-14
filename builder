#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset -o noclobber

rm --recursive --force output
cp --recursive site output

VM=$(mktemp)
curl -sS -- "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json" >| "$VM"


< "$VM" > output/versions/releases.json jq -c '
[
	.versions[] |
	select(.type=="release") |
	{id, content_text:"\(.id)"}
] | {
	"version": "https://jsonfeed.org/version/1.1",
	"title": "Minecraft Releases",
	"home_page_url": "https://mc2feed.xyz",
	"feed_url": "https://mc2feed.xyz/versions/releases.json",
	"items": .
}'

< "$VM" > output/versions/snapshots.json jq -c '
[
	.versions[] |
	select(.type=="release" or .type=="snapshot" ) |
	{id, content_text:"\(.id) - \(.type)"}
] | {
	"version": "https://jsonfeed.org/version/1.1",
	"title": "Minecraft Releases & Snapshots",
	"home_page_url": "https://mc2feed.xyz",
	"feed_url": "https://mc2feed.xyz/versions/snapshots.json",
	"items": .
}'
