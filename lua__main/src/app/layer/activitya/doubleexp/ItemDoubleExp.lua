-- Author: liangzhaowei
-- Date: 2017-07-05 17:00:59
-- 翻倍经验界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemDoubleExp = class("ItemDoubleExp", function()
	return ItemActContent.new(e_id_activity.doubleexp)
end)

--创建函数
function ItemDoubleExp:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemDoubleExp",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemDoubleExp:myInit()
	self.pData = {} --数据
end



--初始化控件
function ItemDoubleExp:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(5, 10226)) --去通关
end

--点击回调
function ItemDoubleExp:onClicked()
	--打开对话框
    -- local tObject = {}
    -- tObject.nType = e_dlg_index.fubenlayer --dlg类型
    -- sendMsg(ghd_show_dlg_by_type,tObject)
    local tObject = {}
	local tOpenChapters = Player:getFuben():getOpenChpater()
	tObject.tData = #tOpenChapters --章节id
	tObject.nType = e_dlg_index.fubenmap --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
	
    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)
end


-- 修改控件内容或者是刷新控件数据
function ItemDoubleExp:updateViews(  )
	self:setActTime()
end

--析构方法
function ItemDoubleExp:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemDoubleExp:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemDoubleExp:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemDoubleExp:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemDoubleExp