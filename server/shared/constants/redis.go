package shared_constants

type RedisKey string

const (
	MusicSearchSuggestionsKey RedisKey = "music:search_suggestions"
	MusicQuickPicksKey        RedisKey = "music:quick_picks"
)

func (k RedisKey) K(id string) string {
	return string(k) + ":" + id
}
