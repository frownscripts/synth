-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DiscordMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 280)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local glowBorder = Instance.new("UIStroke")
glowBorder.Name = "GlowBorder"
glowBorder.Color = Color3.fromRGB(147, 51, 234)
glowBorder.Thickness = 2
glowBorder.Transparency = 0.5
glowBorder.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 70)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
header.BorderSizePixel = 0
header.ZIndex = 10
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerBottom = Instance.new("Frame")
headerBottom.Size = UDim2.new(1, 0, 0, 16)
headerBottom.Position = UDim2.new(0, 0, 1, -16)
headerBottom.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
headerBottom.BorderSizePixel = 0
headerBottom.ZIndex = 10
headerBottom.Parent = header

-- Logo
local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Size = UDim2.new(0, 48, 0, 48)
logoContainer.Position = UDim2.new(0, 18, 0, 11)
logoContainer.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
logoContainer.BackgroundTransparency = 0.9
logoContainer.BorderSizePixel = 0
logoContainer.ZIndex = 11
logoContainer.Parent = header

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 12)
logoCorner.Parent = logoContainer

local logoGlow = Instance.new("UIStroke")
logoGlow.Color = Color3.fromRGB(147, 51, 234)
logoGlow.Thickness = 1
logoGlow.Transparency = 0.7
logoGlow.Parent = logoContainer

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 36, 0, 36)
logo.Position = UDim2.new(0.5, -18, 0.5, -18)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://112965516978450"
logo.ScaleType = Enum.ScaleType.Fit
logo.ZIndex = 12
logo.Parent = logoContainer

-- Title
local titleContainer = Instance.new("Frame")
titleContainer.Name = "TitleContainer"
titleContainer.Size = UDim2.new(0, 300, 0, 48)
titleContainer.Position = UDim2.new(0, 76, 0, 11)
titleContainer.BackgroundTransparency = 1
titleContainer.ZIndex = 11
titleContainer.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Synth"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = titleContainer

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, 0, 0, 16)
subtitle.Position = UDim2.new(0, 0, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Discord Required"
subtitle.TextColor3 = Color3.fromRGB(147, 51, 234)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 12
subtitle.Parent = titleContainer

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -52, 0, 17)
closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
closeButton.BorderSizePixel = 0
closeButton.Text = ""
closeButton.AutoButtonColor = false
closeButton.ZIndex = 12
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

local closeIcon = Instance.new("TextLabel")
closeIcon.Size = UDim2.new(1, 0, 1, 0)
closeIcon.BackgroundTransparency = 1
closeIcon.Text = "X"
closeIcon.TextColor3 = Color3.fromRGB(120, 120, 130)
closeIcon.TextSize = 14
closeIcon.Font = Enum.Font.GothamBold
closeIcon.ZIndex = 13
closeIcon.Parent = closeButton

closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(147, 51, 234)
    }):Play()
    TweenService:Create(closeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    }):Play()
    TweenService:Create(closeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        TextColor3 = Color3.fromRGB(120, 120, 130)
    }):Play()
end)

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -60, 0, 180)
contentArea.Position = UDim2.new(0, 30, 0, 85)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 10
contentArea.Parent = mainFrame

-- Discord Icon
local discordIcon = Instance.new("TextLabel")
discordIcon.Name = "DiscordIcon"
discordIcon.Size = UDim2.new(0, 60, 0, 60)
discordIcon.Position = UDim2.new(0.5, -30, 0, 0)
discordIcon.BackgroundTransparency = 1
discordIcon.Text = "💬"
discordIcon.TextSize = 48
discordIcon.ZIndex = 11
discordIcon.Parent = contentArea

-- Message Text
local messageText = Instance.new("TextLabel")
messageText.Name = "MessageText"
messageText.Size = UDim2.new(1, 0, 0, 50)
messageText.Position = UDim2.new(0, 0, 0, 65)
messageText.BackgroundTransparency = 1
messageText.Text = "In order to get free script\nmust join discord"
messageText.TextColor3 = Color3.fromRGB(200, 200, 210)
messageText.TextSize = 16
messageText.Font = Enum.Font.GothamMedium
messageText.TextWrapped = true
messageText.ZIndex = 11
messageText.Parent = contentArea

-- Copy Button
local copyButton = Instance.new("TextButton")
copyButton.Name = "CopyButton"
copyButton.Size = UDim2.new(1, 0, 0, 50)
copyButton.Position = UDim2.new(0, 0, 0, 125)
copyButton.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
copyButton.BorderSizePixel = 0
copyButton.Text = ""
copyButton.AutoButtonColor = false
copyButton.ZIndex = 11
copyButton.Parent = contentArea

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 12)
copyCorner.Parent = copyButton

local copyGradient = Instance.new("UIGradient")
copyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 51, 234)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(126, 34, 206)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 51, 234))
})
copyGradient.Rotation = 90
copyGradient.Parent = copyButton

local copyStroke = Instance.new("UIStroke")
copyStroke.Color = Color3.fromRGB(192, 132, 252)
copyStroke.Thickness = 0
copyStroke.Transparency = 0.5
copyStroke.Parent = copyButton

local copyButtonText = Instance.new("TextLabel")
copyButtonText.Name = "ButtonText"
copyButtonText.Size = UDim2.new(1, 0, 1, 0)
copyButtonText.BackgroundTransparency = 1
copyButtonText.Text = "Copy Discord Invite"
copyButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButtonText.TextSize = 16
copyButtonText.Font = Enum.Font.GothamBold
copyButtonText.ZIndex = 12
copyButtonText.Parent = copyButton

-- Hover effects
copyButton.MouseEnter:Connect(function()
    TweenService:Create(copyButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Size = UDim2.new(1, 4, 0, 54),
        Position = UDim2.new(0, -2, 0, 123)
    }):Play()
    TweenService:Create(copyStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Thickness = 2
    }):Play()
end)

copyButton.MouseLeave:Connect(function()
    TweenService:Create(copyButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 125)
    }):Play()
    TweenService:Create(copyStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Thickness = 0
    }):Play()
end)

-- Copy functionality
local discordLink = "https://discord.gg/7qMnY5hJyw"

copyButton.MouseButton1Click:Connect(function()
    -- Click animation
    TweenService:Create(copyButton, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
        Size = UDim2.new(1, -6, 0, 46),
        Position = UDim2.new(0, 3, 0, 127)
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(copyButton, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 125)
    }):Play()
    
    -- Copy to clipboard
    setclipboard(discordLink)
    
    -- Visual feedback
    local originalText = copyButtonText.Text
    copyButtonText.Text = "✓ Copied to Clipboard!"
    copyButtonText.TextColor3 = Color3.fromRGB(34, 197, 94)
    
    TweenService:Create(copyButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    }):Play()
    
    task.wait(2)
    
    copyButtonText.Text = originalText
    copyButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    TweenService:Create(copyButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(147, 51, 234)
    }):Play()
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(glowBorder, TweenInfo.new(0.2), {
        Transparency = 1
    }):Play()
    
    task.wait(0.35)
    screenGui:Destroy()
end)

-- Entrance animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1

TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 450, 0, 280),
    BackgroundTransparency = 0
}):Play()

-- Glow animation
spawn(function()
    while mainFrame and mainFrame.Parent do
        TweenService:Create(glowBorder, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.3
        }):Play()
        task.wait(2)
        TweenService:Create(glowBorder, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.7
        }):Play()
        task.wait(2)
    end
end)
