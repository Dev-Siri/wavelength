// GENERATED CODE -- DO NOT EDIT!

'use strict';
var grpc = require('@grpc/grpc-js');
var yt_scraper_pb = require('./yt_scraper_pb.js');

function serialize_yt_scraper_SearchRequest(arg) {
  if (!(arg instanceof yt_scraper_pb.SearchRequest)) {
    throw new Error('Expected argument of type yt_scraper.SearchRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchRequest(buffer_arg) {
  return yt_scraper_pb.SearchRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_yt_scraper_SearchResponse(arg) {
  if (!(arg instanceof yt_scraper_pb.SearchResponse)) {
    throw new Error('Expected argument of type yt_scraper.SearchResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_yt_scraper_SearchResponse(buffer_arg) {
  return yt_scraper_pb.SearchResponse.deserializeBinary(new Uint8Array(buffer_arg));
}


var YTScraperService = exports.YTScraperService = {
  getSearchSuggestions: {
    path: '/yt_scraper.YTScraper/GetSearchSuggestions',
    requestStream: false,
    responseStream: false,
    requestType: yt_scraper_pb.SearchRequest,
    responseType: yt_scraper_pb.SearchResponse,
    requestSerialize: serialize_yt_scraper_SearchRequest,
    requestDeserialize: deserialize_yt_scraper_SearchRequest,
    responseSerialize: serialize_yt_scraper_SearchResponse,
    responseDeserialize: deserialize_yt_scraper_SearchResponse,
  },
};

exports.YTScraperClient = grpc.makeGenericClientConstructor(YTScraperService, 'YTScraper');
