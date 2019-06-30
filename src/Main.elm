module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Events exposing (onKeyDown)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode
import Random exposing (..)
import Time exposing (..)
import Url exposing (..)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { s : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { s = "asdf" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Change String
    | None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change s ->
            if s == "ArrowUp" then
                ( { model | s = s }, Cmd.none )

            else if s == "ArrowDown" then
                ( { model | s = s }, Cmd.none )

            else
                update (ChangeKey "") model

        -- ( model, Cmd.none )
        None ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "firstWindow nes-container is-rounded is-dark" ] (List.map (checkItem "first") (topList ++ [ model.s ]))
        , div [ class "hidden secondWindow nes-container is-rounded is-dark" ] (List.map (checkItem "second") topList)
        ]


topList : List String
topList =
    [ "つよさ", "とくぎ", "どうぐ", "いどう" ]


checkItem : String -> String -> Html Msg
checkItem inputName inputLabel =
    let
        attrs =
            if inputLabel == "つよさ" then
                [ attribute "checked" "", class "nes-radio is-dark", name inputName, type_ "radio" ]

            else
                [ class "nes-radio is-dark", name inputName, type_ "radio" ]
    in
    p []
        [ label []
            [ input attrs
                []
            , span []
                [ text inputLabel ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown (Decode.map Change (Decode.field "key" Decode.string))
        ]

moveChecked : List (String, String) -> String -> List (String, String)
moveChecked list key =
    case list of
        x :: xs ->
            if Tuple.second x == "checked" then
                [(Tuple.first x, "")] ++ [次のやつtail head] ++ [tail]
                case result of
                    Just hoge -> model
                    _ -> list
            else
                moveChecked hoge hoge
