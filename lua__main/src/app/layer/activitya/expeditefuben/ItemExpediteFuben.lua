-- Author: liangzhaowei
-- Date: 2017-06-21 16:17:17
-- 副本加速(副本掉落)界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemExpediteFuben = class("ItemExpediteFuben", function()
	return ItemActContent.new(e_id_activity.expeditefuben)
end)

--创建函数
function ItemExpediteFuben:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemExpediteFuben",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemExpediteFuben:myInit()
	self.pData = {} --数据
end



--初始化控件
function ItemExpediteFuben:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(5, 10234)) --去挑战
end

--点击回调
function ItemExpediteFuben:onClicked()
	-- --打开对话框
 --    local tObject = {}
 --    tObject.nType = e_dlg_index.fubenlayer --dlg类型
 --    sendMsg(ghd_show_dlg_by_type,tObject)


	local tObject = {}
	local tOpenChapters = Player:getFuben():getOpenChpater()
	tObject.tData = #tOpenChapters --章节id
	tObject.nType = e_dlg_index.fubenmap --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)


    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)
end


-- 修改控件内容或者是刷新控件数据
function ItemExpediteFuben:updateViews(  )
	self:setActTime()
end

--析构方法
function ItemExpediteFuben:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemExpediteFuben:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemExpediteFuben:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemExpediteFuben:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemExpediteFuben