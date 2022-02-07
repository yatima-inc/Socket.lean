
import Std
import Parsec
open Std
open Parsec

namespace Http
namespace URI
def Hostname := String
deriving instance ToString for Hostname
def Scheme := String
def Scheme.mk (s: String) := s
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

namespace URI

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

namespace Parser

def schemeParser : Parsec Scheme := do
  skipString "http"
  Scheme.mk "http"

def hostName : Parsec Hostname := do
  let name := many1Chars (asciiLetter <|> digit)
  let start := name ++ pstring "."
  many1Strings start ++ name

def parseDigit! (c : Char) : Nat :=
  match c with
  | '0' => 0
  | '1' => 1
  | '2' => 2
  | '3' => 3
  | '4' => 4
  | '5' => 5
  | '6' => 6
  | '7' => 7
  | '8' => 8
  | '9' => 9
  | _ => panic! "Not a digit"

def parseUInt16 : Parsec UInt16 := do
  let as ← many1 digit
  let mut n := 0
  for (i, c) in as.toList.reverse.enum do
    let d := parseDigit! c
    n := n + d * 10 ^ i
  return n.toUInt16

def maybePort : Parsec (Option UInt16) := do
  option $ parseUInt16

def pathParser : Parsec Path := do
  let psegment := digit <|> asciiLetter
  let comp := pstring "/" ++ manyChars psegment
  manyStrings comp

def queryParser : Parsec Query := do
  skipChar '?'
  let psegment := digit <|> asciiLetter
  let rec entries ← λ map : HashMap String String => do
    let k ← many1Chars psegment
    skipChar '='
    let v ← many1Chars psegment
    let map := HashMap.insert map k v
    if ← test $ skipChar '&' then
      entries map
    else
      map
  entries mkHashMap

def fragmentParser : Parsec Fragment := do
  skipChar '#'
  let psegment := digit <|> asciiLetter
  let rec entries ← λ map : HashMap String String => do
    let k ← many1Chars psegment
    skipChar '='
    let v ← many1Chars psegment
    let map := HashMap.insert map k v
    if ← test $ skipChar '&' then
      entries map
    else
      map
  entries mkHashMap

def parser : Parsec URI := do
  let scheme ← schemeParser
  skipString "://"
  let host ← hostName
  let optPort ← maybePort
  let path ← pathParser
  let query ← queryParser
  let fragment ← fragmentParser

def parse (s : String) : Except String URI :=
  match parser s.mkIterator with
  | Parsec.ParseResult.success _ res => Except.ok res
  | Parsec.ParseResult.error it err  => Except.error s!"offset {it.i.repr}: {err}"

#eval (try parse "http://yatima.io/test?1=1#a")

end Parser
end URI

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
