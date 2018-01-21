module Options.Model exposing (..)


type alias Model =
    { teams : List Team
    , form : TeamForm
    , isLoaded : Bool
    , isImporting : Bool
    , isImportError : Bool
    , importData : String
    , isExporting : Bool
    , exportData : String
    }


type alias Team =
    { id : Int
    , name : String
    , color : String
    }


type alias TeamForm =
    { team : Team
    , isVisible : Bool
    , isValid : Bool
    , isPristine : Bool
    , isNew : Bool
    , nameError : Maybe String
    , colorError : Maybe String
    }


type Msg
    = NoOp
    | InitialLoadComplete
    | NewTeam
    | EditTeam Int
    | RemoveTeam Int
    | FormCancel
    | FormSave
    | InputName String
    | InputColor String
    | InputImportData String
    | ClearStorageData
    | SetStorageData
    | ImportData
    | ImportDataCancel
    | ImportDataSave
    | ImportDataFailed
    | ExportData
    | ExportDataCancel
    | HandleClearStorageOk Bool
    | HandleTeamDecodeOk (List Team)
    | HandleExportOk String
    | HandleDecodeErrorLog (Maybe String)


initialModel : Bool -> Model
initialModel isLoaded =
    { teams =
        []

    -- [ Team 1 "Backend (Dashboard)" "#2e87fb"
    -- , Team 2 "Frontend" "#fdac2a"
    -- ]
    , form = (emptyForm False False)
    , isLoaded = isLoaded
    , isImporting = False
    , isImportError = False
    , importData = ""
    , isExporting = False
    , exportData = ""
    }


formForTeam : Team -> TeamForm
formForTeam team =
    let
        form =
            emptyForm True False
    in
        { form | team = team }


formForNewTeam : Model -> TeamForm
formForNewTeam model =
    let
        form =
            emptyForm True True

        team =
            { emptyTeam | id = (List.length model.teams) + 1 }
    in
        { form | team = team }


emptyForm : Bool -> Bool -> TeamForm
emptyForm visible new =
    { team = emptyTeam
    , isVisible = visible
    , isValid = True
    , isPristine = True
    , isNew = new
    , nameError = Nothing
    , colorError = Nothing
    }


emptyTeam : Team
emptyTeam =
    { id = 0
    , name = ""
    , color = ""
    }


findBy : (b -> a) -> a -> List b -> Maybe b
findBy attr id list =
    list
        |> List.filter (attr >> (==) id)
        |> List.head


findTeam : Int -> Model -> Maybe Team
findTeam id model =
    model.teams
        |> List.filter (\t -> t.id == id)
        |> List.head


setFormPristine : Bool -> TeamForm -> TeamForm
setFormPristine status form =
    { form | isPristine = status }


validateForm : Model -> Model
validateForm model =
    let
        newForm =
            model.form
                |> setFormValid
                |> validateTeamName
                |> validateTeamColor
    in
        { model | form = newForm }


setFormValid : TeamForm -> TeamForm
setFormValid form =
    { form | isValid = True }


isNotEmpty : String -> Bool
isNotEmpty val =
    not (String.isEmpty val)


isNotLongerThan : Int -> String -> Bool
isNotLongerThan len val =
    not ((String.length val) > len)


validate : List (String -> Bool) -> String -> Bool
validate rules val =
    let
        apply rule prev =
            prev && (rule val)
    in
        rules
            |> List.foldl apply True


validateTeamName : TeamForm -> TeamForm
validateTeamName form =
    let
        rules =
            [ isNotEmpty
            , isNotLongerThan 50
            ]
    in
        if (validate rules form.team.name) then
            { form | nameError = Nothing }
        else
            { form | nameError = Just "Can't be empty or too long", isValid = False }


validateTeamColor : TeamForm -> TeamForm
validateTeamColor form =
    let
        rules =
            [ isNotEmpty
            ]
    in
        if (validate rules form.team.color) then
            { form | colorError = Nothing }
        else
            { form | colorError = Just "Must be a valid color", isValid = False }
