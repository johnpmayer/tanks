
module Bullet where

import Color (..)
import Graphics.Collage (..)
import List
import List (..)
import Signal (..)
import Tank (..)
import Time (..)
import Turret (..)

{- Section 1: Input -}

type BulletPos = BuP (Float,Float) Float

getFiring : TankPos -> TurretPos -> BulletPos
getFiring (TaP (x,y) a) (TuP theta) = BuP (x,y) theta

type BulletInput = Fire BulletPos
                 | Tick Float

bulletInput : Signal () -> Signal TankPos -> Signal TurretPos
            -> Signal Float 
            -> Signal BulletInput
bulletInput click ta tu tick = 
  let fireInput = sampleOn click (getFiring <~ ta ~ tu)
  in merge (Fire <~ fireInput) 
           (Tick <~ tick)

{- Section 2: Model -}

bulletSpeed = 10

moveBullet : Float -> BulletPos -> BulletPos
moveBullet delta (BuP (x,y) theta) = 
  let newX = x + (bulletSpeed * (cos theta))
      newY = y + (bulletSpeed * (sin theta))
  in BuP (newX, newY) theta

stepBullets : BulletInput -> List BulletPos -> List BulletPos
stepBullets bi bps = 
  case bi of
    (Fire bp)    -> bp :: bps
    (Tick delta) -> List.map (moveBullet delta) bps

defaultBullets : List BulletPos
defaultBullets = []

bulletsState : Signal () -> Signal TankPos -> Signal TurretPos
             -> Signal Time
             -> Signal (List BulletPos)
bulletsState click tank turret tick =
  foldp stepBullets defaultBullets (bulletInput click tank turret tick)

{- Section 3: View -}

drawBullet : BulletPos -> Form
drawBullet (BuP (x,y) a) =
  move (x,y) <| filled green (circle 3)