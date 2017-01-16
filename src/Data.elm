module Data exposing (..)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)
import Json.Encode as Json
import Http
import RemoteData exposing (RemoteData)


serverUrl : URL
serverUrl =
    "http://localhost:4567"


type alias ID =
    String


type alias URL =
    String


type Error
    = HttpError Http.Error
    | DecodeError String
    | IdMismatch


type Store
    = S { books : Dict ID (RemoteData Error Book) }


initialStore : Store
initialStore =
    S { books = Dict.empty }


type StoreUpdate
    = UpdateBook ID (RemoteData Error Book)
    | Batch (List StoreUpdate)
    | NoOp


updateStore : StoreUpdate -> Store -> Store
updateStore update ((S innerStore) as store) =
    case update of
        NoOp ->
            store

        Batch updates ->
            List.foldl updateStore store updates

        UpdateBook id remoteData ->
            S { innerStore | books = Dict.insert id remoteData innerStore.books }


type alias Book =
    { title : String, author : String, published : Int }


decodeBook : Decoder ( ID, Book )
decodeBook =
    let
        attributes =
            D.map3 Book
                (D.field "title" D.string)
                (D.field "author" D.string)
                (D.field "published" D.int)
    in
        D.field "data" <| D.map2 (,) (D.field "id" D.string) (D.field "attributes" attributes)


decode : Decoder StoreUpdate
decode =
    D.field "data" (D.field "type" D.string)
        |> D.andThen
            (\tipe ->
                case tipe of
                    "book" ->
                        D.map (\( id, book ) -> UpdateBook id (RemoteData.Success book)) decodeBook

                    _ ->
                        D.fail <| "Unrecognized type: " ++ tipe
            )


encodeBook : ID -> Book -> Json.Value
encodeBook id { title, author, published } =
    Json.object
        [ ( "type", Json.string "book" )
        , ( "id", Json.string id )
        , ( "attributes"
          , Json.object
                [ ( "title", Json.string title )
                , ( "author", Json.string author )
                , ( "published", Json.int published )
                ]
          )
        ]
