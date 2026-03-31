package security

import (
	"strings"
	"unicode"
)

const (
	streamIndex                  = "index.m3u8"
	streamMaster                 = "master.m3u8"
	streamStandard               = "standard.m3u8"
	streamHifiTop                = "hifitop.m3u8"
	streamHifiBase               = "hifibase.m3u8"
	streamInit                   = "init.mp4"
	streamAutoStandardInit       = "st_init.mp4"
	streamAutoHifiTopInit        = "ht_init.mp4"
	streamAutoHifiBaseInit       = "hb_init.mp4"
	streamPartPrefix             = "seg"
	streamAutoStandardPartPrefix = "st_seg"
	streamHifiAutoBasePartPrefix = "hb_seg"
	streamHifiAutoTopPartPrefix  = "ht_seg"
	streamPartExt                = ".m4s"
)

func IsRequestObjectResourceNameValid(name string) bool {
	if name == streamIndex ||
		name == streamMaster ||
		name == streamInit ||
		name == streamHifiBase ||
		name == streamHifiTop ||
		name == streamAutoHifiTopInit ||
		name == streamAutoHifiBaseInit ||
		name == streamStandard ||
		name == streamAutoStandardInit {
		return true
	}

	if strings.HasSuffix(name, streamPartExt) {
		if strings.HasPrefix(name, streamPartPrefix) {
			return validateStreamPart(name, streamPartPrefix)
		}

		if strings.HasPrefix(name, streamAutoStandardPartPrefix) {
			return validateStreamPart(name, streamAutoStandardPartPrefix)
		}

		if strings.HasPrefix(name, streamHifiAutoBasePartPrefix) {
			return validateStreamPart(name, streamHifiAutoBasePartPrefix)
		}

		if strings.HasPrefix(name, streamHifiAutoTopPartPrefix) {
			return validateStreamPart(name, streamHifiAutoTopPartPrefix)
		}
	}

	return false
}

func validateStreamPart(name, prefix string) bool {
	num := strings.TrimSuffix(strings.TrimPrefix(name, prefix), streamPartExt)
	if num == "" {
		return false
	}

	for _, c := range num {
		if !unicode.IsDigit(c) {
			return false
		}
	}

	return true
}
