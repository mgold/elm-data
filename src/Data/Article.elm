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
    Debug.crash "TODO"


getMany : Int -> Store -> List ArticleData
getMany n store =
    Debug.crash "TODO"


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


decode : Time -> Decoder ( ID, Data.InternalArticle )
decode time =
    D.map3 (,,)
        (D.at [ "data", "id" ] D.string)
        (D.at [ "data", "attributes" ]
            (D.map2
                ArticleAttributes
                (D.field "title" D.string)
                (D.field "body" (D.list D.string))
            )
        )
        (D.at [ "data", "relationships", "authors" ]
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
