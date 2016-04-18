module ShareApp where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp
import Http
import Json.Decode as JsonD exposing (..)
import Json.Decode.Extra exposing (apply)
import Json.Encode as JsonE
import Effects exposing (Effects, Never)
import Task
import Signal exposing (Signal, Address)
import String
import Window
import Date
import Debug exposing (log)

type alias User = {
  id: String,
  name: String,
  email: String,
  contact: String
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

type alias Model = {
  listings: List Listing
}

type Action = ListingRetrieved (Maybe (List Listing))

init : (Model, Effects Action)
init =
  ( Model []
    , getListings
  )

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ListingRetrieved xs -> ({model | listings = (Maybe.withDefault [] xs)}, Effects.none)

baseUrl: String
baseUrl = "http://devserver.com:8080/api"

getListings : Effects.Effects Action
getListings =
  Http.get listingsDecoder (baseUrl ++ "/listings")
    |> Task.toMaybe
    |> Task.map ListingRetrieved
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
listingsDecoder =
  at ["listings"] (JsonD.list listingDecoder)

listingRow : Listing -> Html
listingRow listing =
  tr [] [
    td [] [text (toString listing.id)],
    td [] [text listing.title]
  ]

view: Signal.Address Action -> Model -> Html
view address model =
  div [class "container-fluid"] [
        h1 [] [text "Listings" ],
        table [class "table table-striped"] [
          thead [] [
            tr [] [
              th [] [text "ID"],
              th [] [text "Title"]
          ]
        ],
        tbody [] (List.map listingRow (log "listings" model.listings))
    ]
  ]

-- start up application through extension
app : StartApp.App Model
app = StartApp.start {
    init = init,
    update = update,
    view = view,
    inputs = []
  }

main : Signal Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
