import Socket


def main (args : List String) : IO Unit := do
  let host ← (if h : args.length > 0
    then args.get 0 h
    else "localhost"
  )
  let path ← (if h : args.length > 1
    then args.get 1 h
    else "/"
  )
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
    "Host: {host}\r\n" ++
    "\r\n\r\n"
  let bytesSend ← socket.send strSend.toUTF8
  IO.println s!"Send {bytesSend} bytes!\n"

  -- get HTTP response and print it out
  let bytesRecv ← socket.recv 5000
  IO.println "-- Responses --\n"
  IO.println <| String.fromUTF8Unchecked bytesRecv
