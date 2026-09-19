local M = {}

-- Cache environment variables once at load time
local HOME = os.getenv("HOME") or ""
local CONFIG_HOME = os.getenv("XDG_CONFIG_HOME") or (HOME .. "/.config")
local BMARKS_FILE = CONFIG_HOME .. "/yazi/plugins/bookmarks.yazi/bmarks"

-- Pre-generate valid slot keys (0-9, a-z) to avoid rebuilding every call
local SLOT_KEYS = {}
do
    for i = 0, 9 do table.insert(SLOT_KEYS, tostring(i)) end
    for i = 97, 122 do table.insert(SLOT_KEYS, string.char(i)) end
end

-- Safe path shortening without regex vulnerability
local function short(p)
    if p:sub(1, #HOME) == HOME then
        return "~" .. p:sub(#HOME + 1)
    end
    return p
end

-- Read bookmarks with minimal I/O
local function read_bmarks()
    local map = {}
    local f = io.open(BMARKS_FILE, "r")
    if not f then return map end

    for line in f:lines() do
        local k, p = line:match("^([%d%a])%s+(.+)$")
        if k then map[k] = p end
    end
    f:close()
    return map
end

-- Write bookmarks safely using ya.mkdir instead of os.execute
local function write_bmarks(slot, path)
    -- Ensure directory exists safely
    ya.mkdir(BMARKS_FILE:match("(.+)/[^/]+$"), { recursive = true })

    local map = read_bmarks()
    map[slot] = path -- nil will remove the key naturally

    local f = io.open(BMARKS_FILE, "w")
    if not f then return end

    -- Write only existing slots in deterministic order
    for _, k in ipairs(SLOT_KEYS) do
        if map[k] then
            f:write(k, " ", map[k], "\n")
        end
    end
    f:close()
end

-- Sync context getter for current working directory
local get_cwd = ya.sync(function()
    return tostring(cx.active.current.cwd)
end)

function M.entry(_, job)
    local mode = job.args[1] or "go"
    local map = read_bmarks()
    local cwd = get_cwd()
    local cands = {}

    -- Build candidate list efficiently
    for _, key in ipairs(SLOT_KEYS) do
        local p = map[key]
        local is_current = (p == cwd)
        local tag = is_current and " ⭐" or ""
        local display_path = p and short(p) or "(Empty)"

        local desc
        if mode == "mark" then
            desc = string.format("Save in %s (%s)", key, display_path)
        elseif mode == "clear" then
            desc = string.format("Clear slot %s -> %s", key, display_path)
        else -- go mode
            desc = string.format("Go %s%s (%s)", key, tag, display_path)
        end

        table.insert(cands, { on = key, desc = desc })
    end

    -- Show selection menu
    local idx = ya.which({ cands = cands, silent = false })
    if not idx then return end

    local slot = cands[idx].on

    if mode == "mark" then
        write_bmarks(slot, cwd)
        ya.notify({ title = "Bookmarks", content = "Saved to slot [" .. slot .. "]", timeout = 1 })
    elseif mode == "clear" then
        write_bmarks(slot, nil)
        ya.notify({
            title = "Bookmarks",
            content = map[slot] and ("Cleared slot [" .. slot .. "]") or ("Slot [" .. slot .. "] was already empty"),
            timeout = 1
        })
    else -- go mode
        local target = map[slot]
        if target then
            ya.emit("cd", { target })
        else
            ya.notify({ title = "Bookmarks", content = "Slot [" .. slot .. "] is empty!", timeout = 1 })
        end
    end
end

return M
