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


type StoreUpdate
    = UpdateBook ID (RemoteData Error Book)
    | Batch (List StoreUpdate)
    | NoOp


type alias Book =
    { name : String, author : String, published : Int }


decodeBook : Decoder ( ID, Book )
decodeBook =
    let
        attributes =
            D.map3 Book
                (D.field "name" D.string)
                (D.field "author" D.string)
                (D.field "published" D.int)
    in
        D.map2 (,) (D.field "id" D.string) (D.field "attributes" attributes)


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
encodeBook id { name, author, published } =
    Json.object
        [ ( "type", Json.string "book" )
        , ( "id", Json.string id )
        , ( "attributes"
          , Json.object
                [ ( "name", Json.string name )
                , ( "author", Json.string author )
                , ( "published", Json.int published )
                ]
          )
        ]
