SHELL := /bin/bash

awesome_lib_path := /usr/local/share/awesome/lib/?.lua;/usr/local/share/awesome/lib/?/init.lua
awesome_local_path := $(shell echo "${HOME}/.config/awesome") 
lua_path := "$(shell lua -e 'print(package.path)');$(awesome_lib_path);$(awesome_local_path)"
$(info $(lua_path))

run:
	Xephyr :1 -name xephyr_awesome -screen "1366x768" >/dev/null 2>&1 &
	sleep 1
	DISPLAY=:1.0 awesome -c rc.lua &

stop:
	kill `pgrep Xephyr` >/dev/null 2>&1

test:
	LUA_PATH=${lua_path} ./fennel-0.8.1 --correlate --metadata test/init.fnl

.PHONY: run stop test
