--[[
    Delta Chat Script v1.0
    ======================
    Script nhắn tin cho Delta Executor
    - UI gọn nhẹ, kéo thả được
    - Nút toggle nhỏ để mở/đóng
    - Chat realtime trong cùng server
    - Hệ thống Room ID riêng tư
--]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

-- Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Config
local Config = {
    RoomID = "default_room",
    UserName = LocalPlayer.Name,
    Theme = {
        BG = Color3.fromRGB(32, 32, 36),
        Card = Color3.fromRGB(42, 42, 47),
        Text = Color3.fromRGB(232, 229, 223),
        Muted = Color3.fromRGB(154, 151, 143),
        Accent = Color3.fromRGB(196, 112, 70),
        Border = Color3.fromRGB(80, 80, 85),
        MyBubble = Color3.fromRGB(196, 112, 70),
        OtherBubble = Color3.fromRGB(60, 60, 65),
    },
    WindowSize = Vector2.new(320, 420),
    ToggleSize = Vector2.new(44, 44),
    Messages = {},
    MaxMessages = 50,
}

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaChat"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, Config.WindowSize.X, 0, Config.WindowSize.Y)
MainWindow.Position = UDim2.new(0.5, -Config.WindowSize.X/2, 0.5, -Config.WindowSize.Y/2)
MainWindow.BackgroundColor3 = Config.Theme.BG
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Theme.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainWindow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Config.Theme.Card
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleBarMask = Instance.new("Frame")
TitleBarMask.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarMask.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarMask.BackgroundColor3 = Config.Theme.Card
TitleBarMask.BorderSizePixel = 0
TitleBarMask.ZIndex = 2
TitleBarMask.Parent = TitleBar

-- Icon
local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 20, 0, 20)
IconFrame.Position = UDim2.new(0, 10, 0.5, -10)
IconFrame.BackgroundColor3 = Config.Theme.Accent
IconFrame.BorderSizePixel = 0
IconFrame.Parent = TitleBar

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 4)
IconCorner.Parent = IconFrame

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 38, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Delta Chat"
TitleText.TextColor3 = Config.Theme.Text
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -34, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Config.Theme.BG
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Config.Theme.Muted
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeBtn

-- Room ID Input
local RoomFrame = Instance.new("Frame")
RoomFrame.Name = "RoomFrame"
RoomFrame.Size = UDim2.new(1, -16, 0, 32)
RoomFrame.Position = UDim2.new(0, 8, 0, 44)
RoomFrame.BackgroundColor3 = Config.Theme.Card
RoomFrame.BorderSizePixel = 0
RoomFrame.Parent = MainWindow

local RoomCorner = Instance.new("UICorner")
RoomCorner.CornerRadius = UDim.new(0, 8)
RoomCorner.Parent = RoomFrame

local RoomLabel = Instance.new("TextLabel")
RoomLabel.Size = UDim2.new(0, 60, 1, 0)
RoomLabel.BackgroundTransparency = 1
RoomLabel.Text = "Room:"
RoomLabel.TextColor3 = Config.Theme.Muted
RoomLabel.TextSize = 12
RoomLabel.Font = Enum.Font.Gotham
RoomLabel.TextXAlignment = Enum.TextXAlignment.Left
RoomLabel.Position = UDim2.new(0, 8, 0, 0)
RoomLabel.Parent = RoomFrame

local RoomInput = Instance.new("TextBox")
RoomInput.Size = UDim2.new(1, -76, 1, 0)
RoomInput.Position = UDim2.new(0, 68, 0, 0)
RoomInput.BackgroundTransparency = 1
RoomInput.Text = Config.RoomID
RoomInput.TextColor3 = Config.Theme.Text
RoomInput.TextSize = 12
RoomInput.Font = Enum.Font.Gotham
RoomInput.TextXAlignment = Enum.TextXAlignment.Left
RoomInput.ClearTextOnFocus = false
RoomInput.Parent = RoomFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 14)
StatusLabel.Position = UDim2.new(0, 8, 0, 68)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● Đang kết nối..."
StatusLabel.TextColor3 = Config.Theme.Muted
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainWindow

-- Chat Container
local ChatContainer = Instance.new("ScrollingFrame")
ChatContainer.Name = "ChatContainer"
ChatContainer.Size = UDim2.new(1, -16, 1, -140)
ChatContainer.Position = UDim2.new(0, 8, 0, 84)
ChatContainer.BackgroundTransparency = 1
ChatContainer.BorderSizePixel = 0
ChatContainer.ScrollBarThickness = 4
ChatContainer.ScrollBarImageColor3 = Config.Theme.Muted
ChatContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatContainer.Parent = MainWindow

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 6)
ChatLayout.Parent = ChatContainer

local ChatPadding = Instance.new("UIPadding")
ChatPadding.PaddingTop = UDim.new(0, 8)
ChatPadding.PaddingBottom = UDim.new(0, 8)
ChatPadding.Parent = ChatContainer

-- Input Area
local InputFrame = Instance.new("Frame")
InputFrame.Name = "InputFrame"
InputFrame.Size = UDim2.new(1, -16, 0, 40)
InputFrame.Position = UDim2.new(0, 8, 1, -48)
InputFrame.BackgroundColor3 = Config.Theme.Card
InputFrame.BorderSizePixel = 0
InputFrame.Parent = MainWindow

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 10)
InputCorner.Parent = InputFrame

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -52, 1, 0)
InputBox.Position = UDim2.new(0, 10, 0, 0)
InputBox.BackgroundTransparency = 1
InputBox.Text = ""
InputBox.PlaceholderText = "Nhắn tin..."
InputBox.PlaceholderColor3 = Config.Theme.Muted
InputBox.TextColor3 = Config.Theme.Text
InputBox.TextSize = 13
InputBox.Font = Enum.Font.Gotham
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.ClearTextOnFocus = false
InputBox.MultiLine = false
InputBox.Parent = InputFrame

-- Send Button
local SendBtn = Instance.new("TextButton")
SendBtn.Name = "SendBtn"
SendBtn.Size = UDim2.new(0, 36, 0, 32)
SendBtn.Position = UDim2.new(1, -40, 0.5, -16)
SendBtn.BackgroundColor3 = Config.Theme.Accent
SendBtn.BorderSizePixel = 0
SendBtn.Text = "➤"
SendBtn.TextColor3 = Config.Theme.BG
SendBtn.TextSize = 16
SendBtn.Font = Enum.Font.GothamBold
SendBtn.Parent = InputFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendBtn

-- Toggle Button (khi minimize)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, Config.ToggleSize.X, 0, Config.ToggleSize.Y)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -Config.ToggleSize.Y/2)
ToggleBtn.BackgroundColor3 = Config.Theme.Accent
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "💬"
ToggleBtn.TextSize = 20
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Config.Theme.Border
ToggleStroke.Thickness = 1
ToggleStroke.Parent = ToggleBtn

-- === DRAG FUNCTIONALITY ===
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Drag Toggle Button
local toggleDragging = false
local toggleDragStart, toggleStartPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                toggleDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        ToggleBtn.Position = UDim2.new(
            toggleStartPos.X.Scale,
            toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale,
            toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

-- === MINIMIZE/TOGGLE ===
local function minimizeWindow()
    MainWindow.Visible = false
    ToggleBtn.Visible = true
    ToggleBtn.Position = UDim2.new(
        MainWindow.Position.X.Scale,
        MainWindow.Position.X.Offset,
        MainWindow.Position.Y.Scale,
        MainWindow.Position.Y.Offset
    )
end

local function restoreWindow()
    MainWindow.Visible = true
    ToggleBtn.Visible = false
end

MinimizeBtn.MouseButton1Click:Connect(minimizeWindow)
ToggleBtn.MouseButton1Click:Connect(restoreWindow)

-- Button hover effects
MinimizeBtn.MouseEnter:Connect(function() MinimizeBtn.BackgroundColor3 = Config.Theme.Card end)
MinimizeBtn.MouseLeave:Connect(function() MinimizeBtn.BackgroundColor3 = Config.Theme.BG end)
SendBtn.MouseEnter:Connect(function() SendBtn.BackgroundColor3 = Color3.fromRGB(216, 132, 90) end)
SendBtn.MouseLeave:Connect(function() SendBtn.BackgroundColor3 = Config.Theme.Accent end)

-- === CHAT FUNCTIONALITY ===
local function addMessage(sender, content, isMe)
    if #Config.Messages >= Config.MaxMessages then
        table.remove(Config.Messages, 1)
        local firstChild = ChatContainer:FindFirstChildOfClass("Frame")
        if firstChild then firstChild:Destroy() end
    end
    
    table.insert(Config.Messages, {sender = sender, content = content, time = os.time()})
    
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, -8, 0, 0)
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.BackgroundTransparency = 1
    msgFrame.BorderSizePixel = 0
    msgFrame.LayoutOrder = #Config.Messages
    msgFrame.Parent = ChatContainer
    
    local bubble = Instance.new("Frame")
    bubble.AutomaticSize = Enum.AutomaticSize.XY
    bubble.BackgroundColor3 = isMe and Config.Theme.MyBubble or Config.Theme.OtherBubble
    bubble.BorderSizePixel = 0
    
    if isMe then
        bubble.AnchorPoint = Vector2.new(1, 0)
        bubble.Position = UDim2.new(1, 0, 0, 0)
    else
        bubble.Position = UDim2.new(0, 0, 0, 0)
    end
    
    bubble.Parent = msgFrame
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(0, 12)
    bubbleCorner.Parent = bubble
    
    local bubblePadding = Instance.new("UIPadding")
    bubblePadding.PaddingLeft = UDim.new(0, 10)
    bubblePadding.PaddingRight = UDim.new(0, 10)
    bubblePadding.PaddingTop = UDim.new(0, 6)
    bubblePadding.PaddingBottom = UDim.new(0, 6)
    bubblePadding.Parent = bubble
    
    if not isMe then
        local senderLabel = Instance.new("TextLabel")
        senderLabel.Size = UDim2.new(1, 0, 0, 12)
        senderLabel.BackgroundTransparency = 1
        senderLabel.Text = sender
        senderLabel.TextColor3 = Config.Theme.Accent
        senderLabel.TextSize = 10
        senderLabel.Font = Enum.Font.GothamBold
        senderLabel.TextXAlignment = Enum.TextXAlignment.Left
        senderLabel.Parent = bubble
        
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(0, math.min(220, #content * 8 + 20), 0, 0)
        contentLabel.Position = UDim2.new(0, 0, 0, 14)
        contentLabel.AutomaticSize = Enum.AutomaticSize.Y
        contentLabel.BackgroundTransparency = 1
        contentLabel.Text = content
        contentLabel.TextColor3 = Config.Theme.Text
        contentLabel.TextSize = 12
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.TextWrapped = true
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.Parent = bubble
    else
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(0, math.min(220, #content * 8 + 20), 0, 0)
        contentLabel.AutomaticSize = Enum.AutomaticSize.Y
        contentLabel.BackgroundTransparency = 1
        contentLabel.Text = content
        contentLabel.TextColor3 = Color3.fromRGB(32, 32, 36)
        contentLabel.TextSize = 12
        contentLabel.Font = Enum.Font.GothamBold
        contentLabel.TextWrapped = true
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.Parent = bubble
    end
    
    task.wait()
    ChatContainer.CanvasSize = UDim2.new(0, 0, 0, ChatLayout.AbsoluteContentSize.Y + 16)
    ChatContainer.CanvasPosition = Vector2.new(0, ChatLayout.AbsoluteContentSize.Y)
end

-- === MESSAGING SERVICE ===
local subscribeSuccess = false

local function subscribeToRoom()
    pcall(function()
        MessagingService:SubscribeAsync("DeltaChat_" .. Config.RoomID, function(message)
            local data = HttpService:JSONDecode(message.Data)
            if data.sender ~= Config.UserName then
                addMessage(data.sender, data.content, false)
            end
        end)
        subscribeSuccess = true
        StatusLabel.Text = "● Đã kết nối (Server Chat)"
        StatusLabel.TextColor3 = Color3.fromRGB(13, 150, 105)
    end)
end

local function sendMessageServer(content)
    pcall(function()
        local data = HttpService:JSONEncode({
            sender = Config.UserName,
            content = content,
            time = os.time()
        })
        MessagingService:PublishAsync("DeltaChat_" .. Config.RoomID, data)
    end)
end

-- === SEND MESSAGE ===
local function sendMessage()
    local content = InputBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if #content == 0 then return end
    if #content > 200 then
        addMessage("System", "Tin nhắn quá dài (max 200 ký tự)", false)
        return
    end
    
    InputBox.Text = ""
    addMessage(Config.UserName, content, true)
    
    if subscribeSuccess then
        sendMessageServer(content)
    end
end

SendBtn.MouseButton1Click:Connect(sendMessage)

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendMessage()
    end
end)

-- === ROOM ID CHANGE ===
RoomInput.FocusLost:Connect(function()
    local newRoom = RoomInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if #newRoom > 0 and newRoom ~= Config.RoomID then
        Config.RoomID = newRoom
        StatusLabel.Text = "● Đang kết nối..."
        StatusLabel.TextColor3 = Config.Theme.Muted
        subscribeToRoom()
    end
end)

-- === INIT ===
subscribeToRoom()

-- Welcome messages
addMessage("System", "Chào mừng đến Delta Chat!", false)
task.wait(0.2)
addMessage("System", "Nhập cùng Room ID để chat với bạn bè", false)
task.wait(0.3)
addMessage("System", "Cả 2 bên cần cùng server & cùng Room ID", false)

print("[Delta Chat] Script loaded!")
