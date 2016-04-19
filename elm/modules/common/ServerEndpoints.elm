module ServerEndpoints where

import Http
import Json.Decode as JsonD exposing (..)
import Json.Decode.Extra exposing (apply)
import Json.Encode as JsonE
import Effects exposing (Effects, Never)
import Task
import Jwt exposing (..)
import Debug exposing (log)

-- Listing Related Endpoint Handlers
-- Models for Listing Related
type alias ListingRequest a =
  { a |
    title: String,
    lType: String,
    creatorId: String,
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
  closed: Bool,
  creator: User,
  users: List User
}

-- HTTP Requests
baseListingUrl: String
baseListingUrl = "http://devserver.com:4000/api/listings"

getListings : (Maybe (List Listing) -> a) -> Effects a
getListings action =
  Http.get listingsDecoder (baseListingUrl)
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

getListing: String -> (Maybe Listing -> a) -> Effects.Effects a
getListing id action =
  Http.get listingDecoder (baseListingUrl ++ "/" ++ id)
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

getCreatorListings: String -> (Maybe (List Listing) -> a) -> Effects a
getCreatorListings id action =
    Http.get listingsDecoder (baseListingUrl ++ "/created/" ++ id)
      |> Task.toMaybe
      |> Task.map action
      |> Effects.task

getParticipatedListings: String -> (Maybe (List Listing) -> a) -> Effects a
getParticipatedListings id action =
    Http.get listingsDecoder (baseListingUrl ++ "/participated/" ++ id)
      |> Task.toMaybe
      |> Task.map action
      |> Effects.task

createListing: ListingRequest a -> (Maybe Listing -> b) -> Effects.Effects b
createListing listing action =
  Http.send Http.defaultSettings {
    verb = "POST",
    url = baseListingUrl,
    body = Http.string (encodeListing listing),
    headers = [("Content-Type", "application/json")]
  }
  |> Http.fromJson listingDecoder
  |> Task.toMaybe
  |> Task.map action
  |> Effects.task

updateListing: String -> ListingRequest a -> (Maybe Listing -> b) -> Effects.Effects b
updateListing id listing action =
  Http.send Http.defaultSettings {
    verb = "PUT",
    url = baseListingUrl ++ "/" ++ id,
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
    url = baseListingUrl ++ "/" ++ id,
    body = Http.empty,
    headers = []
  }
  |> Task.toMaybe
  |> Task.map action
  |> Effects.task

registerUser: String -> String -> (Maybe Http.Response -> a) -> Effects.Effects a
registerUser id userId action =
  Http.send Http.defaultSettings {
    verb = "PUT",
    url = baseListingUrl ++ "/" ++ id ++ "/" ++ userId,
    body = Http.empty,
    headers = []
  }
  |> Task.toMaybe
  |> Task.map action
  |> Effects.task

-- JSON Decoders and Encoders for Listings
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
  `apply` ("creator" := userDecoder)
  `apply` ("users" := usersDecoder)

listingsDecoder : JsonD.Decoder (List Listing)
listingsDecoder = (JsonD.list listingDecoder)

encodeListing : ListingRequest a -> String
encodeListing a =
  JsonE.encode 0 <| JsonE.object [
    ("title", JsonE.string a.title),
    ("type", JsonE.string a.lType),
    ("content", JsonE.string a.content),
    ("creatorId", JsonE.string a.creatorId),
    ("venue", JsonE.string a.venue),
    ("startDate", JsonE.string a.startDate),
    ("endDate", JsonE.string a.endDate),
    ("limit", JsonE.int a.limit),
    ("closed", JsonE.bool a.closed)
  ]

-- User Related Endpoint Handlers
-- Models for User Related
type alias UserRequest a =
  { a |
      name: String,
      password: String,
      email: String,
      contact: String
  }

type alias AuthRequest a = {
  a |
    email: String,
    password: String
}

type alias User = {
  id: String,
  name: String,
  email: String,
  contact: String
}

-- HTTP Requests
baseUserUrl: String
baseUserUrl = "http://devserver.com:4000/api/users"

getUser: String -> (Maybe User -> a) -> Effects.Effects a
getUser id action =
  Http.get userDecoder (baseUserUrl ++ "/" ++ id)
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

createUser: UserRequest a -> (Maybe User -> b)  ->  Effects.Effects b
createUser user action =
  Http.send Http.defaultSettings {
    verb = "POST",
    url = baseUserUrl,
    body = Http.string (encodeUser user),
    headers = [("Content-Type", "application/json")]
  }
    |> Http.fromJson userDecoder
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

authenticate: AuthRequest a -> (Maybe User -> b) -> Effects.Effects b
authenticate request action =
  Http.send Http.defaultSettings {
    verb = "POST",
    url = baseUserUrl ++ "/authenticate",
    body = Http.string (encodeAuth request),
    headers = [("Content-Type", "application/json")]
  }
    |> Http.fromJson userDecoder
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

-- JSON Decoders and Encoders for Users
userDecoder : JsonD.Decoder User
userDecoder = User
  `map` ("id" := JsonD.string)
  `apply` ("name" := JsonD.string)
  `apply` ("email" := JsonD.string)
  `apply` ("contact" := JsonD.string)

usersDecoder : JsonD.Decoder (List User)
usersDecoder = (JsonD.list userDecoder)

encodeUser : UserRequest a -> String
encodeUser a =
  JsonE.encode 0 <| JsonE.object [
    ("name", JsonE.string a.name),
    ("email", JsonE.string a.email),
    ("password", JsonE.string a.password),
    ("contact", JsonE.string a.contact)
  ]

encodeAuth : AuthRequest a -> String
encodeAuth a =
  JsonE.encode 0 <| JsonE.object [
    ("email", JsonE.string a.email),
    ("password", JsonE.string a.password)
  ]

userToken: Maybe(User)
userToken = Nothing
