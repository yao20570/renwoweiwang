----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-23 14:48:37
-- Description: 侦查界面 武将列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemDetectMailCityHero = class("ItemDetectMailCityHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemDetectMailCityHero:ctor(  )
	--解析文件
	parseView("item_detect_mail_city_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemDetectMailCityHero:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemDetectMailCityHero", handler(self, self.onItemDetectMailCityHeroDestroy))
end

-- 析构方法
function ItemDetectMailCityHero:onItemDetectMailCityHeroDestroy(  )
    self:onPause()
end

function ItemDetectMailCityHero:regMsgs(  )
end

function ItemDetectMailCityHero:unregMsgs(  )
end

function ItemDetectMailCityHero:onResume(  )
	self:regMsgs()
end

function ItemDetectMailCityHero:onPause(  )
	self:unregMsgs()
end

function ItemDetectMailCityHero:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	local pTroopsTitle = self:findViewByName("txt_troops_title")
	pTroopsTitle:setString(getConvertedStr(3, 10124))
	self.pTxtTroops = self:findViewByName("txt_troops")
	setTextCCColor(self.pTxtTroops, _cc.blue)
	self.pTxtLocation = self:findViewByName("txt_location")
	self.pTxtFriendName = self:findViewByName("txt_friend_name")
	setTextCCColor(self.pTxtFriendName, _cc.blue)
end

function ItemDetectMailCityHero:updateViews(  )
	if not self.tScoutHeroInfo then
		return
	end
	local nHeroId = self.tScoutHeroInfo.nTemplate or self.tScoutHeroInfo.nHeroId
	local tHeroData = getGoodsByTidFromDB(nHeroId)
	if tHeroData then
		if self.tScoutHeroInfo.nIg then
			tHeroData.nIg = self.tScoutHeroInfo.nIg
		end
		local pHeroIcon = getIconHeroByType(self.pLayIcon, TypeIconHero.NORMAL, tHeroData, TypeIconHeroSize.L)
		pHeroIcon:setHeroType()
		self.pTxtName:setString(string.format("%s %s", tHeroData.sName, getLvString(self.tScoutHeroInfo.nHeroLv)))
	end


	self.pTxtTroops:setString(self.tScoutHeroInfo.nTroops)

	-- 出征武将：
	-- 前往途中                位置：X分钟到达xxxx Lv.？  （xxxx=目标名称）
	-- 返回途中                位置：X分钟返回主城
	-- 停留在主城              位置：城池防守中
	-- 停留在矿点 / 其他城池   位置：xxxx Lv.？  （xxxx=目标名称）

	-- 城门守军：
	-- 停留在主城               位置：城池防守中

	-- 其他玩家协防：
	-- 停留在主城               位置：城池防守中    （同时要显示协防玩家名称和等级）
	if self.tScoutHeroInfo.nHeroState == e_state_hero_scout.go then
		self.pTxtLocation:setString(string.format(getConvertedStr(3, 10236), formatTimeToStr(self.tScoutHeroInfo.nCd, false ,true), self.tScoutHeroInfo.sTarget, getLvString(self.tScoutHeroInfo.nTargetLv)))
	elseif self.tScoutHeroInfo.nHeroState == e_state_hero_scout.back then
		self.pTxtLocation:setString(string.format(getConvertedStr(3, 10155), formatTimeToStr(self.tScoutHeroInfo.nCd, false ,true)))
	elseif self.tScoutHeroInfo.nHeroState == e_state_hero_scout.garrison then
		self.pTxtLocation:setString(getConvertedStr(3, 10235))
	elseif self.tScoutHeroInfo.nHeroState == e_state_hero_scout.stay  then
		self.pTxtLocation:setString(string.format(getConvertedStr(3, 10237), self.tScoutHeroInfo.sTarget, getLvString(self.tScoutHeroInfo.nTargetLv)))
	end

	--友军信息
	if self.tScoutHeroInfo.sGarrisonName and self.tScoutHeroInfo.nGarrsionLv and self.tScoutHeroInfo.nGarrsionCountry then
		self.pTxtFriendName:setVisible(true)
		local sStr = getCountryShortName(self.tScoutHeroInfo.nGarrsionCountry, true) .. self.tScoutHeroInfo.sGarrisonName .. getLvString(self.tScoutHeroInfo.nGarrsionLv)
		self.pTxtFriendName:setString(sStr)
	else
		self.pTxtFriendName:setVisible(false)
	end
end

--tScoutHeroInfo
function ItemDetectMailCityHero:setData( tScoutHeroInfo )
	self.tScoutHeroInfo = tScoutHeroInfo
	self:updateViews()
end

return ItemDetectMailCityHero


