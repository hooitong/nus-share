module UserAuth (Model, Action(..), init, view, update) where

import ServerEndpoints exposing (..)
import Routes
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Effects exposing (Effects, Never)

type alias Model = {
  id: Maybe String,
  name: String,
  email: String,
  password: String,
  contact: String
}

init : Model
init = Model Nothing "" "" "" ""

type Action =
    NoOp
  | ShowAuth
  | Authenticate
  | Register
  | HandleAuthentication (Maybe User)
  | SetUserName (String)
  | SetUserEmail (String)
  | SetUserPassword (String)
  | SetUserContact (String)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    ShowAuth ->
      case model.id of
        Just id -> (model, Effects.map(\_ -> NoOp) (Routes.redirect Routes.ListingListPage))
        Nothing -> update action model

    Authenticate ->
      (model, authenticate {email = model.email, password = model.password} HandleAuthentication)

    Register ->
      (model, createUser {name = model.name, contact = model.contact, email = model.email, password = model.password} HandleAuthentication)

    HandleAuthentication maybeUser ->
      case maybeUser of
        Just user ->
          ({model | id = Just user.id,
                    name = user.name,
                    email = user.email,
                    contact = user.contact},
                    Effects.map (\_ -> NoOp) (Routes.redirect Routes.ListingListPage))

        Nothing ->
          (model, Effects.none)

    SetUserName text ->
      ({model | name = text}, Effects.none)

    SetUserPassword text ->
      ({model | password = text}, Effects.none)

    SetUserEmail text ->
      ({model | email = text}, Effects.none)

    SetUserContact text ->
      ({model | contact = text}, Effects.none)

view : Signal.Address Action -> Model -> Html
view address model =
  div [] [
    div [class "col-sm-6"] [
      h1 [] [text "Login"],
      Html.form [class "form-horizontal"] [
        div [class "form-group"] [
          label [class "col-sm-3 control-label"] [text "Email"],
          div [class "col-sm-9"] [
            input [
              type' "email",
              class "form-control",
              placeholder "Email",
              on "input" targetValue (\str -> Signal.message address (SetUserEmail str))
            ] []
          ]
        ],
        div [class "form-group"] [
          label [class "col-sm-3 control-label"] [text "Password"],
          div [class "col-sm-9"] [
            input [
              type' "password",
              class "form-control",
              placeholder "Password",
              on "input" targetValue (\str -> Signal.message address (SetUserPassword str))
            ] []
          ]
        ],
        div [class "form-group"] [
          div [class "col-sm-offset-3 col-sm-9"] [
            button [
              type' "button",
              class "btn btn-default",
              onClick address Authenticate
            ] [text "Sign In"]
          ]
        ]
      ]
    ],
    div [class "col-sm-6"] [
      h1 [] [text "Registration"],
      Html.form [class "form-horizontal"] [
        div [class "form-group"] [
          label [class "col-sm-3 control-label"] [text "Email"],
          div [class "col-sm-9"] [
            input [
              type' "email",
              class "form-control",
              placeholder "Email",
              on "input" targetValue (\str -> Signal.message address (SetUserEmail str))
            ] []
          ]
        ],
        div [class "form-group"] [
          label [class "col-sm-3 control-label"] [text "Password"],
          div [class "col-sm-9"] [
            input [
              type' "password",
              class "form-control",
              placeholder "Password",
              on "input" targetValue (\str -> Signal.message address (SetUserPassword str))
            ] []
          ]
        ],
        div [class "form-group"] [
          label [class "col-sm-3 control-label"] [text "Name"],
          div [class "col-sm-9"] [
            input [
              class "form-control",
              placeholder "Name",
              on "input" targetValue (\str -> Signal.message address (SetUserName str))
            ] []
          ]
        ],
        div [class "form-group"] [
          label [class "col-sm-3 control-label"] [text "Contact"],
          div [class "col-sm-9"] [
            input [
              class "form-control",
              placeholder "Contact",
              on "input" targetValue (\str -> Signal.message address (SetUserContact str))
            ] []
          ]
        ],
        div [class "form-group"] [
          div [class "col-sm-offset-3 col-sm-9"] [
            button [
              type' "button",
              class "btn btn-default",
              onClick address Register
            ] [text "Register"]
          ]
        ]
      ]
    ]
  ]
