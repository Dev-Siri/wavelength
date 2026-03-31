package models

import "github.com/Dev-Siri/wavelength/server/services/player/types"

type StreamMetadata struct {
	StreamID            string                 `json:"streamId"`
	Bitrate             float64                `json:"bitrate"`
	Codec               string                 `json:"codec"`
	Container           string                 `json:"container"`
	DurationSeconds     float64                `json:"durationSeconds"`
	IsHifiAvailable     bool                   `json:"isHifiAvailable"`
	IsLosslessAvailable *types.LosslessBitType `json:"isLosslessAvailable"`
}

type StreamSourceResponse struct {
	Metadata StreamMetadata `json:"metadata"`
	Source   string         `json:"source"`
}
