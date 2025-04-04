
local function Fetch(URL, Source)
    return not Source and loadstring(game:HttpGet("https://raw.githubusercontent.com/1x1ry/Fentanyl/refs/heads/main/modules/" .. url, true))() or loadstring(game:HttpGet("url"))()
end 

local Environment = getgenv() or _G 
local Version, Added, Changed, Removed = Fetch("changelogs.lua", false)
local Library = Fetch("library.lua", false)

local Loader; Loader = Library:Loader({
    Title = "Fentanyl - " .. Version or "1.1",
    Description = "Loading..."
    Percentage = 0,
    Date = os.date(),
    Added = Added or {},
    Changed = Changed or {},
    Removed = Removed or {},
    Callback = function()
        Fetch("source.lua", true)
        Loader:Close()
    end 
})
