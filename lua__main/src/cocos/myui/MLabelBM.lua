------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-10 10:33:58
-- @Description: 自定义字体的标签
------------------------------

--------------------------------
-- @module MLabelBM

local MView = import(".MView")

local MLabelBM = myclass("MLabelBM", function(options)
	if(not options) then
		options = {}
	end
	options.UILabelType = 1
	options.text = string.gsub(options.text or "","\\n","\n")
	local pView = MView.new(MUI.VIEW_TYPE.labelbm, options)
	pView.__setHorizontalAlignment = pView.setHorizontalAlignment
	pView.__setVerticalAlignment = pView.setVerticalAlignment
	pView.__setString = pView.setString
	return pView
end)


-- start --

--------------------------------
-- UILabel构建函数
-- @function [parent=#MLabelBM] new
-- @param table options 参数表

-- end --

function MLabelBM:ctor(options)

    self:align(display.CENTER)

    if(options.anchorpoint) then
    	self:setAnchorPoint(options.anchorpoint)
    end

    self.args_ = {options}
end

-- start --

--------------------------------
-- UILabel设置控件大小
-- @function [parent=#MLabelBM] setLayoutSize
-- @param number width 宽度
-- @param number height 高度
-- @return MLabelBM#MLabelBM  自身

-- end --

function MLabelBM:setLayoutSize(width, height)
    self:setContentSize(width, height)
    return self
end

--设置文字
function MLabelBM:setString(_string )
	-- body
	_string = string.gsub(_string or "","\\n","\n")
	self:__setString(_string)
end

function MLabelBM:createCloneInstance_()
    return MLabelBM.new(unpack(self.args_))
end

function MLabelBM:copyClonedWidgetChildren_(node)

end
-- 设置水平对齐方式（此方法不建议使用，用setAnchorPoint方法替代）
-- _align（int）：对齐方式
function MLabelBM:setHorizontalAlignment( _align )
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
function MLabelBM:setVerticalAlignment( _align )
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
return MLabelBM
