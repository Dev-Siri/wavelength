// package: common
// file: proto/common.proto

/* tslint:disable */
/* eslint-disable */

import * as jspb from "google-protobuf";

export class Playlist extends jspb.Message { 
    getPlaylistId(): string;
    setPlaylistId(value: string): Playlist;
    getName(): string;
    setName(value: string): Playlist;
    getAuthorGoogleEmail(): string;
    setAuthorGoogleEmail(value: string): Playlist;
    getAuthorName(): string;
    setAuthorName(value: string): Playlist;
    getAuthorImage(): string;
    setAuthorImage(value: string): Playlist;

    hasIsPublic(): boolean;
    clearIsPublic(): void;
    getIsPublic(): boolean | undefined;
    setIsPublic(value: boolean): Playlist;

    hasCoverImage(): boolean;
    clearCoverImage(): void;
    getCoverImage(): string | undefined;
    setCoverImage(value: string): Playlist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): Playlist.AsObject;
    static toObject(includeInstance: boolean, msg: Playlist): Playlist.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: Playlist, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): Playlist;
    static deserializeBinaryFromReader(message: Playlist, reader: jspb.BinaryReader): Playlist;
}

export namespace Playlist {
    export type AsObject = {
        playlistId: string,
        name: string,
        authorGoogleEmail: string,
        authorName: string,
        authorImage: string,
        isPublic?: boolean,
        coverImage?: string,
    }
}

export class PlaylistTrack extends jspb.Message { 
    getPlaylistTrackId(): string;
    setPlaylistTrackId(value: string): PlaylistTrack;
    getTitle(): string;
    setTitle(value: string): PlaylistTrack;
    getThumbnail(): string;
    setThumbnail(value: string): PlaylistTrack;
    getPositionInPlaylist(): number;
    setPositionInPlaylist(value: number): PlaylistTrack;

    hasIsExplicit(): boolean;
    clearIsExplicit(): void;
    getIsExplicit(): boolean | undefined;
    setIsExplicit(value: boolean): PlaylistTrack;
    getDuration(): number;
    setDuration(value: number): PlaylistTrack;
    getVideoId(): string;
    setVideoId(value: string): PlaylistTrack;
    getVideoType(): VideoType;
    setVideoType(value: VideoType): PlaylistTrack;
    getPlaylistId(): string;
    setPlaylistId(value: string): PlaylistTrack;
    clearArtistsList(): void;
    getArtistsList(): Array<EmbeddedArtist>;
    setArtistsList(value: Array<EmbeddedArtist>): PlaylistTrack;
    addArtists(value?: EmbeddedArtist, index?: number): EmbeddedArtist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): PlaylistTrack.AsObject;
    static toObject(includeInstance: boolean, msg: PlaylistTrack): PlaylistTrack.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: PlaylistTrack, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): PlaylistTrack;
    static deserializeBinaryFromReader(message: PlaylistTrack, reader: jspb.BinaryReader): PlaylistTrack;
}

export namespace PlaylistTrack {
    export type AsObject = {
        playlistTrackId: string,
        title: string,
        thumbnail: string,
        positionInPlaylist: number,
        isExplicit?: boolean,
        duration: number,
        videoId: string,
        videoType: VideoType,
        playlistId: string,
        artistsList: Array<EmbeddedArtist.AsObject>,
    }
}

export class TracksLength extends jspb.Message { 
    getSongCount(): number;
    setSongCount(value: number): TracksLength;
    getSongDurationSecond(): number;
    setSongDurationSecond(value: number): TracksLength;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): TracksLength.AsObject;
    static toObject(includeInstance: boolean, msg: TracksLength): TracksLength.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: TracksLength, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): TracksLength;
    static deserializeBinaryFromReader(message: TracksLength, reader: jspb.BinaryReader): TracksLength;
}

export namespace TracksLength {
    export type AsObject = {
        songCount: number,
        songDurationSecond: number,
    }
}

export class LikedTrack extends jspb.Message { 
    getLikeId(): string;
    setLikeId(value: string): LikedTrack;
    getEmail(): string;
    setEmail(value: string): LikedTrack;
    getTitle(): string;
    setTitle(value: string): LikedTrack;
    getThumbnail(): string;
    setThumbnail(value: string): LikedTrack;

    hasIsExplicit(): boolean;
    clearIsExplicit(): void;
    getIsExplicit(): boolean | undefined;
    setIsExplicit(value: boolean): LikedTrack;
    getDuration(): number;
    setDuration(value: number): LikedTrack;
    getVideoId(): string;
    setVideoId(value: string): LikedTrack;
    getVideoType(): VideoType;
    setVideoType(value: VideoType): LikedTrack;
    clearArtistsList(): void;
    getArtistsList(): Array<EmbeddedArtist>;
    setArtistsList(value: Array<EmbeddedArtist>): LikedTrack;
    addArtists(value?: EmbeddedArtist, index?: number): EmbeddedArtist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): LikedTrack.AsObject;
    static toObject(includeInstance: boolean, msg: LikedTrack): LikedTrack.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: LikedTrack, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): LikedTrack;
    static deserializeBinaryFromReader(message: LikedTrack, reader: jspb.BinaryReader): LikedTrack;
}

export namespace LikedTrack {
    export type AsObject = {
        likeId: string,
        email: string,
        title: string,
        thumbnail: string,
        isExplicit?: boolean,
        duration: number,
        videoId: string,
        videoType: VideoType,
        artistsList: Array<EmbeddedArtist.AsObject>,
    }
}

export class SuggestedLink extends jspb.Message { 
    getThumbnail(): string;
    setThumbnail(value: string): SuggestedLink;
    getTitle(): string;
    setTitle(value: string): SuggestedLink;
    getSubtitle(): string;
    setSubtitle(value: string): SuggestedLink;
    getBrowseId(): string;
    setBrowseId(value: string): SuggestedLink;
    getType(): string;
    setType(value: string): SuggestedLink;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SuggestedLink.AsObject;
    static toObject(includeInstance: boolean, msg: SuggestedLink): SuggestedLink.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SuggestedLink, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SuggestedLink;
    static deserializeBinaryFromReader(message: SuggestedLink, reader: jspb.BinaryReader): SuggestedLink;
}

export namespace SuggestedLink {
    export type AsObject = {
        thumbnail: string,
        title: string,
        subtitle: string,
        browseId: string,
        type: string,
    }
}

export class EmbeddedAlbum extends jspb.Message { 
    getBrowseId(): string;
    setBrowseId(value: string): EmbeddedAlbum;
    getTitle(): string;
    setTitle(value: string): EmbeddedAlbum;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): EmbeddedAlbum.AsObject;
    static toObject(includeInstance: boolean, msg: EmbeddedAlbum): EmbeddedAlbum.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: EmbeddedAlbum, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): EmbeddedAlbum;
    static deserializeBinaryFromReader(message: EmbeddedAlbum, reader: jspb.BinaryReader): EmbeddedAlbum;
}

export namespace EmbeddedAlbum {
    export type AsObject = {
        browseId: string,
        title: string,
    }
}

export class EmbeddedArtist extends jspb.Message { 
    getBrowseId(): string;
    setBrowseId(value: string): EmbeddedArtist;
    getTitle(): string;
    setTitle(value: string): EmbeddedArtist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): EmbeddedArtist.AsObject;
    static toObject(includeInstance: boolean, msg: EmbeddedArtist): EmbeddedArtist.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: EmbeddedArtist, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): EmbeddedArtist;
    static deserializeBinaryFromReader(message: EmbeddedArtist, reader: jspb.BinaryReader): EmbeddedArtist;
}

export namespace EmbeddedArtist {
    export type AsObject = {
        browseId: string,
        title: string,
    }
}

export class QuickPick extends jspb.Message { 
    getVideoId(): string;
    setVideoId(value: string): QuickPick;
    getTitle(): string;
    setTitle(value: string): QuickPick;
    getThumbnail(): string;
    setThumbnail(value: string): QuickPick;
    clearArtistsList(): void;
    getArtistsList(): Array<EmbeddedArtist>;
    setArtistsList(value: Array<EmbeddedArtist>): QuickPick;
    addArtists(value?: EmbeddedArtist, index?: number): EmbeddedArtist;

    hasAlbum(): boolean;
    clearAlbum(): void;
    getAlbum(): EmbeddedAlbum | undefined;
    setAlbum(value?: EmbeddedAlbum): QuickPick;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): QuickPick.AsObject;
    static toObject(includeInstance: boolean, msg: QuickPick): QuickPick.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: QuickPick, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): QuickPick;
    static deserializeBinaryFromReader(message: QuickPick, reader: jspb.BinaryReader): QuickPick;
}

export namespace QuickPick {
    export type AsObject = {
        videoId: string,
        title: string,
        thumbnail: string,
        artistsList: Array<EmbeddedArtist.AsObject>,
        album?: EmbeddedAlbum.AsObject,
    }
}

export class MusicTrackStats extends jspb.Message { 
    getViewCount(): number;
    setViewCount(value: number): MusicTrackStats;
    getLikeCount(): number;
    setLikeCount(value: number): MusicTrackStats;
    getCommentCount(): number;
    setCommentCount(value: number): MusicTrackStats;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): MusicTrackStats.AsObject;
    static toObject(includeInstance: boolean, msg: MusicTrackStats): MusicTrackStats.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: MusicTrackStats, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): MusicTrackStats;
    static deserializeBinaryFromReader(message: MusicTrackStats, reader: jspb.BinaryReader): MusicTrackStats;
}

export namespace MusicTrackStats {
    export type AsObject = {
        viewCount: number,
        likeCount: number,
        commentCount: number,
    }
}

export class YouTubeVideo extends jspb.Message { 
    getVideoId(): string;
    setVideoId(value: string): YouTubeVideo;
    getTitle(): string;
    setTitle(value: string): YouTubeVideo;
    getThumbnail(): string;
    setThumbnail(value: string): YouTubeVideo;
    getAuthor(): string;
    setAuthor(value: string): YouTubeVideo;
    getAuthorChannelId(): string;
    setAuthorChannelId(value: string): YouTubeVideo;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): YouTubeVideo.AsObject;
    static toObject(includeInstance: boolean, msg: YouTubeVideo): YouTubeVideo.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: YouTubeVideo, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): YouTubeVideo;
    static deserializeBinaryFromReader(message: YouTubeVideo, reader: jspb.BinaryReader): YouTubeVideo;
}

export namespace YouTubeVideo {
    export type AsObject = {
        videoId: string,
        title: string,
        thumbnail: string,
        author: string,
        authorChannelId: string,
    }
}

export class AlbumTrack extends jspb.Message { 
    getVideoId(): string;
    setVideoId(value: string): AlbumTrack;
    getTitle(): string;
    setTitle(value: string): AlbumTrack;
    getDuration(): number;
    setDuration(value: number): AlbumTrack;
    getPositionInAlbum(): number;
    setPositionInAlbum(value: number): AlbumTrack;

    hasIsExplicit(): boolean;
    clearIsExplicit(): void;
    getIsExplicit(): boolean | undefined;
    setIsExplicit(value: boolean): AlbumTrack;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): AlbumTrack.AsObject;
    static toObject(includeInstance: boolean, msg: AlbumTrack): AlbumTrack.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: AlbumTrack, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): AlbumTrack;
    static deserializeBinaryFromReader(message: AlbumTrack, reader: jspb.BinaryReader): AlbumTrack;
}

export namespace AlbumTrack {
    export type AsObject = {
        videoId: string,
        title: string,
        duration: number,
        positionInAlbum: number,
        isExplicit?: boolean,
    }
}

export class Album extends jspb.Message { 
    getTitle(): string;
    setTitle(value: string): Album;
    getAlbumType(): AlbumType;
    setAlbumType(value: AlbumType): Album;
    getRelease(): string;
    setRelease(value: string): Album;
    getCover(): string;
    setCover(value: string): Album;
    getTotalSongCount(): number;
    setTotalSongCount(value: number): Album;
    getTotalDuration(): string;
    setTotalDuration(value: string): Album;

    hasArtist(): boolean;
    clearArtist(): void;
    getArtist(): EmbeddedArtist | undefined;
    setArtist(value?: EmbeddedArtist): Album;
    clearAlbumTracksList(): void;
    getAlbumTracksList(): Array<AlbumTrack>;
    setAlbumTracksList(value: Array<AlbumTrack>): Album;
    addAlbumTracks(value?: AlbumTrack, index?: number): AlbumTrack;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): Album.AsObject;
    static toObject(includeInstance: boolean, msg: Album): Album.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: Album, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): Album;
    static deserializeBinaryFromReader(message: Album, reader: jspb.BinaryReader): Album;
}

export namespace Album {
    export type AsObject = {
        title: string,
        albumType: AlbumType,
        release: string,
        cover: string,
        totalSongCount: number,
        totalDuration: string,
        artist?: EmbeddedArtist.AsObject,
        albumTracksList: Array<AlbumTrack.AsObject>,
    }
}

export class Track extends jspb.Message { 
    getVideoId(): string;
    setVideoId(value: string): Track;
    getTitle(): string;
    setTitle(value: string): Track;
    getThumbnail(): string;
    setThumbnail(value: string): Track;
    getDuration(): number;
    setDuration(value: number): Track;
    clearArtistsList(): void;
    getArtistsList(): Array<EmbeddedArtist>;
    setArtistsList(value: Array<EmbeddedArtist>): Track;
    addArtists(value?: EmbeddedArtist, index?: number): EmbeddedArtist;

    hasIsExplicit(): boolean;
    clearIsExplicit(): void;
    getIsExplicit(): boolean | undefined;
    setIsExplicit(value: boolean): Track;

    hasAlbum(): boolean;
    clearAlbum(): void;
    getAlbum(): EmbeddedAlbum | undefined;
    setAlbum(value?: EmbeddedAlbum): Track;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): Track.AsObject;
    static toObject(includeInstance: boolean, msg: Track): Track.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: Track, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): Track;
    static deserializeBinaryFromReader(message: Track, reader: jspb.BinaryReader): Track;
}

export namespace Track {
    export type AsObject = {
        videoId: string,
        title: string,
        thumbnail: string,
        duration: number,
        artistsList: Array<EmbeddedArtist.AsObject>,
        isExplicit?: boolean,
        album?: EmbeddedAlbum.AsObject,
    }
}

export class SearchArtist extends jspb.Message { 
    getBrowseId(): string;
    setBrowseId(value: string): SearchArtist;
    getTitle(): string;
    setTitle(value: string): SearchArtist;
    getThumbnail(): string;
    setThumbnail(value: string): SearchArtist;
    getAudience(): string;
    setAudience(value: string): SearchArtist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchArtist.AsObject;
    static toObject(includeInstance: boolean, msg: SearchArtist): SearchArtist.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchArtist, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchArtist;
    static deserializeBinaryFromReader(message: SearchArtist, reader: jspb.BinaryReader): SearchArtist;
}

export namespace SearchArtist {
    export type AsObject = {
        browseId: string,
        title: string,
        thumbnail: string,
        audience: string,
    }
}

export class Artist extends jspb.Message { 
    getBrowseId(): string;
    setBrowseId(value: string): Artist;
    getTitle(): string;
    setTitle(value: string): Artist;
    getThumbnail(): string;
    setThumbnail(value: string): Artist;
    getDescription(): string;
    setDescription(value: string): Artist;
    getAudience(): string;
    setAudience(value: string): Artist;
    clearTopSongsList(): void;
    getTopSongsList(): Array<Artist.TopSongTrack>;
    setTopSongsList(value: Array<Artist.TopSongTrack>): Artist;
    addTopSongs(value?: Artist.TopSongTrack, index?: number): Artist.TopSongTrack;
    clearAlbumsList(): void;
    getAlbumsList(): Array<Artist.ArtistAlbum>;
    setAlbumsList(value: Array<Artist.ArtistAlbum>): Artist;
    addAlbums(value?: Artist.ArtistAlbum, index?: number): Artist.ArtistAlbum;
    clearSinglesAndEpsList(): void;
    getSinglesAndEpsList(): Array<Artist.ArtistAlbum>;
    setSinglesAndEpsList(value: Array<Artist.ArtistAlbum>): Artist;
    addSinglesAndEps(value?: Artist.ArtistAlbum, index?: number): Artist.ArtistAlbum;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): Artist.AsObject;
    static toObject(includeInstance: boolean, msg: Artist): Artist.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: Artist, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): Artist;
    static deserializeBinaryFromReader(message: Artist, reader: jspb.BinaryReader): Artist;
}

export namespace Artist {
    export type AsObject = {
        browseId: string,
        title: string,
        thumbnail: string,
        description: string,
        audience: string,
        topSongsList: Array<Artist.TopSongTrack.AsObject>,
        albumsList: Array<Artist.ArtistAlbum.AsObject>,
        singlesAndEpsList: Array<Artist.ArtistAlbum.AsObject>,
    }


    export class TopSongTrack extends jspb.Message { 
        getVideoId(): string;
        setVideoId(value: string): TopSongTrack;
        getTitle(): string;
        setTitle(value: string): TopSongTrack;
        getThumbnail(): string;
        setThumbnail(value: string): TopSongTrack;
        getPlayCount(): string;
        setPlayCount(value: string): TopSongTrack;

        hasIsExplicit(): boolean;
        clearIsExplicit(): void;
        getIsExplicit(): boolean | undefined;
        setIsExplicit(value: boolean): TopSongTrack;

        hasAlbum(): boolean;
        clearAlbum(): void;
        getAlbum(): EmbeddedAlbum | undefined;
        setAlbum(value?: EmbeddedAlbum): TopSongTrack;

        serializeBinary(): Uint8Array;
        toObject(includeInstance?: boolean): TopSongTrack.AsObject;
        static toObject(includeInstance: boolean, msg: TopSongTrack): TopSongTrack.AsObject;
        static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
        static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
        static serializeBinaryToWriter(message: TopSongTrack, writer: jspb.BinaryWriter): void;
        static deserializeBinary(bytes: Uint8Array): TopSongTrack;
        static deserializeBinaryFromReader(message: TopSongTrack, reader: jspb.BinaryReader): TopSongTrack;
    }

    export namespace TopSongTrack {
        export type AsObject = {
            videoId: string,
            title: string,
            thumbnail: string,
            playCount: string,
            isExplicit?: boolean,
            album?: EmbeddedAlbum.AsObject,
        }
    }

    export class ArtistAlbum extends jspb.Message { 
        getAlbumId(): string;
        setAlbumId(value: string): ArtistAlbum;
        getTitle(): string;
        setTitle(value: string): ArtistAlbum;
        getThumbnail(): string;
        setThumbnail(value: string): ArtistAlbum;
        getReleaseDate(): string;
        setReleaseDate(value: string): ArtistAlbum;
        getAlbumType(): AlbumType;
        setAlbumType(value: AlbumType): ArtistAlbum;

        serializeBinary(): Uint8Array;
        toObject(includeInstance?: boolean): ArtistAlbum.AsObject;
        static toObject(includeInstance: boolean, msg: ArtistAlbum): ArtistAlbum.AsObject;
        static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
        static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
        static serializeBinaryToWriter(message: ArtistAlbum, writer: jspb.BinaryWriter): void;
        static deserializeBinary(bytes: Uint8Array): ArtistAlbum;
        static deserializeBinaryFromReader(message: ArtistAlbum, reader: jspb.BinaryReader): ArtistAlbum;
    }

    export namespace ArtistAlbum {
        export type AsObject = {
            albumId: string,
            title: string,
            thumbnail: string,
            releaseDate: string,
            albumType: AlbumType,
        }
    }

}

export class SearchAlbum extends jspb.Message { 
    getAlbumId(): string;
    setAlbumId(value: string): SearchAlbum;
    getTitle(): string;
    setTitle(value: string): SearchAlbum;
    getThumbnail(): string;
    setThumbnail(value: string): SearchAlbum;
    getReleaseDate(): string;
    setReleaseDate(value: string): SearchAlbum;
    getAlbumType(): AlbumType;
    setAlbumType(value: AlbumType): SearchAlbum;

    hasArtist(): boolean;
    clearArtist(): void;
    getArtist(): EmbeddedArtist | undefined;
    setArtist(value?: EmbeddedArtist): SearchAlbum;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchAlbum.AsObject;
    static toObject(includeInstance: boolean, msg: SearchAlbum): SearchAlbum.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchAlbum, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchAlbum;
    static deserializeBinaryFromReader(message: SearchAlbum, reader: jspb.BinaryReader): SearchAlbum;
}

export namespace SearchAlbum {
    export type AsObject = {
        albumId: string,
        title: string,
        thumbnail: string,
        releaseDate: string,
        albumType: AlbumType,
        artist?: EmbeddedArtist.AsObject,
    }
}

export class FollowedArtist extends jspb.Message { 
    getFollowId(): string;
    setFollowId(value: string): FollowedArtist;
    getBrowseId(): string;
    setBrowseId(value: string): FollowedArtist;
    getFollowerEmail(): string;
    setFollowerEmail(value: string): FollowedArtist;
    getName(): string;
    setName(value: string): FollowedArtist;
    getThumbnail(): string;
    setThumbnail(value: string): FollowedArtist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): FollowedArtist.AsObject;
    static toObject(includeInstance: boolean, msg: FollowedArtist): FollowedArtist.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: FollowedArtist, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): FollowedArtist;
    static deserializeBinaryFromReader(message: FollowedArtist, reader: jspb.BinaryReader): FollowedArtist;
}

export namespace FollowedArtist {
    export type AsObject = {
        followId: string,
        browseId: string,
        followerEmail: string,
        name: string,
        thumbnail: string,
    }
}

export enum VideoType {
    VIDEO_TYPE_UNSPECIFIED = 0,
    VIDEO_TYPE_TRACK = 1,
    VIDEO_TYPE_UVIDEO = 2,
}

export enum AlbumType {
    ALBUM_TYPE_UNSPECIFIED = 0,
    ALBUM_TYPE_ALBUM = 1,
    ALBUM_TYPE_SINGLE = 2,
    ALBUM_TYPE_EP = 3,
}
