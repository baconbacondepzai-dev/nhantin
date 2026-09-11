-- Delta Executor Mini Chat UI v2 (Head Message + Unread Badge + Drag)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global Unread Counter
local unreadCount = 0

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMiniChat"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame (UI Chat chính)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Title Bar (Thanh tiêu đề kéo thả)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.Text = "Delta Chat"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 13
TitleLabel.Parent = TitleBar

-- Minimize Button (Nút thu nhỏ)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -22, 0, 2)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TitleBar
local MiniCorner = Instance.new("UICorner", MinimizeBtn)
MiniCorner.CornerRadius = UDim.new(0, 4)

-- Chat Logs Area
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -12, 1, -65)
ScrollFrame.Position = UDim2.new(0, 6, 0, 30)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

-- Input Box
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -12, 0, 22)
InputBox.Position = UDim2.new(0, 6, 1, -26)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Nhập tin nhắn..."
InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
InputBox.Font = Enum.Font.SourceSans
InputBox.TextSize = 12
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.Parent = MainFrame
local InputCorner = Instance.new("UICorner", InputBox)
InputCorner.CornerRadius = UDim.new(0, 4)

-- Open Button (Nút mở UI bé khi thu nhỏ)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 28)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "Chat"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 12
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(0, 6)

-- Unread Badge (Nút đỏ hiện số tin nhắn chưa đọc)
local BadgeFrame = Instance.new("Frame")
BadgeFrame.Size = UDim2.new(0, 18, 0, 18)
BadgeFrame.Position = UDim2.new(1, -8, 0, -5)
BadgeFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
BadgeFrame.Visible = false
BadgeFrame.Parent = OpenBtn
local BadgeCorner = Instance.new("UICorner", BadgeFrame)
BadgeCorner.CornerRadius = UDim.new(1, 0)

local BadgeLabel = Instance.new("TextLabel")
BadgeLabel.Size = UDim2.new(1, 0, 1, 0)
BadgeLabel.BackgroundTransparency = 1
BadgeLabel.Text = "0"
BadgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BadgeLabel.Font = Enum.Font.SourceSansBold
BadgeLabel.TextSize = 11
BadgeLabel.Parent = BadgeFrame

-- Dragging Logic (Chức năng Kéo Thả UI)
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(MainFrame)
makeDraggable(OpenBtn)

-- Mini/Open UI Logic & Unread Counter Handling
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
    unreadCount = 0
    BadgeFrame.Visible = false
end)

-- Hiển thị bong bóng tin nhắn trên đầu nhân vật
local function showHeadMessage(senderName, text)
    local targetPlayer = Players:FindFirstChild(senderName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        
        -- Xóa gui cũ trên đầu nếu có
        local oldGui = head:FindFirstChild("DeltaHeadChat")
        if oldGui then oldGui:Destroy() end
        
        local billGui = Instance.new("BillboardGui")
        billGui.Name = "DeltaHeadChat"
        billGui.Size = UDim2.new(0, 180, 0, 40)
        billGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billGui.AlwaysOnTop = true
        billGui.Adornee = head
        billGui.Parent = head
        
        local msgBg = Instance.new("Frame")
        msgBg.Size = UDim2.new(1, 0, 1, 0)
        msgBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        msgBg.BackgroundTransparency = 0.2
        msgBg.Parent = billGui
        local msgCorner = Instance.new("UICorner", msgBg)
        msgCorner.CornerRadius = UDim.new(0, 6)
        
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -8, 1, -4)
        msgLabel.Position = UDim2.new(0, 4, 0, 2)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = text
        msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        msgLabel.Font = Enum.Font.SourceSansBold
        msgLabel.TextSize = 13
        msgLabel.TextWrapped = true
        msgLabel.Parent = msgBg
        
        task.delay(5, function()
            if billGui and billGui.Parent then
                billGui:Destroy()
            end
        end)
    end
end

-- Thêm Message vào UI
local function addMessage(sender, text)
    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, 0, 0, 0)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.TextColor3 = (sender == LocalPlayer.Name) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 220, 100)
    MsgLabel.Text = sender .. ": " .. text
    MsgLabel.Font = Enum.Font.SourceSans
    MsgLabel.TextSize = 12
    MsgLabel.TextWrapped = true
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.Parent = ScrollFrame
    
    MsgLabel.Size = UDim2.new(1, 0, 0, MsgLabel.TextBounds.Y)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset)

    -- Hiện tin nhắn trên đầu
    showHeadMessage(sender, text)

    -- Cập nhật tin nhắn bỏ lỡ nếu UI đang đóng
    if not MainFrame.Visible and sender ~= LocalPlayer.Name then
        unreadCount = unreadCount + 1
        BadgeLabel.Text = tostring(unreadCount)
        BadgeFrame.Visible = true
    end
end

-- Networking System (Kênh đồng bộ tin nhắn qua ReplicatedStorage)
local ChatFolder = game:GetService("ReplicatedStorage"):FindFirstChild("DeltaChatFolder")
if not ChatFolder then
    ChatFolder = Instance.new("Folder")
    ChatFolder.Name = "DeltaChatFolder"
    ChatFolder.Parent = game:GetService("ReplicatedStorage")
end

local ChatEvent = ChatFolder:FindFirstChild("DeltaChatEvent")
if not ChatEvent then
    ChatEvent = Instance.new("StringValue")
    ChatEvent.Name = "DeltaChatEvent"
    ChatEvent.Parent = ChatFolder
end

-- Lắng nghe tin nhắn mới từ những người khác
ChatEvent.Changed:Connect(function(val)
    if val ~= "" then
        local data = string.split(val, "||")
        if #data >= 2 then
            addMessage(data[1], data[2])
        end
    end
end)

-- Gửi tin nhắn khi gõ xong bấm Enter
InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and InputBox.Text ~= "" then
        local msg = InputBox.Text
        InputBox.Text = ""
        ChatEvent.Value = LocalPlayer.Name .. "||" .. msg .. "||" .. math.random(1, 100000)
    end
end)
