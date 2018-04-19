-- Author: liangzhaowei
-- Date: 2017-08-03 16:03:25
-- 副本获得物品框

local MCommonView = require("app.common.MCommonView")
local ItemFubenGetReward = class("ItemFubenGetReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemFubenGetReward:ctor()
	-- body
	self:myInit()

	parseView("item_get_win_reward", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemFubenGetReward",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenGetReward:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemFubenGetReward:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	

	--lb
	--self.pLbN = self:findViewByName("lb_n")
	

	-- self:setupViews()
	-- self:updateViews()
end

-- --初始化控件
-- function ItemFubenGetReward:setupViews( )

-- end

-- 修改控件内容或者是刷新控件数据
function ItemFubenGetReward:updateViews(  )
	-- body

	if not self.pData  then
		return
	end
	-- dump(self.pData)

	if not self.pLyIcon then
		self.pLyIcon= self:findViewByName("ly_icon")
		self.pLyIcon:setAnchorPoint(0,0)
		self.pLbInfo = self:findViewByName("lb_info")
		getIconGoodsByType(self.pLyIcon, TypeIconHero.NORMAL, type_icongoods_show.item, self.pData, TypeIconGoodsSize.L)
		self.pLbInfo:setString(self.pData.sName.."*"..getResourcesStr(self.pData.nCt))
	end


end

--析构方法
function ItemFubenGetReward:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemFubenGetReward:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--self.pLbN:setString(self.pData.sName or "")
	self:updateViews()

end


return ItemFubenGetReward