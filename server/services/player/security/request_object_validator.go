package security

const (
	streamIndex    = "index.m3u8"
	streamMaster   = "master.m3u8"
	streamStandard = "standard.m3u8"
	streamHifiTop  = "hifitop.m3u8"
	streamHifiBase = "hifibase.m3u8"
)

func IsRequestObjectResourceNameValid(name string) bool {
	return name == streamIndex ||
		name == streamMaster ||
		name == streamHifiBase ||
		name == streamHifiTop ||
		name == streamStandard
}
