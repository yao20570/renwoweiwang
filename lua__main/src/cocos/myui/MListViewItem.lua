----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-13 19:56:29 
-- Description: 自定义列表的每一项
-----------------------------------------------------

--------------------------------
-- @module MListViewItem


local MView = import(".MView")
local MScrollLayer = import(".MScrollLayer")

local MListViewItem = myclass("MListViewItem", function()
	return MUI.MLayer.new()
end)

MListViewItem.BG_TAG = 1
MListViewItem.BG_Z_ORDER = 1
MListViewItem.CONTENT_TAG = 11
MListViewItem.CONTENT_Z_ORDER = 11
MListViewItem.ID_COUNTER = 0

function MListViewItem:ctor()
	self.width = 0
	self.height = 0
	self.margin_ = {left = 0, right = 0, top = 0, bottom = 0}
	MListViewItem.ID_COUNTER = MListViewItem.ID_COUNTER + 1
	self.id = MListViewItem.ID_COUNTER
	self:setTag(self.id)
end

-- start --

--------------------------------
-- 将要内容加到列表控件项中
-- @function [parent=#MListViewItem] addContent
-- @param node content 显示内容

-- end --

function MListViewItem:addContent(content)
	if not content then
		return
	end

	self:addView(content, MListViewItem.CONTENT_Z_ORDER, MListViewItem.CONTENT_TAG)
	-- 如果没有这是item大小，默认为传进来的view的大小
	if(self.width or self.height) then
		-- 如果存在自定义的获取宽度方法，就使用自定义的方法
		if(content.getWidth) then
			self:setItemSize(content:getWidth(), content:getHeight())
		else
            local size = content:getContentSize()
			self:setItemSize(size.width, size.height)
		end
	end
end

-- start --

--------------------------------
-- 获取列表控件项中的内容
-- @function [parent=#MListViewItem] getContent
-- @return node#node 

-- end --

function MListViewItem:getContent()
	return self:getChildByTag(MListViewItem.CONTENT_TAG)
end

-- start --

--------------------------------
-- 设置列表项中的大小
-- @function [parent=#MListViewItem] setItemSize
-- @param number w 列表项宽度
-- @param number h 列表项高度
-- @param boolean bNoMargin 是否不使用margin margin可调用setMargin赋值

-- end --

function MListViewItem:setItemSize(w, h, bNoMargin)
	if not bNoMargin then
		if MScrollLayer.DIRECTION_VERTICAL == self.lvDirection_ then
			h = h + self.margin_.top + self.margin_.bottom
		else
			w = w + self.margin_.left + self.margin_.right
		end
	end

	-- print("MListViewItem - setItemSize w:" .. w .. " h:" .. h)

	local oldSize = {width = self.width, height = self.height}
	local newSize = {width = w, height = h}

	self.width = w or 0
	self.height = h or 0
	self:setContentSize(w, h)

	local bg = self:getChildByTag(MListViewItem.BG_TAG)
	if bg then
		bg:setContentSize(w, h)
		bg:setPosition(w/2, h/2)
	end

	self.listener(self, newSize, oldSize)
end

--[[--

设置列表项中的大小

@return number width
@return number height

]]
function MListViewItem:getItemSize()
	return self.width, self.height
end

function MListViewItem:setMargin(margin)
	if margin then
		self.margin_ = margin
	end
	-- dump(self.margin_, "set margin:")
end

function MListViewItem:getMargin()
	return self.margin_
end

function MListViewItem:setBg(bg)
	local sp
	local bgType = tolua.type(bg)
	if "string" == bgType then
		sp = display.newScale9Sprite(bg)
		sp:setAnchorPoint(0.5, 0.5)
		sp:setPosition(self.width/2, self.height/2)
	elseif "ccui.Scale9Sprite" == bgType or "cc.Sprite" == bgType then
		sp = bg
	elseif "cc.SpriteFrame" == bgType then
		sp = ccui.Scale9Sprite:createWithSpriteFrame(bg)
	end
	self:addChild(sp, MListViewItem.BG_Z_ORDER, MListViewItem.BG_TAG)
end

function MListViewItem:getBg()
	return self:getChildByTag(MListViewItem.BG_TAG)
end

function MListViewItem:onSizeChange(listener)
	self.listener = listener

	return self
end

-- just for listview invoke
function MListViewItem:setDirction(dir)
	self.lvDirection_ = dir
end


function MListViewItem:createCloneInstance_()
    return MListViewItem.new(self:getContent():clone())
end

function MListViewItem:copyClonedWidgetChildren_(node)
    -- local children = node:getChildren()
    -- if not children or 0 == #children then
    --     return
    -- end

    -- for i, child in ipairs(children) do
    --     local cloneChild = node:clone()
    --     if cloneChild then
    --         self:addChild(cloneChild)
    --     end
    -- end
end

function MListViewItem:copySpecialProperties_(node)
	self.listener = node.listener
	self:setMargin(node:getMargin())

	local bg = node:getBg()
	if bg then
		if "ccui.Scale9Sprite" == tolua.type(bg) then
			self:setBg(bg:getSprite():getSpriteFrame())
		else
			self:setBg(bg:getSpriteFrame())
		end
	end

	self:setItemSize(node:getItemSize())
end

return MListViewItem
