// GENERATED CODE -- DO NOT EDIT!

'use strict';
var grpc = require('@grpc/grpc-js');
var proto_yt_scraper_pb = require('../proto/yt_scraper_pb.js');
var proto_common_pb = require('../proto/common_pb.js');

function serialize_yt_scraper_GetAlbumDetailsRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetAlbumDetailsRequest)) {
    throw new Error('Expected argument of type yt_scraper.GetAlbumDetailsRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetAlbumDetailsRequest(buffer_arg) {
  return proto_yt_scraper_pb.GetAlbumDetailsRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetAlbumDetailsResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetAlbumDetailsResponse)) {
    throw new Error('Expected argument of type yt_scraper.GetAlbumDetailsResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetAlbumDetailsResponse(buffer_arg) {
  return proto_yt_scraper_pb.GetAlbumDetailsResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetArtistDetailsRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetArtistDetailsRequest)) {
    throw new Error('Expected argument of type yt_scraper.GetArtistDetailsRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetArtistDetailsRequest(buffer_arg) {
  return proto_yt_scraper_pb.GetArtistDetailsRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetArtistDetailsResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetArtistDetailsResponse)) {
    throw new Error('Expected argument of type yt_scraper.GetArtistDetailsResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetArtistDetailsResponse(buffer_arg) {
  return proto_yt_scraper_pb.GetArtistDetailsResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetQuickPicksRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetQuickPicksRequest)) {
    throw new Error('Expected argument of type yt_scraper.GetQuickPicksRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetQuickPicksRequest(buffer_arg) {
  return proto_yt_scraper_pb.GetQuickPicksRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetQuickPicksResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetQuickPicksResponse)) {
    throw new Error('Expected argument of type yt_scraper.GetQuickPicksResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetQuickPicksResponse(buffer_arg) {
  return proto_yt_scraper_pb.GetQuickPicksResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetSearchSuggestionsRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetSearchSuggestionsRequest)) {
    throw new Error('Expected argument of type yt_scraper.GetSearchSuggestionsRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetSearchSuggestionsRequest(buffer_arg) {
  return proto_yt_scraper_pb.GetSearchSuggestionsRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_GetSearchSuggestionsResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.GetSearchSuggestionsResponse)) {
    throw new Error('Expected argument of type yt_scraper.GetSearchSuggestionsResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_GetSearchSuggestionsResponse(buffer_arg) {
  return proto_yt_scraper_pb.GetSearchSuggestionsResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchAlbumsRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.SearchAlbumsRequest)) {
    throw new Error('Expected argument of type yt_scraper.SearchAlbumsRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchAlbumsRequest(buffer_arg) {
  return proto_yt_scraper_pb.SearchAlbumsRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchAlbumsResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.SearchAlbumsResponse)) {
    throw new Error('Expected argument of type yt_scraper.SearchAlbumsResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchAlbumsResponse(buffer_arg) {
  return proto_yt_scraper_pb.SearchAlbumsResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchArtistsRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.SearchArtistsRequest)) {
    throw new Error('Expected argument of type yt_scraper.SearchArtistsRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchArtistsRequest(buffer_arg) {
  return proto_yt_scraper_pb.SearchArtistsRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchArtistsResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.SearchArtistsResponse)) {
    throw new Error('Expected argument of type yt_scraper.SearchArtistsResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchArtistsResponse(buffer_arg) {
  return proto_yt_scraper_pb.SearchArtistsResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchTracksRequest(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.SearchTracksRequest)) {
    throw new Error('Expected argument of type yt_scraper.SearchTracksRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchTracksRequest(buffer_arg) {
  return proto_yt_scraper_pb.SearchTracksRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchTracksResponse(arg) {
  if (!(arg instanceof proto_yt_scraper_pb.SearchTracksResponse)) {
    throw new Error('Expected argument of type yt_scraper.SearchTracksResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchTracksResponse(buffer_arg) {
  return proto_yt_scraper_pb.SearchTracksResponse.deserializeBinary(new Uint8Array(buffer_arg));
}


var YTScraperService = exports.YTScraperService = {
  getSearchSuggestions: {
    path: '/yt_scraper.YTScraper/GetSearchSuggestions',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.GetSearchSuggestionsRequest,
    responseType: proto_yt_scraper_pb.GetSearchSuggestionsResponse,
    requestSerialize: serialize_yt_scraper_GetSearchSuggestionsRequest,
    requestDeserialize: deserialize_yt_scraper_GetSearchSuggestionsRequest,
    responseSerialize: serialize_yt_scraper_GetSearchSuggestionsResponse,
    responseDeserialize: deserialize_yt_scraper_GetSearchSuggestionsResponse,
  },
  getQuickPicks: {
    path: '/yt_scraper.YTScraper/GetQuickPicks',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.GetQuickPicksRequest,
    responseType: proto_yt_scraper_pb.GetQuickPicksResponse,
    requestSerialize: serialize_yt_scraper_GetQuickPicksRequest,
    requestDeserialize: deserialize_yt_scraper_GetQuickPicksRequest,
    responseSerialize: serialize_yt_scraper_GetQuickPicksResponse,
    responseDeserialize: deserialize_yt_scraper_GetQuickPicksResponse,
  },
  getAlbumDetails: {
    path: '/yt_scraper.YTScraper/GetAlbumDetails',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.GetAlbumDetailsRequest,
    responseType: proto_yt_scraper_pb.GetAlbumDetailsResponse,
    requestSerialize: serialize_yt_scraper_GetAlbumDetailsRequest,
    requestDeserialize: deserialize_yt_scraper_GetAlbumDetailsRequest,
    responseSerialize: serialize_yt_scraper_GetAlbumDetailsResponse,
    responseDeserialize: deserialize_yt_scraper_GetAlbumDetailsResponse,
  },
  getArtistDetails: {
    path: '/yt_scraper.YTScraper/GetArtistDetails',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.GetArtistDetailsRequest,
    responseType: proto_yt_scraper_pb.GetArtistDetailsResponse,
    requestSerialize: serialize_yt_scraper_GetArtistDetailsRequest,
    requestDeserialize: deserialize_yt_scraper_GetArtistDetailsRequest,
    responseSerialize: serialize_yt_scraper_GetArtistDetailsResponse,
    responseDeserialize: deserialize_yt_scraper_GetArtistDetailsResponse,
  },
  searchTracks: {
    path: '/yt_scraper.YTScraper/SearchTracks',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.SearchTracksRequest,
    responseType: proto_yt_scraper_pb.SearchTracksResponse,
    requestSerialize: serialize_yt_scraper_SearchTracksRequest,
    requestDeserialize: deserialize_yt_scraper_SearchTracksRequest,
    responseSerialize: serialize_yt_scraper_SearchTracksResponse,
    responseDeserialize: deserialize_yt_scraper_SearchTracksResponse,
  },
  searchArtists: {
    path: '/yt_scraper.YTScraper/SearchArtists',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.SearchArtistsRequest,
    responseType: proto_yt_scraper_pb.SearchArtistsResponse,
    requestSerialize: serialize_yt_scraper_SearchArtistsRequest,
    requestDeserialize: deserialize_yt_scraper_SearchArtistsRequest,
    responseSerialize: serialize_yt_scraper_SearchArtistsResponse,
    responseDeserialize: deserialize_yt_scraper_SearchArtistsResponse,
  },
  searchAlbums: {
    path: '/yt_scraper.YTScraper/SearchAlbums',
    requestStream: false,
    responseStream: false,
    requestType: proto_yt_scraper_pb.SearchAlbumsRequest,
    responseType: proto_yt_scraper_pb.SearchAlbumsResponse,
    requestSerialize: serialize_yt_scraper_SearchAlbumsRequest,
    requestDeserialize: deserialize_yt_scraper_SearchAlbumsRequest,
    responseSerialize: serialize_yt_scraper_SearchAlbumsResponse,
    responseDeserialize: deserialize_yt_scraper_SearchAlbumsResponse,
  },
};

exports.YTScraperClient = grpc.makeGenericClientConstructor(YTScraperService, 'YTScraper');
