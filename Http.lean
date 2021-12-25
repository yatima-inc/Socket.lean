
import Std
import Parsec
open Parsec

namespace Http
namespace URL
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
end URL

open URL
structure URL where
  userinfo : Option Userinfo
  host: Hostname
  port: Option UInt16
  scheme: Scheme
  path: Path
  query: Option Query
  fragment: Option Fragment

namespace URL

def toString (uri : URL) : String :=
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

def parseDigit (c : Char) : Nat :=
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

def parseUInt16 : Parsec UInt16 := do
  let as ← many1 digit
  let mut n := 0
  for (i, c) in enum (as.toList.reverse) do
    let d := parseDigit c
    n := n + d * 10 ^ i
  return n.toUInt16

def maybePort : Parsec (Option UInt16) := do
  option $ map (many1 digit) parseUInt16

def parser : Parsec URL := do
  let scheme ← schemeParser
  skipString "://"
  let host ← hostName
  let optPort ← maybePort
  let path ← pathParser
  let query ← queryParser
  let fragment ← fragmentParser

def parse (s : String) : Except String URL :=
  match parser s.mkIterator with
  | Parsec.ParseResult.success _ res => Except.ok res
  | Parsec.ParseResult.error it err  => Except.error s!"offset {it.i.repr}: {err}"

end Parser
end URL

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
  url : URL
  method : Method
  payload : Option String

end Http
