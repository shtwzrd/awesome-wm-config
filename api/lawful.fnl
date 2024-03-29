(require "patches.fix-snid")
(local lgi (require :lgi))
(local cairo lgi.cairo)
(local rsvg lgi.Rsvg)
(local awful (require :awful))
(local naughty (require :naughty))
(local gears (require :gears))
(local dump gears.debug.dump_return)
(local join gears.table.join)
(local unpack (or table.unpack _G.unpack))
(import-macros {: async : await} :utils.async)

(var lawful {:ext {}
             :geo awful.placement ;; passthrough
             :util {:join join}
             :fs {}
             :img {}
             :notify {}})

(fn lawful.fs.home-dir []
  (os.getenv "HOME"))

(lambda lawful.fs.config-dir []
  (.. (lawful.fs.home-dir) "/.config/awesome/"))

(lambda lawful.fs.cache-dir []
  (.. (lawful.fs.home-dir) "/.cache/awesome/"))

(lambda lawful.fs.icon-dir []
  (.. (lawful.fs.home-dir) "/.cache/awesome/icons/"))

(lambda lawful.img.load-svg [svg-file-name width height]
  (let [surf (cairo.ImageSurface cairo.Format.ARGB32 width height)
        cr (cairo.Context surf)
        handle (assert (rsvg.Handle.new_from_file svg-file-name))
        dim (handle:get_dimensions)
        aspect (math.min (/ width dim.width) (/ height dim.height))]
    (cr:scale aspect aspect)
    (handle:render_cairo cr)
    surf))

(lambda lawful.notify.msg [?message ?args]
  (let [args (or ?args {})
        message (or ?message nil)
        tv (type message)]
    (if message
        (match tv
          :string (naughty.notify (join args {:text message}))
          :number (naughty.notify (join args {:text (.. "" message)}))
          _ (naughty.notify (join args {:text (dump message)})))
        (naughty.notify (join args {:text "nil"})))))

(lambda lawful.notify.info [?message ?timeout]
  (lawful.notify.msg ?message {:timeout (or ?timeout 10)}))

(fn lawful.notify.error [?message]
  (let [err-preset {:timeout 0 :bg "#000000" :fg "#ff0000" :max_height 1080}]
    (lawful.notify.msg ?message err-preset)))

(lambda lawful.ext.shellout [cmd]
  (async
   (let [[out err reason code] (await awful.spawn.easy_async_with_shell cmd)]
     {:stdout out
      :stderr err
      :reason reason
      :code code})))

(lambda lawful.ext.shellout! [cmd]
  (let [{: stdout : stderr : code} (lawful.ext.shellout cmd)]
    (if (= code 0)
        stdout
        (lawful.notify.error stderr))))

(set lawful.ext.spawnbuf {})

(lambda lawful.ext.spawn [cmd ?props ?cb]
  "Spawn application with CMD and set PROPS on resulting client.
Execute callback ?CB if provided, passing the client as the only argument."
  ;; launch everything through an interactive bash so aliases can resolve
  (let [(pid snid) (awesome.spawn (.. "bash -ic " cmd) true)]
    (when snid
      (tset lawful.ext.spawnbuf snid [(or ?props {}) ?cb]))
    (values pid snid)))

(client.connect_signal
 :manage
 (fn [c]
   (when c.startup_id
     (let [snid c.startup_id
           snid-data (. lawful.ext.spawnbuf snid)]
       (when snid-data
         (let [props (. snid-data 1)
               ?cb (. snid-data 2)]
           (each [k v (pairs props)]
             (tset c k v))
           (when (= (. props :titlebars_enabled) false)
             (awful.titlebar.hide c))
           (when (. props :placement) ; apply placement
             ((. props :placement) c))
           (when ?cb
             (?cb c))
           (tset lawful.ext.spawnbuf snid nil)))))))

lawful
