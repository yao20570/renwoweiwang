----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-01 11:02:0
-- Description: 城池详细界面 信息层 系统城池信息
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local SysCityDetailTop = class("SysCityDetailTop", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nSysCityId :world_city id
function SysCityDetailTop:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	--解析文件
	parseView("layout_sys_city_detail_top", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SysCityDetailTop:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("SysCityDetailTop", handler(self, self.onSysCityDetailTopDestroy))
end

-- 析构方法
function SysCityDetailTop:onSysCityDetailTopDestroy(  )
    self:onPause()
end

function SysCityDetailTop:regMsgs(  )
	regMsg(self,ghd_update_city_owner_apply,handler(self,self.updateViews))
end

function SysCityDetailTop:unregMsgs(  )
	unregMsg(self,ghd_update_city_owner_apply)
end

function SysCityDetailTop:onResume(  )
	self:regMsgs()
	
	self:updateViews()
end

function SysCityDetailTop:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function SysCityDetailTop:setupViews(  )
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pLayIcon = self:findViewByName("lay_icon")
	local pTxtOwnerTitle = self:findViewByName("txt_owner_title")
	pTxtOwnerTitle:setString(getConvertedStr(3, 10135))

	self.pTxtOwnerName = self:findViewByName("txt_owner_name")
	setTextCCColor(self.pTxtOwnerName, _cc.blue)
	self.pImgFlag = self:findViewByName("img_flag")
	local pTroopsTitle = self:findViewByName("txt_troops_title")
	pTroopsTitle:setString(getConvertedStr(3, 10136))
	self.pTxtTroops = self:findViewByName("txt_troops")

	local pTxtRemainCdTitle = self:findViewByName("txt_remain_cd_title")
	pTxtRemainCdTitle:setString(getConvertedStr(3, 10137))
	self.pTxtRemainCdTitle = pTxtRemainCdTitle

	self.pTxtCd = self:findViewByName("txt_remain_cd")
	setTextCCColor(self.pTxtCd, _cc.red)
end

function SysCityDetailTop:updateViews(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	--名字
	self.pTxtName:setString(string.format("%s %s", tViewDotMsg:getDotName(), getLvString(tViewDotMsg.nDotLv)))
	--国旗
	WorldFunc.setImgCountryFlag(self.pImgFlag, tViewDotMsg.nDotCountry)
	--图标
	WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tViewDotMsg.nSystemCityId, tViewDotMsg.nSysCountry ,true)

	--群雄势力（没有城主)
	if tViewDotMsg.nSysCountry == e_type_country.qunxiong then
		--城主名
		self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
		-- setTextCCColor(self.pTxtOwnerName, _cc.green)
		--cd时间
		self.pTxtRemainCdTitle:setVisible(false)
		self.pTxtCd:setVisible(false)

		-- local nTroops = getQunxiongTroopsById(tViewDotMsg.nSystemCityId)
		-- --兵力
		-- local tStr = {
		--     {color=_cc.green,text=tostring(nTroops)},
		--     {color=_cc.white,text="/"..tostring(nTroops)},
		-- }
		-- self.pTxtTroops:setString(tStr)

	else
		--有城主
		if tViewDotMsg:getIsSysCityHasOwner() then
			local sOwnerName = tViewDotMsg:getSysCityOwnerName()
			local nOwnerLv = tViewDotMsg:getSysCityOwnerLv()
			--城主名
			self.pTxtOwnerName:setString(sOwnerName.. getLvString(nOwnerLv))
			-- setTextCCColor(self.pTxtOwnerName, _cc.blue)
			--cd时间
			unregUpdateControl(self)
			regUpdateControl(self, handler(self, self.updateCd))
			self.pTxtRemainCdTitle:setVisible(true)
			self.pTxtCd:setVisible(true)
		else

			--城主名
			self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
			-- setTextCCColor(self.pTxtOwnerName, _cc.green)
			--cd时间
			self.pTxtRemainCdTitle:setVisible(false)
			self.pTxtCd:setVisible(false)
		end
	end
	--兵力
	local tStr = {
	    {color=_cc.green,text=tostring(tViewDotMsg.nCurrGarrisonTroops)},
	    {color=_cc.white,text="/"..tostring(tViewDotMsg.nGarrisonTroopsMax)},
	}
	self.pTxtTroops:setString(tStr)
	
end

function SysCityDetailTop:updateCd(  )
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

return SysCityDetailTop


