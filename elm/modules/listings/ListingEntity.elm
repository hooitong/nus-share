module ListingEntity (Model, Action (..), init, view, update) where

import ServerEndpoints exposing (..)
import Routes

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Debug exposing (..)
import String exposing (toInt)
import Date exposing (..)
import Date.Format exposing (..)

---- MODEL ----
-- Application state for each entity
type alias Model = {
  id: Maybe String,
  title: String,
  lType: String,
  content: String,
  venue: String,
  startDate: String,
  endDate: String,
  limit: Int,
  closed: Bool,
  creator: Maybe(User),
  users: Maybe(List User)
}

---- UPDATE ----
type Action =
    NoOp
  | GetListing (String)
  | ShowListing (Maybe Listing)
  | SaveListing
  | HandleSaved (Maybe Listing)
  | SetListingTitle (String)
  | SetListinglType (String)
  | SetListingContent (String)
  | SetListingVenue (String)
  | SetListingStart (String)
  | SetListingEnd (String)
  | SetListingLimit (String)

init : Model
init =
   Model Nothing "" "" "" "" "" "" 0 False Nothing Nothing

update : Action -> Model -> Maybe(String) -> (Model, Effects Action)
update action model userId =
  case action of
    NoOp ->
      (model, Effects.none)

    GetListing id ->
      (model, getListing id ShowListing)

    ShowListing maybeListing ->
      case maybeListing of
        Just listing ->
          ({ model | id = Just listing.id,
                     title = listing.title,
                     lType = listing.lType,
                     content = listing.content,
                     venue = listing.venue,
                     startDate = listing.startDate,
                     endDate = listing.endDate,
                     limit = listing.limit,
                     closed = listing.closed,
                     creator = Just listing.creator,
                     users = Just listing.users
                   }
          , Effects.none
          )
        Nothing ->
          (init, Effects.none)

    SaveListing ->
      case userId of
        Nothing ->
          (model, Effects.none)

        Just userId' ->
          (model, createListing {title = model.title, lType = model.lType, content = model.content, venue = model.venue, startDate = model.startDate, endDate = model.endDate, limit = model.limit, closed = model.closed, creatorId = userId' } HandleSaved)

    HandleSaved maybeListing ->
      case maybeListing of
        Just listing ->
          ({ model | id = Just listing.id,
                     title = listing.title,
                     lType = listing.lType,
                     content = listing.content,
                     venue = listing.venue,
                     startDate = listing.startDate,
                     endDate = listing.endDate,
                     limit = listing.limit,
                     closed = listing.closed,
                     creator = Just listing.creator,
                     users = Just listing.users
                   }
            , Effects.map (\_ -> NoOp) (Routes.redirect Routes.ListingListPage)
          )

        Nothing ->
          Debug.crash "Something wrong when saving."


    SetListingTitle text ->
      ({model | title = text}, Effects.none)

    SetListinglType text ->
      ({model | lType = text}, Effects.none)

    SetListingContent text ->
      ({model | content = text}, Effects.none)

    SetListingVenue text ->
      ({model | venue = text}, Effects.none)

    SetListingStart text ->
      ({model | startDate = text}, Effects.none)

    SetListingEnd text ->
      ({model | endDate = text}, Effects.none)

    SetListingLimit text ->
      ({model | limit = (case (toInt text) of
                          Ok v -> v
                          Err _ -> 1
                        )}, Effects.none)

---- VIEW ----
view : Signal.Address Action -> Model -> Maybe(String) -> Html
view address model userId =
  case model.id of
    Just _ -> viewListing address model userId
    Nothing -> viewCreate address model userId

viewCreate : Signal.Address Action -> Model -> Maybe(String) -> Html
viewCreate address model userId =
  div [class "container"] [
    div [class "row"] [h2 [class "col-md-offset-2"] [text "Create Listing"]],
    br [] [],
    div [class "row"] [
      Html.form [class "form-horizontal"] [
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "Title"],
              div [class "col-sm-8"] [
                input [
                    placeholder "Event Party",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListingTitle str))
                ] []
              ]
          ],
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "Type"],
              div [class "col-sm-4"] [
                input [
                    placeholder "Help Needed",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListinglType str))
                ] []
              ]
          ],
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "Content"],
              div [class "col-sm-8"] [
                textarea [
                    placeholder "This party is about...",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListingContent str))
                ] []
              ]
          ],
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "Venue"],
              div [class "col-sm-8"] [
                input [
                    placeholder "NUS Hall 5",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListingVenue str))
                ] []
              ]
          ],
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "Start Date"],
              div [class "col-sm-4"] [
                input [
                    placeholder "25 September 2016 7pm",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListingStart str))
                ] []
              ]
          ],
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "End Date"],
              div [class "col-sm-4"] [
                input [
                    placeholder "26 September 2016 8pm",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListingEnd str))
                ] []
              ]
          ],
          div [class "form-group"] [
              label [class "col-sm-2 control-label"] [text "Limit"],
              div [class "col-sm-2"] [
                input [
                    placeholder "5",
                    class "form-control",
                    on "input" targetValue (\str -> Signal.message address (SetListingLimit str))
                ] []
              ]
          ],
          div [class "form-group"] [
              div [class "col-sm-offset-2 col-sm-10"] [
                button [
                    class "btn btn-success",
                    type' "button",
                    onClick address SaveListing
                ]
                [text "Save"]
              ]
          ]
      ]
    ]
  ]

viewListing :  Signal.Address Action -> Model -> Maybe(String) -> Html
viewListing address model userId =
  div [class "container"] [
    div [class "row"] [h2 [] [text "View Listing"]],
    div [class "row"] [
      table [class "table table-striped"] [
          thead [] [
            tr [] [
              th [class "col-sm-2"] [],
              th [class "col-sm-8"] []
            ]
          ],
        tbody [] [
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Title"]],
              td [style [("vertical-align", "middle")]] [text model.title]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Type"]],
              td [style [("vertical-align", "middle")]] [text model.lType]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Content"]],
              td [style [("vertical-align", "middle")]] [text model.content]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Venue"]],
              td [style [("vertical-align", "middle")]] [text model.venue]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Start Date"]],
              td [style [("vertical-align", "middle")]] [text (format "%d %b %Y %I:%M%p" (fromString model.startDate |> Result.withDefault (Date.fromTime 0)))]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "End Date"]],
              td [style [("vertical-align", "middle")]] [text (format "%d %b %Y %I:%M%p" (fromString model.endDate |> Result.withDefault (Date.fromTime 0)))]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Limit"]],
              td [style [("vertical-align", "middle")]] [text (toString model.limit)]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Closed"]],
              td [style [("vertical-align", "middle")]] [text (toString model.closed)]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Creator"]],
              td [style [("vertical-align", "middle")]] [
                table [class "table table-striped table-hover table-condensed"] [
                  thead [] [
                      tr [] [
                        th [class "col-sm-4"] [text "Name"],
                        th [class "col-sm-4"] [text "Contact"],
                        th [class "col-sm-4"] [text "Email"]
                      ]
                  ],
                  tbody [] (case model.creator of
                              Nothing -> []
                              Just creator ->
                                [
                                  tr [] [
                                    td [style [("vertical-align", "middle")]] [text creator.name],
                                    td [style [("vertical-align", "middle")]] [text creator.contact],
                                    td [style [("vertical-align", "middle")]] [text creator.email]
                                  ]
                                ]
                            )
                ]
              ]
            ],
            tr [] [
              td [style [("vertical-align", "middle")]] [h4 [] [text "Signups"]],
              td [style [("vertical-align", "middle")]] [
                table [class "table table-striped table-hover table-condensed"] [
                  thead [] [
                    tr [] [
                      th [class "col-sm-4"] [text "Name"],
                      th [class "col-sm-4"] [text "Contact"],
                      th [class "col-sm-4"] [text "Email"]
                    ]
                  ],
                  tbody [] (case model.users of
                              Nothing -> []
                              Just users -> (List.map (userRow address) users))
                ]
              ]
            ]
        ]
      ]
    ]
  ]

-- Helper Methods
userRow : Signal.Address Action -> User -> Html
userRow address user =
  tr [] [
    td [style [("vertical-align", "middle")]] [text user.name],
    td [style [("vertical-align", "middle")]] [text user.contact],
    td [style [("vertical-align", "middle")]] [text user.email]
  ]
