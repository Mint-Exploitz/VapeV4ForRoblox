--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/QP-Offcial/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end
local run = function(func)
	func()
end
local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local lightingService = cloneref(game:GetService('Lighting'))
local marketplaceService = cloneref(game:GetService('MarketplaceService'))
local teleportService = cloneref(game:GetService('TeleportService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local groupService = cloneref(game:GetService('GroupService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local coreGui = cloneref(game:GetService('CoreGui'))

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local vape = shared.vape
local tween = vape.Libraries.tween
local targetinfo = vape.Libraries.targetinfo
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local activeTweens = {}
local activeAnimationTrack = nil
local activeModel = nil
local emoteActive = false
 
local function spinParts(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "Middle" or part.Name == "Outer") then
            local tweenInfo, goal
            if part.Name == "Middle" then
                tweenInfo = TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, -360, 0) }
            elseif part.Name == "Outer" then
                tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, 360, 0) }
            end
 
            local tween = tweenService:Create(part, tweenInfo, goal)
            tween:Play()
            table.insert(activeTweens, tween)
        end
    end
end
 
local function placeModelUnderLeg()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
 
    if humanoidRootPart then
        local assetsFolder = replicatedStorage:FindFirstChild("Assets")
        if assetsFolder then
            local effectsFolder = assetsFolder:FindFirstChild("Effects")
            if effectsFolder then
                local modelTemplate = effectsFolder:FindFirstChild("NightmareEmote")
                if modelTemplate and modelTemplate:IsA("Model") then
                    local clonedModel = modelTemplate:Clone()
                    clonedModel.Parent = workspace
 
                    if clonedModel.PrimaryPart then
                        clonedModel:SetPrimaryPartCFrame(humanoidRootPart.CFrame - Vector3.new(0, 3, 0))
                    else
                        warn("PrimaryPart not set for NightmareEmote model!")
                        return
                    end
 
                    spinParts(clonedModel)
                    activeModel = clonedModel
                else
                    warn("NightmareEmote model not found or is not a valid model!")
                end
            else
                warn("Effects folder not found in Assets!")
            end
        else
            warn("Assets folder not found in ReplicatedStorage!")
        end
    else
        warn("HumanoidRootPart not found in character!")
    end
end
 
local function playAnimation(animationId)
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        activeAnimationTrack = animator:LoadAnimation(animation)
        activeAnimationTrack:Play()
    else
        warn("Humanoid not found in character!")
    end
end
 
local function stopEffects()
    for _, tween in ipairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
 
    if activeAnimationTrack then
        activeAnimationTrack:Stop()
        activeAnimationTrack = nil
    end
 
    if activeModel then
        activeModel:Destroy()
        activeModel = nil
    end
 
    emoteActive = false
end
 
local function monitorWalking()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        humanoid.Running:Connect(function(speed)
            if speed > 0 and emoteActive then
                stopEffects()
            end
        end)
    else
        warn("Humanoid not found in character!")
    end
end
 
local function activateNightmareEmote()
    if emoteActive then
        return
    end
 
    emoteActive = true
    local success, err = pcall(function()
        monitorWalking()
        placeModelUnderLeg()
        playAnimation("rbxassetid://9191822700")
    end)
 
    if not success then
        warn("Error occurred: " .. tostring(err))
        emoteActive = false
    end
end

run(function()
    local InfiniteJump
    local Velocity
    InfiniteJump = vape.Categories.Modules:CreateModule({
        Name = "InfiniteJump",
        Function = function(callback)
            if callback then
                local UserInputService = game:GetService("UserInputService")
                local player = playersService.LocalPlayer
                local function setupInfiniteJump()
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                    InfiniteJump:Clean(UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
                            while UserInputService:IsKeyDown(Enum.KeyCode.Space) do
                                humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, Velocity.Value, humanoidRootPart.Velocity.Z)
                                wait()
                            end
                        end
                    end))
					if UserInputService.TouchEnabled then
						local Jumping = false
						local JumpButton: ImageButton = lplr.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
						
						InfiniteJump:Clean(JumpButton.MouseButton1Down:Connect(function()
							Jumping = true
						end))

						InfiniteJump:Clean(JumpButton.MouseButton1Up:Connect(function()
							Jumping = false
						end))

						InfiniteJump:Clean(runService.RenderStepped:Connect(function()
							if Jumping then
								humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, Velocity.Value, humanoidRootPart.Velocity.Z)
							end
						end))
					end
                end
                player.CharacterAdded:Connect(setupInfiniteJump)
                if player.Character then
                    setupInfiniteJump()
                end
            end
        end,
        Tooltip = "Allows infinite jumping"
    })
    Velocity = InfiniteJump:CreateSlider({
        Name = 'Velocity',
        Min = 50,
        Max = 300,
        Default = 50
    })

    local BedTP
    BedTP = vape.Categories.Modules:CreateModule({
        Name = "BedTP",
        Description = "Teleports to enemy beds",
        Function = function(callback)
            if callback then
                BedTP:Toggle(false)
                local collection = game:GetService('CollectionService') :: CollectionService;
                local lplr = playersService.LocalPlayer;
                local tween = game:GetService('TweenService') :: TweenService

                local isshield = function(obj: Model)
                    return obj:GetAttribute('BedShieldEndTime') and obj:GetAttribute('BedShieldEndTime') > workspace:GetServerTimeNow() 
                end
                local getbed = function()
                    for i: number, v: Model? in collection:GetTagged('bed') do
                        if not isshield(v) and v.Bed.BrickColor ~= lplr.TeamColor then
                            return v;
                        end;
                    end;
                end;
                
                local bed = getbed();
                assert(bed, 'lmao');
                pcall(function()
                    lplr.Character.Humanoid.Health = 0
                end)
                local con;
                con = lplr.CharacterAdded:Connect(function(v)
                    con:Disconnect();
                    task.wait(0.2)
                    tween:Create(v.PrimaryPart, TweenInfo.new(1.35), {CFrame = bed.Bed.CFrame + Vector3.new(0, 10, 0)}):Play();
                end);
            end
        end
    })

    local PlayerTP
    PlayerTP = vape.Categories.Modules:CreateModule({
        Name = "PlayerTP",
        Description = "Teleports you to the nearest player",
        Function = function(callback)
            if callback then
                PlayerTP:Toggle(false)
                local Players = game:GetService("Players")
                local TweenService = game:GetService("TweenService")
                local LocalPlayer = playersService.LocalPlayer
                
                local getClosestEnemy = function()
                    local closestPlayer = nil
                    local closestDistance = math.huge
                
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.TeamColor ~= LocalPlayer.TeamColor and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                
                    return closestPlayer
                end
                
                local targetPlayer = getClosestEnemy()
                assert(targetPlayer, "No enemy players found!")
                
                pcall(function()
                    LocalPlayer.Character.Humanoid.Health = 0
                end)
                
                local connection
                connection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
                    connection:Disconnect()
                    task.wait(0.2)
                
                    local targetPosition = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                    TweenService:Create(newCharacter.PrimaryPart, TweenInfo.new(0.75), {CFrame = targetPosition}):Play()
                end)
            end
        end
    })
end)

run(function()
    local NightmareEventButton
    NightmareEventButton = vape.Categories.Modules:CreateModule({
        Name = "Nightmare Emote",
        Description = "Play Nightmare Emote",
        Function = function(callback)
            if callback then
                NightmareEventButton:Toggle(false)
                activateNightmareEmote()
            end
        end
    })

    local pack1
	local packassetids = {
		['1024x Pack'] = 'rbxassetid://14078540433',
		['CottanCandy256x'] = 'rbxassetid://14161283331',
		['512x Pack'] = 'rbxassetid://14224565815',
		['Beloved E-Girl Pack'] = 'rbxassetid://14126814481',
		['GLIZZZYYYYY'] = 'rbxassetid://13804645310',
		['RandomPack1'] = 'rbxassetid://13783192680',
		['RandomPack2'] = 'rbxassetid://13801616054',
		['RandomPack3'] = '',
		['RandomPack4'] = 'rbxassetid://13801509384',
		['RandomPack5'] = 'rbxassetid://13802020264',
		['RandomPack6'] = 'rbxassetid://13780890894',
		['RandomPack7'] = 'rbxassetid://14033898270',
		['DemonSlayer Pack'] = 'rbxassetid://14241215869',
		['Exhibition Pack'] = 'rbxassetid://14060102755',
		['Vibe Pack'] = 'rbxassetid://14282106674',
		['MainPack'] = 'rbxassetid://79898012794679'
	}
    local TexturePacks 
	TexturePacks = vape.Categories.Modules:CreateModule({
        Name = 'TexturePacks',
        Tooltip = 'Gives you a cool unique textures for tools.',
        Function = function(call)
            if call then
				local import = game:GetObjects(packassetids[pack1.Value])[1]
				import.Parent = replicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
				}
				for i,v in {'Wood', 'Diamond', 'Emerald', 'Stone', 'Iron', 'Gold'} do
					if import:FindFirstChild(`{v}_Pickaxe`) then
						table.insert(index, {
							name = `{v:lower()}_pickaxe`,
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import[`{v}_Pickaxe`],
						})
					end
					if import:FindFirstChild(v) then
						table.insert(index, {
							name = `{v:lower()}`,
							offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(table.find({'Emerald', 'Diamond'}, v) and 90 or -90)),
							model = import[`{v}`],
						})
					end
				end
				TexturePacks:Clean(workspace.Camera.Viewmodel.ChildAdded:Connect(function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = lplr.Character:WaitForChild(tool.Name)
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end            
							end            
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(0.6,0,-.9)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end))
            end
        end
    })
	local list = {}
	for i,v in packassetids do
		table.insert(list, i)
	end
    pack1 = TexturePacks:CreateDropdown({
        Name = 'Pack',
        List = list,
		Function = function()
			if TexturePacks.Enabled then
				TexturePacks:Toggle()
				TexturePacks:Toggle()
			end
		end
    })
end)

run(function()
    local Skybox
    GameThemeV2 = vape.Categories.Modules:CreateModule({
        Name = 'GameThemeV2',
        Tooltip = '',
        Function = function(call)
            if call then
                if Skybox.Value == "NebulaSky" then
					local Vignette = true

					local Lighting = game:GetService("Lighting")
					local ColorCor = Instance.new("ColorCorrectionEffect")
					local Sky = Instance.new("Sky")
					local Atm = Instance.new("Atmosphere")
					
					for i, v in pairs(Lighting:GetChildren()) do
						if v then
							v:Destroy()
						end
					end
					
					ColorCor.Parent = Lighting
					Sky.Parent = Lighting
					Atm.Parent = Lighting
					
					if Vignette == true then
						local Gui = Instance.new("ScreenGui")
						Gui.Parent = game:GetService("StarterGui")
						Gui.IgnoreGuiInset = true
					
						local ShadowFrame = Instance.new("ImageLabel")
						ShadowFrame.Parent = Gui
						ShadowFrame.AnchorPoint = Vector2.new(0, 1)
						ShadowFrame.Position = UDim2.new(0, 0, 0, 0)
						ShadowFrame.Size = UDim2.new(0, 0, 0, 0)
						ShadowFrame.BackgroundTransparency = 1
						ShadowFrame.Image = ""
						ShadowFrame.ImageTransparency = 1
						ShadowFrame.ZIndex = 0
					end
					
					ColorCor.Brightness = 0
					ColorCor.Contrast = 0.5
					ColorCor.Saturation = -0.3
					ColorCor.TintColor = Color3.fromRGB(255, 235, 203)
					
					Sky.SkyboxBk = "rbxassetid://13581437029"
					Sky.SkyboxDn = "rbxassetid://13581439832"
					Sky.SkyboxFt = "rbxassetid://13581447312"
					Sky.SkyboxLf = "rbxassetid://13581443463"
					Sky.SkyboxRt = "rbxassetid://13581452875"
					Sky.SkyboxUp = "rbxassetid://13581450222"
					Sky.SunAngularSize = 0
					
					Lighting.Ambient = Color3.fromRGB(2, 2, 2)
					Lighting.Brightness = 1
					Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
					Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
					Lighting.EnvironmentDiffuseScale = 0.2
					Lighting.EnvironmentSpecularScale = 0.2
					Lighting.GlobalShadows = true
					Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
					Lighting.ShadowSoftness = 0.2
					Lighting.ClockTime = 8
					Lighting.GeographicLatitude = 45
					Lighting.ExposureCompensation = 0.5
					
					Atm.Density = 0.364
					Atm.Offset = 0.556
					Atm.Color = Color3.fromRGB(172, 120, 186)
					Atm.Decay = Color3.fromRGB(155, 212, 255)
					Atm.Glare = 0.36
					Atm.Haze = 1.72					
                elseif Skybox.Value == "PinkMountainSky" then
					game.Lighting.Sky.SkyboxBk = "http://www.roblox.com/asset/?id=160188495"
					game.Lighting.Sky.SkyboxDn = "http://www.roblox.com/asset/?id=160188614"
					game.Lighting.Sky.SkyboxFt = "http://www.roblox.com/asset/?id=160188609"
					game.Lighting.Sky.SkyboxLf = "http://www.roblox.com/asset/?id=160188589"
					game.Lighting.Sky.SkyboxRt = "http://www.roblox.com/asset/?id=160188597"
					game.Lighting.Sky.SkyboxUp = "http://www.roblox.com/asset/?id=160188588"
				elseif Skybox.Value == "PurpleSky" then
					game.Lighting.Sky.SkyboxBk = "http://www.roblox.com/asset/?id=570557514"
					game.Lighting.Sky.SkyboxDn = "http://www.roblox.com/asset/?id=570557775"
					game.Lighting.Sky.SkyboxFt = "http://www.roblox.com/asset/?id=570557559"
					game.Lighting.Sky.SkyboxLf = "http://www.roblox.com/asset/?id=570557620"
					game.Lighting.Sky.SkyboxRt = "http://www.roblox.com/asset/?id=570557672"
					game.Lighting.Sky.SkyboxUp = "http://www.roblox.com/asset/?id=570557727"
					game.Lighting.ColorCorrectionEffect.Saturation = 0.7
					game.Lighting.ColorCorrectionEffect.Brightness = -0.02					
                elseif Skybox.Value == "CitySky" then

					local Vignette = true

					local Lighting = game:GetService("Lighting")
					local ColorCor = Instance.new("ColorCorrectionEffect")
					local Sky = Instance.new("Sky")
					local Atm = Instance.new("Atmosphere")

					game.Lighting.Sky.SkyboxBk = "rbxassetid://11263062161"
					game.Lighting.Sky.SkyboxDn = "rbxassetid://11263065295"
					game.Lighting.Sky.SkyboxFt = "rbxassetid://11263066644"
					game.Lighting.Sky.SkyboxLf = "rbxassetid://11263068413"
					game.Lighting.Sky.SkyboxRt = "rbxassetid://11263069782"
					game.Lighting.Sky.SkyboxUp = "rbxassetid://11263070890"

					Atm.Density = 0.364
					Atm.Offset = 0.556
					Atm.Color = Color3.fromRGB(172, 120, 186)
					Atm.Decay = Color3.fromRGB(155, 212, 255)
					Atm.Glare = 0.36
					Atm.Haze = 1.72		
                elseif Skybox.Value == "PinkSky" then
					game.Lighting.Sky.SkyboxBk = "http://www.roblox.com/asset/?id=271042516"
					game.Lighting.Sky.SkyboxDn = "http://www.roblox.com/asset/?id=271077243"
					game.Lighting.Sky.SkyboxFt = "http://www.roblox.com/asset/?id=271042556"
					game.Lighting.Sky.SkyboxLf = "http://www.roblox.com/asset/?id=271042310"
					game.Lighting.Sky.SkyboxRt = "http://www.roblox.com/asset/?id=271042467"
					game.Lighting.Sky.SkyboxUp = "http://www.roblox.com/asset/?id=271077958"
                elseif Skybox.Value == "EgirlSky" then
					game.Lighting.Sky.SkyboxBk = "rbxassetid://2128458653"
					game.Lighting.Sky.SkyboxDn = "rbxassetid://2128462480"
					game.Lighting.Sky.SkyboxFt = "rbxassetid://2128458653"
					game.Lighting.Sky.SkyboxLf = "rbxassetid://2128462027"
					game.Lighting.Sky.SkyboxRt = "rbxassetid://2128462027"
					game.Lighting.Sky.SkyboxUp = "rbxassetid://2128462236"
					game.Lighting.sky.SunAngularSize = 4
					game.Lighting.sky.MoonTextureId = "rbxassetid://8139665943"
					game.Lighting.sky.MoonAngularSize = 11
					lightingService.Atmosphere.Color = Color3.fromRGB(255, 214, 172)
					lightingService.Atmosphere.Decay = Color3.fromRGB(255, 202, 175)
                elseif Skybox.Value == "SpaceSky" then
					game.Lighting.Sky.SkyboxBk = "rbxassetid://1735468027"
					game.Lighting.Sky.SkyboxDn = "rbxassetid://1735500192"
					game.Lighting.Sky.SkyboxFt = "rbxassetid://1735467260"
					game.Lighting.Sky.SkyboxLf = "rbxassetid://1735467682"
					game.Lighting.Sky.SkyboxRt = "rbxassetid://1735466772"
					game.Lighting.Sky.SkyboxUp = "rbxassetid://1735500898"
				elseif Skybox.Value == "WhiteMountains" then 
					local Vignette = true
					local Lighting = game:GetService("Lighting")
					local ColorCor = Instance.new("ColorCorrectionEffect")
					local SunRays = Instance.new("SunRaysEffect")
					local Sky = Instance.new("Sky")
					local Atm = Instance.new("Atmosphere")
					game.Lighting.Sky.SkyboxBk = "http://www.roblox.com/asset/?id=14365017479"
					game.Lighting.Sky.SkyboxDn = "http://www.roblox.com/asset/?id=14365021997"
					game.Lighting.Sky.SkyboxFt = "http://www.roblox.com/asset/?id=14365016611"
					game.Lighting.Sky.SkyboxLf = "http://www.roblox.com/asset/?id=14365016884"
					game.Lighting.Sky.SkyboxRt = "http://www.roblox.com/asset/?id=14365016261"
					game.Lighting.Sky.SkyboxUp = "http://www.roblox.com/asset/?id=14365017884"
					

					Lighting.Ambient = Color3.fromRGB(2,2,2)
					Lighting.Brightness = 0.3
					Lighting.EnvironmentDiffuseScale = 0.2
					Lighting.EnvironmentSpecularScale = 0.2
					Lighting.GlobalShadows = true
					Lighting.ShadowSoftness = 0.2
					Lighting.ClockTime = 15
					Lighting.GeographicLatitude = 45
					Lighting.ExposureCompensation = 0.5
					Atm.Density = 0.364
					Atm.Offset = 0.556
					Atm.Glare = 0.36
					Atm.Haze = 1.72
                elseif Skybox.Value == "Infinite" then
					game.Lighting.Sky.SkyboxBk = "rbxassetid://14358449723"
					game.Lighting.Sky.SkyboxDn = "rbxassetid://14358455642"
					game.Lighting.Sky.SkyboxFt = "rbxassetid://14358452362"
					game.Lighting.Sky.SkyboxLf = "rbxassetid://14358784700"
					game.Lighting.Sky.SkyboxRt = "rbxassetid://14358454172"
					game.Lighting.Sky.SkyboxUp = "rbxassetid://14358455112"
                end
            end
        end
    })
    Skybox = GameThemeV2:CreateDropdown({
        Name = 'Themes',
        List = {'NebulaSky', "PinkMountainSky", 
		"CitySky", "PinkSky", 
		"EgirlSky", "SpaceSky", "WhiteMountains",
		"Infinite", "PurpleSky"},
        ["Function"] = function() end
    })
end)

run(function()
    local GodMode
	function IsAlive(plr)
		plr = plr or lplr
		if not plr.Character then return false end
		if not plr.Character:FindFirstChild("Head") then return false end
		if not plr.Character:FindFirstChild("Humanoid") then return false end
		if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
		return true
	end
	local Slowmode = {Value = 2}
	GodMode = vape.Categories.Modules:CreateModule({
		Name = "AntiHit",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait()
						local success, res = pcall(function()
							if (not vape.Modules.Fly.Enabled) and (not vape.Modules.InfiniteFly.Enabled) then
								for i, v in pairs(game:GetService("Players"):GetChildren()) do
									if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
										if v and v ~= lplr then
											local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
											if TargetDistance < 25 then
												if not lplr.Character:WaitForChild("HumanoidRootPart"):FindFirstChildOfClass("BodyVelocity") then
													if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
														lplr.Character.Archivable = true
				
														local Clone = lplr.Character:Clone()
														Clone.Parent = game.Workspace
														Clone.Head:ClearAllChildren()
														gameCamera.CameraSubject = Clone:FindFirstChild("Humanoid")
					
														for i,v in pairs(Clone:GetChildren()) do
															if string.lower(v.ClassName):find("part") and v.Name ~= "HumanoidRootPart" then
																v.Transparency = 1
															end
															if v:IsA("Accessory") then
																v:FindFirstChild("Handle").Transparency = 1
															end
														end
					
														lplr.Character:WaitForChild("HumanoidRootPart").CFrame = lplr.Character:WaitForChild("HumanoidRootPart").CFrame + Vector3.new(0,100000,0)
					
														GodMode:Clean(game:GetService("RunService").RenderStepped:Connect(function()
															if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
																Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character:WaitForChild("HumanoidRootPart").Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character:WaitForChild("HumanoidRootPart").Position.Z)
															end
														end))
					
														task.wait(Slowmode.Value/10)
														lplr.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(lplr.Character:WaitForChild("HumanoidRootPart").Velocity.X, -1, lplr.Character:WaitForChild("HumanoidRootPart").Velocity.Z)
														lplr.Character:WaitForChild("HumanoidRootPart").CFrame = Clone.HumanoidRootPart.CFrame
														gameCamera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
														Clone:Destroy()
														task.wait(0.15)
													end
												end
											end
										end
									end
								end
							end
						end)
						if not success then 
							print(res)
						end
					until (not GodMode.Enabled)
				end)
			end
		end
	})
	Slowmode = GodMode:CreateSlider({
		Name = "Slowmode",
		Function = function() end,
		Default = 2,
		Min = 1,
		Max = 25
	})
end)

run(function()
    local AdetundeExploit
    local AdetundeExploit_List

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

    AdetundeExploit = vape.Categories.Modules:CreateModule({
        Name = 'AdetundeExploit',
        Function = function(calling)
            if calling then 
                -- Check if in testing mode or equipped kit
                -- if tostring(store.queueType) == "training_room" or store.equippedKit == "adetunde" then
                --     AdetundeExploit["ToggleButton"](false) 
                --     current_upgrador = AdetundeExploit_List.Value
                task.spawn(function()
                    repeat
                        local returning_table = adetunde_remotes[current_upgrador]()
                        
                        if type(returning_table) == "table" then
                            local Speed = returning_table["speed"]
                            local Strength = returning_table["strength"]
                            local Shield = returning_table["shield"]

                            print("Speed: " .. tostring(Speed))
                            print("Strength: " .. tostring(Strength))
                            print("Shield: " .. tostring(Shield))
                            print("Current Upgrador: " .. tostring(current_upgrador))

                            if returning_table[string.lower(current_upgrador)] == 3 then
                                if Strength and Shield and Speed then
                                    if Strength == 3 or Speed == 3 or Shield == 3 then
                                        if (Strength == 3 and Speed == 2 and Shield == 2) or
                                           (Strength == 2 and Speed == 3 and Shield == 2) or
                                           (Strength == 2 and Speed == 2 and Shield == 3) then
                                            -- warningNotification("AdetundeExploit", "Fully upgraded everything possible!", 7)
                                            hasnt_upgraded_everything = false
                                        else
                                            local things = {}
                                            for i, v in pairs(adetunde_remotes) do
                                                table.insert(things, i)
                                            end
                                            for i, v in pairs(things) do
                                                if things[i] == current_upgrador then
                                                    table.remove(things, i)
                                                end
                                            end
                                            local random = things[math.random(1, #things)]
                                            current_upgrador = random
                                        end
                                    end
                                end
                            end
                        else
                            local things = {}
                            for i, v in pairs(adetunde_remotes) do
                                table.insert(things, i)
                            end
                            for i, v in pairs(things) do
                                if things[i] == current_upgrador then
                                    table.remove(things, i)
                                end
                            end
                            local random = things[math.random(1, #things)]
                            current_upgrador = random
                        end
                        task.wait(0.1)
                    until not AdetundeExploit.Enabled or not hasnt_upgraded_everything
                end)
                -- else
                --     AdetundeExploit["ToggleButton"](false)
                --     warningNotification("AdetundeExploit", "Kit required or you need to be in testing mode", 5)
                -- end
            end
        end
    })

    local real_list = {}
    for i, v in pairs(adetunde_remotes) do
        table.insert(real_list, i)
    end

    AdetundeExploit_List = AdetundeExploit:CreateDropdown({
        Name = 'Preferred Upgrade',
        List = real_list,
        Function = function() end,
        Default = "Shield"
    })
end)