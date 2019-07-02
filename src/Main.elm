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
    { s : String
    , menus : List ( String, String )
    , selectedMenu : String
    , showClass : String
    , showWindow : ShowWindow
    }


type alias ShowWindow =
    { fst : String
    , snd : String
    , trd : String
    , fth : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { s = "asdf"
      , menus = [ ( "つよさ", "checked" ), ( "とくぎ", "" ), ( "どうぐ", "" ), ( "いどう", "" ) ]
      , selectedMenu = ""
      , showClass = "hidden"
      , showWindow = showContent
      }
    , Cmd.none
    )


showContent =
    { fst = "hidden"
    , snd = "hidden"
    , trd = "hidden"
    , fth = "hidden"
    }



-- UPDATE


type Msg
    = Change String
    | None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change s ->
            if s == "ArrowUp" then
                ( { model | menus = upChecked model.menus "up" }, Cmd.none )

            else if s == "ArrowDown" then
                ( { model | menus = moveChecked model.menus "down" }, Cmd.none )

            else if s == "Enter" then
                case List.head <| List.filter (\m -> Tuple.second m == "checked") model.menus of
                    Just m ->
                        ( { model | showWindow = showWindow m }, Cmd.none )

                    _ ->
                        ( model, Cmd.none )

            else if s == "Backspace" then
                ( { model | showWindow = showContent }, Cmd.none )

            else
                ( model, Cmd.none )

        -- ( model, Cmd.none )
        None ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "firstWindow nes-container is-rounded is-dark" ] (List.map (checkItem "first") model.menus)
        , div [ class model.showWindow.fst, class "secondWindow nes-container is-rounded is-dark" ] [ text "しかし 何も 見つからなかった" ]
        , div [ class model.showWindow.snd, class "secondWindow nes-container is-rounded is-dark" ] [ text "なんと バグを 見つけた" ]
        , div [ class model.showWindow.trd, class "secondWindow nes-container is-rounded is-dark" ]
            [ p [] [ a [ target "_blank", href "https://qsk.netlify.com/" ] [ text "typing" ] ]
            ]
        , div [ class model.showWindow.fth, class "secondWindow nes-container is-rounded is-dark" ]
            [ p [] [ a [ target "_blank", href "https://twitter.com/8140i2865_3" ] [ text "twitter" ] ]
            , p [] [ a [ target "_blank", href "https://github.com/kyu-suke" ] [ text "github" ] ]
            , p [] [ a [ target "_blank", href "https://homedogheavy.hatenablog.com/" ] [ text "homedogheavy" ] ]
            ]
        ]


checkItem : String -> ( String, String ) -> Html Msg
checkItem inputName inputTuple =
    let
        attrs =
            [ checked (Tuple.second inputTuple == "checked"), class "nes-radio is-dark", name inputName, type_ "radio", value (Tuple.first inputTuple) ]
    in
    p []
        [ label []
            [ input attrs
                []
            , span []
                [ text <| Tuple.first inputTuple ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown (Decode.map Change (Decode.field "key" Decode.string))
        ]


moveChecked : List ( String, String ) -> String -> List ( String, String )
moveChecked list key =
    let
        lastChecked =
            case List.head <| List.reverse list of
                Just l ->
                    Tuple.second l

                _ ->
                    ""
    in
    if key == "end" then
        case list of
            x :: xs ->
                [ ( Tuple.first x, "checked" ) ] ++ xs

            _ ->
                []

    else if lastChecked == "checked" then
        case list of
            x :: xs ->
                [ ( Tuple.first x, "checked" ) ] ++ List.map (\l -> ( Tuple.first l, "" )) xs

            _ ->
                list

    else
        case list of
            x :: xs ->
                if Tuple.second x == "checked" then
                    [ ( Tuple.first x, "" ) ] ++ moveChecked xs "end"

                else
                    [ ( Tuple.first x, "" ) ] ++ moveChecked xs ""

            _ ->
                []


upChecked list key =
    List.reverse <| moveChecked (List.reverse list) key


showWindow : ( String, String ) -> ShowWindow
showWindow t =
    let
        key =
            Tuple.first t
    in
    case key of
        "つよさ" ->
            { showContent | fst = "" }

        "とくぎ" ->
            { showContent | snd = "" }

        "どうぐ" ->
            { showContent | trd = "" }

        "いどう" ->
            { showContent | fth = "" }

        _ ->
            showContent
