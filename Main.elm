module Main exposing (..)

import Constants exposing (..)
import Html exposing (Html, div, program, text)
import Html.Attributes exposing (style)
import Keyboard
import Model exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArrowPressed key ->
            ( keyDown key model, Cmd.none )

        TickUpdate dt ->
            ( gameLoop model, Cmd.none )


gameLoop : Model -> Model
gameLoop model =
    model
        |> doesBallHitWall
        |> updateBall


updateBall : Model -> Model
updateBall model =
    let
        positionX =
            model.ballPosition.x + model.ballVelocity.x

        positionY =
            model.ballPosition.y + model.ballVelocity.y
    in
    { model | ballPosition = { x = positionX, y = positionY } }


doesBallHitWall : Model -> Model
doesBallHitWall model =
    let
        currentVelocity =
            model.ballVelocity

        newVelocityX =
            { currentVelocity | x = currentVelocity.x * -1 }

        newVelocityY =
            { currentVelocity | y = currentVelocity.y * -1 }
    in
    if model.ballPosition.x < 0 then
        { model | ballVelocity = newVelocityX }
    else if model.ballPosition.x > gameAttributes.width then
        { model | ballVelocity = newVelocityX }
    else if model.ballPosition.y < 0 then
        { model | ballVelocity = newVelocityY }
    else if model.ballPosition.y > gameAttributes.height then
        { model | ballVelocity = newVelocityY }
    else
        model


keyDown : ArrowKey -> Model -> Model
keyDown key model =
    case key of
        LeftKey ->
            { model | paddleX = model.paddleX - 5 }

        RightKey ->
            { model | paddleX = model.paddleX + 5 }

        SpaceKey ->
            let
                currentVelocity =
                    model.ballVelocity

                newVelocityX =
                    { currentVelocity | x = currentVelocity.x * -1 }

                newVelocityY =
                    { currentVelocity | y = currentVelocity.y * -1 }
            in
            if model.ballPosition.x < 50 then
                { model | ballVelocity = newVelocityX }
            else if model.ballPosition.x > 50 then
                { model | ballVelocity = newVelocityX }
            else if model.ballPosition.y < 50 then
                { model | ballVelocity = newVelocityY }
            else if model.ballPosition.y > 50 then
                { model | ballVelocity = newVelocityY }
            else
                model

        _ ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    let
        --        paddlePosition =
        --            toString model.paddleX
        --        ballPositionX =
        --          toString model.ballPosition.x
        --    ballPositionY =
        --      toString model.ballPosition.y
        nodes =
            pad model.paddleX
                :: ball model.ballPosition.x model.ballPosition.y
                :: List.map brick model.bricks
    in
    svg [ width (toString gameAttributes.width), height (toString gameAttributes.height), Html.Attributes.style [ ( "background-color", "#efefef" ) ] ]
        nodes


pad : Int -> Svg Msg
pad x =
    block (toFloat x) paddleAttributes.yPosition paddleAttributes.width paddleAttributes.height


ball : Int -> Int -> Svg Msg
ball x y =
    block (toFloat x) (toFloat y) ballAttributes.width ballAttributes.height


brick : Brick -> Svg Msg
brick b =
    block b.position.x b.position.y b.size.width b.size.height


block : Float -> Float -> Int -> Int -> Svg Msg
block x_ y_ width_ height_ =
    rect
        [ x (toString x_)
        , y (toString y_)
        , width (toString width_)
        , height (toString height_)
        ]
        []



--[ rect [ width (toString ballAttributes.width), height (toString ballAttributes.height), x ballPositionX, y ballPositionY ] []
--, rect [ width (toString paddleAttributes.width), height (toString paddleAttributes.height), x paddlePosition, y (toString paddleAttributes.yPosition) ] []
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ arrowChanged, tick ]


tick : Sub Msg
tick =
    Time.every (100 * Time.millisecond) TickUpdate


arrowChanged : Sub Msg
arrowChanged =
    Keyboard.downs toArrowChanged


toArrowChanged : Keyboard.KeyCode -> Msg
toArrowChanged code =
    case code of
        37 ->
            ArrowPressed LeftKey

        39 ->
            ArrowPressed RightKey

        32 ->
            ArrowPressed SpaceKey

        default ->
            ArrowPressed NoKey
