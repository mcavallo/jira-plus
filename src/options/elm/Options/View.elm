module Options.View exposing (view)

import Html exposing (Html, text, div, section, header, h1, button, span, i, p, input, label)
import Html.Attributes exposing (class, disabled, placeholder, type_, value, id)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array, toList)
import Options.Types exposing (..)
import Options.Model exposing (Model)


errorClass : FieldStatus -> Html.Attribute Msg
errorClass status =
    let
        invalid =
            not (List.any (\a -> a == status) [ Unchanged, Valid ])
    in
        (if invalid then
            " has-error"
         else
            ""
        )
            |> String.append "form-group"
            |> class


errorDisplay : FieldStatus -> Html Msg
errorDisplay status =
    case status of
        Empty ->
            span [ class "error-display" ]
                [ text "Cannot be empty" ]

        Invalid ->
            span [ class "error-display" ]
                [ text "Invalid format" ]

        _ ->
            text ""


teamsListView : Model -> Html Msg
teamsListView model =
    let
        saveStatus =
            model.formStatus /= FormValid
    in
        if (Array.length model.teams) == 0 then
            div [ class "empty" ]
                [ p [ class "empty-title h5" ]
                    [ text "You have no teams configured" ]
                , p [ class "empty-subtitle" ]
                    [ text "Click the button to start adding your teams" ]
                , div [ class "empty-action" ]
                    [ button [ class "btn btn-primary", onClick AddTeam ]
                        [ text "Add Team" ]
                    ]
                ]
        else
            section []
                [ div [ class "teams-container" ]
                    (toList (Array.indexedMap teamRowView model.teams))
                , div [ class "buttons" ]
                    [ button [ class "btn btn-primary btn-lg", disabled saveStatus, onClick Save ]
                        [ text "Save Changes" ]
                    , button [ class "btn btn-lg", disabled saveStatus ]
                        [ text "Cancel" ]
                    ]
                ]


teamRowView : Int -> Team -> Html Msg
teamRowView index team =
    let
        formMsg index msg =
            ChangeTeam index << msg
    in
        div [ class "team" ]
            [ div [ class "team-field-name" ]
                [ div [ errorClass team.nameStatus ]
                    [ label []
                        [ span []
                            [ text "Name" ]
                        , errorDisplay team.nameStatus
                        , input
                            [ class "form-input"
                            , type_ "text"
                            , placeholder "As it appears in Jira. No funky characters."
                            , value team.name
                            , onInput <| formMsg index ChangeName
                            ]
                            []
                        ]
                    ]
                ]
            , div [ class "team-field-color" ]
                [ div [ errorClass team.colorStatus ]
                    [ label []
                        [ span []
                            [ text "Color" ]
                        , errorDisplay team.colorStatus
                        , input
                            [ class "form-input"
                            , type_ "text"
                            , placeholder "CSS color"
                            , value team.color
                            , onInput <| formMsg index ChangeColor
                            ]
                            []
                        ]
                    ]
                ]
            , div [ class "team-field-remove" ]
                [ button [ class "btn btn-action", onClick (RemoveTeam index) ]
                    [ i [ class "icon icon-cross" ] [] ]
                ]
            ]


messagesView : Model -> Html Msg
messagesView model =
    let
        message =
            case model.saveStatus of
                SaveUnchanged ->
                    text "..."

                SaveSent ->
                    text "Saving..."

                SaveSuccess ->
                    text "Saved"

                SaveFailed ->
                    text "Changes not saved :("
    in
        div [ class "save-message" ]
            [ message ]


headerView : Model -> Html Msg
headerView model =
    header []
        [ h1 [ id "logo" ]
            [ text "Jira+ Options" ]
        , messagesView model
        , h1 []
            [ text "Teams "
            , button [ class "btn btn-action btn-primary btn-sm", onClick AddTeam ]
                [ i [ class "icon icon-plus" ] [] ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "outer-wrap" ]
        [ headerView model
        , teamsListView model

        -- , Utils.PrintAny.view model
        ]
