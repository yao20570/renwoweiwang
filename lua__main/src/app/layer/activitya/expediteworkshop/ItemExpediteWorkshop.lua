-- Author: liangzhaowei
-- Date: 2017-06-29 10:26:44
-- 工坊加速界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemExpediteWorkshop = class("ItemExpediteWorkshop", function()
	return ItemActContent.new(e_id_activity.expediteworkshop)
end)

--创建函数
function ItemExpediteWorkshop:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemExpediteWorkshop",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemExpediteWorkshop:myInit()
	self.pData = {} --数据
end


--初始化控件
function ItemExpediteWorkshop:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(5, 10216)) --去生产
	self:addAccountImg()
end

--点击回调
function ItemExpediteWorkshop:onClicked()
	--打开对话框
	local pAtelier = Player:getBuildData():getBuildById(e_build_ids.atelier)
	--dump(pAtelier, "pAtelier", 100)
	if pAtelier then--跳转到工坊建筑位置		
		local pObj = {}
		pObj.nCell = e_build_cell.atelier
		sendMsg(ghd_move_to_build_dlg_msg, pObj)
	    closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
		sendMsg(ghd_home_show_base_or_world, 1)--主城或世界跳转	
	else
		showBuildOpenTips(e_build_ids.atelier)
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemExpediteWorkshop:updateViews(  )
	self:setActTime()
end

--析构方法
function ItemExpediteWorkshop:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemExpediteWorkshop:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemExpediteWorkshop:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemExpediteWorkshop:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemExpediteWorkshop