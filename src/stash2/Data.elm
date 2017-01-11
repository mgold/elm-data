module Data exposing (..)

{-| Module docs
-}

import Dict exposing (Dict)
import Time exposing (Time)
import Http


baseUrl =
    "http://localhost:4567"


type alias ID =
    String


type alias URL =
    String


type alias ArticleAttributes =
    { title : String, body : List String }


type alias AuthorAttributes =
    { firstName : String, lastName : String }


type alias Data a =
    { id : ID
    , attributes : a
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


type alias InternalArticle =
    InternalData ArticleAttributes { authors : List ( ID, URL ) }


type alias InternalAuthor =
    InternalData AuthorAttributes { articles : List ( ID, URL ) }


toExternal ( id, { data, lastUpdated } ) =
    Data id data lastUpdated


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
    | ArticleLoad ID InternalArticle
    | ArticleCacheHit Time ID
      -- add more error info later?
    | ArticleLoadFailure Time Http.Error


update : StoreUpdate -> Store -> Store
update updt store =
    case updt of
        Batch updates ->
            List.foldl update store updates

        ArticleLoadFailure time err ->
            let
                _ =
                    Debug.log "Failed to load article(s)" err
            in
                { store | errorLog = ( time, toString err ) :: store.errorLog }

        ArticleLoad id internalArticle ->
            { store | articles = Dict.insert id internalArticle store.articles }

        ArticleCacheHit time id ->
            store
