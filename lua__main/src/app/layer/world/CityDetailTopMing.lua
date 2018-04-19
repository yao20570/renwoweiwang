----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 信息层 系统名城信息
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local CityDetailTopMing = class("CityDetailTopMing", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nSysCityId :world_city id
function CityDetailTopMing:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	--解析文件
	parseView("lay_city_detail_top_ming", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CityDetailTopMing:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CityDetailTopMing", handler(self, self.onCityDetailTopMingDestroy))
end

-- 析构方法
function CityDetailTopMing:onCityDetailTopMingDestroy(  )
    self:onPause()
end

function CityDetailTopMing:regMsgs(  )
end

function CityDetailTopMing:unregMsgs(  )
end

function CityDetailTopMing:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function CityDetailTopMing:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function CityDetailTopMing:setupViews(  )
	--城名
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)

	--城坐标
	local pTxtPosTitle = self:findViewByName("txt_pos_title")
	pTxtPosTitle:setString(getConvertedStr(3, 10134))
	self.pTxtPos = self:findViewByName("txt_pos")
	setTextCCColor(self.pTxtPos, _cc.blue)

	--城图标
	self.pLayIcon = self:findViewByName("lay_icon")

	--名字图片
	-- self.pImgRename = self:findViewByName("img_rename")
	-- self.pImgRename:setViewTouched(true)
	-- self.pImgRename:onMViewClicked(handler(self, self.onRenameClicked))

	--改名按钮
	self.pLayRename = self:findViewByName("lay_btn_rename")
	self.pBtnRename = getCommonButtonOfContainer(self.pLayRename,TypeCommonBtn.M_BLUE, getConvertedStr(7, 10299))
	setMCommonBtnScale(self.pLayRename, self.pBtnRename, 0.8)
	self.pBtnRename:onCommonBtnClicked(handler(self, self.onRenameClicked))

	--城主
	local pTxtOwnerTitle = self:findViewByName("txt_owner_title")
	pTxtOwnerTitle:setString(getConvertedStr(3, 10135))
	self.pTxtOwnerName = self:findViewByName("txt_owner_name")
	setTextCCColor(self.pTxtOwnerName, _cc.blue)

	--国旗
	self.pImgFlag = self:findViewByName("img_flag")

	--人口
	self.pTxtPeopleTitle = self:findViewByName("txt_people_title")
	self.pTxtPeopleTitle:setString(getConvertedStr(3, 10341))

	self.pTxtPeople = self:findViewByName("txt_people")
	setTextCCColor(self.pTxtPeople, _cc.blue) 
	self.pTxtPeople:setString(getBuildParam("cityPeople"))

	--兵力
	local pTroopsTitle = self:findViewByName("txt_troops_title")
	pTroopsTitle:setString(getConvertedStr(3, 10136))
	self.pLayRichtextTroops = self:findViewByName("lay_richtext_troops")
	local tStr = {
		    {color=_cc.green,text="0"},
		    {color=_cc.white,text="/0"},
		}
	self.pRichtextTroops = getRichLabelOfContainer(self.pLayRichtextTroops, tStr)

	--剩余任期
	local pTxtRemainCdTitle = self:findViewByName("txt_remain_cd_title")
	pTxtRemainCdTitle:setString(getConvertedStr(3, 10137))

	self.pTxtCd = self:findViewByName("txt_remain_cd")
	setTextCCColor(self.pTxtCd, _cc.red)
end

function CityDetailTopMing:updateName( )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--名字
	self.pTxtName:setString(string.format("%s %s", tViewDotMsg:getDotName(), getLvString(tViewDotMsg.nDotLv)))
end

function CityDetailTopMing:updateViews(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--名字
	self:updateName()
	--坐标
	self.pTxtPos:setString(getWorldPosString(tViewDotMsg.nX, tViewDotMsg.nY))
	--国旗
	WorldFunc.setImgCountryFlag(self.pImgFlag, tViewDotMsg.nDotCountry)
	--图标
	WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tViewDotMsg.nSystemCityId, tViewDotMsg.nSysCountry ,true)

	--改名
	self.pLayRename:setVisible(tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence)

	--群雄势力（没有城主)
	if tViewDotMsg.nSysCountry == e_type_country.qunxiong then
		--城主名
		self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
		setTextCCColor(self.pTxtOwnerName, _cc.green)
		--cd时间
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
			self.pTxtOwnerName:setString(sOwnerName .. getLvString(nOwnerLv))
			setTextCCColor(self.pTxtOwnerName, _cc.blue)
			--cd时间
			self.pTxtCd:setVisible(true)
			--兵力
			self.pRichtextTroops:updateLbByNum(1, tostring(tViewDotMsg.nCurrGarrisonTroops))
			self.pRichtextTroops:updateLbByNum(2, "/"..tostring(tViewDotMsg.nGarrisonTroopsMax))
		else
			--城主名
			self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
			setTextCCColor(self.pTxtOwnerName, _cc.green)
			--cd时间
			self.pTxtCd:setVisible(false)
			--兵力
			self.pRichtextTroops:updateLbByNum(1, tostring(tViewDotMsg.nCurrGarrisonTroops))
			self.pRichtextTroops:updateLbByNum(2, "/"..tostring(tViewDotMsg.nGarrisonTroopsMax))
		end
	end
	self:updateCd()
end

function CityDetailTopMing:updateCd(  )
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

--改名按钮
function CityDetailTopMing:onRenameClicked( pView )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	
	if tViewDotMsg.nSysCityOwnerId ~= Player:getPlayerInfo().pid then
		TOAST(getConvertedStr(3, 10377))
		return
	end

	local tData = {
		nCityId = tViewDotMsg.nSystemCityId,
		sCityName = tViewDotMsg:getDotName(),
	}
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.rename, --dlg类型
	    tData = tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end


return CityDetailTopMing


