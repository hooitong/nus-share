module ShareApp where

import ListingList
import ListingEntity
import UserHome
import Routes exposing (..)
import ServerEndpoints

import Html exposing (..)
import Html.Attributes exposing (..)
import Task exposing (..)
import Effects exposing (Effects, Never)
import Signal exposing (message)
import StartApp
import TransitRouter exposing (WithRoute, getTransition)
import TransitStyle

import Debug exposing (..)

type alias Model = WithRoute Routes.Route
  { userHomeModel : UserHome.Model
  , listingListModel : ListingList.Model
  , listingEntityModel : ListingEntity.Model
  }

type Action =
    NoOp
  | HomeAction UserHome.Action
  | ListingListAction ListingList.Action
  | ListingEntityAction ListingEntity.Action
  | RouterAction (TransitRouter.Action Routes.Route)

initialModel : Model
initialModel =
  { transitRouter = TransitRouter.empty Routes.EmptyRoute
  , userHomeModel = UserHome.init
  , listingListModel = ListingList.init
  , listingEntityModel = ListingEntity.init
  }


actions : Signal Action
actions =
  Signal.map RouterAction TransitRouter.actions


mountRoute : Route -> Route -> Model -> (Model, Effects Action)
mountRoute prevRoute route model =
  case route of
    UserHomePage ->
      (model, Effects.none)

    ListingListPage ->
      (model, Effects.map ListingListAction (ServerEndpoints.getListings ListingList.HandleListingsRetrieved))

    ListingEntityPage listingId ->
      (model, Effects.map ListingEntityAction (ServerEndpoints.getListing listingId ListingEntity.ShowListing))

    NewListingPage ->
      ({ model | listingEntityModel = ListingEntity.init } , Effects.none)

    EmptyRoute ->
      (model, Effects.none)


routerConfig : TransitRouter.Config Routes.Route Action Model
routerConfig =
  { mountRoute = mountRoute
  , getDurations = \_ _ _ -> (50, 200)
  , actionWrapper = RouterAction
  , routeDecoder = Routes.decode
  }


init : String -> (Model, Effects Action)
init path =
  TransitRouter.init routerConfig path initialModel

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    HomeAction homeAction ->
      let (model', effects) = UserHome.update homeAction model.userHomeModel
      in ( { model | userHomeModel = model' }
         , Effects.map HomeAction effects )

    ListingListAction act ->
      let (model', effects) = ListingList.update act model.listingListModel
      in ( { model | listingListModel = model' }
         , Effects.map ListingListAction effects )

    ListingEntityAction act ->
      let (model', effects) = ListingEntity.update act model.listingEntityModel
      in ( { model | listingEntityModel = model' }
         , Effects.map ListingEntityAction effects )

    RouterAction routeAction ->
      TransitRouter.update routerConfig routeAction model


-- Main view/layout functions
menu : Signal.Address Action -> Model -> Html
menu address model =
  header [class "navbar navbar-default"] [
    div [class "container"] [
        div [class "navbar-header"] [
          div [ class "navbar-brand" ] [
            a (linkAttrs UserHomePage) [ text "Login/Register" ]
          ]
        ]
      , ul [class "nav navbar-nav"] [
          li [] [a (linkAttrs ListingListPage) [ text "Artists" ]]
      ]
    ]
  ]

contentView : Signal.Address Action -> Model -> Html
contentView address model =
  case (TransitRouter.getRoute model) of
    UserHomePage ->
      UserHome.view (Signal.forwardTo address HomeAction) model.userHomeModel

    ListingListPage ->
      ListingList.view (Signal.forwardTo address ListingListAction) model.listingListModel

    ListingEntityPage i ->
      ListingEntity.view (Signal.forwardTo address ListingEntityAction) model.listingEntityModel

    NewListingPage  ->
      ListingEntity.view (Signal.forwardTo address ListingEntityAction) model.listingEntityModel

    EmptyRoute ->
      text "Empty Route"

view : Signal.Address Action -> Model -> Html
view address model =
  div [class "container-fluid"] [
      menu address model
    , div [ class "content"
          , style (TransitStyle.fadeSlideLeft 100 (getTransition model))]
          [contentView address model]
  ]

-- wiring up start app
app : StartApp.App Model
app =
  StartApp.start
    { init = init initialPath
    , update = update
    , view = view
    , inputs = [actions]
    }

main : Signal Html
main =
  app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

port initialPath : String
