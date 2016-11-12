module Data exposing (..)

{-| Module docs
-}

import Dict exposing (Dict)
import Time exposing (Time)


baseUrl =
    "http://localhost:4567"


type alias ID =
    String


type alias ArticleAttributes =
    { title : String, body : String }


type alias AuthorAttributes =
    { firstName : String, lastName : String }


type alias Data a =
    { id : ID
    , data : a
    , lastUpdated : Time
    }


type alias ArticleData =
    Data ArticleAttributes


type alias AuthorData =
    Data AuthorAttributes


type alias InternalData a rels =
    { data : a
    , relationships : rels
    , lastUpdated : Time
    }


type alias URL =
    String


type alias InternalArticle =
    InternalData ArticleAttributes { authors : List ( ID, URL ) }


type alias InternalAuthor =
    InternalData AuthorAttributes { articles : List ( ID, URL ) }


type alias Store =
    { articles : Dict ID InternalArticle
    , authors : Dict ID InternalAuthor
    , errorLog : List ( Time, String )
    , log : List ( Time, String )
    }


initialStore : Store
initialStore =
    Store Dict.empty Dict.empty [] []


type StoreUpdate
    = Batch (List StoreUpdate)
    | NewArticle ID ArticleData
    | RetrievedArticle Time ID
    | NewAuthor ID AuthorData
    | RetrievedAuthor Time ID


update : StoreUpdate -> Store -> Store
update updt store =
    case updt of
        Batch updates ->
            List.foldl update store updates

        _ ->
            store
