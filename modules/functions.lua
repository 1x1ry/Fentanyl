local Services, Library = {}, {
    Directory = "Fentanyl",
    Repository = "Fentanyl",
    
    Connections = {},
    Instances = {},
    Drawings = {}, 

    Events = {
        OnDied = {},
        CharacterAdded = {},
        PlayerAdded = {},
        PlayerRemoving = {},
        Unload = {}
    },

    Clients = {
        All = {},
        Alive = {}
    },

    FontCache = {},
    Typeface = {}

}; setmetatable(Services, {
    __index = function(self, key)
        return cloneref and cloneref(game:GetService(key)) or game:GetService(key)
    end
})

local Players = Services.Players 
local RunService = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local CoreGui = Services.CoreGui
local UserInputService = Services.UserInputService

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

function Library:SafeCall(func, ...)
    local Success, Result = pcall(func, ...)
    if not Success then
        return false, Result -- Return false and the error message
    end
    return true, Result -- Return true and the result if no error
end

function Library:Fetch(url, method, headers, body)
    local response = request({
        Url = url,
        Method = method or "GET",
        Headers = headers or {},
        Body = body or nil
    })

    return response.Body and HttpService:JSONDecode(response.Body) or response
end

function Library:Loadstring(Url)
    local Success, Result = Library:SafeCall(function()
        return loadstring(game:HttpGet(Url, true))()
    end)

    if not Success then 
        warn("Failed to load string from URL: " .. Url .. "\nError: " .. Result)
        return
    end

    return Result
end 

function Library:GetExecutorName()
    return identifyexecutor and identifyexecutor() or "Shitsploit"
end 

function Library:Instance(Class : string, Parent : instance, Properties : table)
    local Instance = Instance.new(Class)

    if Parent then 
        Instance.Parent = Parent 
    else
        Instance.Parent = CoreGui 
    end 

    if Properties then 
        for Index, Value in pairs(Properties) do 
            Instance[Index] = Value 
        end
    end 

    table.insert(self.Instances, Instance)

    return Instance
end

function Library:Draw(Class : string, Properties : table)
    local Drawing = Drawing.new(Class)

    if Properties then 
        for Index, Value in pairs(Properties) do 
            Drawing[Index] = Value 
        end
    end 

    table.insert(self.Drawings, Drawing)

    return Drawing
end

function Library:Connect(Index, Connection, Callback)
    local Connection = Connection:Connect(Callback)
    self.Connections[Index or #self.Connections] = Connection
    return Connection 
end

function Library:Disconnect(Index : string)
    if self.Connections[Index] then 
        self.Connections[Index]:Disconnect()
        self.Connections[Index] = nil 
    end 
end

function Library:GetCharacter(Player)
    return Player:FindFirstChild("Character")
end 

function Library:GetRoot(Character)
    return Character:FindFirstChild("HumanoidRootPart")
end 

function Library:GetHumanoid(Character)
    return Character:FindFirstChildOfClass("Humanoid")
end

function Library:GetTeam(Player) 
    return Player.Team
end

function Library:GetStatus(Player)
    if Player.Character then 
        if Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChildOfClass("Humanoid") then
            if Player.Character.Humanoid.Health > 0 then 
                return true 
            end 
        end
    end

    return false
end

function Library:IsFriendly(Player)
    return (self:GetTeam(Player) == self:GetTeam(LocalPlayer))
end

function Library:IsLocalPlayer(Player)
    return Player == LocalPlayer
end

function Library:WorldToViewportPoint(Position)
    return Camera:WorldToViewportPoint(Position)
end

function Library:WorldToScreenPoint(Position)
    return Camera:WorldToScreenPoint(Position)
end

function Library:GetClosestPlayerByMouse(Valid)
    local Table = Library.Clients.Alive
    local ClosestPlayer 
    local ClosestPosition
    local ShortestDistance = math.huge 
    local Check = Valid or function() return true end
    for _, Player in ipairs(Table) do 
        if not Check(Player) then continue end

        local ScreenPosition, OnScreen = self:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
        local Mouse = UserInputService:GetMouseLocation()
        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

        if OnScreen and Magnitude < ShortestDistance then 
            ClosestPlayer = Player 
            ClosestPosition = ScreenPosition
            ShortestDistance = Magnitude
        end
    end 

    return ClosestPlayer, ClosestPosition
end 

function Library:GetClosestPartByMouse(List)
    local ClosestPart 
    local ClosestPosition 
    local ShortestDistance = math.huge 

    for _, Part in ipairs(List) do 
        if Part:IsA("BasePart") then 
            local ScreenPosition, OnScreen = self:WorldToViewportPoint(Part.Position)
            local Mouse = UserInputService:GetMouseLocation()
            local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

            if OnScreen and Magnitude < ShortestDistance then 
                ClosestPart = Part 
                ClosestPosition = ScreenPosition
                ShortestDistance = Magnitude
            end
        end
    end
    return ClosestPart, ClosestPosition
end 

function Library:ListBodyParts(Character, Rootpart, Indexes, Hitboxes)
    local Parts = {}
    local Hitboxes = Hitboxes or {"Head", "Torso", "Arms", "Legs"}

    for _, Part in ipairs(Character:GetChildren()) do 
        if Part:IsA("BasePart") and Part ~= Rootpart then 
            local Name = string.lower(Part.Name)
            local Index = Indexes and Part.Name or #Parts + 1
            if table.find(Hitboxes, "Head") and Name:find("head") then
                Parts[Index] = Part
            elseif table.find(Hitboxes, "Torso") and Name:find("torso") then 
                Parts[Index] = Part
            elseif table.find(Hitboxes, "Arms") and Name:find("arm") then 
                Parts[Index] = Part
            elseif table.find(Hitboxes, "Legs") and Name:find("leg") then 
                Parts[Index] = Part
            end
        end 
    end 

    return Parts
end

function Library:BindEvent(Event, Callback)
    if self.Events[Event] then 
        table.insert(self.Events[Event], Callback)
    end 
end

function Library:RegisterFont(baseDirectory, fontInfo)
    assert(type(baseDirectory) == "string", "Base directory must be a string")
    assert(type(fontInfo) == "table", "Font info must be a table")
    assert(fontInfo.name, "Font must have a name")
    assert(fontInfo.link, "Font must have a download link")
    
    fontInfo.weight = fontInfo.weight or "Regular"
    fontInfo.style = fontInfo.style or "Normal"
    
    if not isfolder(baseDirectory) then
        makefolder(baseDirectory)
    end
    
    local fontsDir = baseDirectory .. "/fonts"
    if not isfolder(fontsDir) then
        makefolder(fontsDir)
    end
    
    local fontName = fontInfo.name:gsub("%s+", "_"):lower()
    local rawFontPath = fontsDir .. "/" .. fontName .. ".ttf"
    local encodedFontPath = fontsDir .. "/" .. fontName .. "_encoded.ttf"
    
    if not ensureFile(rawFontPath, fontInfo.link) then
        return nil
    end
    
    local fontDescriptor = {
        name = fontInfo.name,
        faces = {
            {
                name = fontInfo.weight,
                weight = fontInfo.weight == "Bold" and 700 or 400,
                style = fontInfo.style:lower(),
                assetId = getcustomasset(rawFontPath)
            }
        }
    }
    
    writefile(encodedFontPath, HttpService:JSONEncode(fontDescriptor))
    
    local weightEnum = Enum.FontWeight.Regular
    if fontInfo.weight == "Bold" then
        weightEnum = Enum.FontWeight.Bold
    elseif fontInfo.weight == "Light" then
        weightEnum = Enum.FontWeight.Light
    end
    
    local cacheKey = fontInfo.name .. "-" .. fontInfo.weight .. "-" .. fontInfo.style
    if not FontCache[cacheKey] then
        FontCache[cacheKey] = Font.new(getcustomasset(encodedFontPath), weightEnum)
    end
    
    return FontCache[cacheKey]
end

function Library:GetFont(fontName, weight, style)
    weight = weight or "Regular"
    style = style or "Normal"
    
    local cacheKey = fontName .. "-" .. weight .. "-" .. style
    return FontCache[cacheKey]
end

function Library:Unload()
    for _, Connection in ipairs(self.Connections) do 
        Connection:Disconnect()
    end

    for _, Instance in ipairs(self.Instances) do 
        Instance:Destroy()
    end 

    for _, Drawing in ipairs(self.Drawings) do 
        Drawing:Remove()
    end

    for _, Callback in ipairs(self.Events.Unload) do 
        Callback()
    end

end 

Library:Connect("PlayerAdded", Players.PlayerAdded, function(Player)
    if not Player or not Player:IsA("Player") then return end

    table.insert(Library.Clients.All, Player)

    for _, Callback in ipairs(Library.Events.PlayerAdded) do 
        Callback(Player)
    end

    if Library:GetStatus(Player) then 
        table.insert(Library.Clients.Alive, Player)
    end

    Player.CharacterAdded:Connect(function(Character)
        if not Character or not Character:IsA("Model") then return end

        for _, Callback in ipairs(Library.Events.CharacterAdded) do 
            Callback(Player, Character)
        end

        local Humanoid = Character:WaitForChild("Humanoid", 5)
        if not Humanoid then return end

        Humanoid.Died:Connect(function()
            local aliveIndex = table.find(Library.Clients.Alive, Player)
            if aliveIndex then
                table.remove(Library.Clients.Alive, aliveIndex)
            end

            for _, Callback in ipairs(Library.Events.OnDied) do 
                Callback(Player, Character)
            end
        end)
    end)
end)

Library:Connect("PlayerRemoving", Players.PlayerRemoving, function(Player)
    if not Player or not Player:IsA("Player") then return end

    local index = table.find(Library.Clients.All, Player)
    if index then
        table.remove(Library.Clients.All, index)
    end

    local aliveIndex = table.find(Library.Clients.Alive, Player)
    if aliveIndex then
        table.remove(Library.Clients.Alive, aliveIndex)
    end

    for _, Callback in ipairs(Library.Events.PlayerRemoving) do 
        Callback(Player)
    end
end)

for i, v in ipairs(Players:GetPlayers()) do 
    if v ~= LocalPlayer then 
        table.insert(Library.Clients.All, v)

        if Library:GetStatus(v) then 
            table.insert(Library.Clients.Alive, v)
        end
    end 
end 

return Library
