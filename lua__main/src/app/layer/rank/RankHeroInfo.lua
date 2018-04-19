-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-17 15:05:40 星期三
-- Description: 排行榜玩家信息的武将显示
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local RankHeroInfo = class("RankHeroInfo", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function RankHeroInfo:ctor(  )
	-- body	
	self:myInit()	
	parseView("rank_hero_info", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function RankHeroInfo:myInit(   )
	-- body		
	self.tCurData 			= 	nil 				--当前数据	
	self.bIsIconCanTouched 	= 	false
end

--解析布局回调事件
function RankHeroInfo:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("RankHeroInfo",handler(self, self.onRankHeroInfoDestroy))
end

--初始化控件
function RankHeroInfo:setupViews( )
	-- body
	--头像
	self.pLayIcon = self:findViewByName("lay_icon")
	--名字等级
	self.pLbNameLV = self:findViewByName("lb_name_lv")
	setTextCCColor(self.pLbNameLV, _cc.blue)
	--资质
	self.pLbZizhi = self:findViewByName("lb_zizhi")	

end

-- 修改控件内容或者是刷新控件数据
function RankHeroInfo:updateViews( )
	-- body
	if self.tCurData then
		self:setVisible(true)
		local therobasedata = getHeroDataById(self.tCurData.id)
		if self.tCurData.hs then
			therobasedata.nIg = self.tCurData.hs.ig
		end
		local pIcon = getIconHeroByType(self.pLayIcon, TypeIconHero.NORMAL, therobasedata , TypeIconHeroSize.M)
		pIcon:setHeroType()
		pIcon:setIconIsCanTouched(false)		
		--武将的名字等级
		self.pLbNameLV:setString(therobasedata.sName..getLvString(self.tCurData.lv, false))
		--总资质
		local sStr = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10249)},
			{color=_cc.green, text=self.tCurData.tt},
		}
		self.pLbZizhi:setString(sStr, false)
	else
		self:setVisible(false)
	end
end

-- 析构方法
function RankHeroInfo:onRankHeroInfoDestroy( )
	-- body
end

function RankHeroInfo:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

return RankHeroInfo