module Main exposing (..)

import Task
import Data exposing (ID, Store)
import Book
import Html exposing (Html)
import Html.Attributes as Attrs exposing (href)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData(..))


bookIDs : List ID
bookIDs =
    List.range 1 21 |> List.map toString


type alias Model =
    Store


type Msg
    = StoreUpdate Data.StoreUpdate
    | Load ID
    | LoadAll


main : Program Never Model Msg
main =
    Html.program
        { init = ( Data.initialStore, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg store =
    case msg of
        StoreUpdate update ->
            Data.updateStore update store ! []

        Load id ->
            ( store, Book.load id store |> Cmd.map StoreUpdate )

        LoadAll ->
            ( store, Book.loadMany |> Cmd.map StoreUpdate )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.a [ href "#", onClick LoadAll ] [ Html.text "Load Mutliple Books (index route)" ]
        , Html.ul [] <|
            List.map (viewBook model) bookIDs
        ]


viewBook : Model -> ID -> Html Msg
viewBook store id =
    Html.li [ Attrs.id id ] <|
        case Book.get id store of
            NotAsked ->
                [ Html.text ("Book #" ++ id ++ ": ")
                , Html.a [ href ("#" ++ id), onClick (Load id) ] [ Html.text "Load" ]
                ]

            Loading ->
                [ Html.text "LOADING..." ]

            Success { title, author, published } ->
                [ Html.text <| title ++ " by " ++ author ++ ", published " ++ toString published ]

            Failure err ->
                [ Html.text <| "Failure: " ++ toString err ]
