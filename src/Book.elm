module Book exposing (..)

import Dict
import RemoteData exposing (RemoteData)
import Data exposing (..)
import Http
import Task exposing (Task)


url : ID -> URL
url id =
    serverUrl ++ "/books/" ++ id


load : ID -> Store -> Cmd StoreUpdate
load id (S { books }) =
    case Dict.get id books |> Maybe.withDefault RemoteData.NotAsked of
        RemoteData.NotAsked ->
            Cmd.batch
                [ UpdateBook id RemoteData.Loading |> Task.succeed |> Task.perform identity
                , Http.get (url id) decodeBook
                    |> Http.toTask
                    |> Task.map
                        (\( new_id, book ) ->
                            if new_id == id then
                                UpdateBook id (RemoteData.Success book)
                            else
                                UpdateBook id (RemoteData.Failure IdMismatch)
                        )
                    |> Task.onError
                        (\err ->
                            Task.succeed <| UpdateBook id (RemoteData.Failure (HttpError err))
                        )
                    |> Task.perform identity
                ]

        _ ->
            Task.succeed NoOp |> Task.perform identity


get : ID -> Store -> RemoteData Error Book
get id (S { books }) =
    Dict.get id books |> Maybe.withDefault RemoteData.NotAsked
