module ListingList (Model, Action (..), init, view, update) where

import ServerEndpoints exposing (..)
import Routes
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Effects exposing (Effects, Never)
import Http
import Debug exposing (..)

type alias Model =
  { listings : List Listing }

type Action =
    Show
  | HandleListingsRetrieved (Maybe (List Listing))
  | CloseListing (String)
  | RegisterUser (String)
  | HandleListingClosed (Maybe Http.Response)

init : Model
init = Model []

update : Action -> Model -> Maybe(String) -> (Model, Effects Action)
update action model userId =
  case action of
    Show ->
      (model, getListings HandleListingsRetrieved)

    HandleListingsRetrieved xs ->
      ( {model | listings = (Maybe.withDefault [] xs) }
      , Effects.none
      )

    CloseListing id ->
      (model, closeListing id HandleListingClosed)

    RegisterUser id ->
      case (log "test111" userId) of
        Just userId' -> (model, registerUser id (log "test22" userId') HandleListingClosed)
        Nothing -> (model, getListings HandleListingsRetrieved)

    HandleListingClosed res ->
      (model, getListings HandleListingsRetrieved)

-- View Portion
listingRow : Signal.Address Action -> Listing -> Html
listingRow address listing =
  tr [] [
    td [style [("vertical-align", "middle")]] [text listing.title],
    td [style [("vertical-align", "middle")]] [text listing.creator.name],
    td [style [("vertical-align", "middle")]] [text listing.venue],
    td [style [("vertical-align", "middle")]] [text listing.startDate],
    td [style [("vertical-align", "middle")]] [text listing.endDate],
    td [] [button [class "btn btn-default", Routes.clickAttr <| Routes.ListingEntityPage listing.id ] [text "View"]],
    td [] [button [class "btn btn-primary", onClick address (RegisterUser listing.id)] [ text "Help" ]]
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
              th [] [text "Venue"],
              th [] [text "Start Date"],
              th [] [text "End Date"],
              th [] [],
              th [] []
          ]
        ]
        , tbody [] (List.map (listingRow address) model.listings)
    ]
  ]
