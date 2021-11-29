
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
  payload : Option String

end Http
