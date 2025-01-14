import getArtistDetails from "./artists/get-artist-details";
import getQuickPicks from "./home/quick-picks";
import getMatch from "./root/get-match";
import searchMusic from "./search/search-music";

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
