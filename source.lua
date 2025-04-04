local Repository = "https://raw.githubusercontent.com/1x1ry/Fentanyl/refs/heads/main/modules/"
local Library = loadstring(game:HttpGet(Repository .. "library.lua", true))()
local Services, Utility = loadstring(game:HttpGet(Repository .. "functions.lua", true))()
local Crosshair; do 
    local Library = {
        Visible = true, 
        VisColor = {Color3.fromRGB(255, 255, 255), 1},
        Outline = true,
        OutlineColor = {Color3.fromRGB(255, 255, 255), 1},
        SpinSetting = {true, 1},
        Fading = {true, 10},
        Offset = {0, 0},
        Thickness = 2, 
        Gap = 5,
        Length = 20,
        Lines = { Top = Drawing.new("Line"), Bottom = Drawing.new("Line"), Left = Drawing.new("Line"), Right = Drawing.new("Line")},
        Outlines = { Top = Drawing.new("Line"), Bottom = Drawing.new("Line"), Left = Drawing.new("Line"), Right = Drawing.new("Line")},
    }

    function Library.Update()
        local centerX, centerY = workspace.CurrentCamera.ViewportSize.X / 2 + Library.Offset[1], workspace.CurrentCamera.ViewportSize.Y / 2 + Library.Offset[2]
        local gap, length = Library.Gap, Library.Length

        Library.Lines.Top.From = Vector2.new(centerX, centerY - gap)
        Library.Lines.Top.To = Vector2.new(centerX, centerY - gap - length)

        Library.Lines.Bottom.From = Vector2.new(centerX, centerY + gap)
        Library.Lines.Bottom.To = Vector2.new(centerX, centerY + gap + length)

        Library.Lines.Left.From = Vector2.new(centerX - gap, centerY)
        Library.Lines.Left.To = Vector2.new(centerX - gap - length, centerY)

        Library.Lines.Right.From = Vector2.new(centerX + gap, centerY)
        Library.Lines.Right.To = Vector2.new(centerX + gap + length, centerY)

        Library.Outlines.Top.From = Vector2.new(centerX, centerY - gap)
        Library.Outlines.Top.To = Vector2.new(centerX, centerY - gap - length - 2)

        Library.Outlines.Bottom.From = Vector2.new(centerX, centerY + gap)
        Library.Outlines.Bottom.To = Vector2.new(centerX, centerY + gap + length + 2)

        Library.Outlines.Left.From = Vector2.new(centerX - gap, centerY)
        Library.Outlines.Left.To = Vector2.new(centerX - gap - length - 2, centerY)

        Library.Outlines.Right.From = Vector2.new(centerX + gap, centerY)
        Library.Outlines.Right.To = Vector2.new(centerX + gap + length + 2, centerY)
    end

    function Library.Fade()
        local alpha = math.abs(math.sin(tick() * Library.Fading[2]))
        for _, line in pairs(Library.Lines) do
            line.Transparency = alpha
        end
        for _, outline in pairs(Library.Outlines) do
            outline.Transparency = alpha
        end
    end 

    function Library.Spin()
        local angle = tick() * Library.SpinSetting[2]
        local sin, cos = math.sin(angle), math.cos(angle)

        for _, line in pairs(Library.Lines) do
            local from, to = line.From, line.To
            local centerX, centerY = workspace.CurrentCamera.ViewportSize.X / 2 + Library.Offset[1], workspace.CurrentCamera.ViewportSize.Y / 2 + Library.Offset[2]
            line.From = Vector2.new(
                cos * (from.X - centerX) - sin * (from.Y - centerY) + centerX,
                sin * (from.X - centerX) + cos * (from.Y - centerY) + centerY
            )
            line.To = Vector2.new(
                cos * (to.X - centerX) - sin * (to.Y - centerY) + centerX,
                sin * (to.X - centerX) + cos * (to.Y - centerY) + centerY
            )
        end

        for _, outline in pairs(Library.Outlines) do
            local from, to = outline.From, outline.To
            local centerX, centerY = workspace.CurrentCamera.ViewportSize.X / 2 + Library.Offset[1], workspace.CurrentCamera.ViewportSize.Y / 2 + Library.Offset[2]
            outline.From = Vector2.new(
                cos * (from.X - centerX) - sin * (from.Y - centerY) + centerX,
                sin * (from.X - centerX) + cos * (from.Y - centerY) + centerY
            )
            outline.To = Vector2.new(
                cos * (to.X - centerX) - sin * (to.Y - centerY) + centerX,
                sin * (to.X - centerX) + cos * (to.Y - centerY) + centerY
            )
        end
    end 

    function Library.Destroy()
        for _, line in pairs(Library.Lines) do
            line:Remove()
        end
        for _, outline in pairs(Library.Outlines) do
            outline:Remove()
        end
    end

    for _, line in pairs(Library.Lines) do
        line.ZIndex = 2
    end

    for _, outline in pairs(Library.Outlines) do
        outline.ZIndex = 1 -- Fixed typo
    end

    Crosshair = Library
end 
local Sense = loadstring(game:HttpGet(Repository .. "render.lua", true))(); Sense.Load()

local ReplicatedStorage, UserInputService, RunService, TweenService, HttpService, MarketplaceService, Lighting, CoreGui, Stats, Players = Services.ReplicatedStorage, Services.UserInputService, Services.RunService, Services.TweenService, Services.HttpService, Services.MarketplaceService, Services.Lighting, Services.CoreGui, Services.Stats, Services.Players
local LocalPlayer, Camera = Players.LocalPlayer, workspace.CurrentCamera 
local Mouse = UserInputService:GetMouseLocation()
local Jitter, CurrentAngle, OldRotate = false, CFrame.new(), LocalPlayer.Character.Humanoid.AutoRotate

local AimCircle, SilentCircle = Utility:newDrawing("Circle", { Visible = false, Thickness = 1, Color = Color3.fromRGB(255, 100, 100), Filled = false, NumSides = 64, Radius = 180}), Utility:newDrawing("Circle", { Visible = false, Thickness = 1, Color = Color3.fromRGB(255, 100, 100), Filled = false, NumSides = 64, Radius = 180})
local BloomEffect, ColorCorrectionEffect = Instance.new("BloomEffect", Lighting), Instance.new("ColorCorrectionEffect", Lighting)

local Window, Flags, Playerlist, Watermark = Library:Load({
    Title = "Fentanyl.win",
    folder = "Fentanyl",
    playerlist = true,
    playerlistmax = 20,
    sizey = 575
}), Library.flags, Library.Playerlist, Library:Watermark("Fentanyl.win | developer | universal | 60 fps | 200 ping"); do 
    local Tabs = { 
        [1] = Window:Tab(" Combat "), 
        [2] = Window:Tab(" Visuals "), 
        [3] = Window:Tab(" Miscallaenous "), 
        [4] = Window:SettingsTab(Watermark, function()
            Utility:Unload()
            Library:Unload()
            Sense.Unload()
            BloomEffect:Destroy()
            ColorCorrectionEffect:Destroy()
        end)
    }; 
    
    local Aim, AimMisc = Tabs[1]:MultiSection({Sections = {"Aim Assist ", " Misc "}}) do 
        Aim:Toggle({Name = "Enabled", Flag = "Aim"}):Keybind({ listname = "Aim Assist", mode = "Hold", Flag = "Aim Key"})
        Aim:Dropdown({Name = "Method", Content = {"Camera", "Mouse"}, Default = "Mouse", Flag = "Aim Method"})
        Aim:Dropdown({Name = "Target Area", Content = {"Head", "Torso", "Arms", "Legs"}, Default = {"Head"}, Multi = true, Flag = "Aim Target"})
        Aim:Slider({Name = "X Smoothing", Default = 50, Float = 1, Min = 0, Max = 100, Suffix = "%", Flag = "Aim X"})
        Aim:Slider({Name = "Y Smoothing", Default = 50, Float = 1, Min = 0, Max = 100, Suffix = "%", Flag = "Aim Y"})
        Aim:Separator()
        Aim:Toggle({Name = "Prediction", Flag = "Aim Prediction"})
        Aim:Slider({Name = "Factor", Default = 0, Float = 0.5, Min = -10, Max = 10, Flag = "Aim Prediction Value"})
        AimMisc:Toggle({Name = "Enabled", Flag = "Aim FOV", Callback = function(Value)
            AimCircle.Visible = Value
        end}):Colorpicker({Name = "FOV Color", Alpha = 1, Default = Color3.fromRGB(255, 100, 100), Flag = "Aim FOV Color", Callback = function(Value, Transparency)
            AimCircle.Color = Value 
            AimCircle.Transparency = Transparency
        end})
        AimMisc:Toggle({Name = "Filled", Flag = "Aim FOV Fill", Callback = function(Value)
            AimCircle.Filled = Value
        end})
        AimMisc:Slider({Name = "Radius", Min = 0, Max = 360, Default = 180, Float = 1, Suffix = " pixels", Flag = "Aim Radius", Callback = function(Value)
            AimCircle.Radius = Value 
        end})
        AimMisc:Slider({Name = "Thickness", Min = 1, Max = 10, Float = 0.25, Default = 1, Suffix = " pixels", Flag = "Aim Thickness", Callback = function(Value)
            AimCircle.Thickness = Value
        end})
        AimMisc:Slider({Name = "Sides", Min = 3, Max = 128, Float = 1, Default = 64, Flag = "Aim Sides", Callback = function(Value)
            AimCircle.NumSides = Value
        end})
    end

    local Silent, SilentMisc = Tabs[1]:MultiSection({Side = "Left", Sections = {"Silent Aim ", " Misc "}}) do 
        Silent:Toggle({Name = "Enabled"}):Keybind({ listname = "Silent Aim", mode = "Toggle"})
        Silent:Dropdown({Name = "Method", Content = {"Raycast", "FindPartOnRaycast"}, Default = "FindPartOnRaycast"})
        Silent:Dropdown({Name = "Target Area", Content = {"Head", "Torso", "Arms", "Legs"}, Default = {"Head"}, Multi = true})
        Silent:Slider({Name = "Hit Chance", Min = 0, Max = 100, Default = 100, Float = 1, Suffix = "%"})
        Silent:Separator()
        Silent:Toggle({Name = "Prediction"})
        Silent:Slider({Name = "Factor", Default = 0, Float = 0.5, Min = -10, Max = 10})
        SilentMisc:Toggle({Name = "Enabled"}):Colorpicker({Name = "FOV Color", Alpha = 1})
        SilentMisc:Toggle({Name = "Filled"})
        SilentMisc:Slider({Name = "Radius", Min = 0, Max = 360, Default = 180, Float = 1, Suffix = " pixels"})
        SilentMisc:Slider({Name = "Thickness", Min = 1, Max = 10, Float = 0.25, Default = 1, Suffix = " pixels"})
    end 

    local Checks = Tabs[1]:Section({Side = "Right", Name = "Validation Checks"}) do 
        Checks:Dropdown({Name = "Validation Checks", Content = {"Team", "Visible", "ForceField", "Whitelisted"}, Default = {"Team", "Visible"}, Multi = true, Flag = "Combat Checks"})
        Checks:Toggle({Name = "Limit Health", Flag = "Combat Health"})
        Checks:Slider({Name = "Minimum Health", Min = 0, Max = 100, Default = 0, Float = 1, Suffix = "%", Flag = "Combat Health Min"})
        Checks:Slider({Name = "Maximum Health", Min = 0, Max = 100, Default = 100, Float = 1, Suffix = "%", Flag = "Combat Health Max"})
        Checks:Toggle({Name = "Limit Distance", Flag = "Combat Distance"})
        Checks:Slider({Name = "Minimum Distance", Min = 0, Max = 500, Default = 0, Float = 1, Suffix = " studs", Flag = "Combat Distance Min"})
        Checks:Slider({Name = "Maximum Distance", Min = 500, Max = 2500, Default = 500, Float = 1, Suffix = " studs", Flag = "Combat Distance Max"})
    end 
    
    local Anti, Lag = Tabs[1]:MultiSection({Side = "Right", Sections = {"Anti-Aim ", " Fake Lag"}}) do 
        Anti:Toggle({Name = "Enabled", Flag = "Anti"}):Keybind({})
        Anti:Dropdown({Name = "Yaw Base", Content = {"Camera", "Random", "Spin"}, Default = "Camera", Flag = "Anti Yaw"})
        Anti:Slider({Name = "Yaw Offset", Min = -180, Max = 180, Default = 0, Flag = "Anti Offset"})
        Anti:Dropdown({Name = "Yaw Modifier", Content = {"None", "Jitter", "Offset Jitter"}, Default = "None", Flag = "Anti Modifier"})
        Anti:Slider({Name = "Modifier Offset", Min = -180, Max = 180, Default = 0, Flag = "Anti Modifier Offset"})
    
        Lag:Toggle({Name = "Enabled"}):Keybind({})
        Lag:Dropdown({Name = "Method", Content = {"Static", "Random"}, Default = "Static", Flag = "Lag Method"})
        Lag:Slider({Name = "Limit", Min = 1, Max = 16, Default = 6, Flag = "Lag Limit"})
        Lag:Toggle({Name = "Visualize", Flag = "Lag Visualize"}):Colorpicker({Name = "Visualize Color", Default = Color3.fromRGB(255, 100, 100), Alpha = 1, Flag = "Lag Visualize Color"})
        Lag:Toggle({Name = "Freeze World", Flag = "Lag Freeze"}):Keybind({Flag = "Lag Freeze Key"})
    end

    local Trigger, Hitbox = Tabs[1]:Section({Side = "Middle", Name = "Trigerbot"}), Tabs[1]:Section({Side = "Middle", Name = "Hitbox Expander"}) do 
        Trigger:Toggle({Name = "Enabled", Flag = "Trigger Enabled"}):Keybind({Flag = "Trigger Key"})
        Trigger:Dropdown({Name = "Target Area", Content = {"Head", "Torso", "Arms", "Legs"}, Default = {"Head"}, Multi = true, Flag = "Trigger Target Area"})
        Trigger:Slider({Name = "Delay", Min = 0, Max = 1, Default = 0, Float = 0.05, Suffix = " ms", Flag = "Trigger Delay"})
        
        local toggle = Hitbox:Toggle({Name = "Enabled", Flag = "Hitbox"})
        toggle:Colorpicker({Alpha = 1, Flag = "Hitbox Color"})
        Hitbox:Dropdown({Name = "Target Area", Content = {"Head", "Torso", "Arms", "Legs"}, Default = "Head", Multi = false, Flag = "Hitbox Target"})
        Hitbox:Slider({Name = "X Factor", Min = 0, Max = 100, Default = 50, Float = 1, Suffix = "%", Flag = "Hitbox X Factor"})
        Hitbox:Slider({Name = "Y Factor", Min = 0, Max = 100, Default = 50, Float = 1, Suffix = "%", Flag = "Hitbox Y Factor"})
        Hitbox:Slider({Name = "Z Factor", Min = 0, Max = 100, Default = 50, Float = 1, Suffix = "%", Flag = "Hitbox Z Factor"})
        Hitbox:Dropdown({Name = "Material", Content = {"Plastic", "SmoothPlastic", "Glass", "ForceField", "Neon"}, Default = "ForceField", Flag = "Hitbox Material"})
        
    end

    local Enemy, Friendly, Settings = Tabs[2]:MultiSection({Sections = {"Enemy ", " Friendly ", " Settings "}}) do 
        for i = 1, 2 do 
            local flag = i == 1 and "ESP Enemy " or "ESP Friendly " 
            local section = i == 1 and Enemy or Friendly
            local path = i == 1 and Sense.teamSettings.enemy or Sense.teamSettings.friendly
            
            section:Toggle({Name = "Enabled", Flag = (i == 1 and "ESP Enemy" or "ESP Friendly"), Callback = function(Value)
                path.enabled = Value
            end})
            
            local toggle = section:Toggle({Name = "Bounding Boxes", Flag = flag .. "Box", Callback = function(Value)
                path.box = Value
            end}) 
            toggle:Colorpicker({Name = "Box Color", Default = path.boxColor[1], Flag = flag .. "Boxes Color", Alpha = path.boxColor[2], Callback = function(Value, Transparency)
                path.boxColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Box Outline Color", Default = path.boxOutlineColor[1], Flag = flag .. "Boxes Outline Color", Alpha = path.boxOutlineColor[2], Callback = function(Value, Transparency)
                path.boxOutlineColor = {Value, Transparency}
            end})
            section:Toggle({Name = "Filled", Flag = flag .. "Fill", Callback = function(Value)
                path.boxFill = Value
            end}):Colorpicker({Name = "Fill Color", Default = path.boxFillColor[1], Flag = flag .. "Fill Color", Alpha = path.boxFillColor[2], Callback = function(Value, Transparency)
                path.boxFillColor = {Value, Transparency}
            end})
            section:Toggle({Name = "3D Boxes", Flag = flag .. "3D", Callback = function(Value)
                path.box3d = Value
            end}):Colorpicker({Name = "Box Color", Default = path.box3dColor[1], Flag = flag .. "3D Color", Alpha = path.box3dColor[2], Callback = function(Value, Transparency)
                path.box3dColor = {Value, Transparency}
            end})
            local toggle = section:Toggle({Name = "Health Bars", Flag = flag .. "Bar", Callback = function(Value)
                path.healthBar = Value
            end}) 
            toggle:Colorpicker({Name = "Healthy Color", Default = path.healthyColor, Flag = flag .. "Healthy Color", Callback = function(Value)
                path.healthyColor = Value
            end})
            toggle:Colorpicker({Name = "Dying Color", Default = path.dyingColor, Flag = flag .. "Dying Color", Callback = function(Value)
                path.dyingColor = Value
            end})
            local toggle = section:Toggle({Name = "Health Text", Flag = flag .. "Health", Callback = function(Value)
                path.healthText = Value
            end}) 
            toggle:Colorpicker({Name = "Main Color", Default = path.healthTextColor[1], Flag = flag .. "Health Color", Alpha = path.healthTextColor[2], Callback = function(Value, Transparency)
                path.healthTextColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.healthTextOutlineColor, Flag = flag .. "Health Outline Color", Callback = function(Value)
                path.healthTextOutlineColor = Value
            end})
            local toggle = section:Toggle({Name = "Names", Flag = flag .. "Name", Callback = function(Value)
                path.name = Value
            end}) 
            toggle:Colorpicker({Name = "Main Color", Default = path.nameColor[1], Flag = flag .. "Name Color", Alpha = path.nameColor[2], Callback = function(Value, Transparency)
                path.nameColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.nameOutlineColor, Flag = flag .. "Name Outline Color", Callback = function(Value)
                path.nameOutlineColor = Value
            end})
            local toggle = section:Toggle({Name = "Distances", Flag = flag .. "Distance", Callback = function(Value)
                path.distance = Value
            end}) 
            toggle:Colorpicker({Name = "Main Color", Default = path.distanceColor[1], Flag = flag .. "Distance Color", Alpha = path.distanceColor[2], Callback = function(Value, Transparency)
                path.distanceColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.distanceOutlineColor, Flag = flag .. "Distance Outline Color", Callback = function(Value)
                path.distanceOutlineColor = Value
            end})
            local toggle = section:Toggle({Name = "Weapons", Flag = flag .. "Weapon", Callback = function(Value)
                path.weapon = Value
            end}) 
            toggle:Colorpicker({Name = "Main Color", Default = path.weaponColor[1], Flag = flag .. "Weapon Color", Alpha = path.weaponColor[2], Callback = function(Value, Transparency)
                path.weaponColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.weaponOutlineColor, Flag = flag .. "Weapon Outline Color", Callback = function(Value)
                path.weaponOutlineColor = Value
            end})
            local toggle = section:Toggle({Name = "Tracers", Flag = flag .. "Tracer", Callback = function(Value)
                path.tracer = Value
            end}) 
            section:Dropdown({Name = "Tracer Position", Content = {"Top", "Middle", "Bottom"}, Default = path.tracerOrigin, Flag = flag .. "Tracer Position", Callback = function(Value)
                path.tracerOrigin = Value
            end})
            toggle:Colorpicker({Name = "Main Color", Default = path.tracerColor[1], Flag = flag .. "Tracer Color", Alpha = path.tracerColor[2], Callback = function(Value, Transparency)
                path.tracerColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.tracerOutlineColor[1], Flag = flag .. "Tracer Outline Color", Alpha = path.tracerOutlineColor[2], Callback = function(Value, Transparency)
                path.tracerOutlineColor = {Value, Transparency}
            end})
            local toggle = section:Toggle({Name = "Arrows", Flag = flag .. "Arrow", Callback = function(Value)
                path.offScreenArrow = Value
            end}) 
            toggle:Colorpicker({Name = "Main Color", Default = path.offScreenArrowColor[1], Flag = flag .. "Arrow Color", Alpha = path.offScreenArrowColor[2], Callback = function(Value, Transparency)
                path.offScreenArrowColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.offScreenArrowOutlineColor[1], Flag = flag .. "Arrow Outline Color", Alpha = path.offScreenArrowOutlineColor[2], Callback = function(Value, Transparency)
                path.offScreenArrowOutlineColor = {Value, Transparency}
            end})
            section:Slider({Name = "Arrow Size", Min = 0, Max = 35, Default = path.offScreenArrowSize, Float = 1, Flag = flag .. "Arrow Size", Callback = function(Value)
                path.offScreenArrowSize = Value
            end})
            section:Slider({Name = "Arrow Radius", Min = 0, Max = 350, Default = path.offScreenArrowRadius, Float = 1, Flag = flag .. "Arrow Radius", Callback = function(Value)
                path.offScreenArrowRadius = Value
            end})
            local toggle = section:Toggle({Name = "Chams", Flag = flag .. "Chams", Callback = function(Value)
                path.chams = Value
            end}) 
            section:Toggle({Name = "Visible Only", Flag = flag .. "Chams Visible", Callback = function(Value)
                path.chamsVisibleOnly = Value
            end})
            toggle:Colorpicker({Name = "Main Color", Default = path.chamsFillColor[1], Flag = flag .. "Chams Color", Alpha = path.chamsFillColor[2], Callback = function(Value, Transparency)
                path.chamsFillColor = {Value, Transparency}
            end})
            toggle:Colorpicker({Name = "Outline Color", Default = path.chamsOutlineColor[1], Flag = flag .. "Chams Outline Color", Alpha = path.chamsOutlineColor[2], Callback = function(Value, Transparency)
                path.chamsOutlineColor = {Value, Transparency}
            end})
        end
        Settings:Dropdown({Name = "Text Casing", Content = {"UPPERCASE", "NormalCase", "lowercase"}, Default = "NormalCase", Flag = "ESP Case", Callback = function(Value)
            Sense.sharedSettings.casing = Value
        end})
        Settings:Dropdown({Name = "Text Surrounding", Content = {"None", "--", "<>", "><", "[]", "{}"}, Default = "None", Flag = "ESP Surround", Callback = function(Value)
            Sense.sharedSettings.surround = Value == "None" and "" or Value
        end})
        Settings:Slider({Name = "Font Size", Min = 0, Max = 30, Default = 13, Float = 1, Flag = "ESP Font Size", Suffix = " px", Callback = function(Value)
            Sense.sharedSettings.textSize = Value
        end})
        Settings:Toggle({Name = "Limit Distance", Flag = "ESP Limit Distance", Callback = function(Value)
            Sense.sharedSettings.limitDistance = Value
        end})
        Settings:Slider({Name = "Maximum Distance", Min = 100, Max = 2500, Float = 25, Suffix = " studs", Flag = "ESP Max Distance", Default = 500, Callback = function(Value)
            Sense.sharedSettings.maxDistance = Value
        end})
        Settings:Toggle({Name = "Use Team Color", Flag = "ESP Team Color", Callback = function(Value)
            Sense.sharedSettings.useTeamColor = Value
        end})
        Settings:Box({Name = "Health Suffix", Default = "%", Flag = "ESP Health Suffix", Callback = function(Value)
            Sense.sharedSettings.healthSuffix = Value
        end})
        Settings:Box({Name = "Distance Suffix", Default = "studs", Flag = "ESP Distance Suffix", Callback = function(Value)
            Sense.sharedSettings.distanceSuffix = " " .. Value
        end})
    end

    local World, Bloom, Color = Tabs[2]:MultiSection({Sections = {"World ", " Bloom ", " Color "}, Side = "Middle"}) do 
        local toggle = World:Toggle({Name = "Ambience", Flag = "World Ambient", Callback = function(Value)
            if Value then 
                Lighting.Ambient = Flags["World Ambient Value"]
            end
        end}):Colorpicker({Name = "Ambience Color", Flag = "World Ambient Value", Callback = function(Value)
            if Flags["World Ambient"] then 
                Lighting.Ambient = Value
            end
        end})
        World:Toggle({Name = "Global Shadows", Flag = "World Global", Default = Lighting.GlobalShadows, Callback = function(Value)
            Lighting.GlobalShadows = Value
        end})
        World:Dropdown({Name = "Lighting Technology", Content = {"Voxel", "ShadowMap", "Future"}, Flag = "World Technology"})
        World:Slider({Name = "Shadow Softness", Min = 0, Max = 10, Default = Lighting.ShadowSoftness, Float = 0.25, Flag = "World Softness", Callback = function(Value)
            Lighting.ShadowSoftness = Value
        end})

        Bloom:Toggle({Name = "Enabled", Flag = "World Bloom", Callback = function(Value)
            BloomEffect.Enabled = Value
        end})
        Bloom:Slider({Name = "Intensity", Min = 0, Max = 25, Flag = "World Bloom Intensity", Callback = function(Value)
            BloomEffect.Intensity = Value
        end})
        Bloom:Slider({Name = "Size", Min = 0, Max = 25, Flag = "World Bloom Size", Callback = function(Value)
            BloomEffect.Size = Value
        end})
        Bloom:Slider({Name = "Threshold", Min = 0, Max = 25, Flag = "World Bloom Threshold", Callback = function(Value)
            BloomEffect.Threshold = Value
        end})
        
        Color:Toggle({Name = "Enabled", Flag = "World Color", Callback = function(Value)
            ColorCorrectionEffect.Enabled = Value
        end}):Colorpicker({Name = "Tint Color", Flag = "World Color Value", Callback = function(Value)
            ColorCorrectionEffect.TintColor = Value
        end})
        Color:Slider({Name = "Contrast", Min = -25, Max = 25, Default = 0, Flag = "World Color Contrast", Callback = function(Value)
            ColorCorrectionEffect.Contrast = Value
        end})
        Color:Slider({Name = "Saturation", Min = -25, Max = 25, Default = 0, Flag = "World Color Saturation", Callback = function(Value)
            ColorCorrectionEffect.Saturation = Value
        end})
        Color:Slider({Name = "Brightness", Min = -5, Max = 5, Default = 0, Float = 0.025, Flag = "World Color Brightness", Callback = function(Value)
            ColorCorrectionEffect.Brightness = Value
        end})
    end 

    local Camera = Tabs[2]:Section({Name = "Camera", Side = "Middle"}) do 
        Camera:Toggle({Name = "Third Person", Flag = "Third Person"}):Keybind({Flag = "Third Person Key"})
        Camera:Slider({Name = "Distance", Min = 3, Max = 15, Default = 12, Flag = "Third Person Distance"})
        Camera:Separator()
        Camera:Toggle({Name = "FOV Changer", Flag = "Camera FOV Changer"})
        Camera:Toggle({Name = "Zoom", Flag = "Camera Zoom"}):Keybind({Flag = "Camera Zoom Key"})
        Camera:Slider({Name = "Field Of View", Min = 0, Max = 120, Default = Camera.FieldOfView, Float = 0.5, Flag = "Camera FOV"})
        Camera:Slider({Name = "Field Of View", Min = 0, Max = 120, Default = 30, Float = 0.5})
    end 

local CrosshairSection = Tabs[2]:Section({Name = "Crosshair", Side = "Right"}) do
    -- Toggle Crosshair Visibility
    CrosshairSection:Toggle({
        Name = "Visible",
        Flag = "Crosshair Visible",
        Default = Crosshair.Visible,
        Callback = function(Value)
            Crosshair.Visible = Value
            for _, line in pairs(Crosshair.Lines) do
                line.Visible = Value
            end
            for _, outline in pairs(Crosshair.Outlines) do
                outline.Visible = Value
            end
        end
    }):Colorpicker({
        Name = "Crosshair Color",
        Alpha = Crosshair.VisColor[2],
        Default = Crosshair.VisColor[1],
        Flag = "Crosshair Color",
        Callback = function(Value, Transparency)
            Crosshair.VisColor = {Value, Transparency}
            for _, line in pairs(Crosshair.Lines) do
                line.Color = Value
                line.Transparency = Transparency
            end
        end
    })

    -- Toggle Crosshair Outline
    CrosshairSection:Toggle({
        Name = "Outline",
        Flag = "Crosshair Outline",
        Default = Crosshair.Outline,
        Callback = function(Value)
            Crosshair.Outline = Value
            for _, outline in pairs(Crosshair.Outlines) do
                outline.Visible = Value
            end
        end
    }):Colorpicker({
        Name = "Outline Color",
        Alpha = Crosshair.OutlineColor[2],
        Default = Crosshair.OutlineColor[1],
        Flag = "Crosshair Outline Color",
        Callback = function(Value, Transparency)
            Crosshair.OutlineColor = {Value, Transparency}
            for _, outline in pairs(Crosshair.Outlines) do
                outline.Color = Value
                outline.Transparency = Transparency
            end
        end
    })

    CrosshairSection:Slider({
        Name = "Thicknes",
        Min = 1,
        Max = 15,
        Float = 1,
        Default = Crosshair.Thickness,
        Flag = "Crosshair Thickness",
        Callback = function(Value)
            Crosshair.Thickness = Value 
            for _, v in ipairs(Crosshair.Lines) do 
                v.Thickness = Value 
            end 

            for _, v in ipairs(Crosshair.Outlines) do 
                v.Thickness = Value + 2.5
            end 

        end
    })

    -- Toggle Crosshair Spin
    CrosshairSection:Toggle({
        Name = "Spin",
        Flag = "Crosshair Spin",
        Default = Crosshair.SpinSetting[1],
        Callback = function(Value)
            Crosshair.SpinSetting[1] = Value
        end
    })

    -- Adjust Spin Speed
    CrosshairSection:Slider({
        Name = "Spin Speed",
        Min = 1,
        Max = 15,
        Float = 1,
        Default = Crosshair.SpinSetting[2],
        Flag = "Crosshair Spin Speed",
        Callback = function(Value)
            Crosshair.SpinSetting[2] = Value / 10000000
        end
    })

    -- Adjust Crosshair Gap and Length
    CrosshairSection:Slider({
        Name = "Gap",
        Min = 0,
        Max = 30,
        Float = 0.25,
        Default = Crosshair.Gap,
        Flag = "Crosshair Gap",
        Callback = function(Value)
            Crosshair.Gap = Value
            Crosshair.Update()
        end
    })
    CrosshairSection:Slider({
        Name = "Length",
        Min = 0,
        Max = 35,
        Float = 1,
        Default = Crosshair.Length,
        Flag = "Crosshair Length",
        Callback = function(Value)
            Crosshair.Length = Value
            Crosshair.Update()
        end
    })

    -- Toggle Crosshair Fading
    CrosshairSection:Toggle({
        Name = "Fading",
        Flag = "Crosshair Fading",
        Default = Crosshair.Fading[1],
        Callback = function(Value)
            Crosshair.Fading[1] = Value
        end
    })

    -- Adjust Fade Speed
    CrosshairSection:Slider({
        Name = "Fade Speed",
        Min = 0,
        Max = 1000,
        Float = 1,
        Default = Crosshair.Fading[2],
        Suffix = " ms",
        Flag = "Crosshair Fade Speed",
        Callback = function(Value)
            Crosshair.Fading[2] = Value
        end
    })

    -- Adjust Crosshair Offset
    CrosshairSection:Slider({
        Name = "X Offset",
        Min = -200,
        Max = 200,
        Float = 0.5,
        Default = Crosshair.Offset[1],
        Flag = "Crosshair X Offset",
        Callback = function(Value)
            Crosshair.Offset[1] = Value
            Crosshair.Update()
        end
    })
    CrosshairSection:Slider({
        Name = "Y Offset",
        Min = -200,
        Max = 200,
        Float = 0.5,
        Default = Crosshair.Offset[2],
        Flag = "Crosshair Y Offset",
        Callback = function(Value)
            Crosshair.Offset[2] = Value
            Crosshair.Update()
        end
    })
end

-- Update Crosshair Behavior in RenderStepped
RunService.RenderStepped:Connect(function()
    if Crosshair.Visible then
        if Crosshair.Fading[1] then
            Crosshair.Fade()
        end
        if Crosshair.SpinSetting[1] then
            Crosshair.Spin()
        end
    end
end)

    local LocalPlayer = Tabs[3]:Section({Name = "Local Player"}) do 
        LocalPlayer:Toggle({Name = "Speed Modifications", Flag = "Local Speed"}):Keybind({})
        LocalPlayer:Dropdown({Name = "Method", Content = {"Walkspeed", "CFrame"}, Default = "CFrame", Flag = "Local Speed Method"})
        LocalPlayer:Slider({Name = "Speed", Min = 0, Max = 2.5, Default = 1, Float = 0.25, Flag = "Local Speed Value"})
        LocalPlayer:Separator()
        LocalPlayer:Toggle({Name = "Jump Modifications", Flag = "Local Jump"}):Keybind({})
        LocalPlayer:Slider({Name = "Jump Height", Min = 0, Max = 100, Default = 50, Float = 1, Flag = "Local Jump Value"})
        LocalPlayer:Slider({Name = "Jump Power", Min = 50, Max = 200, Default = 100, Float = 1, Flag = "Local Jump Power"})
        LocalPlayer:Separator()
        LocalPlayer:Toggle({Name = "Fly", Flag = "Local Fly"}):Keybind({})
        LocalPlayer:Slider({Name = "Speed", Min = 0, Max = 100, Default = 50, Float = 1, Flag = "Local Fly Speed"})
    end 

    
    Playerlist:button({Name = "Whitelist", Callback = function(list, plr)
        if not list:IsTagged(plr, "Whitelisted") then 
            list:Tag({Player = plr, Text = "Whitelisted", Color = Color3.fromRGB(100, 255, 100)})
            table.insert(Sense.whitelist, plr.UserId)
        else 
            list:RemoveTag(plr, "Whitelisted")
            table.remove(Sense.whitelist, plr.UserId)
        end 
    end})

    Playerlist:button({Name = "Teleport", Callback = function(list, plr)

    end})

    Playerlist:button({Name = "Spectate", Callback = function(list, plr)
        if not list:IsTagged(plr, "Spectating") then 
            list:Tag({Player = plr, Text = "Spectating", Color = Color3.fromRGB(255, 255, 255)})
        else 
            list:RemoveTag(plr, "Spectating")
        end 
    end})

    Playerlist:Label({
        Name = "",
        Handler = function(Player)
            return (Utility:isFriendly(Player) and "Friendly") or "Enemy"
        end 
    })

    Library:Init()
end 

Utility:newSignal({
    Signal = Services.RunService.RenderStepped,
    Index = "Renderstepped",
    Callback = function(Delta)        
        if Utility:isAlive(LocalPlayer) then
            local Magnitude; Utility.ClosestPlayer = Utility:getClosestPlayer(function(Player, MouseDistance)
                if table.find(Flags["Combat Checks"], "Team") and Utility:isFriendly(Player) then 
                    return false  
                end

                if table.find(Flags["Combat Checks"], "Whitelisted") and Playerlist:IsTagged(Player, "Whitelisted") then 
                    return false 
                end 

                if table.find(Flags["Combat Checks"], "Forcefield") and Player.Character.Humanoid:FindFirstChild("ForceField") then 
                    return false 
                end 

                if Flags["Combat Health"] then 
                    local Health = Player.Character.Humanoid.Health
                    if Health < Flags["Combat Health Min"] or Health > Flags["Combat Health Max"] then 
                        return false 
                    end 
                end

                if Flags["Combat Distance"] then 
                    local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if Distance < Flags["Combat Distance Min"] or Distance > Flags["Combat Distance Max"] then 
                        return false 
                    end 
                end 

                if table.find(Flags["Combat Checks"], "Visible") then 
                    return Utility:isVisible(Camera.CFrame.Position, Player.Character.Head.Position, Player.Character.Head)
                end

                Magnitude = MouseDistance

                return true 
            end)
            
            if Flags["Anti"] then
                LocalPlayer.Character.Humanoid.AutoRotate = false 
                
                local Angle; do 
                    Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(-90)
                    if Flags["Anti Yaw"] == "Random" then 
                        Angle =  -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(math.random(0, 360))
                    elseif Flags["Anti Yaw"] == "Spin" then 
                        Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + tick() * 10 % 360
                    end 
                end 

                local Offset = math.rad(Flags["Anti Offset"]); Jitter = not Jitter 

                if Jitter then 
                    if Flags["Anti Modifier"] == "Jitter" then 
                        Offset = math.rad(Flags["Anti Modifier Offset"])
                    elseif Flags["Anti Modifier"] == "Offset" then
                        Offset = Offset + math.rad(Flags["Anti Modifier Offset"])
                    end 
                end 

                local function ToYRotation(_CFrame)
                    local X, Y, Z = _CFrame:ToOrientation()
                    return CFrame.new(_CFrame.Position) * CFrame.Angles(0, Y, 0)
                end
                
                CurrentAngle = Angle + Offset
                LocalPlayer.Character.HumanoidRootPart.CFrame = ToYRotation(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.Angles(0, Angle + Offset, 0))
                
            else 
                LocalPlayer.Character.Humanoid.AutoRotate = OldRotate
            end
            
            if Utility.ClosestPlayer then 
                if Flags["Aim"] then 
                    if (string.find(tostring(Flags["Aim Key"]), "KeyCode") and UserInputService:IsKeyDown(Flags["Aim Key"])) or (string.find(tostring(Flags["Aim Key"]), "UserInputType")) and UserInputService:IsMouseButtonPressed(Flags["Aim Key"]) then 
                        local Target, Position = Utility:getClosestPart(Utility.ClosestPlayer, Utility:getBodyParts( Utility.ClosestPlayer.Character,  Utility.ClosestPlayer.Character.HumanoidRootPart, false, Flags["Aim Target"]))
                        
                        if Flags["Aim Method"] == "Mouse" then 
                            mousemoverel(
                                ((Position.X - UserInputService:GetMouseLocation().X) * (Flags["Aim X"] / 100)),
                                ((Position.Y - UserInputService:GetMouseLocation().Y) * (Flags["Aim Y"] / 100))
                            )
                        end
                    end 
                    
                    if Flags["Aim FOV"] then 
                        AimCircle.Position = UserInputService:GetMouseLocation()
                    end 
                end 
            end
        end 

        do 
            Utility.FrameCounter = Utility.FrameCounter + 1

            if (tick() - Utility.FrameTimer) >= 1 then
                Utility.FPS = Utility.FrameCounter;
                Utility.FrameTimer = tick();
                Utility.FrameCounter = 0;
            end;

            Watermark:Set("Fentanyl.win | developer | universal | " .. math.floor(Utility.FPS) .. " fps | " .. math.floor(Services.Stats.Network.ServerStatsItem['Data Ping']:GetValue()) .. " ping")
        end
    end
})

