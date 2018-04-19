----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-07-08 16:22:18 
-- Description: 带图片的文本控件，图片允许在文字的左侧或者右侧，不能放中间
-- 下面是使用方式
-- local MImgLabel = require("app.common.button.MImgLabel")
-- local pImgLabel = MImgLabel.new({text="", size=20, parent=MLayer})
-- pImgLabel:setImg("xxxx.png", 1)
-- pImgLabel:followPos("left", 0, 0, 5, -5)
-- pImgLabel:setString("测试")
-- pImgLabel:showRedLine(true)
-----------------------------------------------------
local MImgLabel = class("MImgLabel", function ( options )
	local pView = MUI.MLabel.new(options)
	pView.__imglabelsetstring = pView.setString
	return pView
end)
function MImgLabel:ctor( options )
	if(options.parent) then
		self.m_par = options.parent
		local zOrder = options.zorder or 0
		options.parent:addChild(self, zOrder)
		-- 初始化位置
		self:setPositionX(-1000)
		self.m_tipImg = MUI.MImage.new("ui/daitu.png")
		self.m_tipImg:setAnchorPoint(cc.p(0, 0.5))
		self.m_par:addChild(self.m_tipImg, zOrder)
		-- 初始化位置
		self.m_tipImg:setPositionX(-1000)
	end
	self.m_followType = "left"
	self.m_followPosX = 0
	self.m_followPosY = 0
	self.m_followDis = 5
    self.m_diffY = 0
	self.m_imgType = "left"
	self.m_lineType = "label"
	-- 设置图片
	self:setImg(options.img, options.imgscale, options.imgtype)
	self:setAnchorPoint(cc.p(0, 0.5))
end
-- 重置跟随位置
function MImgLabel:__resetFollow(  )
	-- 刻意做分帧处理，目的为了多个同时调用时的刷新统一控制
	gRefreshViewsAsync(self, 1, function ( _bEnd, _index )
		if(_index == 1) then
			local totalWidth = 0
			-- 增加图片的宽度
			if(self.m_tipImg and self.m_tipImg:isVisible()) then
				totalWidth = totalWidth + self.m_tipImg:getWidth()*self.m_tipImg:getScale()
			end
			-- 增加间距的宽度
			totalWidth = totalWidth + self.m_followDis
			-- 增加文字的宽度
			totalWidth = totalWidth + self:getWidth()
			if(self.m_imgType == "left") then
				-- 重置图片和文字的位置
				if(self.m_followType == "left") then
					if(self.m_tipImg and self.m_tipImg:isVisible()) then
						self.m_tipImg:setPositionX(self.m_followPosX)
					else
						-- 故意减去间距，下面可以统一加上间距进行处理
						self.m_tipImg:setPositionX(self.m_followPosX
							-self.m_tipImg:getWidth()*self.m_tipImg:getScale()-self.m_followDis)
					end
				elseif(self.m_followType == "center") then
					if(self.m_tipImg and self.m_tipImg:isVisible()) then
						self.m_tipImg:setPositionX(self.m_followPosX-totalWidth/2)
					else
						-- 故意减去间距，下面可以统一加上间距进行处理
						self.m_tipImg:setPositionX(self.m_followPosX-totalWidth/2
							-self.m_tipImg:getWidth()*self.m_tipImg:getScale()-self.m_followDis)
					end
				elseif(self.m_followType == "right") then
					if(self.m_tipImg and self.m_tipImg:isVisible()) then
						self.m_tipImg:setPositionX(self.m_followPosX-totalWidth)
					else
						-- 故意减去间距，下面可以统一加上间距进行处理
						self.m_tipImg:setPositionX(self.m_followPosX-totalWidth
							-self.m_tipImg:getWidth()*self.m_tipImg:getScale()-self.m_followDis)
					end
				end
				self.m_tipImg:setPositionY(self.m_followPosY + self.m_diffY)
				-- 设置文字的位置
				self:setPosition(self.m_tipImg:getPositionX()
					+self.m_tipImg:getWidth()*self.m_tipImg:getScale()+self.m_followDis, 
					self.m_followPosY)
			else
				-- 先重置文本的位置
				if(self.m_followType == "left") then
					self:setPosition(self.m_followPosX, self.m_followPosY)
				elseif(self.m_followType == "center") then
					self:setPosition(self.m_followPosX-totalWidth/2, self.m_followPosY)
				elseif(self.m_followType == "right") then
					self:setPosition(self.m_followPosX-totalWidth, self.m_followPosY)
				end
				-- 设置图片的位置
				self.m_tipImg:setPosition(
					self:getPositionX()+self:getWidth()+self.m_followDis, self.m_followPosY + self.m_diffY)
			end
			if(self.m_redline) then
				if(self.m_lineType == "label") then
					self.m_redline:setPosition(self:getPositionX(), self:getPositionY())
				else
					if self.m_tipImg and self.m_tipImg:isVisible() then
						self.m_redline:setPosition(self.m_tipImg:getPositionX()-5, 
							self.m_tipImg:getPositionY())
					else
						self.m_redline:setPosition(self:getPositionX()-10, 
							self.m_tipImg:getPositionY())
					end
				end
			end
		end
	end)
end
----------------------------------------------------------------------------------------
-- 设置图片
-- _name(string): 图片名称
-- _scale(number): 图片的缩放大小
-- _type（string）: 图片放置的位置，left是左边，right是右边
function MImgLabel:setImg( _name, _scale, _type )
	_name = _name or "ui/daitu.png"
	_scale = _scale or 1

	if(not self.m_par) then
		return
	end
	self.m_imgType = _type or "left"
	-- 设置图片名称
	self.m_tipImg:setCurrentImage(_name)
	-- 设置图片缩放大小
	self.m_tipImg:setScale(_scale)
	-- 设置位置
	self:__resetFollow()
end
-- 隐藏图片
function MImgLabel:hideImg( )
	if(self.m_tipImg) then
		self.m_tipImg:setVisible(false)
	end
	-- 设置位置
	self:__resetFollow()
end

--显示图片
function MImgLabel:showImg( )
	if(self.m_tipImg) then
		self.m_tipImg:setVisible(true)
	end
	-- 设置位置
	self:__resetFollow()
end

--获取图片
function MImgLabel:getImg( )
	return self.m_tipImg
end

-- 设置跟随状态，此方法代替了setPostion的功能，可以自动动态改变图片和文字的实际位置展示
-- _sType(string): 跟随类型-- left, right, center
-- _posx(number): 跟随的坐标x值
-- _posy(number): 跟随的坐标y值
-- _dis(number): 图片和文字之间的水平间距
-- _nDiffY(number): 图片和文字的锚点的垂直间距
function MImgLabel:followPos( _sType, _posx, _posy, _dis, _nDiffY )
	if(not _sType) then
		return
	end
	self.m_followType = _sType or self.m_followType
	self.m_followPosX = _posx or self.m_followPosX
	self.m_followPosY = _posy or self.m_followPosY
	self.m_followDis = _dis or self.m_followDis
	self.m_diffY = _nDiffY or self.m_diffY
	-- 重置展示位置
	self:__resetFollow()
end
-- 重写父类方法
function MImgLabel:setString( _string )
	-- 设置父类的内容
	self:__imglabelsetstring(_string, false)
	-- 刷新位置
	self:__resetFollow()
end
-- 展示红色线
-- _bShow(boolean): 是否显示红线
-- _scaleX(boolean): 设置红线缩放宽度，目的是为了可以加长红线的展示
-- _sType(string): 红线开始的位置, img是从图片开始，label是从文字开始，默认是从文字开始
function MImgLabel:showRedLine( _bShow, _scaleX, _sType )
	if(not self.m_par) then
		return
	end
	self.m_lineType = _sType or "label"
	if(_bShow) then
		-- 新建一个红线
		if(not self.m_redline) then
			self.m_redline =  MUI.MImage.new("#v1_line_red2.png")
			self.m_redline:setAnchorPoint(0,0.5)
			self.m_par:addChild(self.m_redline)
			-- 初始化位置
			self.m_redline:setPositionX(-1000)
		end
		-- 将红线显示出来
		self.m_redline:setVisible(true)
		-- 重置展示位置
		self:__resetFollow()
	else
		-- 隐藏红线
		if(self.m_redline) then
			self.m_redline:setVisible(false)
		end
	end
	-- 此处理可以增加红线的长度
	if self.m_lineType == "all" then
		if self.m_redline then
			local nLenght = self:getLineAllLength()
			local nscaleX = nLenght/self.m_redline:getWidth()
			self.m_redline:setScaleX(nscaleX)
		end
	else
		if(_scaleX and self.m_redline) then
			self.m_redline:setScaleX(_scaleX)
		end
	end
end

function MImgLabel:getLineAllLength(  )
	-- body
	local totalWidth = 0
	-- 增加图片的宽度
	if(self.m_tipImg and self.m_tipImg:isVisible()) then
		totalWidth = totalWidth + self.m_tipImg:getWidth()*self.m_tipImg:getScale()
	end
	-- 增加间距的宽度
	totalWidth = totalWidth + self.m_followDis
	-- 增加文字的宽度
	totalWidth = totalWidth + self:getWidth() + 10	
	return totalWidth
end

function MImgLabel:remove()
	-- body
	if(self.m_tipImg) then
		self.m_tipImg:removeSelf()

	end
	if self.m_redline then 
		self.m_redline:removeSelf()
	end
	self:removeSelf()
end

return MImgLabel