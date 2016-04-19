module Routes where

import Effects exposing (Effects)
import RouteParser exposing (..)
import TransitRouter
import Html exposing (Attribute)
import Html.Attributes exposing (href)
import Json.Decode as Json
import Html.Events exposing (on, onClick, onWithOptions)
import Signal

type Route
  = UserAuthPage
  | ListingListPage
  | ListingEntityPage String
  | MyListingsPage
  | ParticipatedListingsPage
  | NewListingPage
  | EmptyRoute

routeParsers : List (Matcher Route)
routeParsers =
  [ static UserAuthPage "/login",
    static ListingListPage "/",
    static MyListingsPage "/me/created",
    static ParticipatedListingsPage "/me/participated",
    static NewListingPage "/listings/new",
    dyn1 ListingEntityPage "/listings/" string ""
  ]

decode : String -> Route
decode path =
  RouteParser.match routeParsers path
    |> Maybe.withDefault EmptyRoute


encode : Route -> String
encode route =
  case route of
    UserAuthPage         -> "/login"
    ListingListPage      -> "/"
    MyListingsPage        -> "/me/created"
    ParticipatedListingsPage -> "/me/participated"
    NewListingPage       -> "/listings/new"
    ListingEntityPage id -> "/listings/" ++ id
    EmptyRoute           -> ""


redirect : Route -> Effects ()
redirect route =
  encode route
    |> Signal.send TransitRouter.pushPathAddress
    |> Effects.task


clickAttr : Route -> Attribute
clickAttr route =
  on "click" Json.value (\_ ->  Signal.message TransitRouter.pushPathAddress <| encode route)


linkAttrs : Route -> List Attribute
linkAttrs route =
  let
    path = encode route
  in
    [ href path,
      onWithOptions
        "click"
        { stopPropagation = True, preventDefault = True }
        Json.value
        (\_ ->  Signal.message TransitRouter.pushPathAddress path)
    ]
