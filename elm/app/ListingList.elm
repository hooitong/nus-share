module ListingList (Model, Action (..), init, view, update) where

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
listingRow : Signal.Address Action -> Maybe(String) -> Listing -> Html
listingRow address userId listing =
  tr [] [
    td [style [("vertical-align", "middle")]] [text listing.title],
    td [style [("vertical-align", "middle")]] [text listing.creator.name],
    td [style [("vertical-align", "middle")]] [text listing.venue],
    td [style [("vertical-align", "middle")]] [text (format "%d %b %Y %I:%M%p" (fromString listing.startDate |> Result.withDefault (Date.fromTime 0)))],
    td [style [("vertical-align", "middle")]] [text (format "%d %b %Y %I:%M%p" (fromString listing.endDate |> Result.withDefault (Date.fromTime 0)))],
    td [] [div[class "btn-group"][button [class "btn btn-default", Routes.clickAttr <| Routes.ListingEntityPage listing.id ] [text "View"],
           button [class ("btn btn-primary " ++ (checkHelped listing userId)), onClick address (RegisterUser listing.id)] [ text "Help" ]]]
  ]

view : Signal.Address Action -> Model -> Maybe(String) -> Html
view address model userId =
  div [] [
      h2 [] [ text "Available Listings",
                    button [class "pull-right btn btn-default",
                             Routes.clickAttr Routes.NewListingPage]
                           [text "New Listing"]
            ],
      table [class "table table-striped"] [
          thead [] [
            tr [] [
              th [class "col-sm-3"] [text "Title"],
              th [class "col-sm-2"] [text "Creator"],
              th [class "col-sm-2"] [text "Venue"],
              th [class "col-sm-2"] [text "Start Date"],
              th [class "col-sm-2"] [text "End Date"],
              th [class "col-sm-1"] []
          ]
        ],
        tbody [] (List.map (listingRow address userId) model.listings)
    ]
  ]

-- Helper Methods
checkHelped : Listing -> Maybe(String) -> String
checkHelped listing userId =
  case userId of
    Just userId' -> if fst (foldl isUserPresent (False, userId') listing.users) then "disabled" else ""

    Nothing -> "disabled"

isUserPresent : User -> (Bool, String) -> (Bool, String)
isUserPresent user (acc, userId) =
  if acc == False then ((user.id == userId), userId) else (acc, userId)
