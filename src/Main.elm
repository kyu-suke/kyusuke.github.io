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
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}
    , Cmd.none
    )



-- UPDATE


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "firstWindow nes-container is-rounded is-dark" ] (List.map (checkItem "first") topList)
        , div [ class "secondWindow nes-container is-rounded is-dark" ] (List.map (checkItem "second") topList)
        ]


topList : List String
topList =
    [ "status", "works", "links", "bio", "skills", "setting" ]


checkItem : String -> String -> Html Msg
checkItem inputName inputLabel =
    let
        attrs =
            if inputLabel == "status" then
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
    Sub.batch []
