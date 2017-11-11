port module Options.Main exposing (main)

import Html
import Options.Model exposing (Model, initialModel)
import Options.Ports exposing (subscriptions)
import Options.Types exposing (..)
import Options.Update exposing (update)
import Options.View exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    initialModel ! []
