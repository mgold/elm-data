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
        |> Http.send
            (\result ->
                case result of
                    Err err ->
                        -- TODO report failures
                        NoOp

                    Ok result ->
                        -- TODO check for book type
                        List.map (\( new_id, book ) -> UpdateBook new_id (RemoteData.Success book)) result |> Batch
            )


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
        |> Http.send
            (\result ->
                case result of
                    Err err ->
                        ( NoOp, Err err )

                    Ok ( id, book ) ->
                        ( UpdateBook id (RemoteData.Success book), Ok id )
            )


delete : ID -> Cmd ( StoreUpdate, Result Http.Error () )
delete id =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url id
        , body = Http.stringBody "" ""
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send
            (\result ->
                case result of
                    Err err ->
                        ( NoOp, Err err )

                    Ok _ ->
                        ( NoOp, Ok () )
            )
