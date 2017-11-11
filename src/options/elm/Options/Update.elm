port module Options.Update exposing (update)

import Array exposing (Array)
import Task
import Options.Model exposing (Model)
import Options.Ports exposing (saveToStorage, encodeTeamsArray)
import Options.Types exposing (..)
import Utils.Array as Array exposing (removeAtIndex)


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity


validateTeam : Team -> Team
validateTeam team =
    let
        nameStatus =
            if team.name == "" then
                Empty
            else
                Valid

        colorStatus =
            if team.color == "" then
                Empty
            else
                Valid
    in
        { team
            | nameStatus = nameStatus
            , colorStatus = colorStatus
        }


teamIsValid : Team -> Bool
teamIsValid team =
    team.nameStatus
        == Valid
        && team.colorStatus
        == Valid


formIsValid : Array Team -> Bool
formIsValid teams =
    teams
        |> Array.filter teamIsValid
        |> Array.length
        |> (==) (Array.length teams)


validateForm : Model -> Model
validateForm model =
    let
        updated =
            if (Array.length model.teams) == 0 then
                FormUnchanged
            else if (formIsValid model.teams) then
                FormValid
            else
                FormInvalid
    in
        { model | formStatus = updated }


updateTeam : TeamFieldChange -> Team -> Team
updateTeam fieldChange team =
    case fieldChange of
        ChangeName v ->
            validateTeam { team | name = v }

        ChangeColor v ->
            validateTeam { team | color = v }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTeam ->
            let
                updated =
                    (Array.push (Team "" Unchanged "" Unchanged) model.teams)
            in
                validateForm { model | teams = updated } ! []

        RemoveTeam i ->
            let
                updated =
                    (Array.removeAtIndex i model.teams)
            in
                validateForm { model | teams = updated } ! [ send Save ]

        ChangeTeam i subMsg ->
            case (Array.get i model.teams) of
                Nothing ->
                    model ! []

                Just team ->
                    let
                        updated =
                            (Array.set i (updateTeam subMsg team) model.teams)
                    in
                        validateForm { model | teams = updated } ! []

        Save ->
            model ! [ saveToStorage (encodeTeamsArray model.teams) ]

        Load teams ->
            { model | teams = teams } ! []

        SaveResult status ->
            { model
                | formStatus = FormUnchanged
                , saveStatus = status
            }
                ! []
