-- Author: luwenjing
-- Date: 2017-12-14 16:01:17
-- 体力折扣界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemEnergyDiscount = class("ItemEnergyDiscount", function()
	return ItemActContent.new(e_id_activity.energydiscount)
end)

--创建函数
function ItemEnergyDiscount:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemEnergyDiscount",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemEnergyDiscount:myInit()
	self.pData = {} --数据
end



--初始化控件
function ItemEnergyDiscount:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(6, 10080)) --去挑战
end

--点击回调
function ItemEnergyDiscount:onClicked()
	-- --打开对话框
	openDlgBuyEnergy()
end


-- 修改控件内容或者是刷新控件数据
function ItemEnergyDiscount:updateViews(  )
	self:setActTime()
end

--析构方法
function ItemEnergyDiscount:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemEnergyDiscount:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemEnergyDiscount:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemEnergyDiscount:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemEnergyDiscount