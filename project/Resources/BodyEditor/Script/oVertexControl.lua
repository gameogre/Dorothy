local CCMenuItem = require("CCMenuItem")
local CCSize = require("CCSize")
local CCDrawNode = require("CCDrawNode")
local oVec2 = require("oVec2")
local ccColor4 = require("ccColor4")
local CCMenu = require("CCMenu")
local CCDirector = require("CCDirector")
local CCLayer = require("CCLayer")
local oEditor = require("oEditor")
local CCTouch = require("CCTouch")
local oButton = require("oButton")
local ccColor3 = require("ccColor3")
local oScale = require("oScale")
local oEase = require("oEase")
local CCLabelTTF = require("CCLabelTTF")
local oListener = require("oListener")
local oRoutine = require("oRoutine")
local once = oRoutine.once
local cycle = oRoutine.cycle

local function oVertexControl()
	local winSize = CCDirector.winSize
	local vertSize = 40
	local halfSize = vertSize*0.5
	local vertices = nil
	local vertChanged = nil
	local selectedVert = nil
	
	local layer = CCLayer()
	layer.contentSize = CCSize.zero
	layer.visible = false

	local label = CCLabelTTF("","Arial",16)
	label.color = ccColor3(0x00ffff)
	layer:addChild(label)
	
	local function setLabelPos(target)
		local pos = target.position
		label.text = string.format("%.2f",pos.x)..","..string.format("%.2f",pos.y)
		label.texture.antiAlias = false
		pos = target.parent:convertToWorldSpace(pos)
		pos = layer:convertToNodeSpace(pos)
		local scale = oEditor.world.parent.scaleX
		scale = math.max(1,scale)
		label.scaleX = scale
		label.scaleY = scale
		label.position = oVec2(pos.x,pos.y+45*scale)
	end

	label.data = oListener("viewArea.toScale",function()
		label:schedule(once(function()
			cycle(0.5,function(dt)
				if selectedVert then
					setLabelPos(selectedVert)
				end
			end)
		end))
	end)

	local function itemTapped(eventType,item)
		if eventType == CCMenuItem.TapBegan then
			if selectedVert and item ~= selectedVert then
				selectedVert.opacity = 0.2
				selectedVert.selected = false
			end
			selectedVert = item
			setLabelPos(item)
			if item.opacity == 0.5 then
				item.selected = true
			else
				item.opacity = 0.5
			end
		elseif eventType == CCMenuItem.Tapped then
			item.selected = not item.selected
			selectedVert = item.selected and item or nil
			if not item.selected then label.text = "" end
			item.opacity = item.selected and 0.5 or 0.2
		end
	end
	local function oVertex(pos,index)
		local menuItem = CCMenuItem()
		menuItem:registerTapHandler(itemTapped)
		menuItem.contentSize = CCSize(vertSize,vertSize)
		local circle = CCDrawNode()
		circle:drawDot(oVec2.zero,halfSize,ccColor4(0xff00ffff))
		circle.position = oVec2(halfSize,halfSize)
		menuItem:addChild(circle)
		menuItem.position = pos
		menuItem.opacity = 0.2
		menuItem.index = index
		return menuItem
	end

	local menu = CCMenu(false)
	menu.items = nil
	menu.vs = nil
	menu.touchPriority = oEditor.touchPriorityEditControl+1
	menu.contentSize = CCSize.zero
	menu.transformTarget = oEditor.world
	menu.touchEnabled = false
	layer:addChild(menu)
	
	local function setVertices(vs)
		menu:removeAllChildrenWithCleanup()
		menu.vs = vs
		menu.items = {}
		for i = 1,#vs do
			local item = oVertex(vs[i],i)
			table.insert(menu.items,item)
			menu:addChild(item)
		end
	end
	
	local function addVertex(v)
		local item = oVertex(v,#(menu.items)+1)
		table.insert(menu.items,item)
		menu:addChild(item)
		table.insert(menu.vs,v)
		if vertChanged then
			vertChanged(menu.vs)
		end
		return item
	end
	
	local function removeVertex()
		if selectedVert then
			local index = selectedVert.index
			menu:removeChild(menu.children[index])
			table.remove(menu.items,index)
			for i = 1,#menu.items do
				menu.items[i].index = i
			end
			table.remove(menu.vs,index)
			selectedVert = nil
			if vertChanged then
				vertChanged(menu.vs)
			end
		end
	end

	local vertexToAdd = false
	local addButton = nil
	local totalDelta = oVec2.zero
	layer:registerTouchHandler(function(eventType, touch)
		if eventType == CCTouch.Began then
			if vertexToAdd then
				local pos = menu:convertToNodeSpace(touch.location)
				if oEditor.isFixed then 
					pos = oEditor:round(pos)
				end
				local item = addVertex(pos)
				setLabelPos(item)
				return true
			end
			totalDelta = oVec2.zero
		elseif eventType == CCTouch.Moved then
			if touch.delta ~= oVec2.zero and selectedVert then
				selectedVert.selected = false
				local delta = menu:convertToNodeSpace(touch.location) - menu:convertToNodeSpace(touch.preLocation)
				if oEditor.fixX then delta.x = 0 end
				if oEditor.fixY then delta.y = 0 end
				local pos = selectedVert.position
				if oEditor.isFixed then
					totalDelta = totalDelta + delta
					if totalDelta.x > 1 or totalDelta.x < -1 then
						local posX = pos.x+totalDelta.x
						pos.x = oEditor:round(posX)
						totalDelta.x = 0
					end
					if totalDelta.y > 1 or totalDelta.y < -1 then
						local posY = pos.y+totalDelta.y
						pos.y = oEditor:round(posY)
						totalDelta.y = 0
					end
				else
					pos = pos + delta
				end
				if pos ~= selectedVert.position then
					selectedVert.position = pos
					menu.vs[selectedVert.index] = pos
					setLabelPos(selectedVert)
					if vertChanged then
						vertChanged(menu.vs)
					end
				end
			end
		end
		return true
	end,false,oEditor.touchPriorityEditControl,false)
	
	local mask = CCLayer()
	mask.contentSize = CCSize.zero
	mask:registerTouchHandler(function() return selectedVert ~= nil end,false,oEditor.touchPriorityEditControl+2,true)
	layer:addChild(mask)
	
	local editMenu = CCMenu(false)
	editMenu.anchor = oVec2.zero
	editMenu.touchPriority = oEditor.touchPriorityEditControl
	editMenu.touchEnabled = false
	layer:addChild(editMenu)
	local removeButton = oButton("-",20,50,50,winSize.width-465,winSize.height-35,function()
		removeVertex()
		label.text = ""
	end)
	editMenu:addChild(removeButton)
	addButton = oButton("+",20,50,50,winSize.width-525,winSize.height-35,function(button)
		vertexToAdd = not vertexToAdd
		button.color = vertexToAdd and ccColor3(0xff0080) or ccColor3(0x00ffff)
	end)
	editMenu:addChild(addButton)
	
	layer.show = function(self,vs,pos,angle,callback)
		layer.touchEnabled = true
		mask.touchEnabled = true
		menu.touchEnabled = true
		editMenu.touchEnabled = true
		layer.visible = true
		menu.position = pos
		menu.rotation = angle
		vs = vs or {}
		label.text = ""
		selectedVert = nil
		vertexToAdd = false
		totalDelta = oVec2.zero
		addButton.color = ccColor3(0x00ffff)
		setVertices(vs)
		vertChanged = callback
		addButton:stopAllActions()
		addButton.scaleX = 0
		addButton.scaleY = 0
		addButton:runAction(oScale(0.5,1,1,oEase.OutBack))
		removeButton:stopAllActions()
		removeButton.scaleX = 0
		removeButton.scaleY = 0
		removeButton:runAction(oScale(0.5,1,1,oEase.OutBack))
	end
	layer.hide = function(self)
		if not layer.visible then return end
		vertChanged = nil
		selectedVert = nil
		menu.items = {}
		menu.vs = {}
		menu:removeAllChildrenWithCleanup()
		layer.touchEnabled = false
		mask.touchEnabled = false
		menu.touchEnabled = false
		editMenu.touchEnabled = false
		layer.visible = false
	end

	return layer
end

return oVertexControl
