-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2018-02-06 20:32:0 星期二
-- Description: 伤害排名
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local e_type_tab = {
	harm = 1,
	hitNum = 2,
}

local ItemTLBossRank = class("ItemTLBossRank", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTLBossRank:ctor( )
	-- body	
	self:myInit()	
	parseView("item_tboss_rank", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemTLBossRank:myInit()
end

--解析布局回调事件
function ItemTLBossRank:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemTLBossRank",handler(self, self.onItemTLBossRankDestroy))
end

--初始化控件
function ItemTLBossRank:setupViews( )
	self.pTxtRank = self:findViewByName("txt_rank")
	self.pTxtCountry = self:findViewByName("txt_country")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtHurt = self:findViewByName("txt_harm")

	self:setIsPressedNeedScale(false)                      
	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onClick))
end

-- 修改控件内容或者是刷新控件数据
function ItemTLBossRank:updateViews( )
	if not self.tCurData then
		return
	end
	local nRank = self.nRank
	if nRank then
		self.pTxtRank:setString(nRank)
	end
	local nCountry = self.tCurData.nCountry
	if nCountry then
		local sCountry = getCountryShortName(nCountry)
		self.pTxtCountry:setString(sCountry)
		setTextCCColor(self.pTxtCountry, getColorByCountry(nCountry))
	end
	local sName = self.tCurData.sName
	if sName then
		self.pTxtName:setString(sName)
	end

	if self.nCurrTab == e_type_tab.harm then
		local nHarm = self.tCurData.nHarm
		if nHarm then
			self.pTxtHurt:setString(getResourcesStr(nHarm))
		end
	else
		local nHitNum = self.tCurData.nHitNum
		if nHitNum then
			self.pTxtHurt:setString(nHitNum)
		end
	end
end

-- 析构方法
function ItemTLBossRank:onItemTLBossRankDestroy( )
end

--_data:BossRankVo
function ItemTLBossRank:setCurData( _type, _data, nRank)
	self.nCurrTab = _type
	self.tCurData = _data
	self.nRank = nRank --排名
	self:updateViews()
end

function ItemTLBossRank:setHandler( _nhandler )
	-- body
	self.nHandler = _nhandler
end

function ItemTLBossRank:onClick(  )
	if self.nHandler then
		self.nHandler(self.tCurData)
	end
end

return ItemTLBossRank