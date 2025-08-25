local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


local CONTAINER_PATH = "Workspace/VFX"
local CONTAINER_TYPES = {
    "Obsidian Crate", 
    "Golden Crate",
    "Mega Golden Crate",
    "Mega Wooden Crate", 
    "Mega Steel Crate",
    "Mega Obsidian Crate",
    "Steel Crate",
    "Wooden Crate"
}
local SEARCH_INTERVAL = 0
local TELEPORT_INTERVAL = 0.1
local PROMPT_DELAY = 0.1
local TOGGLE_KEY = Enum.KeyCode.H


local GLOW_COLORS = {
    ["Obsidian Crate"] = Color3.fromRGB(100, 50, 200),      
    ["Golden Crate"] = Color3.fromRGB(255, 215, 0),        
    ["Mega Golden Crate"] = Color3.fromRGB(255, 200, 0),    
    ["Mega Wooden Crate"] = Color3.fromRGB(150, 75, 0),     
    ["Mega Steel Crate"] = Color3.fromRGB(150, 150, 150),   
    ["Mega Obsidian Crate"] = Color3.fromRGB(70, 30, 150),  
    ["Steel Crate"] = Color3.fromRGB(180, 180, 180),        
    ["Wooden Crate"] = Color3.fromRGB(120, 60, 0)           
}


local CONTAINER_PRIORITY = {
    ["Mega Obsidian Crate"] = 100,
    ["Mega Golden Crate"] = 90,
    ["Obsidian Crate"] = 80,
    ["Golden Crate"] = 70,
    ["Mega Steel Crate"] = 60,
    ["Mega Wooden Crate"] = 50,
    ["Steel Crate"] = 40,
    ["Wooden Crate"] = 30
}


local settings = {
    enabled = true,
    showNames = true,
    showIcons = true,
    pulseEffect = true,
    autoTeleport = false,
    autoPickup = false,
    teleportHeight = 3,
    priorityFarm = true  
}


local processedContainers = {}
local screenGui, controlPanel
local isTeleporting = false
local isPickingUp = false
local currentTarget = nil


local function createMainGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ContainerTrackerUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    return screenGui
end


local function createControlPanel()
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlPanel"
    controlFrame.Size = UDim2.new(0, 280, 0, 300)
    controlFrame.Position = UDim2.new(0, 10, 0, 10)
    controlFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    controlFrame.BackgroundTransparency = 0.1
    controlFrame.BorderSizePixel = 0
    controlFrame.Visible = true
    controlFrame.ZIndex = 100

    local authorLabel = Instance.new("TextLabel")
    authorLabel.Text = "by Didod00"
    authorLabel.Size = UDim2.new(1, -30, 0, 20)
    authorLabel.Position = UDim2.new(0, 15, 1, -25)
    authorLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Font = Enum.Font.GothamMedium
    authorLabel.TextSize = 11
    authorLabel.TextXAlignment = Enum.TextXAlignment.Right
    authorLabel.ZIndex = 101
    authorLabel.Parent = controlFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = controlFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 150)
    stroke.Thickness = 2
    stroke.Parent = controlFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = controlFrame

   
    local title = Instance.new("TextLabel")
    title.Text = "🎯 АВТО-ФАРМ КОНТЕЙНЕРОВ"
    title.Size = UDim2.new(1, -30, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 10)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = controlFrame

    
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.ZIndex = 101
    closeButton.Parent = controlFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Text = "ВКЛЮЧЕНО"
    toggleButton.Size = UDim2.new(1, -30, 0, 35)
    toggleButton.Position = UDim2.new(0, 15, 0, 45)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.ZIndex = 101
    toggleButton.Parent = controlFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleButton

    
    local teleportToggle = Instance.new("TextButton")
    teleportToggle.Text = "🚀 Авто-телепорт: ВЫКЛ"
    teleportToggle.Size = UDim2.new(1, -30, 0, 35)
    teleportToggle.Position = UDim2.new(0, 15, 0, 85)
    teleportToggle.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
    teleportToggle.TextColor3 = Color3.new(1, 1, 1)
    teleportToggle.Font = Enum.Font.GothamBold
    teleportToggle.TextSize = 12
    teleportToggle.ZIndex = 101
    teleportToggle.Parent = controlFrame
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 8)
    teleportCorner.Parent = teleportToggle

    
    local pickupToggle = Instance.new("TextButton")
    pickupToggle.Text = "⚡ Авто-подбор: ВЫКЛ"
    pickupToggle.Size = UDim2.new(1, -30, 0, 35)
    pickupToggle.Position = UDim2.new(0, 15, 0, 125)
    pickupToggle.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
    pickupToggle.TextColor3 = Color3.new(1, 1, 1)
    pickupToggle.Font = Enum.Font.GothamBold
    pickupToggle.TextSize = 12
    pickupToggle.ZIndex = 101
    pickupToggle.Parent = controlFrame
    
    local pickupCorner = Instance.new("UICorner")
    pickupCorner.CornerRadius = UDim.new(0, 8)
    pickupCorner.Parent = pickupToggle

    
    local priorityToggle = Instance.new("TextButton")
    priorityToggle.Text = "🎯 Приоритетный фарм: ВКЛ"
    priorityToggle.Size = UDim2.new(1, -30, 0, 35)
    priorityToggle.Position = UDim2.new(0, 15, 0, 165)
    priorityToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    priorityToggle.TextColor3 = Color3.new(1, 1, 1)
    priorityToggle.Font = Enum.Font.GothamBold
    priorityToggle.TextSize = 12
    priorityToggle.ZIndex = 101
    priorityToggle.Parent = controlFrame
    
    local priorityCorner = Instance.new("UICorner")
    priorityCorner.CornerRadius = UDim.new(0, 8)
    priorityCorner.Parent = priorityToggle

    
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Text = "Высота телепортации: " .. settings.teleportHeight .. " studs"
    heightLabel.Size = UDim2.new(1, -30, 0, 25)
    heightLabel.Position = UDim2.new(0, 15, 0, 205)
    heightLabel.TextColor3 = Color3.new(1, 1, 1)
    heightLabel.BackgroundTransparency = 1
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.TextSize = 12
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.ZIndex = 101
    heightLabel.Parent = controlFrame

    local heightSlider = Instance.new("Frame")
    heightSlider.Size = UDim2.new(1, -30, 0, 20)
    heightSlider.Position = UDim2.new(0, 15, 0, 230)
    heightSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    heightSlider.ZIndex = 101
    heightSlider.Parent = controlFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = heightSlider
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((settings.teleportHeight - 1) / 9, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    sliderFill.ZIndex = 102
    sliderFill.Parent = heightSlider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = sliderFill

    
    toggleButton.MouseButton1Click:Connect(function()
        settings.enabled = not settings.enabled
        toggleButton.Text = settings.enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО"
        toggleButton.BackgroundColor3 = settings.enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        updateAllMarkersVisibility()
    end)
    
    teleportToggle.MouseButton1Click:Connect(function()
        settings.autoTeleport = not settings.autoTeleport
        teleportToggle.Text = "🚀 Авто-телепорт: " .. (settings.autoTeleport and "ВКЛ" or "ВЫКЛ")
        teleportToggle.BackgroundColor3 = settings.autoTeleport and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 60, 60)
    end)
    
    pickupToggle.MouseButton1Click:Connect(function()
        settings.autoPickup = not settings.autoPickup
        pickupToggle.Text = "⚡ Авто-подбор: " .. (settings.autoPickup and "ВКЛ" or "ВЫКЛ")
        pickupToggle.BackgroundColor3 = settings.autoPickup and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 60, 60)
    end)
    
    priorityToggle.MouseButton1Click:Connect(function()
        settings.priorityFarm = not settings.priorityFarm
        priorityToggle.Text = "🎯 Приоритетный фарм: " .. (settings.priorityFarm and "ВКЛ" or "ВЫКЛ")
        priorityToggle.BackgroundColor3 = settings.priorityFarm and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 60, 60)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        controlFrame.Visible = false
    end)
    
    
    heightSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.Heartbeat:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = heightSlider.AbsolutePosition
                local sliderSize = heightSlider.AbsoluteSize
                
                local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                settings.teleportHeight = math.floor(1 + relativeX * 9)
                
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                heightLabel.Text = "Высота телепортации: " .. settings.teleportHeight .. " studs"
                
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    connection:Disconnect()
                end
            end)
        end
    end)

    return controlFrame
end


local function createContainerMarker(container)
    if processedContainers[container] then return end
    
    local containerName = container.Name
    local color = GLOW_COLORS[containerName] or Color3.new(1, 1, 1)
    
    local frame = Instance.new("Frame")
    frame.Name = containerName .. "_Marker"
    frame.Size = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Visible = settings.enabled
    frame.ZIndex = 5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 3
    stroke.Parent = frame

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.6, 0, 0.6, 0)
    icon.Position = UDim2.new(0.2, 0, 0.2, 0)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://7733960981"
    icon.ImageColor3 = Color3.new(1, 1, 1)
    icon.ZIndex = 6
    icon.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(2, 0, 0.4, 0)
    label.Position = UDim2.new(-0.5, 0, -0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = containerName
    label.TextColor3 = color
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Visible = settings.showNames
    label.ZIndex = 6
    label.Parent = frame
    
    frame.Parent = screenGui
    
    processedContainers[container] = {
        frame = frame,
        label = label,
        icon = icon,
        pulseTime = 0,
        container = container,
        pickedUp = false,
        priority = CONTAINER_PRIORITY[containerName] or 0
    }
    
    return processedContainers[container]
end


local function updateAllMarkersVisibility()
    for container, data in pairs(processedContainers) do
        if data.frame then
            data.frame.Visible = settings.enabled and not data.pickedUp
        end
    end
end


local function updateAllMarkersTextVisibility()
    for container, data in pairs(processedContainers) do
        if data.label then
            data.label.Visible = settings.showNames and not data.pickedUp
        end
    end
end


local function updateMarkerPosition(markerData, container)
    if markerData.pickedUp then
        markerData.frame.Visible = false
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local containerPos = container:GetPivot().Position
    local containerSize = container:GetExtentsSize()
    local screenPos, onScreen = camera:WorldToScreenPoint(containerPos + Vector3.new(0, containerSize.Y/2 + 3, 0))
    
    if onScreen then
        markerData.frame.Visible = settings.enabled
        markerData.frame.Position = UDim2.new(0, screenPos.X - markerData.frame.AbsoluteSize.X/2, 
                                             0, screenPos.Y - markerData.frame.AbsoluteSize.Y/2)
        
        local distance = (containerPos - camera.CFrame.Position).Magnitude
        local scale = math.clamp(120 / distance, 0.4, 2.0)
        markerData.frame.Size = UDim2.new(0, 50 * scale, 0, 50 * scale)
        
        
        if settings.pulseEffect then
            markerData.pulseTime = markerData.pulseTime + 0.03
            local pulse = 0.8 + 0.2 * math.sin(markerData.pulseTime * 2)
            markerData.icon.Size = UDim2.new(0.6 * pulse, 0, 0.6 * pulse, 0)
            markerData.icon.Position = UDim2.new(0.2 * (2 - pulse), 0, 0.2 * (2 - pulse), 0)
        end
    else
        markerData.frame.Visible = false
    end
end


local function findContainerProximityPrompt(container)

    local prompt = container:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        return prompt
    end
    
    
    for _, child in ipairs(container:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            return child
        end
    end
    
    return nil
end


local function activateProximityPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        
        prompt:InputHoldBegin()
        task.wait(0.1)
        prompt:InputHoldEnd()
        return true
    end
    return false
end


local function pickupContainer(container)
    if isPickingUp or not container:IsDescendantOf(workspace) then return false end
    
    isPickingUp = true
    
   
    task.wait(PROMPT_DELAY)
    
    
    local prompt = findContainerProximityPrompt(container)
    
    if prompt then
     
        local success = activateProximityPrompt(prompt)
        
        if success then
            print("✅ Активирован проксимити промпт: " .. container.Name)
            
           
            task.wait(1)
            
            
            if not container:IsDescendantOf(workspace) then
                
                if processedContainers[container] then
                    processedContainers[container].pickedUp = true
                    processedContainers[container].frame.Visible = false
                end
                print("✅ Контейнер подобран: " .. container.Name)
            else
                print("⚠️ Контейнер не был подобран: " .. container.Name)
            end
        else
            print("⚠️ Не удалось активировать промпт: " .. container.Name)
        end
    else
        print("⚠️ Проксимити промпт не найден: " .. container.Name)
    end
    
    isPickingUp = false
    return true
end


local function teleportToContainer(container)
    if isTeleporting or not container:IsDescendantOf(workspace) then return end
    
    isTeleporting = true
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        isTeleporting = false
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local containerPos = container:GetPivot().Position
    local containerSize = container:GetExtentsSize()
    
   
    local targetPosition = containerPos + Vector3.new(0, 2, 0)
    
   
    humanoidRootPart.CFrame = CFrame.new(targetPosition)
    
    print("🚀 Телепортирован к контейнеру: " .. container.Name)
    
  
    if settings.autoPickup then
        task.wait(0.3)
        pickupContainer(container)
    end
    
    task.wait(TELEPORT_INTERVAL)
    isTeleporting = false
end


local function findBestContainer()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local playerPos = character.HumanoidRootPart.Position
    local bestContainer = nil
    local bestPriority = -1
    local bestDistance = math.huge
    
    for container, markerData in pairs(processedContainers) do
        if container:IsDescendantOf(workspace) and not markerData.pickedUp then
            local containerPos = container:GetPivot().Position
            local distance = (playerPos - containerPos).Magnitude
            local priority = markerData.priority
            
            if settings.priorityFarm then
              
                if priority > bestPriority or (priority == bestPriority and distance < bestDistance) then
                    bestPriority = priority
                    bestDistance = distance
                    bestContainer = container
                end
            else
              
                if distance < bestDistance then
                    bestDistance = distance
                    bestContainer = container
                end
            end
        end
    end
    
    return bestContainer, bestDistance
end


local function autoTeleportAndPickupLoop()
    while true do
        task.wait(1)
        
        if (settings.autoTeleport or settings.autoPickup) and settings.enabled and not isTeleporting then
            local bestContainer, distance = findBestContainer()
            
            if bestContainer then
                currentTarget = bestContainer
                
                
                if settings.autoTeleport and distance > 8 then
                    teleportToContainer(bestContainer)
                
                elseif settings.autoPickup and distance <= 10 then
                    pickupContainer(bestContainer)
                end
            end
        end
    end
end


local function trackContainers()
    while true do
        task.wait(SEARCH_INTERVAL)
        if not settings.enabled then continue end
        
        local containerFolder = workspace:FindFirstChild("VFX")
        if not containerFolder then
            warn("Папка VFX не найдена!")
            task.wait(5)
            continue
        end
        
        
        for _, containerName in ipairs(CONTAINER_TYPES) do
            local container = containerFolder:FindFirstChild(containerName)
            if container and container:IsA("Model") then
                local markerData = processedContainers[container] or createContainerMarker(container)
                if markerData then
                    updateMarkerPosition(markerData, container)
                end
            end
        end
        
       
        for container, markerData in pairs(processedContainers) do
            if not container:IsDescendantOf(workspace) then
                markerData.frame:Destroy()
                processedContainers[container] = nil
                
                if currentTarget == container then
                    currentTarget = nil
                end
            end
        end
    end
end


local function initialize()
    while not workspace:FindFirstChild("VFX") do
        warn("Ожидаю папку VFX...")
        task.wait(3)
    end
    
    screenGui = createMainGUI()
    controlPanel = createControlPanel()
    controlPanel.Parent = screenGui
    
    coroutine.wrap(trackContainers)()
    coroutine.wrap(autoTeleportAndPickupLoop)()
    
    print("✅ Система авто-фарма запущена!")
    print("🎯 Отслеживается " .. #CONTAINER_TYPES .. " типов контейнеров")
    print("🚀 Нажмите H для переключения интерфейса")
    print("⚡ Приоритетный фарм: Mega контейнеры > Редкие > Обычные")
end


UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == TOGGLE_KEY and controlPanel then
        controlPanel.Visible = not controlPanel.Visible
    elseif input.KeyCode == Enum.KeyCode.J then
        settings.enabled = not settings.enabled
        updateAllMarkersVisibility()
        
        if controlPanel then
            local toggleButton = controlPanel:FindFirstChild("TextButton")
            if toggleButton then
                toggleButton.Text = settings.enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО"
                toggleButton.BackgroundColor3 = settings.enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            end
        end
    elseif input.KeyCode == Enum.KeyCode.T then
     
        local bestContainer = findBestContainer()
        if bestContainer then
            teleportToContainer(bestContainer)
        end
    elseif input.KeyCode == Enum.KeyCode.E then
       
        local bestContainer = findBestContainer()
        if bestContainer then
            pickupContainer(bestContainer)
        end
    end
end)


coroutine.wrap(initialize)()
