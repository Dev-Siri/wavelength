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
