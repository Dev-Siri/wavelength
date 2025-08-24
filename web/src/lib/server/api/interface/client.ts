import getArtistDetails from "./artists/get-artist-details.js";
import getQuickPicks from "./home/quick-picks.js";
import getMatch from "./root/get-match.js";
import searchMusic from "./search/search-music.js";

export default function createYoutubeClient() {
  return {
    root: {
      getMatch,
    },
    home: {
      getQuickPicks,
    },
    artists: {
      getArtistDetails,
    },
    search: {
      searchMusic,
    },
  };
}
