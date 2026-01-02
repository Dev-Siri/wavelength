// package: playlist
// file: yt_scraper.proto

/* tslint:disable */
/* eslint-disable */

import * as jspb from "google-protobuf";

export class SearchRequest extends jspb.Message { 
    getQuery(): string;
    setQuery(value: string): SearchRequest;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchRequest.AsObject;
    static toObject(includeInstance: boolean, msg: SearchRequest): SearchRequest.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchRequest, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchRequest;
    static deserializeBinaryFromReader(message: SearchRequest, reader: jspb.BinaryReader): SearchRequest;
}

export namespace SearchRequest {
    export type AsObject = {
        query: string,
    }
}

export class SearchResponse extends jspb.Message { 
    clearSuggestionsList(): void;
    getSuggestionsList(): Array<string>;
    setSuggestionsList(value: Array<string>): SearchResponse;
    addSuggestions(value: string, index?: number): string;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SearchResponse.AsObject;
    static toObject(includeInstance: boolean, msg: SearchResponse): SearchResponse.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SearchResponse, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SearchResponse;
    static deserializeBinaryFromReader(message: SearchResponse, reader: jspb.BinaryReader): SearchResponse;
}

export namespace SearchResponse {
    export type AsObject = {
        suggestionsList: Array<string>,
    }
}
