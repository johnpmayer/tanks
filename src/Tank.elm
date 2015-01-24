
module Tank where

import Color (..)
import Graphics.Collage (..)
import List (..)
import Signal (..)
import Time (..)

{- Section 1: Input -}

type Drive = Forward | Reverse | Stop
type Turn = Left | Right | Straight

type TankInput = TaI Drive Turn

defaultTankInput : TankInput
defaultTankInput = TaI Stop Straight

updateTurn : Int -> Turn -> Turn
updateTurn key turn =
  let leftKey = 65
      rightKey = 68
  in case turn of
    Left     -> if key == leftKey  then Straight else Left
    Right    -> if key == rightKey then Straight else Right
    Straight -> if key == leftKey  then Left else
                if key == rightKey then Right else Straight

updateDrive : Int -> Drive -> Drive
updateDrive key drive =
  let fwdKey = 87
      revKey = 83
  in case drive of
    Forward -> if key == fwdKey then Stop else Forward
    Reverse -> if key == revKey then Stop else Reverse
    Stop    -> if key == fwdKey then Forward else
               if key == revKey then Reverse else Stop

updateTankInput : Int -> TankInput -> TankInput
updateTankInput key (TaI drive turn) = 
  TaI (updateDrive key drive) (updateTurn key turn)

tankInput : Signal (List Int) -> Signal TankInput
tankInput ks = (foldl updateTankInput defaultTankInput) <~ ks

type SampledTankInput = STaI Float TankInput

sampledTankInput : Signal Time -> 
                   Signal (List Int) ->
                   Signal SampledTankInput
sampledTankInput tick ks = 
  sampleOn tick (STaI <~ tick ~ (tankInput ks))

{- Section 2: Model -}

type TankPos = TaP (Float, Float) Float

defaultTank = TaP (0,0) 0

turnRate = 0.002
driveRate = 4

stepTank : SampledTankInput -> TankPos -> TankPos
stepTank (STaI delta (TaI drive turn)) (TaP (x,y) theta) =
  let newTheta = case turn of
                   Straight -> theta
                   Left -> theta - (turnRate * delta)
                   Right -> theta + (turnRate * delta)
      newX = case drive of
               Stop -> x
               Forward -> x + (driveRate * (cos newTheta))
               Reverse -> x - (driveRate * (cos newTheta))
      newY = case drive of
               Stop -> y
               Forward -> y - (driveRate * (sin newTheta))
               Reverse -> y + (driveRate * (sin newTheta))
  in TaP (newX, newY) newTheta

tankState : Signal Time ->
            Signal (List Int) ->
            Signal TankPos
tankState tick ks = 
  foldp stepTank defaultTank (sampledTankInput tick ks)

{- View -}

drawTank : TankPos -> Form
drawTank (TaP (x,y) theta) = 
  let angle = 0 - (theta) in
  move (x,y) <| rotate angle <| filled black (rect 30 20)
