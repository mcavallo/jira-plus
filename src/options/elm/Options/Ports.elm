port module Options.Ports exposing (..)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Options.Model exposing (..)
import Keyboard


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


decodeResult : Json.Decode.Value -> Msg
decodeResult value =
    case Json.Decode.decodeValue Json.Decode.bool value of
        Ok result ->
            HandleResultOk result

        Err err ->
            HandleDecodeErrorLog (Just err)


decodeTeamList : Json.Decode.Value -> Msg
decodeTeamList json =
    case Json.Decode.decodeValue teamListDecoder json of
        Ok result ->
            HandleTeamDecodeOk result

        Err err ->
            HandleDecodeErrorLog (Just err)




teamListDecoder : Decoder (List Team)
teamListDecoder =
    Json.Decode.list teamDecoder


teamDecoder : Decoder Team
teamDecoder =
    decode Team
        |> required "id" Json.Decode.int
        |> required "name" Json.Decode.string
        |> required "color" Json.Decode.string
