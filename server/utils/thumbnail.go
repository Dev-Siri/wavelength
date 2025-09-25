package utils

import "google.golang.org/api/youtube/v3"

func GetHighestPossibleThumbnailUrl(thumbnailDetails *youtube.ThumbnailDetails) string {
	if thumbnailDetails.Maxres != nil && thumbnailDetails.Maxres.Url != "" {
		return thumbnailDetails.Maxres.Url
	}

	if thumbnailDetails.High != nil && thumbnailDetails.High.Url != "" {
		return thumbnailDetails.High.Url
	}

	if thumbnailDetails.Medium != nil && thumbnailDetails.Medium.Url != "" {
		return thumbnailDetails.Medium.Url
	}

	if thumbnailDetails.Standard != nil && thumbnailDetails.Standard.Url != "" {
		return thumbnailDetails.Standard.Url
	}

	if thumbnailDetails.Default != nil && thumbnailDetails.Default.Url != "" {
		return thumbnailDetails.Default.Url
	}

	return ""
}
