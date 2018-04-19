-- Author: maheng
-- Date: 2017-12-05 16:55:24
-- 免费召唤

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemFreeCall = class("ItemFreeCall", function()
	return ItemActContent.new(e_id_activity.freecall)
end)

--创建函数
function ItemFreeCall:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemFreeCall",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFreeCall:myInit()
	self.pData = {} --数据
end


--初始化控件
function ItemFreeCall:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(6, 10632))
	self:setMBtnType(TypeCommonBtn.L_BLUE)
end

--点击回调
function ItemFreeCall:onClicked()
	-- 定位
	local bOfficial = Player:getCountryData():getIsHasOfficial()
	if bOfficial then--当前是国家官员
		--当前玩家属于国家官员 点击跳转
		--进入世界页面
		--定位到当前玩家城池
		--打开召唤面板
		local nPX, nPY = Player:getWorldData():getMyCityDotPos( )
	    sendMsg(ghd_world_location_dotpos_msg, {nX = nPX, nY = nPY, isClick = false})	

		local tObject = {}
		tObject.nType = e_dlg_index.callplayer --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	    --提示非国家官员，没法召唤
	    --关闭活动a界面
	    closeDlgByType( e_dlg_index.actmodela, false)
	else
		TOAST(getConvertedStr(6, 10633))
	end
end


-- 修改控件内容或者是刷新控件数据
function ItemFreeCall:updateViews()
	self:setActTime()
end

--析构方法
function ItemFreeCall:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemFreeCall:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function ItemFreeCall:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemFreeCall:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemFreeCall