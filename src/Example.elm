module Main exposing (..)

import Data
import Data.Article
import Html exposing (Html, program)
import Task


type alias Model =
    { store : Data.Store
    }


type Msg
    = UpdateStore Data.StoreUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateStore storeUpdate ->
            { model | store = Data.update storeUpdate model.store } ! []


view : Model -> Html msg
view { store } =
    Data.Article.getMany 10 store
        |> List.map (.attributes >> viewOne)
        |> Html.div []


viewOne : Data.ArticleAttributes -> Html msg
viewOne { title, body } =
    Html.div [] <|
        Html.h2 [] [ Html.text title ]
            :: List.map (\para -> Html.p [] [ Html.text para ]) body


{-| The point of breaking this up is that if store0 ever becomes more complicated, those changes propogate to cmd0.
-}
init =
    let
        store0 =
            Data.initialStore

        model0 =
            Model store0

        cmd0 =
            Data.Article.loadMany 10 store0
                |> Task.perform UpdateStore
    in
        ( model0, cmd0 )


main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
