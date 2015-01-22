
module Reticule where

import Color (..)
import Graphics.Collage (..)
import Signal (..)

type ReticulePos = ReP (Int, Int)

reticuleState : Signal (Int,Int) -> Signal ReticulePos
reticuleState mp = ReP <~ mp

reticule : Form
reticule =
  let c = 10
      t = 3
      wh = (2*c)+1
      hori = traced (solid red) <| segment (0-c, 0) (c, 0)
      vert = traced (solid red) <| segment (0, 0-c) (0, c)
      circ = outlined (solid red) <| circle (c - t)
  in group [hori, vert, circ]

drawReticule : ReticulePos -> Form
drawReticule (ReP (xi, yi)) = move (toFloat xi, toFloat yi) <| reticule
