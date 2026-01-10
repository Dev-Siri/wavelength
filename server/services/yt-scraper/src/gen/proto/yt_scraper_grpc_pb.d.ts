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
    getAlbumDetails: IYTScraperService_IGetAlbumDetails;
    getArtistDetails: IYTScraperService_IGetArtistDetails;
    searchTracks: IYTScraperService_ISearchTracks;
    searchArtists: IYTScraperService_ISearchArtists;
    searchAlbums: IYTScraperService_ISearchAlbums;
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
interface IYTScraperService_IGetAlbumDetails extends grpc.MethodDefinition<proto_yt_scraper_pb.GetAlbumDetailsRequest, proto_yt_scraper_pb.GetAlbumDetailsResponse> {
    path: "/yt_scraper.YTScraper/GetAlbumDetails";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.GetAlbumDetailsRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetAlbumDetailsRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.GetAlbumDetailsResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetAlbumDetailsResponse>;
}
interface IYTScraperService_IGetArtistDetails extends grpc.MethodDefinition<proto_yt_scraper_pb.GetArtistDetailsRequest, proto_yt_scraper_pb.GetArtistDetailsResponse> {
    path: "/yt_scraper.YTScraper/GetArtistDetails";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.GetArtistDetailsRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetArtistDetailsRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.GetArtistDetailsResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.GetArtistDetailsResponse>;
}
interface IYTScraperService_ISearchTracks extends grpc.MethodDefinition<proto_yt_scraper_pb.SearchTracksRequest, proto_yt_scraper_pb.SearchTracksResponse> {
    path: "/yt_scraper.YTScraper/SearchTracks";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.SearchTracksRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.SearchTracksRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.SearchTracksResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.SearchTracksResponse>;
}
interface IYTScraperService_ISearchArtists extends grpc.MethodDefinition<proto_yt_scraper_pb.SearchArtistsRequest, proto_yt_scraper_pb.SearchArtistsResponse> {
    path: "/yt_scraper.YTScraper/SearchArtists";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.SearchArtistsRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.SearchArtistsRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.SearchArtistsResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.SearchArtistsResponse>;
}
interface IYTScraperService_ISearchAlbums extends grpc.MethodDefinition<proto_yt_scraper_pb.SearchAlbumsRequest, proto_yt_scraper_pb.SearchAlbumsResponse> {
    path: "/yt_scraper.YTScraper/SearchAlbums";
    requestStream: false;
    responseStream: false;
    requestSerialize: grpc.serialize<proto_yt_scraper_pb.SearchAlbumsRequest>;
    requestDeserialize: grpc.deserialize<proto_yt_scraper_pb.SearchAlbumsRequest>;
    responseSerialize: grpc.serialize<proto_yt_scraper_pb.SearchAlbumsResponse>;
    responseDeserialize: grpc.deserialize<proto_yt_scraper_pb.SearchAlbumsResponse>;
}

export const YTScraperService: IYTScraperService;

export interface IYTScraperServer extends grpc.UntypedServiceImplementation {
    getSearchSuggestions: grpc.handleUnaryCall<proto_yt_scraper_pb.GetSearchSuggestionsRequest, proto_yt_scraper_pb.GetSearchSuggestionsResponse>;
    getQuickPicks: grpc.handleUnaryCall<proto_yt_scraper_pb.GetQuickPicksRequest, proto_yt_scraper_pb.GetQuickPicksResponse>;
    getAlbumDetails: grpc.handleUnaryCall<proto_yt_scraper_pb.GetAlbumDetailsRequest, proto_yt_scraper_pb.GetAlbumDetailsResponse>;
    getArtistDetails: grpc.handleUnaryCall<proto_yt_scraper_pb.GetArtistDetailsRequest, proto_yt_scraper_pb.GetArtistDetailsResponse>;
    searchTracks: grpc.handleUnaryCall<proto_yt_scraper_pb.SearchTracksRequest, proto_yt_scraper_pb.SearchTracksResponse>;
    searchArtists: grpc.handleUnaryCall<proto_yt_scraper_pb.SearchArtistsRequest, proto_yt_scraper_pb.SearchArtistsResponse>;
    searchAlbums: grpc.handleUnaryCall<proto_yt_scraper_pb.SearchAlbumsRequest, proto_yt_scraper_pb.SearchAlbumsResponse>;
}

export interface IYTScraperClient {
    getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    getAlbumDetails(request: proto_yt_scraper_pb.GetAlbumDetailsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetAlbumDetailsResponse) => void): grpc.ClientUnaryCall;
    getAlbumDetails(request: proto_yt_scraper_pb.GetAlbumDetailsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetAlbumDetailsResponse) => void): grpc.ClientUnaryCall;
    getAlbumDetails(request: proto_yt_scraper_pb.GetAlbumDetailsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetAlbumDetailsResponse) => void): grpc.ClientUnaryCall;
    getArtistDetails(request: proto_yt_scraper_pb.GetArtistDetailsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetArtistDetailsResponse) => void): grpc.ClientUnaryCall;
    getArtistDetails(request: proto_yt_scraper_pb.GetArtistDetailsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetArtistDetailsResponse) => void): grpc.ClientUnaryCall;
    getArtistDetails(request: proto_yt_scraper_pb.GetArtistDetailsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetArtistDetailsResponse) => void): grpc.ClientUnaryCall;
    searchTracks(request: proto_yt_scraper_pb.SearchTracksRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchTracksResponse) => void): grpc.ClientUnaryCall;
    searchTracks(request: proto_yt_scraper_pb.SearchTracksRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchTracksResponse) => void): grpc.ClientUnaryCall;
    searchTracks(request: proto_yt_scraper_pb.SearchTracksRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchTracksResponse) => void): grpc.ClientUnaryCall;
    searchArtists(request: proto_yt_scraper_pb.SearchArtistsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchArtistsResponse) => void): grpc.ClientUnaryCall;
    searchArtists(request: proto_yt_scraper_pb.SearchArtistsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchArtistsResponse) => void): grpc.ClientUnaryCall;
    searchArtists(request: proto_yt_scraper_pb.SearchArtistsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchArtistsResponse) => void): grpc.ClientUnaryCall;
    searchAlbums(request: proto_yt_scraper_pb.SearchAlbumsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchAlbumsResponse) => void): grpc.ClientUnaryCall;
    searchAlbums(request: proto_yt_scraper_pb.SearchAlbumsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchAlbumsResponse) => void): grpc.ClientUnaryCall;
    searchAlbums(request: proto_yt_scraper_pb.SearchAlbumsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchAlbumsResponse) => void): grpc.ClientUnaryCall;
}

export class YTScraperClient extends grpc.Client implements IYTScraperClient {
    constructor(address: string, credentials: grpc.ChannelCredentials, options?: Partial<grpc.ClientOptions>);
    public getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    public getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    public getSearchSuggestions(request: proto_yt_scraper_pb.GetSearchSuggestionsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetSearchSuggestionsResponse) => void): grpc.ClientUnaryCall;
    public getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    public getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    public getQuickPicks(request: proto_yt_scraper_pb.GetQuickPicksRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetQuickPicksResponse) => void): grpc.ClientUnaryCall;
    public getAlbumDetails(request: proto_yt_scraper_pb.GetAlbumDetailsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetAlbumDetailsResponse) => void): grpc.ClientUnaryCall;
    public getAlbumDetails(request: proto_yt_scraper_pb.GetAlbumDetailsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetAlbumDetailsResponse) => void): grpc.ClientUnaryCall;
    public getAlbumDetails(request: proto_yt_scraper_pb.GetAlbumDetailsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetAlbumDetailsResponse) => void): grpc.ClientUnaryCall;
    public getArtistDetails(request: proto_yt_scraper_pb.GetArtistDetailsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetArtistDetailsResponse) => void): grpc.ClientUnaryCall;
    public getArtistDetails(request: proto_yt_scraper_pb.GetArtistDetailsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetArtistDetailsResponse) => void): grpc.ClientUnaryCall;
    public getArtistDetails(request: proto_yt_scraper_pb.GetArtistDetailsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.GetArtistDetailsResponse) => void): grpc.ClientUnaryCall;
    public searchTracks(request: proto_yt_scraper_pb.SearchTracksRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchTracksResponse) => void): grpc.ClientUnaryCall;
    public searchTracks(request: proto_yt_scraper_pb.SearchTracksRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchTracksResponse) => void): grpc.ClientUnaryCall;
    public searchTracks(request: proto_yt_scraper_pb.SearchTracksRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchTracksResponse) => void): grpc.ClientUnaryCall;
    public searchArtists(request: proto_yt_scraper_pb.SearchArtistsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchArtistsResponse) => void): grpc.ClientUnaryCall;
    public searchArtists(request: proto_yt_scraper_pb.SearchArtistsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchArtistsResponse) => void): grpc.ClientUnaryCall;
    public searchArtists(request: proto_yt_scraper_pb.SearchArtistsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchArtistsResponse) => void): grpc.ClientUnaryCall;
    public searchAlbums(request: proto_yt_scraper_pb.SearchAlbumsRequest, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchAlbumsResponse) => void): grpc.ClientUnaryCall;
    public searchAlbums(request: proto_yt_scraper_pb.SearchAlbumsRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchAlbumsResponse) => void): grpc.ClientUnaryCall;
    public searchAlbums(request: proto_yt_scraper_pb.SearchAlbumsRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_yt_scraper_pb.SearchAlbumsResponse) => void): grpc.ClientUnaryCall;
}
