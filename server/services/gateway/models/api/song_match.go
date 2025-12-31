package api_models

import type_constants "wavelength/services/gateway/constants/types"

type SongMatch struct {
	DisplayName         type_constants.SongDisplayName `json:"displayName"`
	LinkId              string                         `json:"linkId"`
	Platform            type_constants.SongPlatform    `json:"platform"`
	Show                bool                           `json:"show"`
	UniqueId            *string                        `json:"uniqueId"`
	Country             *string                        `json:"country"`
	Url                 *string                        `json:"url"`
	NativeAppUriMobile  *string                        `json:"nativeAppUriMobile"`
	NativeAppUriDesktop *string                        `json:"nativeAppUriDesktop"`
}
