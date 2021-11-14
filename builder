#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset -o noclobber

rm --recursive --force output
cp --recursive site output

VM=$(mktemp)
curl -sS -- "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json" >| "$VM"


< "$VM" > output/versions/releases.json jq -c '
[ .versions[] | select(.type=="release") ] | {
	"version": "https://jsonfeed.org/version/1.1",
	"title": "Minecraft Releases",
	"home_page_url": "https://mc2feed.xyz",
	"feed_url": "https://mc2feed.xyz/versions/releases.json",
	"items": map({
		id: .id,
		url: "https://minecraft.fandom.com/wiki/Java_Edition_\(.id)",
		date_published: .releaseTime,
		content_text:"\(.id)"
	})
}'

< "$VM" > output/versions/snapshots.json jq -c '
[ .versions[] | select(.type=="release" or .type=="snapshot" ) ] | {
	"version": "https://jsonfeed.org/version/1.1",
	"title": "Minecraft Releases & Snapshots",
	"home_page_url": "https://mc2feed.xyz",
	"feed_url": "https://mc2feed.xyz/versions/snapshots.json",
	"items": map({
		id: .id,
		url: "https://minecraft.fandom.com/wiki/Java_Edition_\(.id)",
		date_published: .releaseTime,
		content_text:"\(.id)"
	})
}'


< "$VM" > output/versions/releases.rss jq -r '
[ .versions[] | select(.type=="release") ] |
map("<item>
	<title>\(.id)</title>
	<guid>mcversion:\(.id)</guid>
	<link>https://minecraft.fandom.com/wiki/Java_Edition_\(.id)</link>
	<pubDate>\(.releaseTime|sub("\\+00:00";"Z")|fromdate|strftime("%a, %d %b %Y %T %z"))</pubDate>
</item>") |
"<rss version=\"2.0\">
	<channel>
		<title>Minecraft Releases</title>
		<link>https://mc2feed.xyz/</link>
		<description>Minecraft Releases</description>
		\(.|join("\n"))
	</channel>
</rss>
"'

< "$VM" > output/versions/snapshots.rss jq -r '
[ .versions[] | select(.type=="release" or .type=="snapshot" ) ] | 
map("<item>
	<title>\(.id)</title>
	<guid>mcversion:\(.id)</guid>
	<link>https://minecraft.fandom.com/wiki/Java_Edition_\(.id)</link>
	<pubDate>\(.releaseTime|sub("\\+00:00";"Z")|fromdate|strftime("%a, %d %b %Y %T %z"))</pubDate>
</item>") |
"<rss version=\"2.0\">
	<channel>
		<title>Minecraft Releases & Snapshots</title>
		<link>https://mc2feed.xyz/</link>
		<description>Minecraft Releases & Snapshots</description>
		\(.|join("\n"))
	</channel>
</rss>
"'

