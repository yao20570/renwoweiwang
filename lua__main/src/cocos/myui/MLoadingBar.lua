----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 18:09:37 
-- Description: 自定义进度条
-----------------------------------------------------

--------------------------------
-- @module MLoadingBar

local MView = import(".MView")
local MClippingNode = import(".MClippingNode")

local MLoadingBar = myclass("MLoadingBar", function()
	return MView.new(MUI.VIEW_TYPE.loadingbar)
end)

MLoadingBar.DIRECTION_LEFT_TO_RIGHT = 0
MLoadingBar.DIRECTION_RIGHT_TO_LEFT = 1

-- start --

--------------------------------
-- 进度控件构建函数
-- @function [parent=#MLoadingBar] new
-- @param table params 参数

--[[--

进度控件构建函数

可用参数有：

-   scale9 是否缩放
-   capInsets 缩放的区域
-   image 图片
-   viewRect 显示区域
-   percent 进度值 0到100
-	direction 方向，默认值从左到右

]]
-- end --

function MLoadingBar:ctor(params)
	self.__pClippingNode = MClippingNode.new()
	if params.scale9 then
		self.scale9 = true
		-- 判断是否使用代图
	    if(G_checkTexture) then
	        params.image = G_checkTexture(params.image)
	    end
		local scale9sp = ccui.Scale9Sprite or cc.Scale9Sprite
		if string.byte(params.image) == 35 then
			self.bar = scale9sp:createWithSpriteFrameName(
				string.sub(params.image, 2), params.capInsets);
		else
			self.bar = scale9sp:create(
				params.capInsets, params.image)
		end
		self.__pClippingNode:setClippingRegion(cc.rect(0, 0, params.viewRect.width, params.viewRect.height))
	else
		self.bar = display.newSprite(params.image)
	end
	-- 如果有添加背景
	if(params.bgimage) then
		self:setBgImage(params.bgimage)
	end

	self.direction_ = params.direction or MLoadingBar.DIRECTION_LEFT_TO_RIGHT
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setViewRect(params.viewRect)
	self.bar:setAnchorPoint(cc.p(0, 0))
	self.bar:setPosition(0, 0)
	self:setPercent(params.percent or 0)
	self.__pClippingNode:addChild(self.bar)
	self:addChild(self.__pClippingNode, 0)
	local pClipAnchor = self.__pClippingNode:getAnchorPoint()
	self.__pClippingNode:setPosition(-params.viewRect.width*(0.5-pClipAnchor.x),
		-params.viewRect.height*(0.5-pClipAnchor.y))

	self.args_ = {params}
end
-- 刷新无效的状态
-- _bEn（bool）：当前状态
function MLoadingBar:__onRefreshEnableState( _bEn )
	if(_bEn == nil) then
		_bEn = self:isViewEnabled()
	end
	if(self.bar) then
		changeSpriteEnabledShowState(self.bar, _bEn)
	end
	if(self.bgSprite) then
		changeSpriteEnabledShowState(self.bgSprite, _bEn)
	end
end

-- 刷新按钮状态是否置灰
-- _bEn（bool）：当前状态
function MLoadingBar:__onRefreshGrayState( _bEn )
	if(_bEn == nil) then
		_bEn = self:isViewGray()
		_bEn = not _bEn
	end
	
	if(self.bar) then
		changeSpriteEnabledShowState(self.bar, _bEn)
	end
	if(self.bgSprite) then
		changeSpriteEnabledShowState(self.bgSprite, _bEn)
	end
end

-- start --

--------------------------------
-- 设置进度控件的进度
-- @function [parent=#MLoadingBar] setPercent
-- @param number percent 进度值 0到100
-- @return MLoadingBar#MLoadingBar 

-- end --

function MLoadingBar:setPercent(percent)
	self.percent_ = percent
	local rect = cc.rect(self.viewRect_.x, self.viewRect_.y,
		self.viewRect_.width, self.viewRect_.height)
	local newWidth = rect.width*self.percent_/100

	rect.x = 0
	rect.y = 0
	if self.scale9 then
		self.bar:setPreferredSize(cc.size(newWidth, rect.height))
		if MLoadingBar.DIRECTION_LEFT_TO_RIGHT ~= self.direction_ then
			self.bar:setPosition(rect.width - newWidth,	0)
		end
	else
		if MLoadingBar.DIRECTION_LEFT_TO_RIGHT == self.direction_ then
			rect.width = newWidth
			self.__pClippingNode:setClippingRegion(cc.rect(rect.x, rect.y, rect.width, rect.height))
		else
			rect.x = rect.x + rect.width - newWidth
			rect.width = newWidth
			self.__pClippingNode:setClippingRegion(cc.rect(rect.x, rect.y, rect.width, rect.height))
		end
	end

	return self
end

-- start --

--------------------------------
-- 得到进度控件的进度
-- @function [parent=#MLoadingBar] getPercent
-- @return number 进度值

-- end --

function MLoadingBar:getPercent()
	return self.percent_
end

-- start --

--------------------------------
-- 设置进度控件的方向
-- @function [parent=#MLoadingBar] setDirection
-- @param integer dir 进度的方向
-- @return MLoadingBar#MLoadingBar 

-- end --

function MLoadingBar:setDirection(dir)
	self.direction_ = dir
	if MLoadingBar.DIRECTION_LEFT_TO_RIGHT ~= self.direction_ then
		if self.bar.setFlippedX then
			self.bar:setFlippedX(true)
		end
	end

	return self
end

-- start --

--------------------------------
-- 设置进度控件的显示区域
-- @function [parent=#MLoadingBar] setViewRect
-- @param table rect 显示区域
-- @return MLoadingBar#MLoadingBar 

-- end --

function MLoadingBar:setViewRect(rect)
	if(rect == nil) then
		return
	end
	self.viewRect_ = rect
	if(self.bar) then
		self.bar:setContentSize(rect.width, rect.height)
	end
	if(self.percent_) then
		self:setPercent(self.percent_)
	end
	-- 设置当前控件的宽高
	self:setContentSize(rect.width, rect.height)
	return self
end
-- 返回显示的区域
function MLoadingBar:getViewRect(  )
	return self.viewRect_
end

function MLoadingBar:createCloneInstance_()
	self.args_.viewRect = self.viewRect_
	self.args_.direction = self.direction_
	return MLoadingBar.new(unpack(self.args_))
end
-- 添加背景图片
-- _image(string): 背景图片的相对路径
function MLoadingBar:setBgImage( _image )
	if(not _image) then
		return
	end
	if(not self.bgSprite) then
		self.bgSprite = display.newSprite(_image)

		self.bgSprite:setAnchorPoint(cc.p(0, 0))
		local fDis = 2 -- 可以增加2个像素点的处理
		local fScaleX = 1
		local fScaleY = 1
		if(self.viewRect_ and self.viewRect_.width > 0) then
			fScaleX = (self.viewRect_.width+fDis*2) / self.bgSprite:getContentSize().width
			fScaleY = (self.viewRect_.height+fDis*2) / self.bgSprite:getContentSize().height
			self.bgSprite:setScaleX(fScaleX)
			self.bgSprite:setScaleY(fScaleY)
		end
		local x = self.__pClippingNode:getPositionX()-fDis
		-- y值刻意降低一个像素
		local y = self.__pClippingNode:getPositionY()-fDis-1
		self.bgSprite:setPosition(x, y)
		self:addChild(self.bgSprite, -1)
	else
		-- 这里直接使用纹理去处理，后续再考虑是否添加到缓存池中
		self.bgSprite:setTexture(_image)
	end
end

-- 修改进度条
-- _image(string)：进度条图片相对路径
function MLoadingBar:setBarImage( _image )
	-- body
	if(not _image) then
		return
	end
	if(not self.bar) then
		self.bar = display.newSprite(_image)
		self.bar:setAnchorPoint(cc.p(0, 0))
		self.bar:setPosition(0, 0)
		self.__pClippingNode:addChild(self.bar)
	else
		-- 这里直接使用纹理去处理，后续再考虑是否添加到缓存池中
		self.bar:setTexture(_image)
	end
end

return MLoadingBar
