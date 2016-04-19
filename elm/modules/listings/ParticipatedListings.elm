module ParticipatedListings (Model, Action (..), init, view, update) where

import ServerEndpoints exposing (..)
import Routes

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Effects exposing (Effects, Never)
import Http
import Debug exposing (..)
import List exposing (..)
import Date exposing (..)
import Date.Format exposing (..)

---- MODEL ----
type alias Model =
  { listings : List Listing }

---- UPDATE ----
type Action =
    Show
  | HandleListingsRetrieved (Maybe (List Listing))

init : Model
init = Model []

update : Action -> Model -> String -> (Model, Effects Action)
update action model userId =
  case action of
    Show ->
      (model, getCreatorListings userId HandleListingsRetrieved)

    HandleListingsRetrieved xs ->
      ( {model | listings = (Maybe.withDefault [] xs) }, Effects.none)

---- VIEW ----
listingRow : Signal.Address Action -> Maybe(String) -> Listing -> Html
listingRow address userId listing =
  tr [] [
    td [style [("vertical-align", "middle")]] [text listing.title],
    td [style [("vertical-align", "middle")]] [text listing.creator.name],
    td [style [("vertical-align", "middle")]] [text listing.venue],
    td [style [("vertical-align", "middle")]] [text (format "%d %b %Y %I:%M%p" (fromString listing.startDate |> Result.withDefault (Date.fromTime 0)))],
    td [style [("vertical-align", "middle")]] [text (format "%d %b %Y %I:%M%p" (fromString listing.endDate |> Result.withDefault (Date.fromTime 0)))],
    td [class "pull-right"] [div [] [button [class "btn btn-default", Routes.clickAttr <| Routes.ListingEntityPage listing.id ] [text "View"]]]
  ]

view : Signal.Address Action -> Model -> Maybe(String) -> Html
view address model userId =
  div [class "container"] [
      h2 [] [ text "Participated Listings" ],
      table [class "table table-striped"] [
          thead [] [
            tr [] [
              th [class "col-sm-2"] [text "Title"],
              th [class "col-sm-2"] [text "Creator"],
              th [class "col-sm-2"] [text "Venue"],
              th [class "col-sm-2"] [text "Start Date"],
              th [class "col-sm-2"] [text "End Date"],
              th [class "col-sm-2"] []
          ]
        ],
        tbody [] (List.map (listingRow address userId) model.listings)
    ]
  ]
