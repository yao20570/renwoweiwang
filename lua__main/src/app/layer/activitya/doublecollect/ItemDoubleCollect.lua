-- Author: liangzhaowei
-- Date: 2017-07-05 14:44:14
-- 采集翻倍界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemDoubleCollect = class("ItemDoubleCollect", function()
	return ItemActContent.new(e_id_activity.doublecollect)
end)

--创建函数
function ItemDoubleCollect:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemDoubleCollect",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemDoubleCollect:myInit()
	self.pData = {} --数据
end


--初始化控件
function ItemDoubleCollect:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:addAccountImg("#v1_fonts_cjfb.png")
	self:setMBtnText(getConvertedStr(5, 10225)) --去采集
end

--点击回调
function ItemDoubleCollect:onClicked()
	-- 跳到世界
    sendMsg(ghd_home_show_base_or_world, 2)
    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)

end


-- 修改控件内容或者是刷新控件数据
function ItemDoubleCollect:updateViews()
	self:setActTime()
end

--析构方法
function ItemDoubleCollect:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemDoubleCollect:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function ItemDoubleCollect:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemDoubleCollect:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemDoubleCollect