-- force load vendored fennel file instead of any system fennel
originalPath = package.path
cfgDir = os.getenv("HOME") .. "/.config/awesome/"
package.path = cfgDir .. "?.lua"
fennel = require("fennel")
-- and revert to original package.path
package.path = originalPath

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
