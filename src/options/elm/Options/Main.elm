port module Options.Main exposing (main)

import Html
import Dom
import Task
import Options.Ports exposing (..)
import Options.Model exposing (..)
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitialLoadComplete ->
            { model | isLoaded = True } ! []

        NewTeam ->
            { model | form = (formForNewTeam model) }
                ! [ focusById "field-team-name" ]

        EditTeam id ->
            (setTeamToEdit id model)
                ! [ focusById "field-team-name" ]

        RemoveTeam id ->
            handleRemoveTeam model id
                |> update SetStorageData

        FormCancel ->
            { model | form = (emptyForm False False) }
                ! []

        FormSave ->
            handleFormSave model
                |> update SetStorageData

        InputName name ->
            (model
                |> setFormValue (setName name)
                |> setFormDirty
                |> validateForm
            )
                ! []

        InputColor color ->
            (model
                |> setFormValue (setColor color)
                |> setFormDirty
                |> validateForm
            )
                ! []

        ClearStorageData ->
            model ! [ clearStorage "" ]

        SetStorageData ->
            model ! [ saveToStorage model.teams ]

        HandleResultOk result ->
            let
                _ =
                    Debug.log "HandleResultOk" result
            in
                model ! []

        HandleTeamDecodeOk result ->
            { model | teams = result }
                |> update InitialLoadComplete

        HandleDecodeErrorLog err ->
            let
                _ =
                    Debug.log "HandleDecodeErrorLog" err
            in
                model ! []

        NoOp ->
            model ! []


handleRemoveTeam : Model -> Int -> Model
handleRemoveTeam model id =
    case (findBy .id id model.teams) of
        Just team ->
            let
                newTeams =
                    List.filter (\t -> t.id /= id) model.teams
            in
                { model
                    | form = (emptyForm False False)
                    , teams = newTeams
                }

        Nothing ->
            model


handleFormSave : Model -> Model
handleFormSave model =
    let
        newTeam =
            model.form.team

        newModel =
            { model | form = emptyForm False False }
    in
        if model.form.isNew then
            { newModel | teams = (newTeam :: model.teams) }
        else
            { newModel | teams = (updateTeam model.teams newTeam) }


updateTeam : List Team -> Team -> List Team
updateTeam teams newTeam =
    teams
        |> List.map
            (\team ->
                if team.id == newTeam.id then
                    newTeam
                else
                    team
            )


setTeamToEdit : Int -> Model -> Model
setTeamToEdit id model =
    case (findBy .id id model.teams) of
        Just team ->
            { model | form = (formForTeam team) }

        Nothing ->
            model


setFormDirty : Model -> Model
setFormDirty model =
    { model | form = setFormPristine False model.form }


setFormValue : (Team -> Team) -> Model -> Model
setFormValue func model =
    let
        update form =
            { form | team = (func model.form.team) }
    in
        { model | form = (update model.form) }


setName : String -> Team -> Team
setName newName team =
    { team | name = newName }


setColor : String -> Team -> Team
setColor newColor team =
    { team | color = newColor }


focusById : String -> Cmd Msg
focusById id =
    Task.attempt (always NoOp) (Dom.focus id)
