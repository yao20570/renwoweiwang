-- Author: liangzhaowei
-- Date: 2017-06-29 09:33:24
-- 乱军图纸界面

local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemEnemyDrawing = class("ItemEnemyDrawing", function()
	return ItemActContent.new(e_id_activity.enemydrawing)
end)

--创建函数
function ItemEnemyDrawing:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemEnemyDrawing",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemEnemyDrawing:myInit()
	self.pData = {} --数据
end


--初始化控件
function ItemEnemyDrawing:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
end

--点击回调
function ItemEnemyDrawing:onClicked()
	-- 定位
    sendMsg(ghd_world_dot_near_my_city,{nDotType = e_type_builddot.wildArmy})
    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)

end


-- 修改控件内容或者是刷新控件数据
function ItemEnemyDrawing:updateViews()
	self:setActTime()
end

--析构方法
function ItemEnemyDrawing:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemEnemyDrawing:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function ItemEnemyDrawing:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemEnemyDrawing:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemEnemyDrawing