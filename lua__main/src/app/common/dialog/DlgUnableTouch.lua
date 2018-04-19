-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-17 10:20:26 星期五
-- Description: 覆盖对话框层，遮掉所有的点击触摸事件
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local DlgUnableTouch = class("DlgUnableTouch", function ()
	return MDialog.new()
end)

function DlgUnableTouch:ctor(_func)
    self:setIsNeedOutside(false)
    self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
	self.eDlgType = e_dlg_index.unabletouch -- 对话框类型
	self._callFunc = _func
	self:onMViewClicked(function ( ... )
		-- body
		if self._callFunc then
			self._callFunc()
		end
	end)
end

function DlgUnableTouch:setCallFunc( _func)
	self._callFunc = _func
end

return DlgUnableTouch