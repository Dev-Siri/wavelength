// package: yt_scraper
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
    clearSuggestedQueriesList(): void;
    getSuggestedQueriesList(): Array<string>;
    setSuggestedQueriesList(value: Array<string>): SearchResponse;
    addSuggestedQueries(value: string, index?: number): string;
    clearSuggestedLinksList(): void;
    getSuggestedLinksList(): Array<SearchResponse.SuggestedLink>;
    setSuggestedLinksList(value: Array<SearchResponse.SuggestedLink>): SearchResponse;
    addSuggestedLinks(value?: SearchResponse.SuggestedLink, index?: number): SearchResponse.SuggestedLink;

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
        suggestedQueriesList: Array<string>,
        suggestedLinksList: Array<SearchResponse.SuggestedLink.AsObject>,
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

}
