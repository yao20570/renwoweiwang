-- Author: liangzhaowei
-- Date: 2017-07-05 17:21:13
-- 物产加速界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemExpediteProducts = class("ItemExpediteProducts", function()
	return ItemActContent.new(e_id_activity.expediteproducts)
end)

--创建函数
function ItemExpediteProducts:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemExpediteProducts",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemExpediteProducts:myInit()
	self.pData = {} --数据
end


--初始化控件
function ItemExpediteProducts:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(5, 10224)) --去攻打
	self:addAccountImg("#v1_fonts_zbtz.png")
end

--点击回调
function ItemExpediteProducts:onClicked()
	-- 跳到世界
    sendMsg(ghd_home_show_base_or_world, 2)
    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)

end


-- 修改控件内容或者是刷新控件数据
function ItemExpediteProducts:updateViews()
	self:setActTime()
end

--析构方法
function ItemExpediteProducts:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemExpediteProducts:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function ItemExpediteProducts:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemExpediteProducts:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemExpediteProducts