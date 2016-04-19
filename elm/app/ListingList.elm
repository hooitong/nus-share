module ListingList (Model, Action (..), init, view, update) where

import ServerEndpoints exposing (..)
import Routes
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Effects exposing (Effects, Never)
import Http

type alias Model =
  { listings : List Listing }

type Action =
    Show
  | HandleListingsRetrieved (Maybe (List Listing))
  | CloseListing (String)
  | HandleListingClosed (Maybe Http.Response)

init : Model
init =
  Model []

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Show ->
      (model, getListings HandleListingsRetrieved)

    HandleListingsRetrieved xs ->
      ( {model | listings = (Maybe.withDefault [] xs) }
      , Effects.none
      )

    CloseListing id ->
      (model, closeListing id HandleListingClosed)

    HandleListingClosed res ->
      (model, getListings HandleListingsRetrieved)

-- View Portion
listingRow : Signal.Address Action -> Listing -> Html
listingRow address listing =
  tr [] [
    td [] [text listing.title],
    td [] [text listing.creator.name],
    td [] [button [class "btn btn-default", Routes.clickAttr <| Routes.ListingEntityPage listing.id ] [text "Edit"]],
    td [] [button [class "btn btn-default", onClick address (CloseListing listing.id)] [ text "Delete" ]]
  ]

view : Signal.Address Action -> Model -> Html
view address model =
  div [] [
      h2 [] [text "Available Listings" ]
    , button [
            class "pull-right btn btn-default"
          , Routes.clickAttr Routes.NewListingPage
        ]
        [text "New Listing"]
    , table [class "table table-striped"] [
          thead [] [
            tr [] [
              th [] [text "Title"],
              th [] [text "Creator"],
              th [] [],
              th [] []
          ]
        ]
        , tbody [] (List.map (listingRow address) model.listings)
    ]
  ]
