------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-10 10:33:58
-- @Description: 自定义文字标签
------------------------------

--------------------------------
-- @module MLabel

local MView = import(".MView")

local MLabel = myclass("MLabel", function(options)
	if(not options) then
		options = {}
	end
	options.UILabelType = 2
	if(device.platform == "windows") then
		options.text = string.gsub(options.text or "","\\n","\n")
	else
		options.text = string.gsub(options.text or "","\\n","<br/>")
	end
	local pView = MView.new(MUI.VIEW_TYPE.label, options)
	pView.__setHorizontalAlignment = pView.setHorizontalAlignment
	pView.__setVerticalAlignment = pView.setVerticalAlignment
	pView.__setString = pView.setString
	return pView
end)


-- start --

--------------------------------
-- UILabel构建函数
-- @function [parent=#MLabel] new
-- @param table options 参数表

-- end --

function MLabel:ctor(options)
	-- 通用的重置初始值行为
    self:__resetOptions(true, options)

end
-- 重置特殊需求的控制
-- 这里的参数与ctor方法的参数一样 
-- _bNew(bool): 是否从ctor中new出来的
function MLabel:__resetOptions( _bNew, options )
	if(_bNew == nil) then
		_bNew = true
	end

    self:align(display.CENTER)

    if(options.anchorpoint) then
    	self:setAnchorPoint(options.anchorpoint)
    end

    self.args_ = options

    self.sCurString = nil
    self.nRandom = -1
    --去掉描边或者投影相关属性
    self:disableEffect()

    --去掉分帧加载，这个比较耗性能，低端机有明显的效果，像小米4lite，会有2-3毫秒的提高
--    self:onUpdate(function (  )
--    	-- body
--    	if self.nRandom ~= -1 then
--    		self.nRandom = self.nRandom - 1
--    		if self.nRandom == 0 then
--    			self:updateTexture()
--    			self.nRandom = -1
--    		end
--    	end
--    end)
    -- 缓存池的特殊操作
    if(not _bNew) then
    	--取消点击事件
    	self:setViewTouched(false)
    	self:onMViewClicked(nil)
		if(options.text) then
			self:setString(tostring(options.text))
		end
		if(options.size) then
			self:setSystemFontSize(tonumber(options.size))
		end
		if(options.color) then
			self:setTextColor(options.color)
		end
		if(options.dimensions) then
			self:setDimensions(options.dimensions.width, options.dimensions.height)
		else
			self:setDimensions(0, 0)
		end
	end
end

-- start --

--------------------------------
-- UILabel设置控件大小
-- @function [parent=#MLabel] setLayoutSize
-- @param number width 宽度
-- @param number height 高度
-- @return MLabel#MLabel  自身

-- end --

function MLabel:setLayoutSize(width, height)
    self:setContentSize(width, height)
    return self
end

--设置文字
function MLabel:setString(_string, _bAsync )
	-- body
	_bAsync = false
	-- 如果是table的话，重新构建成string
	if(type(_string) == "table" and #_string > 0) then
		local str = ""
		for i, v in pairs(_string) do
			local colorStr = ""
			if(not v.color) then
				v.color = self:getTextColor() or cc.c3b(255, 255, 255)
			end
			if(type(v.color) == "string" and #v.color > 0) then
				colorStr = v.color
			else
				-- 将字体颜色转成字符串
				colorStr = string.format("%02x%02x%02x", v.color.r, v.color.g, v.color.b)
			end
			-- 构建table字符串
            if v.text ~= nil then
			    str = str .. "<font color='#" .. colorStr .. "'>" .. v.text .. "</font>"
            end
		end
		_string = str
	end
	-- windows格式化所有html内容
	if(device.platform == "windows") then
		_string = gCutHtmlString(_string)
		-- 处理html里面的空格
		_string = string.gsub(_string or "","&nbsp;"," ")
		_string = string.gsub(_string or "","nbsp;"," ")
		_string = string.gsub(_string or "","\\n","\n")
	else
		if(type(_string) == "table") then
			_string = "*"
		else
			-- 处理配表的\n
			_string = string.gsub(_string or "","\\n","<br/>")
			-- 处理代码的\n
			_string = string.gsub(_string or "","\n","<br/>")
		end
	end
	
	
	if self.sCurString == _string then
		return
	end
	--设置相机类型
	-- self:setCameraMask(MUI.CAMERA_FLAG.USER2,true)
	
	if _bAsync == nil then
		_bAsync = true
	end
	-- 关闭分帧过程
	if(CLOSE_LABEL_ASYNC) then
		_bAsync = false
	end

	self.sCurString = _string
	if _bAsync == false then
		self:updateTexture()
	else
		if self.nRandom == -1 then
			self.nRandom =  math.random(1, 10)
		end
	end

end

--立即刷新内容
function MLabel:updateTexture(  )
	-- body
	self:__setString(self.sCurString)
end

function MLabel:createCloneInstance_()
    return MLabel.new(self.args_)
end

function MLabel:copyClonedWidgetChildren_(node)

end
-- 设置水平对齐方式（此方法不建议使用，用setAnchorPoint方法替代）
-- _align（int）：对齐方式
function MLabel:setHorizontalAlignment( _align )
	if(not _align) then
		return
	end
	local oldPoint = self:getAnchorPoint()
	if(_align == MUI.TEXT_ALIGN_LEFT) then
		oldPoint.x = 0
	elseif(_align == MUI.TEXT_ALIGN_CENTER) then
		oldPoint.x = 0.5
	elseif(_align == MUI.TEXT_ALIGN_RIGHT) then
		oldPoint.x = 1
	end
	self:setAnchorPoint(oldPoint)
end
-- 设置垂直对齐方式（此方法不建议使用，用setAnchorPoint方法替代）
-- _align（int）：对齐方式
function MLabel:setVerticalAlignment( _align )
	if(not _align) then
		return
	end
	local oldPoint = self:getAnchorPoint()
	if(_align == MUI.TEXT_VALIGN_TOP) then
		oldPoint.y = 0
	elseif(_align == MUI.TEXT_VALIGN_CENTER) then
		oldPoint.y = 0.5
	elseif(_align == MUI.TEXT_VALIGN_BOTTOM) then
		oldPoint.y = 1
	end
	self:setAnchorPoint(oldPoint)
end
return MLabel
