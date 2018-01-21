port module Options.Ports exposing (..)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Keyboard
import Options.Model exposing (..)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ loadFromStorage decodeTeamList
        , clearStorageResult decodeResult
        ]



{- TODO: Handle properly:
   > saveToStorageResult
   > Keyboard.ups decodeKeyCode
-}


port loadFromStorage : (Json.Decode.Value -> msg) -> Sub msg


port saveToStorage : List Team -> Cmd msg


port saveToStorageResult : (Json.Decode.Value -> msg) -> Sub msg


port clearStorage : String -> Cmd msg


port clearStorageResult : (Json.Decode.Value -> msg) -> Sub msg


encodeTeams : List Team -> String
encodeTeams teams =
    Json.Encode.encode 0 (teamListEncoder teams)


decodeResult : Json.Decode.Value -> Msg
decodeResult value =
    case Json.Decode.decodeValue Json.Decode.bool value of
        Ok result ->
            HandleClearStorageOk result

        Err err ->
            HandleDecodeErrorLog (Just err)


decodeTeamList : Json.Decode.Value -> Msg
decodeTeamList json =
    case Json.Decode.decodeValue teamListDecoder json of
        Ok result ->
            HandleTeamDecodeOk result

        Err err ->
            HandleDecodeErrorLog (Just err)


decodeImportTeamList : String -> Result.Result String (List Team)
decodeImportTeamList json =
    Json.Decode.decodeString teamListDecoder json


teamListDecoder : Decoder (List Team)
teamListDecoder =
    Json.Decode.list teamDecoder


teamDecoder : Decoder Team
teamDecoder =
    decode Team
        |> required "id" Json.Decode.int
        |> required "name" Json.Decode.string
        |> required "color" Json.Decode.string


teamListEncoder : List Team -> Json.Encode.Value
teamListEncoder teams =
    Json.Encode.list (List.map teamEncoder teams)


teamEncoder : Team -> Json.Encode.Value
teamEncoder team =
    Json.Encode.object
        [ ( "id", Json.Encode.int team.id )
        , ( "name", Json.Encode.string team.name )
        , ( "color", Json.Encode.string team.color )
        ]
