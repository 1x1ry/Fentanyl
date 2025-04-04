local Library = {
    Visible = true, 
    VisColor = {Color3.fromRGB(255, 255, 255), 1},
    Outline = true,
    OutlineColor = {Color3.fromRGB(255, 255, 255), 1},
    Spin = {true, 1},
    Fading = {true, 10},
    Pulse = {true, 2},
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
    local angle = tick() * Library.Spin[2]
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

function Library.Pulse(speed)
    speed = speed or Library.Pulse[2] -- Default to the value in Library.Pulse
    local pulse = math.abs(math.sin(tick() * speed)) * 5
    Library.Resize(Library.Gap + pulse, Library.Length + pulse)
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

return Library
