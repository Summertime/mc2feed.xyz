def releases: [ .versions[] | select(.type=="release") ] ;
def snapshots: [ .versions[] | select(.type=="release" or .type=="snapshot") ] ;

def jsonfeed(title):
	{
		version: "https://jsonfeed.org/version/1.1",
		title: title,
		home_page_url: "https://mc2feed.xyz",
		feed_url: "https://mc2feed.xyz/versions/releases.json",
		items: map({
			id: .id,
			url: "https://minecraft.fandom.com/wiki/Java_Edition_\(.id)",
			date_published: .releaseTime,
			content_text:"\(.id)"
		})
	}
;

def rssfeed(title):
	map("<item>" +
		"<title>\(.id|@html)</title>" +
		"<guid>https://minecraft.invalid/versions/\(.id|@uri)</guid>" +
		"<link>https://minecraft.fandom.com/wiki/Java_Edition_\(.id|@uri)</link>" +
		"<pubDate>\(.releaseTime|sub("\\+00:00";"Z")|fromdate|strftime("%a, %d %b %Y %T %z")|@html)</pubDate>" +
	"</item>") |
	"<rss version=\"2.0\">" +
		"<channel>" +
			"<title>\(title|@html)</title>" +
			"<link>https://mc2feed.xyz/</link>" +
			"<description>\(title|@html)</description>" +
			"\(.|join(""))" +
		"</channel>" +
	"</rss>"
;
