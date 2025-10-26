package models

type HlsStreamShape struct {
	Message string      `json:"message"`
	Streams []HlsStream `json:"streams"`
}

type HlsStreamFragment struct {
	Url      string `json:"url"`
	Duration int    `json:"duration"`
}

type HlsStream struct {
	FormatID         string   `json:"format_id"`
	FormatIndex      *int     `json:"format_index"`
	URL              string   `json:"url"`
	ManifestURL      string   `json:"manifest_url"`
	Tbr              float64  `json:"tbr"`
	Ext              string   `json:"ext"`
	Fps              float64  `json:"fps"`
	Protocol         string   `json:"protocol"`
	Preference       *int     `json:"preference"`
	Quality          int      `json:"quality"`
	HasDrm           bool     `json:"has_drm"`
	Width            int      `json:"width"`
	Height           int      `json:"height"`
	Vcodec           string   `json:"vcodec"`
	Acodec           string   `json:"acodec"`
	DynamicRange     string   `json:"dynamic_range"`
	AvailableAt      int64    `json:"available_at"`
	SourcePreference int      `json:"source_preference"`
	VideoExt         string   `json:"video_ext"`
	AudioExt         string   `json:"audio_ext"`
	Vbr              *float64 `json:"vbr"`
	Abr              *float64 `json:"abr"`
	Resolution       string   `json:"resolution"`
	AspectRatio      float64  `json:"aspect_ratio"`
	Format           string   `json:"format"`
	// YouTube sends this but it's not used in the application code.
	// HttpHeaders       map[string]string  `json:"http_headers"`
}
