-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-17 10:20:26 星期五
-- Description: 覆盖对话框层，遮掉所有的点击触摸事件
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local DlgOverScene = class("DlgOverScene", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function DlgOverScene:ctor(_func)
    self:setBackgroundImage("ui/bg_base/v1_bg_tiaozhuan.jpg", {scale9 = true, capInsets=cc.rect(0,0, 640, 1)})
	self.eDlgType = e_dlg_index.overscene -- 对话框类型
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function (  )
		-- body
		print("过度场景点击")
	end)
end

return DlgOverScene