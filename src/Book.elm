module Book exposing (..)

import Dict
import RemoteData exposing (RemoteData)
import Data exposing (..)
import Http
import Task exposing (Task)


url : ID -> URL
url id =
    serverUrl ++ "/books/" ++ id


load : ID -> Store -> Task x StoreUpdate
load id (S { books }) =
    case Dict.get id books |> Maybe.withDefault RemoteData.NotAsked of
        RemoteData.NotAsked ->
            Http.get (url id) decodeBook
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

        _ ->
            Task.succeed NoOp


get : ID -> Store -> RemoteData Error Book
get id (S { books }) =
    Dict.get id books |> Maybe.withDefault RemoteData.NotAsked
