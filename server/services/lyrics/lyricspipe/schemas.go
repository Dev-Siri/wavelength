package lyricspipe

import "github.com/Dev-Siri/wavelength/server/proto/commonpb"

type Syllable struct {
	Text          string  `json:"text"`
	Part          bool    `json:"part"`
	Timestamp     int     `json:"timestamp"`
	Endtime       int     `json:"endtime"`
	RomanizedText *string `json:"romanizedText"`
	LineSynced    *bool   `json:"lineSynced"`
}

type LyricsLine struct {
	Text           []Syllable                              `json:"text"`
	Background     bool                                    `json:"background"`
	BackgroundText []Syllable                              `json:"backgroundText"`
	OppositeTurn   bool                                    `json:"oppositeTurn"`
	Timestamp      int                                     `json:"timestamp"`
	Endtime        int                                     `json:"endtime"`
	IsWordSynced   *bool                                   `json:"isWordSynced"`
	Alignment      *commonpb.LyricsLine_AlignmentDirection `json:"alignment"`
	SongPart       *string                                 `json:"songPart"`
	RomanizedText  *string                                 `json:"romanizedText"`
	Translation    *string                                 `json:"translation"`
}

type SongMetadata struct {
	Title      string  `json:"title"`
	Artist     string  `json:"artist"`
	Album      *string `json:"album"`
	DurationMs *int    `json:"durationMs"`
}

type SongCatalogResult struct {
	Title      *string `json:"title"`
	Artist     *string `json:"artist"`
	Album      *string `json:"album"`
	DurationMs *int    `json:"durationMs"`
	// Look for: appleMusic *string
	ID   map[string]string `json:"id"`
	ISRC *string           `json:"isrc"`
}

type ParsedQueryMetadata struct {
	Title  *string `json:"title"`
	Artist *string `json:"artist"`
	Album  *string `json:"album"`
}

type YouLyPlusLyricsResult struct {
	Lines  []*commonpb.LyricsLine `json:"lines"`
	Source string                 `json:"source"`
}

type ResolvedMetadata struct {
	Metadata    *SongMetadata `json:"metadata"`
	AppleID     *string       `json:"appleId"`
	AppleSong   *any          `json:"appleSong"`
	CatalogISRC string        `json:"catalogIsrc"`
}
