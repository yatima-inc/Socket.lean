import Socket

import Std

namespace Http
namespace URI
def Hostname := String
deriving instance ToString for Hostname
def Scheme := String
deriving instance ToString for Scheme
def Path := String
deriving instance ToString for Path 
def Userinfo := String
deriving instance ToString for Userinfo
def Fragment := String
deriving instance ToString for Fragment

def Query := Std.HashMap String String
instance : ToString Query where
  toString (q : Query) := ""
end URI

open URI
structure URI where
  userinfo : Option Userinfo
  host: Hostname
  port: Option UInt16
  scheme: Scheme
  path: Path
  query: Option Query
  fragment: Option Fragment

def toString (uri : URI) : String :=
  s!"{uri.scheme}://"
  ++ if let some user := uri.userinfo then s!"{user}@"
  else ""
  ++ s!"{uri.host}"
  ++ if let some port := uri.port then s!":{port}"
  else ""
  ++ s!"{uri.path}"
  ++ if let some query := uri.query then s!"?{query}"
  else ""
  ++ if let some fragment := uri.fragment then s!"#{fragment}"
  else ""

inductive Method
  | GET
  | HEAD
  | POST
  | PUT
  | DELETE
  | CONNECT
  | OPTIONS
  | TRACE
  | PATCH

def Method.toString: Method → String
  | GET => "GET"
  | HEAD => "HEAD"
  | POST => "POST"
  | PUT => "PUT"
  | DELETE => "DELETE"
  | CONNECT => "CONNECT"
  | OPTIONS => "OPTIONS"
  | TRACE => "TRACE"
  | PATCH => "PATCH"

instance : ToString Method where
  toString := Method.toString

structure Request where
  url : URI
  method : Method

end Http

def main (args : List String) : IO Unit := do
  let host ← (if h : args.length > 0
    then args.get 0 h
    else "localhost"
  )
  let path ← (if h : args.length > 1
    then args.get 1 h
    else "/"
  )
  /- let url : Http.URI ← { -/
  /-   userinfo := none -/
  /-   host := host -/
  /-   path := path -/
  /-   fragment := none -/
  /-   query := none -/
  /-   scheme := "http" -/
  /-   port := some 80 -/
  /-  } -/
  -- configure remote SockAddr
  let remoteAddr ← SockAddr.mk {
    host := host
    port := "80"
    family := inet
    type := stream
  }
  IO.println s!"Remote Addr: {remoteAddr}"
  
  let socket ← Socket.mk inet stream
  socket.connect remoteAddr
  IO.println "Connected!"

  -- send HTTP request
  let strSend := 
    s!"GET {path} HTTP/1.1\r\n" ++
    s!"Host: {host}\r\n" ++
    "\r\n\r\n"
  let bytesSend ← socket.send strSend.toUTF8
  IO.println s!"Send {bytesSend} bytes!\n"

  -- get HTTP response and print it out
  let bytesRecv ← socket.recv 5000
  IO.println "-- Responses --\n"
  IO.println <| String.fromUTF8Unchecked bytesRecv
