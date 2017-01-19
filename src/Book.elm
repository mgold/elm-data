module Book exposing (..)

import Dict
import RemoteData exposing (RemoteData)
import Data exposing (..)
import Http
import Task exposing (Task)
import Json.Decode as Decode


collectionUrl : URL
collectionUrl =
    serverUrl ++ "/books"


url : ID -> URL
url id =
    serverUrl ++ "/books/" ++ id


load : ID -> Store -> Cmd StoreUpdate
load id (S { books }) =
    case Dict.get id books |> Maybe.withDefault RemoteData.NotAsked of
        RemoteData.NotAsked ->
            Cmd.batch
                [ UpdateBook id RemoteData.Loading |> Task.succeed |> Task.perform identity
                , Http.get (url id) (decodeBook |> expectID id |> expectType "book")
                    |> Http.toTask
                    |> Task.map
                        (\( new_id, book ) -> UpdateBook id (RemoteData.Success book))
                    |> Task.onError
                        (\err -> Task.succeed <| UpdateBook id (RemoteData.Failure (HttpError err)))
                    |> Task.perform identity
                ]

        _ ->
            Task.succeed NoOp |> Task.perform identity


loadMany : Cmd StoreUpdate
loadMany =
    Http.get collectionUrl (decodeBook |> expectMany)
        -- TODO check for book type
        |>
            Http.toTask
        |> Task.map
            (\result ->
                List.map (\( new_id, book ) -> UpdateBook new_id (RemoteData.Success book)) result |> Batch
            )
        |> Task.onError
            (\err -> Debug.crash (toString err) "")
        -- TODO: report this somehow
        |>
            Task.perform identity


get : ID -> Store -> RemoteData Error Book
get id (S { books }) =
    Dict.get id books |> Maybe.withDefault RemoteData.NotAsked


post : Book -> Cmd ( StoreUpdate, Result Http.Error ID )
post book =
    -- TODO use "Content-Type: application/vnd.api+json"
    encodeBook Nothing book
        |> inData
        |> Http.jsonBody
        |> flip (Http.post collectionUrl) (decodeBook |> expectType "book" |> Decode.field "data")
        |> Http.toTask
        |> Task.map (\( id, book ) -> ( UpdateBook id (RemoteData.Success book), Ok id ))
        |> Task.onError (\err -> Task.succeed ( NoOp, Err err ))
        |> Task.perform identity
