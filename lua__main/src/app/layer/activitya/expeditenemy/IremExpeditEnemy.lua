-- Author: liangzhaowei
-- Date: 2017-07-05 14:12:59
-- 乱军加速界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local IremExpeditEnemy = class("IremExpeditEnemy", function()
	return ItemActContent.new(e_id_activity.expeditenemy)
end)

--创建函数
function IremExpeditEnemy:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("IremExpeditEnemy",handler(self, self.onDestroy))
	
end

--初始化参数
function IremExpeditEnemy:myInit()
	self.pData = {} --数据
end


--初始化控件
function IremExpeditEnemy:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
end

--点击回调
function IremExpeditEnemy:onClicked()
	-- 定位
    sendMsg(ghd_world_dot_near_my_city,{nDotType = e_type_builddot.wildArmy})
    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)

end


-- 修改控件内容或者是刷新控件数据
function IremExpeditEnemy:updateViews()
	self:setActTime()
	self:setMBtnText(getConvertedStr(5, 10224)) --去攻打
end

--析构方法
function IremExpeditEnemy:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function IremExpeditEnemy:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function IremExpeditEnemy:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function IremExpeditEnemy:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return IremExpeditEnemy