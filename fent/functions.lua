local Services, Utility = {}, {
    Directory = "Fentanyl",
    Repository = "Fentanyl",
    
    Connections = {},
    Instances = {},
    Drawings = {},
    
    ClosestPlayer,

    FrameTimer = tick(),
    FrameCounter = 0,
    FPS = 60,

    RaycastParameters = RaycastParams.new(),
}; setmetatable(Services, {
    __index = function(self, key)
        return cloneref and cloneref(game:GetService(key)) or game:GetService(key)
    end
})

local ReplicatedStorage, UserInputService, RunService, TweenService, HttpService, MarketplaceService, Lighting, CoreGui, Stats, Players = Services.ReplicatedStorage, Services.UserInputService, Services.RunService, Services.TweenService, Services.HttpService, Services.MarketplaceService, Services.Lighting, Services.CoreGui, Services.Stats, Services.Players
local LocalPlayer, Camera = Players.LocalPlayer, workspace.CurrentCamera 
local Mouse = UserInputService:GetMouseLocation()

do 

    do --## Main ## 
        function Utility:newInstance(Config : table) 
            local Instance = Instance.new(Config.Instance or Config.Type or "Frame")
            local Index = Config.Index or #self.Instances
            local Properties = Config.Properties or Config.Config or {}

            for _, v in next, Properties do
                Instance[_] = v
            end 

            self.Instances[Index] = Instance

            return Instance
        end

        function Utility:newDrawing(Type, Properties)
            local Drawing = Drawing.new(Type)

            for index, value in ipairs(Properties) do 
                Drawing[index] = value
            end; table.insert(self.Drawings, Drawing)

            return Drawing 
        end

        function Utility:newSignal(Config : table)
            local Signal = Config.Signal or Services.RunService.RenderStepped 
            local Index = Config.Index or #self.Connections
            local Function = Config.Function or Config.Func or Config.Callback or function() end 

            local Connection = Signal:Connect(Function)

            self.Connections[Index] = Connection

            return Connection
        end
    end

    do --## Core ##
        Utility.RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character}
        Utility.RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
        function Utility:isVisible(Start, Endpoint, Expectation)

            local Direction = (Endpoint - Start).Unit
            local Distance = (Endpoint - Start).Magnitude
            local Result = workspace:Raycast(Start, Direction * Distance, Utility.RaycastParameters)

            if Result == nil then 
                return true
            end 

            return (typeof(Expectation) == "string" and (Result.Instance.Name == Expectation)) or Result.Instance == Expectation
        end 

        function Utility:setRaycastParams(Table)
            for _, v in ipairs(Table) do 
                Utility.RaycastParameters[_] = v
            end
        end 


        function Utility:isAlive(Player : Player)
            if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                if Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then 
                    return true
                end
            end
            
            return false
        end
        
        function Utility:isFriendly(Player : Player)
            return (Player.Team == LocalPlayer.Team)
        end

        function Utility:hasForcefield(Player : Player)
            return false
        end 

        function Utility:getClosestPlayer(Function)
            local extraCheck = Function or function() return true end
            local closestPlayer = nil
            local shortestDistance = math.huge

            for _, Player in ipairs(Players:GetPlayers()) do
                if Player == LocalPlayer then continue end 
                if self:isAlive(Player) then
                    local Position = Player.Character.HumanoidRootPart.Position
                    local pos, OnScreen = Camera:WorldToViewportPoint(Position)
                    local mouseLocation = Mouse -- Dynamically fetch mouse position
                    local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).magnitude
                    if extraCheck(Player, magnitude) and magnitude < shortestDistance and OnScreen then
                        closestPlayer = Player
                        shortestDistance = magnitude
                    end
                end
            end

            return closestPlayer
        end

        function Utility:getClosestPart(Player: Instance, List: Table)
            local shortestDistance = math.huge
            local closestPart
            local position 
            if Utility:isAlive(Player) then
                for _, Value in pairs(Player.Character:GetChildren()) do
                    if Value:IsA("BasePart") then 
                        local pos = Camera:WorldToViewportPoint(Value.Position)
                        local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude

                            if magnitude < shortestDistance and table.find(List, Value.Name) then
                                closestPart = Value
                                shortestDistance = magnitude
                                position = pos
                            end
                        end
                    end 
                return closestPart, position
            end
        end 

        function Utility:getBodyParts(Character, RootPart, Indexes, Hitboxes)
            local Parts = {}
            local Hitboxes = Hitboxes or {"Head", "Torso", "Arms", "Legs"}

            for Index, Part in ipairs(Character:GetChildren()) do
                if Part:IsA("BasePart") and Part ~= RootPart then
                    if table.find(Hitboxes, "Head") and Part.Name:lower():find("head") then
                        table.insert(Parts, Part.Name)
                    elseif table.find(Hitboxes, "Torso") and Part.Name:lower():find("torso") then
                        table.insert(Parts, Part.Name)
                    elseif table.find(Hitboxes, "Arms") and Part.Name:lower():find("arm") then
                        table.insert(Parts, Part.Name)
                    elseif table.find(Hitboxes, "Legs") and Part.Name:lower():find("leg") then
                        table.insert(Parts, Part.Name)
                    elseif (table.find(Hitboxes, "Arms") and Part.Name:lower():find("hand")) or (table.find(Hitboxes, "Legs") and Part.Name:lower():find("foot")) then
                        table.insert(Parts, Part.Name)
                    end
                end
            end

            return Parts
        end


        function Utility:getPlayerHealth(Player)
            if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                return Player.Character:FindFirstChildOfClass("Humanoid").Health
            end
            return 0
        end

        function Utility:getDistance(Player1, Player2)
            if Player1.Character and Player2.Character then
                local pos1 = Player1.Character:FindFirstChild("HumanoidRootPart").Position
                local pos2 = Player2.Character:FindFirstChild("HumanoidRootPart").Position
                return (pos1 - pos2).Magnitude
            end

            return math.huge
        end

        function Utility:bindKeyEvent(Config : table)
        end
    end 

    do --## Miscallaenous ## 
        function Utility:worldToViewportPoint(Object)
            return workspace.CurrentCamera:WorldToViewportPoint(Object)
        end

        function Utility:worldToScreenPoint(Object)
            return workspace.CurrentCamera:WorldToScreenPoint(Object)
        end

        function Utility:getMouseLocation()
            return localPlayer:GetMouseLocation()
        end 

        function Utility:getPlayers()
            return Players:GetPlayers()
        end
    end

    function Utility:Unload()
        for i, v in ipairs(self.Connections) do 
            v:Disconnect()
        end 

        for i, v in ipairs(self.Drawings) do 
            v:Remove()
        end 

        for i, v in ipairs(self.Instances) do 
            v:Destroy()
        end 

    end 
end
return Services, Utility
