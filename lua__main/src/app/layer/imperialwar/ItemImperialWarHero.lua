----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 14:50:00
-- Description: 战斗战场武将 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemImperialWarHero = class("ItemImperialWarHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemImperialWarHero:ctor(  )
	--解析文件
	parseView("item_imperial_war_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemImperialWarHero:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemImperialWarHero", handler(self, self.onItemImperialWarHeroDestroy))
end

-- 析构方法
function ItemImperialWarHero:onItemImperialWarHeroDestroy(  )
    self:onPause()
end

function ItemImperialWarHero:regMsgs(  )
end

function ItemImperialWarHero:unregMsgs(  )
end

function ItemImperialWarHero:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemImperialWarHero:onPause(  )
	self:unregMsgs()
end

function ItemImperialWarHero:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	local pTxtTroopsTitle = self:findViewByName("txt_troops_title")
	pTxtTroopsTitle:setString(getConvertedStr(3, 10183))
	self.pTxtState = self:findViewByName("txt_state")
	self.pTxtTroops = self:findViewByName("txt_troops")

	local pLayBarTroops = self:findViewByName("lay_bar_troops")
	local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
	self.pBarTroops = MCommonProgressBar.new({bar = "v1_bar_blue_3a.png",barWidth = 212, barHeight = 20})
    pLayBarTroops:addView(self.pBarTroops,1)
    centerInView(pLayBarTroops, self.pBarTroops)
end

function ItemImperialWarHero:updateViews(  )
	if not self.tData then
		return
	end

	local tHeroShowVo = self.tData:getHeroVo()
	local tHeroData = heroShowVoParseHeroData(tHeroShowVo)
	self.pIcon = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,tHeroData,TypeIconHeroSize.M)
	self.pIcon:setIconIsCanTouched(false)
	self.pIcon:setHeroType()
	self.pBarTroops:setPercent(self.tData:getTroopsCurr()/self.tData:getTroopsMax()*100)
	self.pTxtTroops:setString(string.format("<font color='#%s'>%s</font>/%s", _cc.yellow, self.tData:getTroopsCurr(), self.tData:getTroopsMax()))
	if self.tData:getTroopsCurr() > 0 then
		self.pTxtState:setString(getConvertedStr(3, 10926)) 
		setTextCCColor(self.pTxtState, _cc.green)
	else
		self.pTxtState:setString(getConvertedStr(3, 10925)) 
		setTextCCColor(self.pTxtState, _cc.red)
	end

	--武将名字
	if tHeroData then
		self.pTxtName:setString(tHeroData.sName .. getLvString(self.tData:getHeroLv()))
		setTextCCColor(self.pTxtName, getColorByQuality(tHeroData.nQuality))
	end
end

--tData: tMyHeroShow
function ItemImperialWarHero:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemImperialWarHero


