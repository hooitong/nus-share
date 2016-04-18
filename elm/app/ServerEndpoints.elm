module ServerEndpoints where

import Http
import Json.Decode as JsonD exposing (..)
import Json.Decode.Extra exposing (apply)
import Json.Encode as JsonE
import Effects exposing (Effects, Never)
import Task
import Debug exposing (log)

type alias ListingRequest a =
  { a |
    title: String,
    lType: String,
    content: String,
    venue: String,
    startDate: String,
    endDate: String,
    limit: Int,
    closed: Bool
  }

type alias Listing = {
  id: String,
  title: String,
  lType: String,
  content: String,
  venue: String,
  startDate: String,
  endDate: String,
  limit: Int,
  closed: Bool
}

type alias User = {
  id: String,
  name: String,
  email: String,
  contact: String
}

baseUrl: String
baseUrl = "http://devserver.com:8080/api"

getListings : (Maybe (List Listing) -> a) -> Effects a
getListings action =
  Http.get listingsDecoder (baseUrl ++ "/listings")
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

getListing: String -> (Maybe Listing -> a) -> Effects.Effects a
getListing id action =
  Http.get listingDecoder (baseUrl ++ "/listings/" ++ id)
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

createListing: ListingRequest a -> (Maybe Listing -> b) -> Effects.Effects b
createListing listing action =
  Http.send Http.defaultSettings {
    verb = "POST",
    url = baseUrl ++ "/listings",
    body = Http.string (encodeListing listing),
    headers = [("Content-Type", "application/json")]
  }
  |> Http.fromJson listingDecoder
  |> Task.toMaybe
  |> Task.map action
  |> Effects.task

updateListing: Listing -> (Maybe Listing -> a) -> Effects.Effects a
updateListing listing action =
  Http.send Http.defaultSettings {
    verb = "PUT",
    url = baseUrl ++ "/listings/" ++ listing.id,
    body = Http.string (encodeListing listing),
    headers = [("Content-Type", "application/json")]
  }
  |> Http.fromJson listingDecoder
  |> Task.toMaybe
  |> Task.map action
  |> Effects.task

closeListing: String -> (Maybe Http.Response -> a) -> Effects.Effects a
closeListing id action =
  Http.send Http.defaultSettings {
    verb = "DELETE",
    url = baseUrl ++ "/listings" ++ id,
    body = Http.empty,
    headers = []
  }
  |> Task.toMaybe
  |> Task.map action
  |> Effects.task


listingDecoder : JsonD.Decoder Listing
listingDecoder = Listing
  `map` ("id" := JsonD.string)
  `apply` ("title" := JsonD.string)
  `apply` ("type" := JsonD.string)
  `apply` ("content" := JsonD.string)
  `apply` ("venue" := JsonD.string)
  `apply` ("startDate" := JsonD.string)
  `apply` ("endDate" := JsonD.string)
  `apply` ("limit" := JsonD.int)
  `apply` ("closed" := JsonD.bool)

listingsDecoder : JsonD.Decoder (List Listing)
listingsDecoder = (JsonD.list listingDecoder)

encodeListing : ListingRequest a -> String
encodeListing a =
  JsonE.encode 0 <| JsonE.object [
    ("title", JsonE.string a.title),
    ("type", JsonE.string a.lType),
    ("content", JsonE.string a.content),
    ("venue", JsonE.string a.venue),
    ("startDate", JsonE.string a.startDate),
    ("endDate", JsonE.string a.endDate),
    ("limit", JsonE.int a.limit),
    ("closed", JsonE.bool a.closed)
  ]
