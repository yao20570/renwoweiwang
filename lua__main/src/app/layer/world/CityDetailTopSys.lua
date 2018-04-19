----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 信息层 系统城池信息
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local CityDetailTopSys = class("CityDetailTopSys", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nSysCityId :world_city id
function CityDetailTopSys:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	--解析文件
	parseView("lay_city_detail_top_sys", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CityDetailTopSys:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CityDetailTopSys", handler(self, self.onCityDetailTopSysDestroy))
end

-- 析构方法
function CityDetailTopSys:onCityDetailTopSysDestroy(  )
    self:onPause()
end

function CityDetailTopSys:regMsgs(  )
end

function CityDetailTopSys:unregMsgs(  )
end

function CityDetailTopSys:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function CityDetailTopSys:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function CityDetailTopSys:setupViews(  )
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	local pTxtPosTitle = self:findViewByName("txt_pos_title")
	pTxtPosTitle:setString(getConvertedStr(3, 10134))
	self.pLayIcon = self:findViewByName("lay_icon")

	self.pTxtPos = self:findViewByName("txt_pos")
	setTextCCColor(self.pTxtPos, _cc.blue)
	local pTxtOwnerTitle = self:findViewByName("txt_owner_title")
	pTxtOwnerTitle:setString(getConvertedStr(3, 10135))

	self.pTxtOwnerName = self:findViewByName("txt_owner_name")
	setTextCCColor(self.pTxtOwnerName, _cc.blue)
	self.pImgFlag = self:findViewByName("img_flag")
	local pTroopsTitle = self:findViewByName("txt_troops_title")
	pTroopsTitle:setString(getConvertedStr(3, 10136))

	self.pLayRichtextTroops = self:findViewByName("lay_richtext_troops")
	local tStr = {
		    {color=_cc.green,text="0"},
		    {color=_cc.white,text="/0"},
		}
	self.pRichtextTroops = getRichLabelOfContainer(self.pLayRichtextTroops, tStr)

	local pTxtRemainCdTitle = self:findViewByName("txt_remain_cd_title")
	pTxtRemainCdTitle:setString(getConvertedStr(3, 10137))
	self.pTxtRemainCdTitle = pTxtRemainCdTitle

	self.pTxtCd = self:findViewByName("txt_remain_cd")
	setTextCCColor(self.pTxtCd, _cc.red)
end

function CityDetailTopSys:updateViews(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	--名字
	self.pTxtName:setString(string.format("%s %s", tViewDotMsg:getDotName(), getLvString(tViewDotMsg.nDotLv)))
	--坐标
	self.pTxtPos:setString(getWorldPosString(tViewDotMsg.nX, tViewDotMsg.nY))
	--国旗
	WorldFunc.setImgCountryFlag(self.pImgFlag, tViewDotMsg.nDotCountry)
	--图标
	WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tViewDotMsg.nSystemCityId, tViewDotMsg.nSysCountry ,true)

	--群雄势力（没有城主)
	if tViewDotMsg.nSysCountry == e_type_country.qunxiong then
		--城主名
		self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
		setTextCCColor(self.pTxtOwnerName, _cc.green)
		--cd时间
		self.pTxtRemainCdTitle:setVisible(false)
		self.pTxtCd:setVisible(false)
		--兵力
		self.pRichtextTroops:updateLbByNum(1, tostring(tViewDotMsg.nCurrGarrisonTroops))
		self.pRichtextTroops:updateLbByNum(2, "/"..tostring(tViewDotMsg.nGarrisonTroopsMax))
	else
		--有城主
		if tViewDotMsg:getIsSysCityHasOwner() then
			local sOwnerName = tViewDotMsg:getSysCityOwnerName()
			local nOwnerLv = tViewDotMsg:getSysCityOwnerLv()
			--城主名
			self.pTxtOwnerName:setString(sOwnerName.. getLvString(nOwnerLv))
			setTextCCColor(self.pTxtOwnerName, _cc.blue)
			--cd时间
			self.pTxtRemainCdTitle:setVisible(true)
			self.pTxtCd:setVisible(true)
			--兵力
			self.pRichtextTroops:updateLbByNum(1, tostring(tViewDotMsg.nCurrGarrisonTroops))
			self.pRichtextTroops:updateLbByNum(2, "/"..tostring(tViewDotMsg.nGarrisonTroopsMax))
		else
			--城主名
			self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
			setTextCCColor(self.pTxtOwnerName, _cc.green)
			--cd时间
			self.pTxtRemainCdTitle:setVisible(false)
			self.pTxtCd:setVisible(false)
			--兵力
			self.pRichtextTroops:updateLbByNum(1, tostring(tViewDotMsg.nCurrGarrisonTroops))
			self.pRichtextTroops:updateLbByNum(2, "/"..tostring(tViewDotMsg.nGarrisonTroopsMax))
		end
	end
end

function CityDetailTopSys:updateCd(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	local nCd = tViewDotMsg:getRetireTime()
	if nCd > 0 then
		self.pTxtCd:setString(getTimeFormatCn(nCd))
	else
		unregUpdateControl(self)
	end
end

return CityDetailTopSys


