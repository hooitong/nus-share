module ListingEntity (Model, Action (..), init, view, update) where

import ServerEndpoints exposing (..)
import Routes
import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Debug exposing (..)


type alias Model = {
  id: Maybe String,
  title: String,
  lType: String,
  content: String,
  venue: String,
  startDate: String,
  endDate: String,
  limit: Int,
  closed: Bool
}

type Action =
    NoOp
  | GetListing (String)
  | ShowListing (Maybe Listing)
  | SetListingTitle (String)
  | SaveListing
  | HandleSaved (Maybe Listing)

init : Model
init =
   Model Nothing "" "" "" "" "" "" 0 False

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    GetListing id ->
      (model, getListing (log "id" id) ShowListing)

    ShowListing maybeListing ->
      case maybeListing of
        Just listing ->
          ( { model | id = Just listing.id
                    , title = listing.title}
          , Effects.none
          )
        Nothing ->
          ( { model | id = Nothing
                    , title = ""}
          , Effects.none
          )

    SaveListing ->
      case model.id of
        Just id ->
          (model, updateListing id {title = model.title, lType = model.lType, content = model.content, venue = model.venue, startDate = model.startDate, endDate = model.endDate, limit = model.limit, closed = model.closed } HandleSaved)
        Nothing ->
          (model, createListing {title = model.title, lType = model.lType, content = model.content, venue = model.venue, startDate = model.startDate, endDate = model.endDate, limit = model.limit, closed = model.closed } HandleSaved)

    HandleSaved maybeListing ->
      case maybeListing of
        Just listing ->
          ({ model | id = Just listing.id
                   , title = listing.title }
            , Effects.map (\_ -> NoOp) (Routes.redirect Routes.ListingListPage)
          )

        Nothing ->
          Debug.crash "Something wrong when saving."


    SetListingTitle text ->
      ({model | title = text}, Effects.none)


pageTitle : Model -> String
pageTitle model =
  case model.id of
    Just x -> "Edit Listing"
    Nothing -> "New Listing"


view : Signal.Address Action -> Model -> Maybe(String) -> Html
view address model userId =
  div [] [
      h1 [] [text <| pageTitle (log "model" model)]
    , Html.form [class "form-horizontal"] [
        div [class "form-group"] [
            label [class "col-sm-2 control-label"] [text "Title"]
          , div [class "col-sm-10"] [
              input [
                  class "form-control"
                , value model.title
                , on "input" targetValue (\str -> Signal.message address (SetListingTitle str))
              ] []
            ]
        ]
        , div [class "form-group"] [
            div [class "col-sm-offset-2 col-sm-10"] [
              button [
                  class "btn btn-default"
                , type' "button"
                , onClick address SaveListing
              ]
              [text "Save"]
            ]
        ]
    ]
  ]
