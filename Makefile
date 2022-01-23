SHELL := /bin/bash

awesome_lib_path := $(shell echo "${GUIX_ENVIRONMENT}/share/awesome/lib/?.lua;${GUIX_ENVIRONMENT}/share/awesome/lib/?/init.lua")
lua_share_path := $(shell echo "${GUIX_ENVIRONMENT}/share/lua/5.1/?.lua;${GUIX_ENVIRONMENT}/share/lua/5.1/init.lua")
lua_lib_path := $(shell echo "${GUIX_ENVIRONMENT}/lib/lua/5.1/?.lua;${GUIX_ENVIRONMENT}/lib/lua/5.1/init.lua")

awesome_local_path := $(shell echo "${HOME}/.config/awesome/?.lua;${HOME}/.config/awesome/?/?.lua")
lua_path := "$(shell lua -e 'print(package.path)');$(awesome_lib_path);$(awesome_local_path);$(lua_share_path);$(lua_lib_path)"

lua_cpath := "$(shell lua -e 'print(package.path)');${GUIX_ENVIRONMENT}/lib/lua/5.1/?.so"

run:
	Xephyr :1 -name xephyr_awesome -screen "1366x768" >/dev/null 2>&1 &
	sleep 1
	DISPLAY=:1.0 awesome -c rc.lua &

stop:
	kill `pgrep Xephyr` >/dev/null 2>&1

test:
	LUA_PATH=${lua_path} LUA_CPATH=${lua_cpath} fennel --globals awesome,client --correlate --metadata --lua luajit test/init.fnl

.PHONY: run stop test
