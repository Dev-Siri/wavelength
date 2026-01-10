// package: yt_scraper
// file: proto/yt_scraper.proto

/* tslint:disable */
/* eslint-disable */

import * as jspb from "google-protobuf";
import * as proto_common_pb from "../proto/common_pb";

export class GetSearchSuggestionsRequest extends jspb.Message { 
    getQuery(): string;
    setQuery(value: string): GetSearchSuggestionsRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetSearchSuggestionsRequest.AsObject;
    static toObject(includeInstance: boolean, msg: GetSearchSuggestionsRequest): GetSearchSuggestionsRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetSearchSuggestionsRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetSearchSuggestionsRequest;
    static deserializeBinaryFromReader(message: GetSearchSuggestionsRequest, reader: jspb.BinaryReader): GetSearchSuggestionsRequest;
}

export namespace GetSearchSuggestionsRequest {
    export type AsObject = {
        query: string,
    }
}

export class GetSearchSuggestionsResponse extends jspb.Message { 
    clearSuggestedQueriesList(): void;
    getSuggestedQueriesList(): Array<string>;
    setSuggestedQueriesList(value: Array<string>): GetSearchSuggestionsResponse;
    addSuggestedQueries(value: string, index?: number): string;
    clearSuggestedLinksList(): void;
    getSuggestedLinksList(): Array<proto_common_pb.SuggestedLink>;
    setSuggestedLinksList(value: Array<proto_common_pb.SuggestedLink>): GetSearchSuggestionsResponse;
    addSuggestedLinks(value?: proto_common_pb.SuggestedLink, index?: number): proto_common_pb.SuggestedLink;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetSearchSuggestionsResponse.AsObject;
    static toObject(includeInstance: boolean, msg: GetSearchSuggestionsResponse): GetSearchSuggestionsResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetSearchSuggestionsResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetSearchSuggestionsResponse;
    static deserializeBinaryFromReader(message: GetSearchSuggestionsResponse, reader: jspb.BinaryReader): GetSearchSuggestionsResponse;
}

export namespace GetSearchSuggestionsResponse {
    export type AsObject = {
        suggestedQueriesList: Array<string>,
        suggestedLinksList: Array<proto_common_pb.SuggestedLink.AsObject>,
    }
}

export class GetQuickPicksRequest extends jspb.Message { 
    getGl(): string;
    setGl(value: string): GetQuickPicksRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetQuickPicksRequest.AsObject;
    static toObject(includeInstance: boolean, msg: GetQuickPicksRequest): GetQuickPicksRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetQuickPicksRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetQuickPicksRequest;
    static deserializeBinaryFromReader(message: GetQuickPicksRequest, reader: jspb.BinaryReader): GetQuickPicksRequest;
}

export namespace GetQuickPicksRequest {
    export type AsObject = {
        gl: string,
    }
}

export class GetQuickPicksResponse extends jspb.Message { 
    clearQuickPicksList(): void;
    getQuickPicksList(): Array<proto_common_pb.QuickPick>;
    setQuickPicksList(value: Array<proto_common_pb.QuickPick>): GetQuickPicksResponse;
    addQuickPicks(value?: proto_common_pb.QuickPick, index?: number): proto_common_pb.QuickPick;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetQuickPicksResponse.AsObject;
    static toObject(includeInstance: boolean, msg: GetQuickPicksResponse): GetQuickPicksResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetQuickPicksResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetQuickPicksResponse;
    static deserializeBinaryFromReader(message: GetQuickPicksResponse, reader: jspb.BinaryReader): GetQuickPicksResponse;
}

export namespace GetQuickPicksResponse {
    export type AsObject = {
        quickPicksList: Array<proto_common_pb.QuickPick.AsObject>,
    }
}

export class SearchTracksRequest extends jspb.Message { 
    getQuery(): string;
    setQuery(value: string): SearchTracksRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchTracksRequest.AsObject;
    static toObject(includeInstance: boolean, msg: SearchTracksRequest): SearchTracksRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchTracksRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchTracksRequest;
    static deserializeBinaryFromReader(message: SearchTracksRequest, reader: jspb.BinaryReader): SearchTracksRequest;
}

export namespace SearchTracksRequest {
    export type AsObject = {
        query: string,
    }
}

export class SearchTracksResponse extends jspb.Message { 
    clearTracksList(): void;
    getTracksList(): Array<proto_common_pb.Track>;
    setTracksList(value: Array<proto_common_pb.Track>): SearchTracksResponse;
    addTracks(value?: proto_common_pb.Track, index?: number): proto_common_pb.Track;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchTracksResponse.AsObject;
    static toObject(includeInstance: boolean, msg: SearchTracksResponse): SearchTracksResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchTracksResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchTracksResponse;
    static deserializeBinaryFromReader(message: SearchTracksResponse, reader: jspb.BinaryReader): SearchTracksResponse;
}

export namespace SearchTracksResponse {
    export type AsObject = {
        tracksList: Array<proto_common_pb.Track.AsObject>,
    }
}

export class GetAlbumDetailsRequest extends jspb.Message { 
    getAlbumId(): string;
    setAlbumId(value: string): GetAlbumDetailsRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetAlbumDetailsRequest.AsObject;
    static toObject(includeInstance: boolean, msg: GetAlbumDetailsRequest): GetAlbumDetailsRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetAlbumDetailsRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetAlbumDetailsRequest;
    static deserializeBinaryFromReader(message: GetAlbumDetailsRequest, reader: jspb.BinaryReader): GetAlbumDetailsRequest;
}

export namespace GetAlbumDetailsRequest {
    export type AsObject = {
        albumId: string,
    }
}

export class GetAlbumDetailsResponse extends jspb.Message { 

    hasAlbum(): boolean;
    clearAlbum(): void;
    getAlbum(): proto_common_pb.Album | undefined;
    setAlbum(value?: proto_common_pb.Album): GetAlbumDetailsResponse;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetAlbumDetailsResponse.AsObject;
    static toObject(includeInstance: boolean, msg: GetAlbumDetailsResponse): GetAlbumDetailsResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetAlbumDetailsResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetAlbumDetailsResponse;
    static deserializeBinaryFromReader(message: GetAlbumDetailsResponse, reader: jspb.BinaryReader): GetAlbumDetailsResponse;
}

export namespace GetAlbumDetailsResponse {
    export type AsObject = {
        album?: proto_common_pb.Album.AsObject,
    }
}

export class SearchArtistsRequest extends jspb.Message { 
    getQuery(): string;
    setQuery(value: string): SearchArtistsRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchArtistsRequest.AsObject;
    static toObject(includeInstance: boolean, msg: SearchArtistsRequest): SearchArtistsRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchArtistsRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchArtistsRequest;
    static deserializeBinaryFromReader(message: SearchArtistsRequest, reader: jspb.BinaryReader): SearchArtistsRequest;
}

export namespace SearchArtistsRequest {
    export type AsObject = {
        query: string,
    }
}

export class SearchArtistsResponse extends jspb.Message { 
    clearArtistsList(): void;
    getArtistsList(): Array<proto_common_pb.SearchArtist>;
    setArtistsList(value: Array<proto_common_pb.SearchArtist>): SearchArtistsResponse;
    addArtists(value?: proto_common_pb.SearchArtist, index?: number): proto_common_pb.SearchArtist;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchArtistsResponse.AsObject;
    static toObject(includeInstance: boolean, msg: SearchArtistsResponse): SearchArtistsResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchArtistsResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchArtistsResponse;
    static deserializeBinaryFromReader(message: SearchArtistsResponse, reader: jspb.BinaryReader): SearchArtistsResponse;
}

export namespace SearchArtistsResponse {
    export type AsObject = {
        artistsList: Array<proto_common_pb.SearchArtist.AsObject>,
    }
}

export class SearchAlbumsRequest extends jspb.Message { 
    getQuery(): string;
    setQuery(value: string): SearchAlbumsRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchAlbumsRequest.AsObject;
    static toObject(includeInstance: boolean, msg: SearchAlbumsRequest): SearchAlbumsRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchAlbumsRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchAlbumsRequest;
    static deserializeBinaryFromReader(message: SearchAlbumsRequest, reader: jspb.BinaryReader): SearchAlbumsRequest;
}

export namespace SearchAlbumsRequest {
    export type AsObject = {
        query: string,
    }
}

export class SearchAlbumsResponse extends jspb.Message { 
    clearAlbumsList(): void;
    getAlbumsList(): Array<proto_common_pb.SearchAlbum>;
    setAlbumsList(value: Array<proto_common_pb.SearchAlbum>): SearchAlbumsResponse;
    addAlbums(value?: proto_common_pb.SearchAlbum, index?: number): proto_common_pb.SearchAlbum;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchAlbumsResponse.AsObject;
    static toObject(includeInstance: boolean, msg: SearchAlbumsResponse): SearchAlbumsResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchAlbumsResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchAlbumsResponse;
    static deserializeBinaryFromReader(message: SearchAlbumsResponse, reader: jspb.BinaryReader): SearchAlbumsResponse;
}

export namespace SearchAlbumsResponse {
    export type AsObject = {
        albumsList: Array<proto_common_pb.SearchAlbum.AsObject>,
    }
}

export class GetArtistDetailsRequest extends jspb.Message { 
    getBrowseId(): string;
    setBrowseId(value: string): GetArtistDetailsRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetArtistDetailsRequest.AsObject;
    static toObject(includeInstance: boolean, msg: GetArtistDetailsRequest): GetArtistDetailsRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetArtistDetailsRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetArtistDetailsRequest;
    static deserializeBinaryFromReader(message: GetArtistDetailsRequest, reader: jspb.BinaryReader): GetArtistDetailsRequest;
}

export namespace GetArtistDetailsRequest {
    export type AsObject = {
        browseId: string,
    }
}

export class GetArtistDetailsResponse extends jspb.Message { 

    hasArtist(): boolean;
    clearArtist(): void;
    getArtist(): proto_common_pb.Artist | undefined;
    setArtist(value?: proto_common_pb.Artist): GetArtistDetailsResponse;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GetArtistDetailsResponse.AsObject;
    static toObject(includeInstance: boolean, msg: GetArtistDetailsResponse): GetArtistDetailsResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GetArtistDetailsResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GetArtistDetailsResponse;
    static deserializeBinaryFromReader(message: GetArtistDetailsResponse, reader: jspb.BinaryReader): GetArtistDetailsResponse;
}

export namespace GetArtistDetailsResponse {
    export type AsObject = {
        artist?: proto_common_pb.Artist.AsObject,
    }
}
