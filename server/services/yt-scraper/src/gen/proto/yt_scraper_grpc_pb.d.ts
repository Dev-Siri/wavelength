// package: yt_scraper
// file: proto/yt_scraper.proto

/* tslint:disable */
/* eslint-disable */

import * as grpc from "@grpc/grpc-js";
import * as proto_yt_scraper_pb from "../proto/yt_scraper_pb";
import * as proto_common_pb from "../proto/common_pb";

interface IYTScraperService extends grpc.ServiceDefinition<grpc.UntypedServiceImplementation> {
    getSearchSuggestions: IYTScraperService_IGetSearchSuggestions;
    getQuickPicks: IYTScraperService_IGetQuickPicks;
}

interface IYTScraperService_IGetSearchSuggestions extends grpc.MethodDefinition<proto_yt_scraper_pb.GetSearchSuggestionsRequest, proto_yt_scraper_pb.GetSearchSuggestionsResponse> {
    path: "/yt_scraper.YTScraper/GetSearchSuggestions";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.GetSearchSuggestionsRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetSearchSuggestionsRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.GetSearchSuggestionsResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetSearchSuggestionsResponse>;
}
interface IYTScraperService_IGetQuickPicks extends grpc.MethodDefinition<proto_yt_scraper_pb.GetQuickPicksRequest, proto_yt_scraper_pb.GetQuickPicksResponse> {
    path: "/yt_scraper.YTScraper/GetQuickPicks";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.GetQuickPicksRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetQuickPicksRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.GetQuickPicksResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetQuickPicksResponse>;
}

export const YTScraperService: IYTScraperService;

export interface IYTScraperServer extends grpc.UntypedServiceImplementation {
    getSearchSuggestions: grpc.handleUnaryCall<proto_yt_scraper_pb.GetSearchSuggestionsRequest, proto_yt_scraper_pb.GetSearchSuggestionsResponse>;
    getQuickPicks: grpc.handleUnaryCall<proto_yt_scraper_pb.GetQuickPicksRequest, proto_yt_scraper_pb.GetQuickPicksResponse>;
}

export interface IYTScraperClient {
    getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
}

export class YTScraperClient extends grpc.Client implements IYTScraperClient {
    constructor(address: string, credentials: grpc.ChannelCredentials, options?: Partial<grpc.ClientOptions>);
    public getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    public getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    public getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    public getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    public getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    public getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
}
