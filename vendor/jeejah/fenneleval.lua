local fennel = require("fennel")
local fennelview_ok, fennelview = pcall(require, "fennelview")
if not fennelview_ok then fennelview = fennel.dofile("fennelview.fnl") end

local d = os.getenv("DEBUG") and print or function(_) end

local repls = {}

local print_for = function(write)
   return function(...)
      local args = {...}
      for i,x in ipairs(args) do args[i] = tostring(x) end
      table.insert(args, "\n")
      write(table.concat(args, " "))
   end
end

local make_repl = function(session, repls)
   local on_values = function(xs)
      session.values(xs)
      session.done({status={"done"}})
   end
   local read = function()
      -- If we skip empty input, it confuses the client.
      local input = coroutine.yield()
      if(input:find("^%s*$")) then return "nil\n" else return input end
   end
   local err = function(errtype, msg)
      session.write(table.concat({errtype, msg}, ": ")) session.done()
   end

   local env = session.sandbox
   if not env then
      env = {}
      for k, v in pairs(_G) do env[k] = v end
      env.io = {}
   end
   env.print = print_for(session.write)
   env.io.write = session.write
   env.io.read = function()
      session.needinput()
      local input, done = coroutine.yield()
      done()
      return input
   end

   local f = function()
      return fennel.repl({readChunk = read,
                          onValues = on_values,
                          onError = err,
                          env = env,
                          pp = fennelview})
   end
   repls[session.id] = coroutine.wrap(f)
   repls[session.id]()
   return repls[session.id]
end

return function(conn, msg, session, send, response_for)
   d("Evaluating", msg.code)
   local repl = repls[session.id] or make_repl(session, repls)
   if msg.op == "eval" then
      session.values = function(xs)
         send(conn, response_for(msg, {value=table.concat(xs, "\n") .. "\n"}))
      end
      session.done = function()
         send(conn, response_for(msg, {status={"done"}}))
      end
      session.needinput = function()
         send(conn, response_for(msg, {status={"need-input"}}))
      end
      repl(msg.code .. "\n")
   elseif msg.op == "stdin" then
      repl(msg.stdin,
           function() send(conn, response_for(msg, {status={"done"}})) end)
   end
end
