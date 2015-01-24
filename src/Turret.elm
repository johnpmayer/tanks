
module Turret where

import Color (..)
import Graphics.Collage (..)
import Tank (..)
import Reticule (..)

type TurretPos = TuP Float

turretState :  TankPos ->  ReticulePos ->  TurretPos
turretState (TaP (tx,ty) a) (ReP (rxi,ryi)) =
  let rx = toFloat rxi
      ry = toFloat ryi
      ratio = (ry-ty) / (rx-tx)
  in TuP <| atan2 (ry-ty) (rx-tx)

turret : Form
turret =
  let c = 20
      wh = 2 * c + 1
      len = 12
      side = 8
      gauge = 2
      pill = filled grey <| rect len side
      barrel = moveX len <| filled grey <| rect (2 * len) gauge
  in group [ pill, barrel ]

drawTurret : TankPos -> TurretPos -> Form
drawTurret (TaP coord _) (TuP theta) = 
  move coord <| rotate (theta) <| turret