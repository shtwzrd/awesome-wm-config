(local gears (require "gears"))
(local theme-name "dracula")
(local theme-assets (require "beautiful.theme_assets"))
(local xresources (require "beautiful.xresources"))
(local xrdb (xresources.get_current_theme))
(local dpi xresources.apply_dpi)
(local gfs (require "gears.filesystem"))
(local themes-path (gfs.get_themes_dir))
(local lume (require "vendor.lume"))
(local tip (.. (os.getenv "HOME") "/.config/awesome/themes/" theme-name "/titlebar/"))
(local icon-loader (require "icons.loader"))

 ; based on hlissner's doom-dracula emacs theme
(local core-colors
       {
        :black          "#191A21"
        :bg             "#282a36" 
        :bg-alt         "#1E2029" 
        :base0          "#1E2029" 
        :base1          "#282a36" 
        :base2          "#373844" 
        :base3          "#44475a" 
        :base4          "#565761" 
        :base5          "#6272a4" 
        :base6          "#b6b6b2" 
        :base7          "#ccccc7" 
        :base8          "#f8f8f2" 
        :fg             "#f8f8f2" 
        :fg-alt         "#e2e2dc" 
                       
        :grey           "#565761"
        :red            "#ff5555" 
        :orange         "#ffb86c" 
        :green          "#50fa7b" 
        :yellow         "#f1fa8c" 
        :blue           "#0189cc" 
        :magenta        "#ff79c6" 
        :violet         "#bd93f9" 
        :cyan           "#9aedfe" 
        :teal           "#8be9fd" 
                        
        :bright-red     "#ff6e67"
        :bright-blue    "#61bfff" 
        :bright-green   "#5af78e"
        :bright-yellow  "#f4f99d"
        :bright-violet  "#caa9fa"
        :bright-magenta "#ff92d0"
        })

(local xcolors
       {
        :xbackground (or xrdb.background core-colors.base0)
        :xforeground (or xrdb.foreground core-colors.fg-alt)
        :xcolor0 (or xrdb.color0 core-colors.base3)
        :xcolor1 (or xrdb.color1 core-colors.red)
        :xcolor2 (or xrdb.color2 core-colors.green)
        :xcolor3 (or xrdb.color3 core-colors.yellow)
        :xcolor4 (or xrdb.color4 core-colors.violet)
        :xcolor5 (or xrdb.color5 core-colors.magenta)
        :xcolor6 (or xrdb.color6 core-colors.teal)
        :xcolor7 (or xrdb.color7 core-colors.base7)
        :xcolor8 (or xrdb.color8 core-colors.grey)
        :xcolor9 (or xrdb.color9 core-colors.bright-red)
        :xcolor10 (or xrdb.color10 core-colors.bright-green)
        :xcolor11 (or xrdb.color11 core-colors.bright-yellow)
        :xcolor12 (or xrdb.color12 core-colors.bright-violet)
        :xcolor13 (or xrdb.color13 core-colors.bright-magenta)
        :xcolor14 (or xrdb.color14 core-colors.cyan)
        :xcolor15 (or xrdb.color15 core-colors.fg)
        })

(local extended-colors
       {
        :bg_dark core-colors.bg-alt
        :bg_normal core-colors.bg
        :bg_focus core-colors.base1
        :bg_urgent core-colors.base5
        :bg_minimize core-colors.base0
        :bg_systray core-colors.base0

        :fg_normal core-colors.fg
        :fg_focus core-colors.magenta
        :fg_urgent core-colors.yellow
        :fg_minimize core-colors.base5

        :border_color core-colors.bg
        :border_normal core-colors.bg
        :border_focus core-colors.base5

        :notification_fg xcolors.xcolor15
        :notification_bg core-colors.base0

        :hotkeys_fg xcolors.xcolor15
        :hotkeys_bg core-colors.base0
        :hotkeys_modifiers_fg core-colors.violet
        :hotkeys_label_fg xcolors.xcolor8
        :hotkeys_label_bg xcolors.xcolor2

        :snap_bg xcolors.xcolor8
        })

(local taglist
       {
        :taglist_fg_focus core-colors.fg
        :taglist_bg_focus core-colors.base2
        :taglist_fg_urgent core-colors.yellow
        :taglist_bg_urgent core-colors.bg
        :taglist_fg_occupied core-colors.fg
        :taglist_bg_occupied core-colors.bg
        :taglist_fg_empty core-colors.fg
        :taglist_bg_empty core-colors.bg
        :taglist_fg_volatile core-colors.fg
        :taglist_bg_volatile core-colors.bg
        :taglist_fg_hover core-colors.fg-alt
        :taglist_bg_hover core-colors.base3
        :taglist_shape gears.shape.circle
        :taglist_shape_border_width (dpi 4)
        :taglist_shape_border_color core-colors.black
        })

(local titlebar
       {
        :titlebar_fg_focus core-colors.fg-alt
        :titlebar_bg_focus core-colors.bg
        :titlebar_fg_normal core-colors.fg
        :titlebar_bg_normal core-colors.bg
        })

(local wibar
       {
        :wibar_position :top
        :wibar_ontop false
        :wibar_height (dpi 32)
        :wibar_fg core-colors.fg
        :wibar_bg "#ffffff00"; core-colors.black
        :wibar_border_color core-colors.base5
        :wibar_border_width (dpi 0)
        :wibar_border_radius (dpi 0)

        :tasklist_disable_icon true
        :tasklist_plain_task_name true
        :tasklist_bg_focus core-colors.base3
        :tasklist_fg_focus core-colors.violet
        :tasklist_bg_normal core-colors.base3
        :tasklist_fg_normal xcolors.xcolor15
        :tasklist_bg_minimize core-colors.base3
        :tasklist_fg_minimize extended-colors.fg_minimize
        :tasklist_bg_urgent core-colors.base3
        :tasklist_fg_urgent xcolors.xcolor3
        :tasklist_spacing (dpi 5)
        :tasklist_align :center
        })

(local menu
       {
        :menu_bg_normal core-colors.base3
        :menu_fg_normal xcolors.xcolor7
        :menu_bg_focus xcolors.xcolor8
        :menu_fg_focus xcolors.xcolor7
        :menu_border_color core-colors.base3
        })

(local spacing {
                :border_width (dpi 2)
                :screen_margin (dpi 3) 
                :useless_gap (dpi 3)
                :menu_height (dpi 32) 
                :menu_width (dpi 180)
                :menu_border_width (dpi 0)
                :hotkeys_group_margin (dpi 20)
                })

(local fonts {
              :font "monospace 12"
              :taglist_font "monospace bold 10"
              :hotkeys_font "monospace bold 12"
              :hotkeys_description_font "monospace 10"
              })

(local icons {
              :icon_theme "/usr/share/icons/Adwaita/"
              :awesome_icon (theme-assets.awesome_icon
                             spacing.menu_height
                             extended-colors.bg_focus
                             extended-colors.fg_focus)
              })

(local
 titlebar-buttons
 {
  :titlebar_close_button_normal
  (.. tip "close_normal.svg")
  :titlebar_close_button_focus
  (.. tip "close_focus.svg")
  :titlebar_minimize_button_normal
  (.. tip "minimize_normal.svg")
  :titlebar_minimize_button_focus
  (.. tip "minimize_focus.svg")
  :titlebar_ontop_button_normal_inactive
  (.. tip "ontop_normal_inactive.svg")
  :titlebar_ontop_button_focus_inactive
  (.. tip "ontop_focus_inactive.svg")
  :titlebar_ontop_button_normal_active
  (.. tip "ontop_normal_active.svg")
  :titlebar_ontop_button_focus_active
  (.. tip "ontop_focus_active.svg")
  :titlebar_sticky_button_normal_inactive
  (.. tip "sticky_normal_inactive.svg")
  :titlebar_sticky_button_focus_inactive
  (.. tip "sticky_focus_inactive.svg")
  :titlebar_sticky_button_normal_active
  (.. tip "sticky_normal_active.svg")
  :titlebar_sticky_button_focus_active
  (.. tip "sticky_focus_active.svg")
  :titlebar_floating_button_normal_inactive
  (.. tip "floating_normal_inactive.svg")
  :titlebar_floating_button_focus_inactive
  (.. tip "floating_focus_inactive.svg")
  :titlebar_floating_button_normal_active
  (.. tip "floating_normal_active.svg")
  :titlebar_floating_button_focus_active
  (.. tip "floating_focus_active.svg")
  :titlebar_maximized_button_normal_inactive
  (.. tip "maximized_normal_inactive.svg")
  :titlebar_maximized_button_focus_inactive
  (.. tip "maximized_focus_inactive.svg")
  :titlebar_maximized_button_normal_active
  (.. tip "maximized_normal_active.svg")
  :titlebar_maximized_button_focus_active
  (.. tip "maximized_focus_active.svg")

  :titlebar_close_button_normal_hover
  (.. tip "close_normal_hover.svg")
  :titlebar_close_button_focus_hover
  (.. tip "close_focus_hover.svg")
  :titlebar_minimize_button_normal_hover
  (.. tip "minimize_normal_hover.svg")
  :titlebar_minimize_button_focus_hover
  (.. tip "minimize_focus_hover.svg")
  :titlebar_ontop_button_normal_inactive_hover
  (.. tip "ontop_normal_inactive_hover.svg")
  :titlebar_ontop_button_focus_inactive_hover
  (.. tip "ontop_focus_inactive_hover.svg")
  :titlebar_ontop_button_normal_active_hover
  (.. tip "ontop_normal_active_hover.svg")
  :titlebar_ontop_button_focus_active_hover
  (.. tip "ontop_focus_active_hover.svg")
  :titlebar_sticky_button_normal_inactive_hover
  (.. tip "sticky_normal_inactive_hover.svg")
  :titlebar_sticky_button_focus_inactive_hover
  (.. tip "sticky_focus_inactive_hover.svg")
  :titlebar_sticky_button_normal_active_hover
  (.. tip "sticky_normal_active_hover.svg")
  :titlebar_sticky_button_focus_active_hover
  (.. tip "sticky_focus_active_hover.svg")
  :titlebar_floating_button_normal_inactive_hover
  (.. tip "floating_normal_inactive_hover.svg")
  :titlebar_floating_button_focus_inactive_hover
  (.. tip "floating_focus_inactive_hover.svg")
  :titlebar_floating_button_normal_active_hover
  (.. tip "floating_normal_active_hover.svg")
  :titlebar_floating_button_focus_active_hover
  (.. tip "floating_focus_active_hover.svg")
  :titlebar_maximized_button_normal_inactive_hover
  (.. tip "maximized_normal_inactive_hover.svg")
  :titlebar_maximized_button_focus_inactive_hover
  (.. tip "maximized_focus_inactive_hover.svg")
  :titlebar_maximized_button_normal_active_hover
  (.. tip "maximized_normal_active_hover.svg")
  :titlebar_maximized_button_focus_active_hover
  (.. tip "maximized_focus_active_hover.svg")
  })

(local theme
       (lume.merge
        core-colors
        xcolors
        extended-colors
        titlebar
        taglist
        wibar
        menu
        spacing
        titlebar-buttons
        icons
        fonts
        ))

theme
