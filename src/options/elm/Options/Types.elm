module Options.Types exposing (..)

import Array exposing (Array)


type alias Team =
    { name : String
    , nameStatus : FieldStatus
    , color : String
    , colorStatus : FieldStatus
    }


type FormStatus
    = FormUnchanged
    | FormValid
    | FormInvalid


type SaveStatus
    = SaveUnchanged
    | SaveSent
    | SaveSuccess
    | SaveFailed


type FieldStatus
    = Unchanged
    | Valid
    | Empty
    | Invalid


type TeamFieldChange
    = ChangeName String
    | ChangeColor String


type Msg
    = AddTeam
    | RemoveTeam Int
    | ChangeTeam Int TeamFieldChange
    | Save
    | Load (Array Team)
    | SaveResult SaveStatus



-- | SaveResult (Result String SaveStatus)
