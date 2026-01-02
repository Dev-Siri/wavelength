// package: yt_scraper
// file: yt_scraper.proto

/* tslint:disable */
/* eslint-disable */

import * as grpc from "@grpc/grpc-js";
import * as yt_scraper_pb from "./yt_scraper_pb";

interface IYTScraperService extends grpc.ServiceDefinition<grpc.UntypedServiceImplementation> {
    getSearchSuggestions: IYTScraperService_IGetSearchSuggestions;
}

interface IYTScraperService_IGetSearchSuggestions extends grpc.MethodDefinition<yt_scraper_pb.SearchRequest, yt_scraper_pb.SearchResponse> {
    path: "/yt_scraper.YTScraper/GetSearchSuggestions";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<yt_scraper_pb.SearchRequest>;
    requestDeserialize: grpc.deserialize<yt_scraper_pb.SearchRequest>;
    responseSerialize: grpc.serialize<yt_scraper_pb.SearchResponse>;
    responseDeserialize: grpc.deserialize<yt_scraper_pb.SearchResponse>;
}

export const YTScraperService: IYTScraperService;

export interface IYTScraperServer extends grpc.UntypedServiceImplementation {
    getSearchSuggestions: grpc.handleUnaryCall<yt_scraper_pb.SearchRequest, yt_scraper_pb.SearchResponse>;
}

export interface IYTScraperClient {
    getSearchSuggestions(request: yt_scraper_pb.SearchRequest, callback: (error: grpc.ServiceError | null, response: yt_scraper_pb.SearchResponse) => void): grpc.ClientUnaryCall;
    getSearchSuggestions(request: yt_scraper_pb.SearchRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: yt_scraper_pb.SearchResponse) => void): grpc.ClientUnaryCall;
    getSearchSuggestions(request: yt_scraper_pb.SearchRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: yt_scraper_pb.SearchResponse) => void): grpc.ClientUnaryCall;
}

export class YTScraperClient extends grpc.Client implements IYTScraperClient {
    constructor(address: string, credentials: grpc.ChannelCredentials, options?: Partial<grpc.ClientOptions>);
    public getSearchSuggestions(request: yt_scraper_pb.SearchRequest, callback: (error: grpc.ServiceError | null, response: yt_scraper_pb.SearchResponse) => void): grpc.ClientUnaryCall;
    public getSearchSuggestions(request: yt_scraper_pb.SearchRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: yt_scraper_pb.SearchResponse) => void): grpc.ClientUnaryCall;
    public getSearchSuggestions(request: yt_scraper_pb.SearchRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: yt_scraper_pb.SearchResponse) => void): grpc.ClientUnaryCall;
}
