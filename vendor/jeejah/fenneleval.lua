local fennel = require("fennel")
-- fall back to pre-0.8.0 if necessary
local fennelview = fennel.view or require("fennelview")

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
   local repl = repls[session.id] or make_repl(session, repls)
   if msg.op == "eval" then
      d("Evaluating", msg.code)
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
      d("Evaluating", msg.code)
      repl(msg.stdin,
           function() send(conn, response_for(msg, {status={"done"}})) end)
   elseif msg.op == "completions" then
      d("Completions", msg.prefix)
      session.values = function(xs)
         local result = {}
         for _, v in pairs(xs) do
             table.insert(result, {candidate = v})
         end
         send(conn, response_for(msg, {completions = result}))
      end
      session.done = function()
         send(conn, response_for(msg, {status={"done"}}))
      end
      session.needinput = function()
         send(conn, response_for(msg, {status={"need-input"}}))
      end
      repl(",complete " .. msg.prefix .. "\n")
   elseif msg.op == "lookup" then
      d("Lookup", msg.sym)
      session.values = function(xs)
         if #xs == 0 or
            string.find(xs[1], "#<undocumented>") or
            xs[1] == msg.sym .. " not found" then
              -- nREPL spec has no error-signalling for this, just empty map
              send(conn, response_for(msg, {info = {}}))
         else
            local i = string.find(xs[1], "\n")
            local top_line = string.sub(xs[1], 1, i)
            local j = string.find(top_line, " ") + 1
            local k = string.find(top_line, "%)") - 1
            local info = {name = msg.sym,
                          arglists = "([" .. string.sub(top_line, j, k) .. "])",
                          doc = string.sub(xs[1], i + 1)}
            send(conn, response_for(msg, {info = info}))
         end
      end
      session.done = function()
         send(conn, response_for(msg, {status={"done"}}))
      end
      session.needinput = function()
         send(conn, response_for(msg, {status={"need-input"}}))
      end
      repl(",doc " .. msg.sym .. "\n")
   end
end
