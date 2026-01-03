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
    getAuthor(): string;
    setAuthor(value: string): PlaylistTrack;
    getDuration(): string;
    setDuration(value: string): PlaylistTrack;
    getVideoId(): string;
    setVideoId(value: string): PlaylistTrack;
    getVideoType(): VideoType;
    setVideoType(value: VideoType): PlaylistTrack;
    getPlaylistId(): string;
    setPlaylistId(value: string): PlaylistTrack;

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
        author: string,
        duration: string,
        videoId: string,
        videoType: VideoType,
        playlistId: string,
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
    getAuthor(): string;
    setAuthor(value: string): LikedTrack;
    getDuration(): string;
    setDuration(value: string): LikedTrack;
    getVideoId(): string;
    setVideoId(value: string): LikedTrack;
    getVideoType(): VideoType;
    setVideoType(value: VideoType): LikedTrack;

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
        author: string,
        duration: string,
        videoId: string,
        videoType: VideoType,
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

export class QuickPick extends jspb.Message { 
    getVideoId(): string;
    setVideoId(value: string): QuickPick;
    getTitle(): string;
    setTitle(value: string): QuickPick;
    getThumbnail(): string;
    setThumbnail(value: string): QuickPick;
    clearArtistsList(): void;
    getArtistsList(): Array<QuickPick.QuickPickArtist>;
    setArtistsList(value: Array<QuickPick.QuickPickArtist>): QuickPick;
    addArtists(value?: QuickPick.QuickPickArtist, index?: number): QuickPick.QuickPickArtist;

    hasAlbum(): boolean;
    clearAlbum(): void;
    getAlbum(): QuickPick.QuickPickAlbum | undefined;
    setAlbum(value?: QuickPick.QuickPickAlbum): QuickPick;

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
        artistsList: Array<QuickPick.QuickPickArtist.AsObject>,
        album?: QuickPick.QuickPickAlbum.AsObject,
    }


    export class QuickPickAlbum extends jspb.Message { 
        getBrowseId(): string;
        setBrowseId(value: string): QuickPickAlbum;
        getTitle(): string;
        setTitle(value: string): QuickPickAlbum;

        serializeBinary(): Uint8Array;
        toObject(includeInstance?: boolean): QuickPickAlbum.AsObject;
        static toObject(includeInstance: boolean, msg: QuickPickAlbum): QuickPickAlbum.AsObject;
        static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
        static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
        static serializeBinaryToWriter(message: QuickPickAlbum, writer: jspb.BinaryWriter): void;
        static deserializeBinary(bytes: Uint8Array): QuickPickAlbum;
        static deserializeBinaryFromReader(message: QuickPickAlbum, reader: jspb.BinaryReader): QuickPickAlbum;
    }

    export namespace QuickPickAlbum {
        export type AsObject = {
            browseId: string,
            title: string,
        }
    }

    export class QuickPickArtist extends jspb.Message { 
        getBrowseId(): string;
        setBrowseId(value: string): QuickPickArtist;
        getTitle(): string;
        setTitle(value: string): QuickPickArtist;

        serializeBinary(): Uint8Array;
        toObject(includeInstance?: boolean): QuickPickArtist.AsObject;
        static toObject(includeInstance: boolean, msg: QuickPickArtist): QuickPickArtist.AsObject;
        static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
        static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
        static serializeBinaryToWriter(message: QuickPickArtist, writer: jspb.BinaryWriter): void;
        static deserializeBinary(bytes: Uint8Array): QuickPickArtist;
        static deserializeBinaryFromReader(message: QuickPickArtist, reader: jspb.BinaryReader): QuickPickArtist;
    }

    export namespace QuickPickArtist {
        export type AsObject = {
            browseId: string,
            title: string,
        }
    }

}

export enum VideoType {
    VIDEO_TYPE_UNSPECIFIED = 0,
    VIDEO_TYPE_TRACK = 1,
    VIDEO_TYPE_UVIDEO = 2,
}
