(local awful (require "awful"))
(local beautiful (require "beautiful"))
(local lume (require "vendor.lume"))
(local identicon (require "utils.identicon"))

(local tags {})

(lambda tags.list-visible [?scr]
  "Return all active (visible) tags in-order"
  (let [s (or ?scr (awful.screen.focused))]
    (-> s.tags
        (lume.reject (fn [t] t.hide))
        (lume.sort (fn [a b] (< a.name b.name))))))

(lambda tags.create [?scr ?layout ?props]
  "Create a new tag on ?SCR or focused screen with ?LAYOUT. 
Passthrough ?PROPS will merge, overwriting the defaults"
  (let [s (or ?scr (awful.screen.focused))
        id (.. (os.time) "-" (os.clock))] ; sequential name for filter/sort
    (awful.tag.add
     id 
     (lume.merge
      {:screen s
       :layout (or ?layout awful.layout.suit.tile)
       :icon (identicon.create id 5 128)
       :selected true
       :gap beautiful.useless_gap}
      (or ?props {})))))

(lambda tags.destroy [tag]
  "Delete TAG"
  (let [name tag.name]
    (: tag :delete)
    (awesome.emit_signal "tag::deleted" name)))

(lambda tags.get-next [?scr]
  "Return the tag after current tag, creating a new tag if there is no next"
  (let [s (or ?scr (awful.screen.focused))
        visible (tags.list-visible s)
        ct (or
            (. (awful.screen.focused) :selected_tag)
            (lume.last visible))
        ct-index (lume.find visible ct)
        nt (. visible (+ (or ct-index (# visible)) 1))]
    (or nt (tags.create s ct.layout))))

(lambda tags.view-next [?scr]
  "Unmap current tag and map next tag, creating a new tag if none exists"
  (let [s (or ?scr (awful.screen.focused))
        visible (tags.list-visible s)
        ct (or
            (. (awful.screen.focused) :selected_tag)
            (lume.last visible))
        nt (tags.get-next s)]
    (tset nt :selected true)
    (when ct
      (tset ct :selected false))))

(lambda tags.get-prev [?scr]
  "Return the tag before current tag, or first visible tag"
  (let [s (or ?scr (awful.screen.focused))
        visible (tags.list-visible s)
        ct (or
            (. (awful.screen.focused) :selected_tag)
            (lume.last visible))
        ct-index (lume.find visible ct)
        pt-index (- (or ct-index (# visible)) 1)]
    (or (. visible pt-index) (. visible 1))))

(lambda tags.view-prev [?scr]
  "Unmap current tag and map previous tag"
  (let [s (or ?scr (awful.screen.focused))
        visible (tags.list-visible s)
        ct (or
            (. (awful.screen.focused) :selected_tag)
            (lume.last visible))
        pt (tags.get-prev s)]
    (when pt 
      (do
        (tset ct :selected false)
        (tset pt :selected true)
        (when (= (# (: ct :clients)) 0)
          (when (~= ct pt)
            (tags.destroy ct)))))))

(lambda tags.activate [tag]
  "Idempotently activate a tag"
  (tset tag :hide false))

(lambda tags.deactivate [tag]
  "Idempotently deactivate a tag"
  (tset tag :hide true)
  (tset tag :selected false))

(fn tags.get-or-create
  [scr tag-prop]
  (let [{:pos pos :workspace workspace} tag-prop
        tag-by-props (lume.filter scr.tags (fn [t]
                                             (and
                                              (= t.pos pos)
                                              (= t.workspace workspace))))]
    (if (= (# tag-by-props) 0)
        (awful.tag.add pos {:layout (. awful.layout.layouts 1)
                            :screen scr
                            :pos pos
                            :workspace workspace })
        (. tag-by-props 1))))

(fn tags.get-by-prop
  [key value ?invert]
  (lume.filter (root.tags) (fn [t] (if ?invert
                                       (~= (. t key) value))
                             (= (. t key) value))))

tags
