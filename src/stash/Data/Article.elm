module Data.Article exposing (..)

{-| Module docs
-}

import Dict
import Data exposing (ArticleData, ArticleAttributes, Data, ID, Store, StoreUpdate(..))
import Json.Decode as D exposing (Decoder, (:=))
import Time exposing (Time)
import Task exposing (Task)
import Http


decode : Time -> Decoder ( ID, Data.InternalArticle )
decode time =
    D.object3 (,,)
        (D.at [ "data", "id" ] D.string)
        (D.at [ "data", "attributes" ]
            (D.object2
                ArticleAttributes
                ("firstName" := D.string)
                ("lastName" := D.string)
            )
        )
        (D.at [ "data", "relationships", "authors" ]
            (D.list
                (D.object2 (,)
                    (D.at [ "data", "id" ] D.string)
                    (D.at [ "links", "related" ] D.string)
                )
            )
            |> D.map (\related -> { authors = related })
        )
        |> D.map
            (\( id, attrs, rels ) ->
                ( id, { data = attrs, relationships = rels, lastUpdated = time } )
            )


andThen =
    flip Task.andThen


get : Store -> ID -> Task x ( StoreUpdate, ArticleData )
get store id =
    Time.now
        |> andThen
            (\time ->
                case Dict.get id store.articles of
                    Just { data, lastUpdated } ->
                        ( RetrievedArticle time id, Data id data lastUpdated )
                            |> Task.succeed

                    _ ->
                        Debug.crash "TODO"
             {--
                Nothing ->
                    Http.get (decoder (D.succeed time)) (Data.baseUrl ++ "articles/" ++ id) `Task.andThen` (\


            let
                decoder =
                    decode (D.succeed time) (Data.baseUrl ++ "articles/" ++ id)
            in
                Task.succeed ( Batch [], { lastUpdated = time, id = id, data = { body = "", title = "" } } )
        )
        --}
            )
