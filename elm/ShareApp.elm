module ShareApp where

import ListingList
import ListingEntity
import MyListings
import ParticipatedListings
import UserAuth
import Routes exposing (..)
import ServerEndpoints

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Task exposing (..)
import Effects exposing (Effects, Never)
import Signal exposing (message)
import StartApp
import TransitRouter exposing (WithRoute, getTransition)
import TransitStyle
import Debug exposing (..)

-- Setup model types for each module imported
type alias Model = WithRoute Routes.Route {
    userAuthModel : UserAuth.Model,
    listingListModel : ListingList.Model,
    listingEntityModel : ListingEntity.Model,
    myListingsModel : MyListings.Model,
    participatedListingsModel : ParticipatedListings.Model,
    userId: Maybe (String)
  }

-- Initialize model with empty models using pure functions in modules
initialModel : Model
initialModel = {
    transitRouter = TransitRouter.empty Routes.EmptyRoute,
    userAuthModel = UserAuth.init,
    listingListModel = ListingList.init,
    listingEntityModel = ListingEntity.init,
    myListingsModel = MyListings.init,
    participatedListingsModel = ParticipatedListings.init,
    userId = Nothing
  }

-- Setup action types for each module imported
type Action =
    NoOp
  | UserAuthAction UserAuth.Action
  | ListingListAction ListingList.Action
  | ListingEntityAction ListingEntity.Action
  | MyListingsAction MyListings.Action
  | ParticipatedListingsAction ParticipatedListings.Action
  | RouterAction (TransitRouter.Action Routes.Route)
  | LogoutAction

actions : Signal Action
actions =
  Signal.map RouterAction TransitRouter.actions

-- Provides the correct update when new route mounted
mountRoute : Route -> Route -> Model -> (Model, Effects Action)
mountRoute prevRoute route model =
  case route of
    UserAuthPage ->
      (model, Effects.none)

    ListingListPage ->
      (model, Effects.map ListingListAction (ServerEndpoints.getListings ListingList.HandleListingsRetrieved))

    ListingEntityPage listingId ->
      (model, Effects.map ListingEntityAction (ServerEndpoints.getListing listingId ListingEntity.ShowListing))

    MyListingsPage ->
      case model.userId of
        Nothing ->
          (model, Effects.none)

        Just userId ->
          (model, Effects.map MyListingsAction (ServerEndpoints.getCreatorListings userId MyListings.HandleListingsRetrieved))

    ParticipatedListingsPage ->
      case model.userId of
        Nothing ->
          (model, Effects.none)

        Just userId ->
          (model, Effects.map ParticipatedListingsAction (ServerEndpoints.getParticipatedListings userId ParticipatedListings.HandleListingsRetrieved))

    NewListingPage ->
      ({ model | listingEntityModel = ListingEntity.init } , Effects.none)

    EmptyRoute ->
      (model, Effects.none)

routerConfig : TransitRouter.Config Routes.Route Action Model
routerConfig = {
    mountRoute = mountRoute,
    getDurations = \_ _ _ -> (50, 200),
    actionWrapper = RouterAction,
    routeDecoder = Routes.decode
  }

init : String -> (Model, Effects Action)
init path =
  TransitRouter.init routerConfig path initialModel

-- Update based on given action requested and return the corresponding effect
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    UserAuthAction userAuthAction ->
      let (model', effects) = UserAuth.update userAuthAction model.userAuthModel
      in ( { model | userAuthModel = model', userId = model'.id  },
           Effects.map UserAuthAction effects )

    ListingListAction act ->
      let (model', effects) = ListingList.update act model.listingListModel model.userId
      in ( { model | listingListModel = model'},
           Effects.map ListingListAction effects )

    ListingEntityAction act ->
      let (model', effects) = ListingEntity.update act model.listingEntityModel model.userId
      in ( { model | listingEntityModel = model' },
           Effects.map ListingEntityAction effects )

    MyListingsAction act ->
      case model.userId of
        Nothing -> (model, Effects.none)
        Just userId' ->
          let (model', effects) = MyListings.update act model.myListingsModel userId'
          in ( { model | myListingsModel = model'},
                Effects.map MyListingsAction effects )

    ParticipatedListingsAction act ->
      case model.userId of
        Nothing -> (model, Effects.none)
        Just userId' ->
          let (model', effects) = ParticipatedListings.update act model.participatedListingsModel userId'
          in ( { model | participatedListingsModel = model'},
                Effects.map ParticipatedListingsAction effects )

    RouterAction routeAction ->
      TransitRouter.update routerConfig routeAction model

    LogoutAction ->
      ({model | userAuthModel = UserAuth.init, userId = Nothing}, Effects.none)

-- Main view/layout functions
menu : Signal.Address Action -> Model -> Html
menu address model =
  header [class "navbar navbar-default"] [
    div [class "container"] [
        div [class "navbar-header"] [
          div [ class "navbar-brand" ] [
            a (linkAttrs ListingListPage) [ text "NUSShare" ]
          ]
        ],
        ul [class "nav navbar-nav", hidden <| (model.userId == Nothing)] [
          li [] [a (linkAttrs MyListingsPage) [ text "My Listings" ]]
        ],
        ul [class "nav navbar-nav", hidden <| (model.userId == Nothing)] [
          li [] [a (linkAttrs ParticipatedListingsPage) [ text "Participated Listings" ]]
        ],
        div [class "navbar-right"] [
          ul [class "nav navbar-nav"] [
            li [] [a (linkAttrs UserAuthPage) [text <| navAuthTitle model.userAuthModel]]
          ],
          ul [class "nav navbar-nav", hidden <| (model.userId == Nothing)] [
            li [] [button [class "btn btn-info navbar-btn", type' "button", onClick address LogoutAction] [span [class "glyphicon glyphicon-send"] [], text "  Logout"]]
          ]
        ]
    ]
  ]

navAuthTitle : UserAuth.Model -> String
navAuthTitle user =
  case user.id of
    Just _ -> "Welcome, " ++ user.name
    Nothing -> "Login / Register"


contentView : Signal.Address Action -> Model -> Html
contentView address model =
  case (TransitRouter.getRoute model) of
    UserAuthPage ->
      UserAuth.view (Signal.forwardTo address UserAuthAction) model.userAuthModel

    ListingListPage ->
      ListingList.view (Signal.forwardTo address ListingListAction) model.listingListModel model.userId

    ListingEntityPage i ->
      ListingEntity.view (Signal.forwardTo address ListingEntityAction) model.listingEntityModel model.userId

    NewListingPage ->
      ListingEntity.view (Signal.forwardTo address ListingEntityAction) model.listingEntityModel model.userId

    MyListingsPage ->
      MyListings.view (Signal.forwardTo address MyListingsAction) model.myListingsModel model.userId

    ParticipatedListingsPage ->
      ParticipatedListings.view (Signal.forwardTo address ParticipatedListingsAction) model.participatedListingsModel model.userId

    EmptyRoute ->
      text "Empty Route"

view : Signal.Address Action -> Model -> Html
view address model =
  div [class "container-fluid"] [
      menu address model,
      div [ class "content",
            style (TransitStyle.fadeSlideLeft 100 (getTransition model))]
          [contentView address model]
  ]

-- Wiring up StartApp boilerplate with our defined views, inputs, router, update
app : StartApp.App Model
app =
  StartApp.start {
      init = init initialPath,
      update = update,
      view = view,
      inputs = [actions]
    }

main : Signal Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks

port initialPath : String
