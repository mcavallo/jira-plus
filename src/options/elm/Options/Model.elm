module Options.Model exposing (..)

import Array exposing (Array)
import Options.Types exposing (..)


type alias Model =
    { teams : Array Team
    , formStatus : FormStatus
    , saveStatus : SaveStatus
    }


initialModel : Model
initialModel =
    { teams = Array.empty
    , formStatus = FormUnchanged
    , saveStatus = SaveUnchanged
    }
