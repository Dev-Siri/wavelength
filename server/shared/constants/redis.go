package shared_constants

type RedisKey string

const (
	MusicSearchSuggestionsKey RedisKey = "music:search_suggestions"
	MusicQuickPicksKey        RedisKey = "music:quick_picks"
	OAuthSessionKey           RedisKey = "oauth:session"
	AuthCodeKey               RedisKey = "oauth:code"
)

func (k RedisKey) K(id string) string {
	return string(k) + ":" + id
}
