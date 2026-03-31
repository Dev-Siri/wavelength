package types

type PreferredQuality string

const (
	PreferredQualityStandard PreferredQuality = "128"
	PreferredQualityHifiBase PreferredQuality = "256"
	PreferredQualityHifiTop  PreferredQuality = "320"
	PreferredQualityAuto     PreferredQuality = "auto"
	PreferredQualityLossless PreferredQuality = "lossless"
)

func NewPreferredQualityOrDefault(quality string) PreferredQuality {
	if quality != string(PreferredQualityStandard) &&
		quality != string(PreferredQualityHifiBase) &&
		quality != string(PreferredQualityHifiTop) &&
		quality != string(PreferredQualityAuto) &&
		quality != string(PreferredQualityLossless) {
		return PreferredQualityStandard
	}

	return PreferredQuality(quality)
}
