
module Lobby where

import Graphics.Element
import Graphics.Element (Element, flow, down)
import Graphics.Input
import Http
import Http (Request, Response(..))
import Json.Decode
import Json.Decode (Decoder, (:=))
import List
import Result
import Result (Result(..))
import Signal
import Signal (Channel, Signal, (<~),(~))
import Signal.Extra
import Text

port login : Signal ()

port logout : Signal ()

loginChan : Channel ()
loginChan = Signal.channel ()

port onLogin : Signal ()
port onLogin = Signal.subscribe loginChan

logoutChan : Channel ()
logoutChan = Signal.channel ()

port onLogout : Signal ()
port onLogout = Signal.subscribe logoutChan

hostChan : Channel ()
hostChan = Signal.channel ()

port onHost : Signal ()
port onHost = Signal.subscribe hostChan

decodeResponse : Decoder a -> Response String -> Result String a
decodeResponse dec res = case res of
  Success s -> Json.Decode.decodeString dec s
  Waiting -> Err "Waiting"
  Failure i err -> Err err

type alias Session = { email: Maybe String }

decodeSession : Decoder Session
decodeSession = Json.Decode.object1 (\e -> { email = e }) <| "email" := Json.Decode.maybe Json.Decode.string

session : Signal (Result String Session)
session = Signal.map (decodeResponse decodeSession)
        << Http.send 
        << Signal.sampleOn (Signal.merge login logout)
        << Signal.constant 
        <| Http.get "/session"

sessionButtons : Signal Element
sessionButtons =
  let view rSession = case rSession of
    Err err -> Text.asText err
    Ok {email} -> case email of 
      Nothing -> Graphics.Input.button (Signal.send loginChan ()) "Login"
      Just email -> flow down
        [ Text.asText <| "Hello, " ++ email
        , Graphics.Input.button (Signal.send logoutChan ()) "Logout"
        ]
  in view <~ session

lobbyRequest : Result String Session -> Request String
lobbyRequest rSession = case rSession of
  Err err -> Http.get ""
  Ok {email} -> case email of
    Nothing -> Http.get ""
    Just _ -> Http.get "/lobby"

type alias Lobby = { rooms: List { host: String } }

decodeLobby : Decoder Lobby
decodeLobby = Json.Decode.object1 (\rs -> {rooms = rs}) << Json.Decode.list << Json.Decode.object1 (\h -> {host = h}) <| "host" := Json.Decode.string

lobby : Signal (Result String Lobby)
lobby = Signal.map (decodeResponse decodeLobby) 
      << Http.send 
      << Signal.map lobbyRequest 
      <| session

lobbyTable : Signal Element
lobbyTable  = 
  let view rLobby = case rLobby of
    Err err -> Text.asText err
    Ok {rooms} -> flow down <| 
      Text.asText ("Rooms: " ++ toString (List.length rooms)) 
      :: Graphics.Input.button (Signal.send hostChan ()) "Host"
      :: List.map (Text.asText << .host) rooms
  in view <~ lobby

main : Signal Element
main = Signal.Extra.mapMany (flow down) [sessionButtons, lobbyTable]

