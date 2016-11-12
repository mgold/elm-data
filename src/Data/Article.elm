module Data.Article exposing (..)

{-| Module docs
-}

import Dict
import Data exposing (ArticleData, ArticleAttributes, AuthorData, Data, ID, Store, StoreUpdate(..))
import Json.Decode as D exposing (Decoder)
import Time exposing (Time)
import Task exposing (Task)
import Http


loadMany : Int -> Store -> Task x StoreUpdate
loadMany n store =
    let
        url =
            Data.baseUrl ++ "/articles?page[size]=" ++ toString n
    in
        Time.now
            |> Task.andThen
                (\now ->
                    Http.get url (decodeMany now)
                        |> Http.toTask
                        |> Task.map (List.map (uncurry ArticleLoad) >> Batch)
                        |> Task.onError (ArticleLoadFailure now >> Task.succeed)
                )


getMany : Int -> Store -> List ArticleData
getMany n { articles } =
    articles
        |> Dict.toList
        |> List.take n
        |> List.map (\( id, { data, lastUpdated } ) -> Data id data lastUpdated)


load : ID -> Store -> Task x StoreUpdate
load id store =
    Debug.crash "TODO"


get : ID -> Store -> Maybe ArticleData
get id store =
    Debug.crash "TODO"


loadAuthors : List ID -> Store -> Task x StoreUpdate
loadAuthors ids store =
    Debug.crash "TODO"


getAuthors : List ID -> Store -> List (Result ID AuthorData)
getAuthors ids store =
    Debug.crash "TODO"


decode1 : Time -> Decoder ( ID, Data.InternalArticle )
decode1 time =
    D.map3 (,,)
        (D.field "id" D.string)
        (D.field "attributes"
            (D.map2
                ArticleAttributes
                (D.field "title" D.string)
                (D.field "body" (D.list D.string))
            )
        )
        (D.at [ "relationships", "authors" ]
            (D.list
                (D.map2 (,)
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


decodeMany : Time -> Decoder (List ( ID, Data.InternalArticle ))
decodeMany time =
    D.field "data" (D.list (decode1 time))



{--
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
                Nothing ->
                    Http.get (decoder (D.succeed time)) (Data.baseUrl ++ "articles/" ++ id) `Task.andThen` (\


            let
                decoder =
                    decode (D.succeed time) (Data.baseUrl ++ "articles/" ++ id)
            in
                Task.succeed ( Batch [], { lastUpdated = time, id = id, data = { body = "", title = "" } } )
        )
            )

            --}
