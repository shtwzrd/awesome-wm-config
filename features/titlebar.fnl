(local wibox (require :wibox))
(local awful (require :awful))
(local lawful (require :api.lawful))
(local {: map} (require :lume))
(import-macros {: /< : with-current-tag } :awesome-macros)

(var titlebars? false)
(var enabled? false)

(fn add-titlebar [c]
  "Decorate client C with a titlebar."
  (let [buttons (lawful.util.join
                 (awful.button [] 1 (fn []
                                      (: c :emit_signal :request::activate :titlebar {:raise true})
                                      (awful.mouse.client.move c)))
                 (awful.button [] 3 (fn []
                                      (: c :emit_signal :request::activate :titlebar {:raise true})
                                      (awful.mouse.client.resize c))))
        titlebar (awful.titlebar c)]
    (: titlebar :setup (/<
                        (/< ;; Left
                         (awful.titlebar.widget.iconwidget c)
                         :buttons buttons
                         :layout wibox.layout.fixed.horizontal)
                        (/< ;; Middle
                         ;; (/< ;; Title
                         ;; :align "center"
                         ;; :widget (awful.titlebar.widget.titlewidget c))
                         :buttons buttons
                         :layout wibox.layout.flex.horizontal)
                        (/< ;; Right
                         (awful.titlebar.widget.floatingbutton  c)
                         (awful.titlebar.widget.maximizedbutton c)
                         (awful.titlebar.widget.stickybutton    c)
                         (awful.titlebar.widget.ontopbutton     c)
                         (awful.titlebar.widget.closebutton     c)
                         :layout (wibox.layout.fixed.horizontal))
                        :layout wibox.layout.align.horizontal))
    (when (not titlebars?)
      (awful.titlebar.hide c))))

(fn enable []
  "Enable titlebars for all windows in current tag."
  (set titlebars? true)
  (with-current-tag t
                    (map (t:clients) (fn [c] 
                                       (awful.titlebar.show c)))))

(fn disable []
  "Disable titlebars for all windows in current tag."
  (set titlebars? false)
  (with-current-tag t
                    (map (t:clients) (fn [c] 
                                       (awful.titlebar.hide c)))))

(fn toggle []
  "Toggle titlebars for all windows in current tag."
  (if titlebars?
      (disable)
      (enable)))

(client.connect_signal :request::titlebars add-titlebar)

{:toggle toggle
 :disable disable
 :enable enable}
