----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-01 11:02:0
-- Description: 城池详细界面 信息层 系统城池信息
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local SysCityDetailTopMing = class("SysCityDetailTopMing", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nSysCityId :world_city id
function SysCityDetailTopMing:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	--解析文件
	parseView("layout_sys_city_detail_top_ming", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SysCityDetailTopMing:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("SysCityDetailTopMing", handler(self, self.onSysCityDetailTopMingDestroy))
end

-- 析构方法
function SysCityDetailTopMing:onSysCityDetailTopMingDestroy(  )
    self:onPause()
end

function SysCityDetailTopMing:regMsgs(  )
end

function SysCityDetailTopMing:unregMsgs(  )
end

function SysCityDetailTopMing:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function SysCityDetailTopMing:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function SysCityDetailTopMing:setupViews(  )
	--城名
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)

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
	self.pTxtTroops = self:findViewByName("txt_troops")

	--剩余任期
	local pTxtRemainCdTitle = self:findViewByName("txt_remain_cd_title")
	pTxtRemainCdTitle:setString(getConvertedStr(3, 10137))
	self.pTxtRemainCdTitle = pTxtRemainCdTitle

	self.pTxtCd = self:findViewByName("txt_remain_cd")
	setTextCCColor(self.pTxtCd, _cc.red)
end

function SysCityDetailTopMing:updateName( )
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

function SysCityDetailTopMing:updateViews(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--名字
	self:updateName()
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
		-- setTextCCColor(self.pTxtOwnerName, _cc.green)
		--cd时间
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
			self.pTxtOwnerName:setString(sOwnerName .. getLvString(nOwnerLv))
			-- setTextCCColor(self.pTxtOwnerName, _cc.blue)
			--cd时间
			self.pTxtCd:setVisible(true)
		else
			--城主名
			self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
			-- setTextCCColor(self.pTxtOwnerName, _cc.green)
			self.pTxtRemainCdTitle:setVisible(false)
			--cd时间
			self.pTxtCd:setVisible(false)
		end
	end
	--兵力
	local tStr = {
	    {color=_cc.green,text=tostring(tViewDotMsg.nCurrGarrisonTroops)},
	    {color=_cc.white,text="/"..tostring(tViewDotMsg.nGarrisonTroopsMax)},
	}
	self.pTxtTroops:setString(tStr)
	

	self:updateCd()
end

function SysCityDetailTopMing:updateCd(  )
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
function SysCityDetailTopMing:onRenameClicked( pView )
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


return SysCityDetailTopMing


