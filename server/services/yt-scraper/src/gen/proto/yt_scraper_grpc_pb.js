// GENERATED CODE -- DO NOT EDIT!

'use strict';
var grpc = require('@grpc/grpc-js');
var proto_yt_scraper_pb = require('../proto/yt_scraper_pb.js');
var proto_common_pb = require('../proto/common_pb.js');

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
};

exports.YTScraperClient = grpc.makeGenericClientConstructor(YTScraperService, 'YTScraper');
