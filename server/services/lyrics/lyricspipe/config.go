package lyricspipe

const (
	version                = "1.1.4"
	defaultKpoeSourceOrder = "apple,lyricsplus,musixmatch,spotify,musixmatch-word"
	geniusWorkerURL        = "https://fetch-genius.samidy.workers.dev/"
	cacheServerURL         = "https://lyrics-api.binimum.org"
	directKpoeServerURL    = "https://lyricsplus.binimum.org/v2/lyrics/get"
)

var kpoeServers = []string{
	"https://lyricsplus.binimum.org",
	"https://lyricsplus.atomix.one",
	"https://lyricsplus-seven.vercel.app",
	"https://lyricsplus.prjktla.workers.dev",
	"https://lyrics-plus-backend.vercel.app",
}

var tidalServers = []string{
	"https://arran.monochrome.tf",
	"https://api.monochrome.tf/",
	"https://triton.squid.wtf",
	"https://wolf.qqdl.site",
	"https://maus.qqdl.site",
	"https://vogel.qqdl.site",
	"https://katze.qqdl.site",
	"https://hund.qqdl.site",
	"https://tidal.kinoplus.online",
	"https://hifi-one.spotisaver.net",
	"https://hifi-two.spotisaver.net",
}
