module ShareApp where

import ListingList
import ListingEntity
import UserAuth
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

type alias Model = WithRoute Routes.Route {
    userAuthModel : UserAuth.Model,
    listingListModel : ListingList.Model,
    listingEntityModel : ListingEntity.Model,
    userId: Maybe (String)
  }

type Action =
    NoOp
  | UserAuthAction UserAuth.Action
  | ListingListAction ListingList.Action
  | ListingEntityAction ListingEntity.Action
  | RouterAction (TransitRouter.Action Routes.Route)

initialModel : Model
initialModel = {
    transitRouter = TransitRouter.empty Routes.EmptyRoute,
    userAuthModel = UserAuth.init,
    listingListModel = ListingList.init,
    listingEntityModel = ListingEntity.init,
    userId = Nothing
  }


actions : Signal Action
actions =
  Signal.map RouterAction TransitRouter.actions


mountRoute : Route -> Route -> Model -> (Model, Effects Action)
mountRoute prevRoute route model =
  case route of
    UserAuthPage ->
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
routerConfig = {
    mountRoute = mountRoute,
    getDurations = \_ _ _ -> (50, 200),
    actionWrapper = RouterAction,
    routeDecoder = Routes.decode
  }


init : String -> (Model, Effects Action)
init path =
  TransitRouter.init routerConfig path initialModel

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    UserAuthAction userAuthAction ->
      let (model', effects) = UserAuth.update userAuthAction model.userAuthModel
      in ( { model | userAuthModel = (log "bb" model'), userId = model'.id  }
         , Effects.map UserAuthAction effects )

    ListingListAction act ->
      let (model', effects) = ListingList.update act model.listingListModel model.userId
      in ( { model | listingListModel = (log "aa" model')}
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
            a (linkAttrs ListingListPage) [ text "NUSShare" ]
          ]
        ],
        ul [class "nav navbar-nav"] [
          li [] [a (linkAttrs ListingListPage) [ text "Listings" ]]
        ],
        ul [class "nav navbar-nav navbar-right"] [
          li [] [a (linkAttrs UserAuthPage) [text <| navAuthTitle model.userAuthModel.name]]
        ]
    ]
  ]

navAuthTitle : String -> String
navAuthTitle name =
  case name of
    "" -> "Login / Register"
    _ -> "Welcome, " ++ name


contentView : Signal.Address Action -> Model -> Html
contentView address model =
  case (TransitRouter.getRoute model) of
    UserAuthPage ->
      UserAuth.view (Signal.forwardTo address UserAuthAction) model.userAuthModel

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
