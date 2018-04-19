------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-10 10:33:58
-- @Description: 自定义文字标签
------------------------------

--------------------------------
-- @module MLabelAtlas

local MView = import(".MView")

local MLabelAtlas = myclass("MLabelAtlas", function(options)
	local pView = MView.new(MUI.VIEW_TYPE.labelatlas, options)
	pView.__setString = pView.setString
	return pView
end)


-- start --

--------------------------------
-- UILabel构建函数
-- @function [parent=#MLabelAtlas] new
-- @param table options 参数表

-- end --

function MLabelAtlas:ctor(options)

    self:align(display.CENTER)

    if(options.anchorpoint) then
    	self:setAnchorPoint(options.anchorpoint)
    end

    self.args_ = {options}
end

-- start --

--------------------------------
-- UILabel设置控件大小
-- @function [parent=#MLabelAtlas] setLayoutSize
-- @param number width 宽度
-- @param number height 高度
-- @return MLabelAtlas#MLabelAtlas  自身

-- end --

function MLabelAtlas:setLayoutSize(width, height)
    self:setContentSize(width, height)
    return self
end

--设置文字
function MLabelAtlas:setString(_string )
	-- body
	--设置相机类型
	-- self:setCameraMask(MUI.CAMERA_FLAG.USER2,true)
	self:__setString(_string)
end

function MLabelAtlas:createCloneInstance_()
    return MLabelAtlas.new(unpack(self.args_))
end

function MLabelAtlas:copyClonedWidgetChildren_(node)

end
-- 设置水平对齐方式（此方法不建议使用，用setAnchorPoint方法替代）
-- _align（int）：对齐方式
function MLabelAtlas:setHorizontalAlignment( _align )
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
function MLabelAtlas:setVerticalAlignment( _align )
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
return MLabelAtlas
