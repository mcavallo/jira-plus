module Options.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Options.Model exposing (..)


view : Model -> Html Msg
view model =
    div
        [ class "outer-wrap"
        , classList [ ( "loaded", model.isLoaded ) ]
        ]
        [ headerView model
        , teamsListView model
        , formModalView model
        ]


headerView : Model -> Html Msg
headerView model =
    header [ class "navbar" ]
        [ section [ class "navbar-section" ]
            [ span [ class "navbar-brand" ]
                [ text "Jira+ Options" ]
            ]
        , section [ class "navbar-center" ]
            [ text "  " ]
        , section [ class "navbar-section" ]
            [ a
                [ class "btn btn-primary btn-sm", onClick NewTeam ]
                [ text "Add Team" ]
            , div [ class "dropdown dropdown-right" ]
                [ a
                    [ class "btn btn-link dropdown-toggle", tabindex 0 ]
                    [ i [ class "icon icon-menu" ]
                        []
                    ]
                , ul [ class "menu" ]
                    [ li [ class "divider", attribute "data-content" "DATA" ]
                        []
                    , li [ class "menu-item disabled" ]
                        [ a []
                            [ text "Import" ]
                        ]
                    , li [ class "menu-item disabled" ]
                        [ a []
                            [ text "Export" ]
                        ]
                    , li [ class "menu-item" ]
                        [ a [ onClick ClearStorageData ]
                            [ text "Destroy" ]
                        ]
                    ]
                ]
            ]
        ]


emptyListView : Html Msg
emptyListView =
    div [ class "empty" ]
        [ p [ class "empty-title h5" ]
            [ text "You have no teams configured" ]
        , p [ class "empty-subtitle" ]
            [ text "Click the button below to get started" ]
        , div [ class "empty-action" ]
            [ button
                [ class "btn btn-primary"
                , onClick NewTeam
                ]
                [ text "Add team" ]
            ]
        ]


teamsListView : Model -> Html Msg
teamsListView model =
    if (List.length model.teams) == 0 then
        emptyListView
    else
        model.teams
            |> List.reverse
            |> List.map teamRow
            |> ul [ class "teams" ]


teamRow : Team -> Html Msg
teamRow team =
    let
        styles =
            style [ ( "background", team.color ) ]
    in
        li [ onClick (EditTeam team.id) ]
            [ span [ class "color", styles ]
                []
            , span [ class "name" ]
                [ text team.name
                ]
            ]


formModalHeader : Model -> Html Msg
formModalHeader model =
    let
        title =
            if model.form.isNew then
                "Add Team"
            else
                "Edit Team"
    in
        div [ class "modal-header" ]
            [ a
                [ class "btn btn-clear float-right"
                , onClick FormCancel
                ]
                []
            , div [ class "modal-title h5" ]
                [ text title ]
            ]


formModalView : Model -> Html Msg
formModalView model =
    let
        saveDisabled =
            model.form.isPristine || not model.form.isValid

        cancelDisabled =
            model.form.isPristine
    in
        div
            [ class "modal modal-sm"
            , classList
                [ ( "active", model.form.isVisible )
                ]
            ]
            [ a [ class "modal-overlay", onClick FormCancel ]
                []
            , div [ class "modal-container" ]
                [ formModalHeader model
                , div [ class "modal-body" ]
                    [ div [ class "content" ]
                        [ teamsForm model ]
                    ]
                , div [ class "modal-footer" ]
                    [ teamRemoveButton model
                    , a
                        [ class "btn btn-primary btn-form"
                        , classList [ ( "disabled", saveDisabled ) ]
                        , onClick FormSave
                        ]
                        [ text "Save" ]
                    , a
                        [ class "btn btn-link btn-form"
                        , classList [ ( "disabled", cancelDisabled ) ]
                        , onClick FormCancel
                        ]
                        [ text "Cancel" ]
                    ]
                ]
            ]


teamRemoveButton : Model -> Html Msg
teamRemoveButton model =
    if model.form.isNew then
        text ""
    else
        a
            [ class "btn btn-error"
            , onClick (RemoveTeam model.form.team.id)
            ]
            [ i [ class "icon icon-delete" ]
                []
            ]


teamsForm : Model -> Html Msg
teamsForm model =
    let
        nameError =
            model.form.nameError /= Nothing

        colorError =
            model.form.colorError /= Nothing
    in
        div [ class "form" ]
            [ div
                [ class "form-group"
                , classList [ ( "has-error", nameError ) ]
                ]
                [ label
                    [ class "form-label", for "field-team-name" ]
                    [ text "Team Name" ]
                , textField
                    [ id "field-team-name"
                    , placeholder "As it appears in Jira"
                    , value model.form.team.name
                    , onInput InputName
                    ]
                , formError model.form.nameError
                ]
            , div
                [ class "form-group"
                , classList [ ( "has-error", colorError ) ]
                ]
                [ label
                    [ class "form-label", for "field-team-color" ]
                    [ text "Color" ]
                , textField
                    [ id "field-team-color"
                    , placeholder "Any kind of CSS color"
                    , value model.form.team.color
                    , onInput InputColor
                    ]
                , formError model.form.colorError
                ]
            ]


textField : List (Html.Attribute msg) -> Html.Html msg
textField extraAttrs =
    let
        attrs =
            List.concat
                [ [ type_ "text", class "form-input" ]
                , extraAttrs
                ]
    in
        input attrs []


formError : Maybe String -> Html Msg
formError error =
    case error of
        Just msg ->
            p [ class "form-input-hint" ]
                [ text msg ]

        Nothing ->
            text ""
