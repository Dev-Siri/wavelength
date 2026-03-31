package types

type PlayabilityStatus string

const (
	PlayabilityStatusPlayable    PlayabilityStatus = "PLAYABLE"
	PlayabilityStatusUnplayable  PlayabilityStatus = "UNPLAYABLE"
	PlayabilityStatusUnavailable PlayabilityStatus = "UNAVAILABLE"
)
