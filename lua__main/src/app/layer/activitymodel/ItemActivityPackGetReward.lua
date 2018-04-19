-- Author: liangzhaowei
-- Date: 2017-08-10 13:55:21
-- 活动标题模板中购买物品(136*202)

local MCommonView = require("app.common.MCommonView")
local ItemActivityPackGetReward = class("ItemActivityPackGetReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemActivityPackGetReward:ctor()
	-- body
	self:myInit()

	parseView("item_activity_pack_get_reward", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemActivityPackGetReward",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActivityPackGetReward:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemActivityPackGetReward:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	--ly         	
	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLyBtn = self:findViewByName("ly_btn")
	

end

--初始化控件
function ItemActivityPackGetReward:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemActivityPackGetReward:updateViews(  )
	-- body
end

--析构方法
function ItemActivityPackGetReward:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActivityPackGetReward:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:updateViews()
	--self.pLbN:setString(self.pData.sName or "")
end

--获得icon Ly
function ItemActivityPackGetReward:getLyIcon()
	return self.pLyIcon
end

--获得btn Ly
function ItemActivityPackGetReward:getLyBtn()
	return self.pLyBtn
end


return ItemActivityPackGetReward