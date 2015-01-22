
module Game where

import Graphics.Collage (..)
import Graphics.Element (..)
import Keyboard (..)
import List
import Mouse
import Signal (..)
import Time (..)
import Window

import Tank (TankPos, tankState, drawTank)
import Reticule (ReticulePos, reticuleState, drawReticule)
import Turret (TurretPos, turretState, drawTurret)
import Bullet (BulletPos, bulletsState, drawBullet)

tick : Signal Time
tick = fps 30

type GameState = GS TankPos ReticulePos TurretPos (List BulletPos)

relPosition : (Int, Int) -> (Int, Int) -> (Int, Int)
relPosition (wX, wY) (mX, mY) = (mX - wX // 2, wY // 2 - mY)

gameState : Signal GameState
gameState = let gTankState = tankState tick keysDown
                gReticuleState = reticuleState (relPosition <~ Window.dimensions ~ Mouse.position)
                gTurretState = turretState <~ gTankState ~ gReticuleState
                gBulletsState = bulletsState Mouse.clicks gTankState gTurretState tick
            in GS <~ gTankState 
                   ~ gReticuleState 
                   ~ gTurretState
                   ~ gBulletsState

display : (Int, Int) -> GameState -> Element
display (w, h) (GS ta re tu bs) = 
  collage w h ( drawTank ta
              :: drawReticule re
              :: drawTurret ta tu
              :: List.map drawBullet bs
              )

main : Signal Element
main = display <~ Window.dimensions ~ gameState
