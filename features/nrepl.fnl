(local lawful (require :api.lawful))
(local gears (require :gears))
(local jeejah (require :vendor.jeejah))

(local nrepl-port-filepath (.. (lawful.fs.config-dir) ".nrepl-port"))

(var _coro nil)

(lambda spawn-nrepl [?port]
  (let [port (or ?port 7888)]
    (set _coro (jeejah.start port {:debug true :fennel true}))
    (with-open [nrepl-port-file (io.open nrepl-port-filepath :w)]
      (nrepl-port-file:write port))
    (lawful.notify.info (.. "nREPL server listening on " port "."))
    (gears.timer {:autostart true
                  :call_now true
                  :timeout 0.100
                  :callback (fn [] (coroutine.resume _coro))})))

(lambda kill-nrepl []
  (jeejah.stop _coro)
  (os.remove nrepl-port-filepath)
  (lawful.notify.info "nREPL server disconnected."))

{:spawn-nrepl spawn-nrepl
 :kill-nrepl kill-nrepl}
