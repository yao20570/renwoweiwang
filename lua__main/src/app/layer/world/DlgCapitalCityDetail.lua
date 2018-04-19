----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-25 15:13:34
-- Description: 系统都城详细界面
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local AlignContainerLayer = require("app.layer.world.AlignContainerLayer")

local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local nArmysCol = 3 --御林军列

local DlgCapitalCityDetail = class("DlgCapitalCityDetail", function()
	return DlgCommon.new(e_dlg_index.syscitydetail, 800 - 60 - 130, 130)
end)

--nSysCityId :world_city id
function DlgCapitalCityDetail:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	parseView("dlg_capital_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCapitalCityDetail:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10021))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCapitalCityDetail",handler(self, self.onDlgCapitalCityDetailDestroy))
end

-- 析构方法
function DlgCapitalCityDetail:onDlgCapitalCityDetailDestroy(  )
    self:onPause()
end

function DlgCapitalCityDetail:regMsgs(  )
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))
	-- regMsg(self, ghd_syscity_rename_success_msg, handler(self, self.updateName))
	
end

function DlgCapitalCityDetail:unregMsgs(  )
	unregMsg(self, gud_world_dot_change_msg)
	-- unregMsg(self, ghd_syscity_rename_success_msg)
end

function DlgCapitalCityDetail:onResume(  )
	self:regMsgs()
end

function DlgCapitalCityDetail:onPause(  )
	self:unregMsgs()
end

function DlgCapitalCityDetail:setupViews(  )
	--ui位置更新
	local tUiPos = {
		{sUiName = "lay_info", nTopSpac = 12},
		{sUiName = "lay_content", nTopSpac = 10},
		{sUiName = "lay_btn", nBottomSpac = 20},
		{sUiName = "txt_bottom_tip3", nBottomSpac = 10},
	}
	restUiPosByData(tUiPos, self.pView)
	--ui位置更新

	local pLayInfo = self:findViewByName("lay_info")
	setGradientBackground(pLayInfo)

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

	--国旗
	self.pImgFlag = self:findViewByName("img_flag")

	--人口
	self.pTxtPeopleTitle = self:findViewByName("txt_people_title")
	self.pTxtPeopleTitle:setString(getConvertedStr(3, 10341))

	self.pTxtPeople = self:findViewByName("txt_people")
	setTextCCColor(self.pTxtPeople, _cc.blue) 

	--御林军等级
	self.pTxtArmyLvTitle = self:findViewByName("txt_army_lv_title")
	self.pTxtArmyLvTitle:setString(getConvertedStr(3, 10342))
	self.pTxtArmyLv = self:findViewByName("txt_army_lv")

	--经验
	self.pTxtExpTitle = self:findViewByName("txt_exp_title")
	self.pTxtExpTitle:setString(getConvertedStr(3, 10343))
	local pLayExpBg = self:findViewByName("lay_exp_bg")
	self.pLayExpBg = pLayExpBg
	local pSize = pLayExpBg:getContentSize()
	self.pBarExp = MCommonProgressBar.new({bar = "v1_bar_blue_3.png", barWidth = pSize.width, barHeight = pSize.height})
	self.pBarExp:setPosition(pSize.width/2, pSize.height/2)
	pLayExpBg:addView(self.pBarExp)
	--经验条组合文本
	local tConTable = {}
	local tLb= {
		{"0",getC3B(_cc.blue)},
		{"/0",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLb
	self.pGroupTextExp =  createGroupText(tConTable)
	self.pGroupTextExp:setAnchorPoint(0.5, 0.5)

	self.pGroupTextExp:setPosition(pSize.width/2, pSize.height/2)
	pLayExpBg:addView(self.pGroupTextExp)

	--御林军
	self.pLayArmys = self:findViewByName("lay_armys")
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, self.pLayArmys:getContentSize().width, self.pLayArmys:getContentSize().height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left =  0,
             right =  0,
             top =  5,
             bottom =  5},
    }
    self.pLayArmys:addView(self.pListView)
    self.pListView:setItemCount(0) 
    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))

	--军队描述
	self.pTxtArmyTip1 = self:findViewByName("txt_army_tip1")
	self.pTxtArmyTip3 = self:findViewByName("txt_army_tip3")
	self.pTxtArmyTip3:setString(getConvertedStr(3, 10344))
	setTextCCColor(self.pTxtArmyTip3, _cc.red)
	self.pTxtArmyTip1:setString(getTipsByIndex(10016))

	--国家介绍
	self.pTxtCityTip1 = self:findViewByName("txt_city_tip1")
	local sStr = getTipsByIndex(10017)
	self.pTxtCityTip1:setString(sStr, false)
	local pLayContent = self:findViewByName("lay_content")
	centerInView(pLayContent, self.pTxtCityTip1)

	--bottom文字
	local pLayView = self:findViewByName("view")
	self.pTxtBottomTip1 = MUI.MLabel.new({
            text = "",
            size = 20,
            anchorpoint = cc.p(0, 1),
            align = cc.ui.TEXT_ALIGN_LEFT,
            valign = cc.ui.TEXT_VALIGN_TOP,
            -- color = cc.c3b(255, 255, 255),
            dimensions = cc.size(520, 0),
        })
	pLayView:addView(self.pTxtBottomTip1, 2)
	self.pTxtBottomTip1:setPosition(19, 210)
	-- self.pTxtBottomTip1 = self:findViewByName("txt_bottom_tip1")
	self.pTxtBottomTip1:setString(getTipsByIndex(10015))

	self.pTxtBottomTip2 = self:findViewByName("txt_bottom_tip2")
	self.pTxtBottomTip2:setString(getConvertedStr(3, 10345))
	setTextCCColor(self.pTxtBottomTip2, _cc.gray) 
	self.pTxtBottomTip3 = self:findViewByName("txt_bottom_tip3")

	--国战按钮
	self.pLayBtn = self:findViewByName("lay_btn")
	local pBtnWar = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10082))
	pBtnWar:onCommonBtnClicked(handler(self, self.onWarClicked))
	self.pBtnWar = pBtnWar
end

--名字
function DlgCapitalCityDetail:updateName(  )
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


function DlgCapitalCityDetail:updateViews(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--城池名字
	self:updateName()
	--坐标
	self.pTxtPos:setString(getWorldPosString(tViewDotMsg.nX, tViewDotMsg.nY))
	--国旗
	WorldFunc.setImgCountryFlag(self.pImgFlag, tViewDotMsg.nDotCountry)
	--图标
	WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tViewDotMsg.nSystemCityId, tViewDotMsg.nSysCountry ,true)
	
	--人口
	local tWorldCapital = getWorldCapitalData(tViewDotMsg.nDotLv)
	if tWorldCapital then
		self.pTxtPeople:setString(tWorldCapital.people)
	end

	--隐藏或显示国战按钮
	self.pBtnWar:setVisible(tViewDotMsg:getIsCanCountryWar())

	--群雄势力（没有城主)
	if tViewDotMsg.nSysCountry == e_type_country.qunxiong and not tViewDotMsg:getIsCapitalQun() then
		self.pBtnRename:setVisible(false)
		self.pTxtArmyLvTitle:setVisible(false)
		self.pTxtArmyLv:setVisible(false)
		self.pTxtExpTitle:setVisible(false)
		self.pLayExpBg:setVisible(false)
		self.pLayArmys:setVisible(false)
		self.pTxtArmyTip1:setVisible(false)
		self.pTxtArmyTip3:setVisible(false)
		self.pTxtCityTip1:setVisible(true)
		-- self.pTxtCityTip2:setVisible(true)
		-- self.pTxtCityTip3:setVisible(true)
		self.pTxtBottomTip1:setVisible(false)
		self.pTxtBottomTip2:setVisible(true)
		self.pTxtBottomTip3:setVisible(false)
		self.pLayBtn:setVisible(true)
	else
		self.pTxtArmyLvTitle:setVisible(true)
		self.pTxtArmyLv:setVisible(true)
		self.pTxtExpTitle:setVisible(true)
		self.pTxtCityTip1:setVisible(false)
		-- self.pTxtCityTip2:setVisible(false)
		-- self.pTxtCityTip3:setVisible(false)
		self.pTxtBottomTip1:setVisible(true)
		self.pTxtBottomTip2:setVisible(false)
		self.pLayBtn:setVisible(false)

		--御林军解锁
		if tViewDotMsg.bIsPGuardsUnlock then
			--御林军等级
			if tWorldCapital then
				local tOpen = luaSplit(tWorldCapital.open, ",") 
				if #tOpen == 1 then
					self.pTxtArmyLv:setString(getLvString(tOpen[1]))
				elseif #tOpen > 1 then
					self.pTxtArmyLv:setString(getLvString(tOpen[1]) .. "-" .. getLvString(tOpen[#tOpen]))
				end
				setTextCCColor(self.pTxtArmyLv, _cc.green)

				--御林军
				local tArmysList = {}
				local tConf = getWorldInitData("yljConf")
				for i=1,#tOpen do
					local nLv = tonumber(tOpen[i])
					local nId = tConf[nLv]
					if nId then
						local tNpcList = getNpcGropById(nId)
						if tNpcList then
							for j=1,#tNpcList do
								table.insert(tArmysList, tNpcList[j])
							end
						end
					end
				end
				
				
				local bIsReload = true
				if self.tArmysList then
					if math.ceil(#self.tArmysList/nArmysCol) == math.ceil(#tArmysList/nArmysCol) then
						bIsReload = false
					end
				end
				self.tArmysList = tArmysList
				if bIsReload then
					if self.pListView:getItemCount() > 0 then
					    self.pListView:removeAllItems()
					end
					self.pListView:setItemCount(math.ceil(#self.tArmysList/nArmysCol))
				    self.pListView:reload()
				else
					self.pListView:notifyDataSetChange(true)
				end
				-----

			end
			--中间显示
			self.pTxtArmyTip3:setVisible(false)
			self.pLayArmys:setVisible(true)
		else
			--御林军等级
			self.pTxtArmyLv:setString(getConvertedStr(3, 10347))
			setTextCCColor(self.pTxtArmyLv, _cc.red)
			--中间显示
			self.pTxtArmyTip3:setVisible(true)
			self.pLayArmys:setVisible(false)
		end

		--同势力
		if tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
			--经验
			self.pTxtExpTitle:setVisible(true)
			self.pLayExpBg:setVisible(true)

			--显示改名卡
			self.pBtnRename:setVisible(true)
			self.pTxtBottomTip1:setVisible(true)

			--最高等级
			local nCapitalLvMax = getWorldCapitalLvMax()
			if tViewDotMsg.nSystemCityLv >= nCapitalLvMax then
				-- self.pTxtBottomTip1:setVisible(false)
				self.pTxtBottomTip3:setVisible(true)
				self.pTxtBottomTip3:setString(getConvertedStr(3, 10346)) 
				setTextCCColor(self.pTxtBottomTip3, _cc.green)
				--显示经验条
				if tWorldCapital then
					self.pBarExp:setPercent(100)
					self.pGroupTextExp:setLabelCnCr(1,tWorldCapital.exp)
					self.pGroupTextExp:setLabelCnCr(2,"/"..tostring(tWorldCapital.exp))
				end
			else
				-- self.pTxtBottomTip1:setVisible(true)
				self.pTxtBottomTip3:setVisible(false)
				--显示经验条
				if tWorldCapital then
					self.pBarExp:setPercent(tViewDotMsg.nSysCityExp/tWorldCapital.exp*100)
					self.pGroupTextExp:setLabelCnCr(1,tViewDotMsg.nSysCityExp)
					self.pGroupTextExp:setLabelCnCr(2,"/"..tostring(tWorldCapital.exp))
				end
			end

		--不同势力
		else
			--经验
			self.pTxtExpTitle:setVisible(false)
			self.pLayExpBg:setVisible(false)
			self.pBtnRename:setVisible(false)

			--
			self.pTxtBottomTip3:setVisible(true)
			self.pTxtBottomTip3:setString(getConvertedStr(3, 10348)) 
			setTextCCColor(self.pTxtBottomTip3, _cc.white)
		end		
	end
end

--列表回调
function DlgCapitalCityDetail:onListViewItemCallBack( _index, _pView)
    local pTempView = _pView
    if pTempView == nil then
    	local tParam = {
    		size = cc.size(520, 108),
    		align = 2,
    		margin = 80,
    		leftpos = cc.p(50, 0),
    	}
        pTempView = AlignContainerLayer.new(tParam)
    end

    --数据
    local nIndex = (_index - 1) * nArmysCol
    for i=1,nArmysCol do
    	local pLayIcon = pTempView:getUiByIndex(i)
    	local tTempData = self.tArmysList[nIndex + i]
    	if tTempData then
    		if not pLayIcon then
    			pLayIcon = MUI.MLayer.new()
    			pLayIcon:setLayoutSize(108*0.8, 108*0.8)
    			pTempView:addUi(pLayIcon)
    		else
    			pLayIcon:setVisible(true)
    		end
    		--是否出战
    		local bIsBattled = false
    		if self.nSysCityId then
				local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
				if tViewDotMsg then
	    			bIsBattled = tViewDotMsg:getPGuardIsBattled(tTempData.sTid)
	    		end
	    	end
    		--图标
    		local pIcon = getIconHeroByType(pLayIcon, TypeIconHero.NORMAL, tTempData, TypeIconHeroSize.M)
    		if pIcon then
				pIcon:setCurData(tTempData)
				pIcon:setHeroType()
				pIcon:setBottomText(tTempData.sName .. getLvString(tTempData.nLevel))
				--是否出战
	    		if bIsBattled then
	    			pIcon:setRBBlackBgStr(getConvertedStr(3, 10352), _cc.yellow)
	    		else
	    			pIcon:setRBBlackBgStr(nil)
	    		end
			end
    	else
    		if pLayIcon then
    			pLayIcon:setVisible(false)
    		end
    	end
    end
    --第一行才居中
    if _index > 1 then
    	pTempView:setAlignType(1)
    else
    	pTempView:setAlignType(2)
    end
    pTempView:refreshUisPos() --刷新位置
    return pTempView
end

--国战按钮
function DlgCapitalCityDetail:onWarClicked( pView )
	if not self.nSysCityId then
		return
	end
	sendMsg(ghd_world_country_war_req_msg, self.nSysCityId)
end

--改名按钮
function DlgCapitalCityDetail:onRenameClicked( pView )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	local bIsKing = false
	local tCountryDataVo = Player:getCountryData():getCountryDataVo()
	if tCountryDataVo then
		bIsKing = tCountryDataVo:isKing()
	end
	if not bIsKing then
		TOAST(getConvertedStr(3, 10376))
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

--刷新数据
function DlgCapitalCityDetail:onDotChange( sMsgName, pMsgObj )
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nSystemCityId == self.nSysCityId then
			--刷新数据
			self:updateViews()
		end
	end
end

return DlgCapitalCityDetail