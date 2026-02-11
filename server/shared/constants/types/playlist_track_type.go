package shared_type_constants

import "github.com/Dev-Siri/wavelength/server/proto/commonpb"

type PlaylistTrackType string

const (
	PlaylistTrackTypeTrack  PlaylistTrackType = "track"
	PlaylistTrackTypeUVideo PlaylistTrackType = "uvideo"
)

var PlaylistTrackTypeGrpcMap = map[PlaylistTrackType]commonpb.VideoType{
	PlaylistTrackTypeTrack:  commonpb.VideoType_VIDEO_TYPE_TRACK,
	PlaylistTrackTypeUVideo: commonpb.VideoType_VIDEO_TYPE_UVIDEO,
}
