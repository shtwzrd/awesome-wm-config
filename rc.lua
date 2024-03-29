-- add guix lua packages to package.path
guixEnv = os.getenv("GUIX_ENVIRONMENT")
if guixEnv then
    package.path = package.path .. ";" .. guixEnv .. "/share/lua/5.1/?.lua" ..
                   ";" .. guixEnv .. "/share/lua/5.1/?/init.lua" ..
                   ";" .. guixEnv .. "/lib/lua/5.1/?.lua" ..
                   ";" .. guixEnv .. "/lib/lua/5.1/?/init.lua"

    package.cpath = package.cpath .. ";" .. guixEnv .. "/lib/lua/5.1/?.so"
end

cfgDir = os.getenv("HOME") .. "/.config/awesome/"

-- add the vendor dir
package.path = package.path .. ";" .. cfgDir .. "/vendor/?.lua"
package.path = package.path .. ";" .. cfgDir .. "/vendor/?/?.lua"

fennel = require("fennel")

fennel.path = fennel.path .. ";" .. cfgDir .. "?.fnl;" .. cfgDir .. "?/init.fnl"

searcher = fennel.makeSearcher({
    correlate = true,
    useMetadata = true,
    -- disable strict checking.
    -- TODO: assemble a full list of globals so we can enable this
    allowedGlobals = false
})

table.insert(package.loaders or package.searchers, searcher)
debug.traceback = fennel.traceback
require("init") -- load ~/.config/awesome/init.fnl
