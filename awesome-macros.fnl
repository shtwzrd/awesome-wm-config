(fn /< [...]
  "Create a 'mixed' table like in standard Lua.
The table can contain both sequential and non-sequential keys.
Like:
  (/< (awful.titlebar.widget.iconwidget c)
      :buttons buttons
      :layout wibox.layout.fixed.horizontal)

Useful for wibox declarations."
  (let [tbl {}]
    (var skip 0)
    (each [i v (ipairs [...])]
      (when (~= i skip)
        (let [tv (type v)]
          (match tv
                 "string" (do
                            (set skip (+ i 1))
                            (tset tbl v (. [...] skip)))
                 "table"  (table.insert tbl v)
                 _        (error (.. tv " key literal in mixed table"))))))
    tbl))

(fn with-current-screen [name body ...]
  "Do something with the currently selected screen."
  `(let [,name (awful.screen.focused)]
    (when ,name
     ,body
     ,...)))

(fn with-current-tag [name body ...]
  "Do something with the currently 'active' tag (tag where focus is)."
  `(let [,name (. (awful.screen.focused) :selected_tag)]
    (when ,name
     ,body
     ,...)))

{:/< /<
 :with-current-tag with-current-tag
 :with-current-screen with-current-screen}
