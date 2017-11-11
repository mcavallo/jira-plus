port module Options.Ports exposing (..)

import Array exposing (Array)
import Json.Encode as Encode exposing (Value, encode, string, object, array)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, requiredAt, hardcoded)
import Options.Types exposing (..)
import Options.Model exposing (Model)
import Debug


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ saveToStorageResult (decodeSaveResult >> SaveResult)
        , loadFromStorage (decodeLoad >> Load)
        ]


port saveToStorage : Value -> Cmd msg


port saveToStorageResult : (Value -> msg) -> Sub msg


port loadFromStorage : (Value -> msg) -> Sub msg


decodeLoad : Value -> Array Team
decodeLoad val =
    let
        result =
            decodeValue teamsArrayDecoder val
    in
        case result of
            Ok teams ->
                teams

            Err e ->
                Debug.log (toString e) Array.empty


decodeSaveResult : Value -> SaveStatus
decodeSaveResult val =
    let
        result =
            decodeValue Decode.string val
    in
        case result of
            Ok "OK" ->
                SaveSuccess

            _ ->
                SaveFailed


encodeTeamsArray : Array Team -> Value
encodeTeamsArray teams =
    array
        (Array.map
            encodeTeam
            teams
        )


encodeTeam : Team -> Value
encodeTeam team =
    object
        [ ( "name", string team.name )
        , ( "color", string team.color )
        ]


teamsArrayDecoder : Decoder (Array Team)
teamsArrayDecoder =
    Decode.array decodeTeam


decodeTeam : Decoder Team
decodeTeam =
    decode Team
        |> required "name" Decode.string
        |> hardcoded Unchanged
        |> required "color" Decode.string
        |> hardcoded Unchanged



-- decodeTeam : Value -> Team
-- decodeTeam v =
--     let
--         decoder =
--             Decode.map2 (,)
--                 (Decode.field "name" Decode.string)
--                 (Decode.field "color" Decode.string)
--     in
--         case Decode.decodeValue decoder v of
--             Ok ( name, color ) ->
--                 Team name Unchanged color Unchanged
--
--             _ ->
--                 Team "" Unchanged "" Unchanged
