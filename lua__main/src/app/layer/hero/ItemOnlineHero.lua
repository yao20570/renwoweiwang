-- Author: liangzhaowei
-- Date: 2017-05-24 17:20:22
-- 上阵武将item

local MCommonView = require("app.common.MCommonView")
local HeroInfoLabel = require("app.layer.hero.HeroInfoLabel")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local ItemOnlineHero = class("ItemOnlineHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--  _tData 数据 _nNums 顺序
function ItemOnlineHero:ctor(_tData,_nNums, _listType)
	-- body
	self:myInit()


	self.tData = _tData
	self.nNUms = _nNums or 0
	self.nListType=_listType or 1

	parseView("item_hero_line_up", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemOnlineHero",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemOnlineHero:myInit()
	-- body
	self.tData = {} --数据
	self.pRichViewTips1 = nil --富文本1

end

--解析布局回调事件
function ItemOnlineHero:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	



	--lb
	self.pLbSoldierN = self:findViewByName("lb_soldier_n")
	self.pLbSoldierN:setString(getConvertedStr(5, 10027))
	setTextCCColor(self.pLbSoldierN,_cc.pwhite)



	self:setupViews()
	self:onResume()
end

--初始化控件
function ItemOnlineHero:setupViews( )

	if not self.tData then
		return
	end

	self.pLyHeroMain = self:findViewByName("ly_have_hero")
	--ly
	--资质数据显示
	self.tLyTalentInfo = {}
	for i=1,2 do
		self.tLyTalentInfo[i] = HeroInfoLabel.new(2)
		self.pLyHeroMain:addView(self.tLyTalentInfo[i],10)
		if(i == 1) then
			self.tLyTalentInfo[i]:setPosition(5, 60)
		elseif(i == 2) then
			self.tLyTalentInfo[i]:setPosition(150, 60)
		end
	end


	-- --武将名称,vip等级
	self.pTextNa =  MUI.MLabel.new({text="", size=22})
	self.pLyHeroMain:addView(self.pTextNa,10)
    self.pTextNa:setAnchorPoint(cc.p(0,0.5))
	self.pTextNa:setPosition(5,102)

	local pLyBtn =  self:findViewByName("ly_btn")
	self.pBtnUp = getCommonButtonOfContainer(pLyBtn,TypeCommonBtn.M_BLUE,getConvertedStr(7,10314),true)	
	self.pBtnUp:onCommonBtnClicked(handler(self, self.onClicked))

	--补兵加号
	self.pLayBtnFill = self:findViewByName("lay_btn_add")
	self.pBtnFill = getSepButtonOfContainer(self.pLayBtnFill, TypeSepBtn.PLUS, TypeSepBtnDir.center)
	self.pBtnFill:onMViewClicked(handler(self, self.onAddSoldier))


	self.pLbState = self:findViewByName("lb_state")
	-- self.pLbState:setString(getConvertedStr(5, 10097))

	self.pImgState = self:findViewByName("img_state")


	--说明文字
	self.pLbAccount = self:findViewByName("lb_account")

	
	self.pText =  MUI.MLabel.new({text="", size=18})
	self.pLyHeroMain:addView(self.pText,10)
	self.pText:setPosition(80, 18)
	self.pText:setAnchorPoint(0, 0)

	self.pLyBar = self:findViewByName("ly_bar")


	self.pBarSoldier = 	nil
	self.pBarSoldier = MCommonProgressBar.new({bar = "v1_bar_blue_3.png",barWidth = 142, barHeight = 14})
	self.pLyBar:addView(self.pBarSoldier,100)
	centerInView(self.pLyBar,self.pBarSoldier)

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onHero))


end

-- 修改控件内容或者是刷新控件数据
function ItemOnlineHero:updateViews(  )

	if not self.tData then
		return
	end

	if(not self.pLyIcon) then
		self.pLyIcon = self:findViewByName("ly_icon")
	end

	if type(self.tData) == "table" then
		self.pLyHeroMain:setVisible(true)
		self.pLbAccount:setVisible(false)
		self.pIcon  =  getIconHeroByType(self.pLyIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(handler(self, self.onHero))
		-- self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
		-- self.pIcon:setNormalState()

		local bMaxTalent = true--是否达到最大资质 (true 为没有达到)
		if self.tData and self.tData.nTalentLimitSum and self.tData.getNowTotalTalent then
			if self.tData:getNowTotalTalent() >= self.tData.nTalentLimitSum then
				bMaxTalent = false
			end
		end

		--红点(武将可培养或该武将有可替换的更好装备)
		--背包是否有更好的装备
		-- local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( self.tData.nId, true )
		--加号去掉了所以要显示可替换的更好装备
		local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( self.tData.nId)
		local nFreeMax = tonumber(getHeroInitData("trainFreeMax"))
		if (Player:getHeroInfo().tFe and Player:getHeroInfo().tFe.f and Player:getHeroInfo().tFe.f >= nFreeMax 
		  and (self.tData.nQuality~= 1) and bMaxTalent) or bHasBetterEquip or self.tData:advanceRedNum() then
			showRedTips(self.pIcon,0,1,2)
		else
			showRedTips(self.pIcon,0,0,2)
		end

		-- local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( self.tData.nId )
		-- if bHasBetterEquip then
		-- 	self.pIcon:setHeroAdd()
		-- else
		-- 	self.pIcon:removeHeroAdd()
		-- end

		--属性值
		-- for k,v in pairs(self.tLyTalentInfo) do
		-- 	local tData = self.tData.tAttList[k]
		-- 	if tData then
		-- 		v:setCurData(tData,2) --显示全部属性
		-- 	end
		-- end

		--攻击
		if self.tLyTalentInfo[1] then
			self.tLyTalentInfo[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), self.tData:getAtkMax())
		end
		--防御
		if self.tLyTalentInfo[2] then
			self.tLyTalentInfo[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), self.tData:getDefMax())
		end


		-- --等级文本刷新
		local tStr = {
			{text=self.tData.sName, color=getC3B(getColorByQuality(self.tData.nQuality))},
			{text=getLvString(self.tData.nLv), color=getC3B(getColorByQuality(self.tData.nQuality))},
		}
		self.pTextNa:setString(tStr)

		---状态显示
		if self.tData.nW == 0 then
			self.pImgState:setCurrentImage("#v2_img_xian.png")
			setTextCCColor(self.pLbState, _cc.green)
			-- if self.tData.nLt>= self.tData:getTroopsMax() then
			-- 	self.pBtnUp:updateBtnText(getConvertedStr(5, 10099)) --兵力已满
			-- else
			-- 	self.pBtnUp:updateBtnText(getConvertedStr(5, 10096)) --补充兵力
			-- end
		else
			self.pImgState:setCurrentImage("#v2_img_zhan.png")
			-- self.pBtnUp:updateBtnText(getConvertedStr(5, 10098)) --出征中
			self.pLbState:setString(getConvertedStr(5, 10082))
		end


		--按钮状态
		-- if self.tData.nW == 1 or (self.tData.nLt>= self.tData:getProperty(e_id_hero_att.bingli)) then
		-- 	self.pBtnUp:setBtnEnable(false)
		-- else
		-- 	self.pBtnUp:setBtnEnable(true)
		-- end



		local nMaxSoldier = self.tData:getProperty(e_id_hero_att.bingli)
		if (not nMaxSoldier) or nMaxSoldier == 0  then
			nMaxSoldier = 1
		end
		local nPercent = self.tData.nLt / nMaxSoldier
		if nPercent <= 0.1 then
			self.pBarSoldier:setBarImage("ui/bar/v1_bar_red1.png")
		elseif nPercent >= 1 then
			self.pBarSoldier:setBarImage("ui/bar/v1_bar_blue_3.png")
		else
			self.pBarSoldier:setBarImage("ui/bar/v1_bar_yellow_8.png")
		end
		--以下为刷新拥有兵的内容
		self.pBarSoldier:setPercent(nPercent*100)
		local tStr1 = {
			{text=self.tData.nLt, color=getC3B(_cc.blue)},
			{text="/", color=getC3B(_cc.pwhite)},
			{text=nMaxSoldier, color=getC3B(_cc.white)}
		}
		self.pText:setString(tStr1)

		self.pIcon:setHeroType()

	else

		self.pIcon  =  getIconHeroByType(self.pLyIcon, self.tData, nil, TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(handler(self, self.onHero))
		--设置icon类型
		-- self.pIcon:setIconHeroType(self.tData)

		--移除图标上的便签
		-- self.pIcon:removeHeroType()
		-- self.pIcon:removeHeroAdd()

		-- getIconHeroByType(pLyIcon,self.tData,self.tData,TypeIconHeroSize.L)

		self.pLbAccount:setVisible(true)
		self.pLyHeroMain:setVisible(false)
		if self.tData == TypeIconHero.ADD then
			self.pLbAccount:setString(getConvertedStr(5, 10101))

			--如果没有可上阵武将.将加号变灰
			if not Player:getHeroInfo():bHaveHeroUpByTeam(self.nTeamType) then 
				self.pIcon:stopAddImgAction()
			else
				self.pIcon:setIconBgToGray(false)

				-- self.:addImgAction()
			end
		else
			if self.nNUms then
				local nTnStr = "" 
				local nTnId = 1
				if self.nNUms == 3 then
					nTnId   =  3010 --中级科技id
				elseif self.nNUms == 4 then
					nTnId   =  3020 --高级科技id
				end
				self.tTechnology = getGoodsByTidFromDB(nTnId)
				if self.tTechnology then
					nTnStr = self.tTechnology.sName
				end 
				if nTnStr and (nTnStr~= "") then
					nTnStr = string.format(getConvertedStr(5, 10102),nTnStr)
					self.pLbAccount:setString(nTnStr)
				end
			end
		end
	end



	--新手引导设置入口
	local function guide()
		-- body
		if self.nNUms == 1 then
			Player:getNewGuideMgr():setNewGuideFinger(self.pIcon, e_guide_finer.first_hero_head)
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnUp, e_guide_finer.first_hero_change_btn)
			Player:getGirlGuideMgr():setGirlGuideFinger(self.pIcon, e_guide_finer.first_hero_head)
		end
		if self.nNUms == 2 then
			Player:getNewGuideMgr():setNewGuideFinger(self.pIcon, e_guide_finer.second_hero_head)
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnUp, e_guide_finer.sec_hero_change_btn)
		end
	end

	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.3),
    	cc.CallFunc:create(guide)
	}))

end

--红点提示
function ItemOnlineHero:refreshRedNums()
	if not self.tData or not self.pIcon or type(self.tData) ~= "table" then
		return
	end

	local bMaxTalent = true--是否达到最大资质 (true 为没有达到)
	if self.tData and self.tData.nTalentLimitSum and self.tData.getNowTotalTalent then
		if self.tData:getNowTotalTalent() >= self.tData.nTalentLimitSum then
			bMaxTalent = false
		end
	end

	--红点(武将可培养或该武将有可替换的更好装备)
	--背包是否有更好的装备
	-- local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( self.tData.nId, true )
	--加号去掉了所以要显示可替换的更好装备
	local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( self.tData.nId)
	local nFreeMax = tonumber(getHeroInitData("trainFreeMax"))
	if (Player:getHeroInfo().tFe and Player:getHeroInfo().tFe.f and Player:getHeroInfo().tFe.f >= nFreeMax 
	  and (self.tData.nQuality~= 1) and bMaxTalent) or bHasBetterEquip or self.tData:advanceRedNum() then
		showRedTips(self.pIcon,0,1,2)
	else
		showRedTips(self.pIcon,0,0,2)
	end

end


-- 更换武将按钮点击响应
function ItemOnlineHero:onClicked(pView)

		-- local nWillAddSoldier = 0
		-- local nMaxSoldier = self.tData:getProperty(e_id_hero_att.bingli)
		-- local nLeftNums = 0
		-- nWillAddSoldier =  nMaxSoldier - self.tData.nLt 
		-- local strTips = ""
		
		-- if self.tData.nKind == en_soldier_type.infantry then --步
		-- 	nLeftNums = Player:getPlayerInfo().nInfantry 
		-- 	strTips = getConvertedStr(5, 10033)			
		-- elseif self.tData.nKind == en_soldier_type.sowar then --骑
		-- 	nLeftNums = Player:getPlayerInfo().nSowar
		-- 	strTips = getConvertedStr(5, 10032)			
		-- elseif self.tData.nKind == en_soldier_type.archer then --弓
		-- 	nLeftNums = Player:getPlayerInfo().nArcher
		-- 	strTips = getConvertedStr(5, 10034)			
		-- end
		-- if nLeftNums > 0 then
			--请求甲兵
			-- if self.tData.nId then
			-- 	SocketManager:sendMsg("heroAddSoldier", {self.tData.nId}, handler(self, self.onGetDataFunc))
			-- end
		-- else	
			
		-- end
	--选择武将界面
	local tObject = {}
	tObject.nType = e_dlg_index.selecthero --dlg类型
	tObject.tData = self.tData
	tObject.nTeamType = self.nListType
	sendMsg(ghd_show_dlg_by_type,tObject)

	if self.nNUms == 1 then
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.first_hero_change_btn)
	end
	if self.nNUms == 2 then
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.sec_hero_change_btn)
	end
end

-- 补充兵力点击响应
function ItemOnlineHero:onAddSoldier()
	--出征状态不能补
	if self.tData.nW ~= 0 then
		TOAST(getConvertedStr(3, 10559))
		return
	end
	if self.tData.nLt >= self.tData:getTroopsMax() then
		TOAST(getConvertedStr(3, 10558))
		return
	end
	--请求补兵
	if self.tData.nId then
		SocketManager:sendMsg("heroAddSoldier", {self.tData.nId}, handler(self, self.onGetDataFunc))
	end
end

-- 英雄按钮点击回调
function ItemOnlineHero:onHero(pView)
	if type(self.tData) == "table"  then
		local tObject = {} 
		tObject.tData = self.tData --当前武将数据
		tObject.nType = e_dlg_index.heromain --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)

	else
		--存在添加回调就添加英雄回调
		if self.tData == TypeIconHero.ADD then
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			local nTipIndex = 1
			if self.nNUms == 3 then
				nTipIndex = 10060
			elseif self.nNUms == 4 then
				nTipIndex = 10061
			end
			local tObject = {
			    nType = e_dlg_index.lockherotip, --dlg类型
			    tData = self.tTechnology,
			    sStr = getTextColorByConfigure(getTipsByIndex(nTipIndex))
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
	end
	--新手引导
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pIcon)
	Player:getGirlGuideMgr():setGirlGuideFingerClicked(e_guide_finer.first_hero_head)

end

--接收服务端发回的登录回调
function ItemOnlineHero:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.heroAddSoldier.id then
        	--打开新的界面
        	-- dump(__msg.body,"__msg.body")
		    -- sendMsg(gud_refresh_hero) --通知刷新界面
        end
    --补兵不足弹窗
    elseif __msg.head.state == SocketErrorType.no_available_army then
    	--补兵
    	local strTips = ""
		
		if self.tData.nKind == en_soldier_type.infantry then --步
			strTips = getConvertedStr(5, 10033)			
		elseif self.tData.nKind == en_soldier_type.sowar then --骑
			strTips = getConvertedStr(5, 10032)			
		elseif self.tData.nKind == en_soldier_type.archer then --弓
			strTips = getConvertedStr(5, 10034)			
		end
        local DlgAlert = require("app.common.dialog.DlgAlert")
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		if(not pDlg) then
		    pDlg = DlgAlert.new(e_dlg_index.alert)
		end
		pDlg:setTitle(getConvertedStr(5, 10104))
		pDlg:setContent(strTips..getConvertedStr(5, 10103))
		pDlg:setRightHandler(function (  )
			closeDlgByType(e_dlg_index.alert, false)
			
			local nBuildId = 0
			if self.tData.nKind == en_soldier_type.infantry then --步
				nBuildId = e_build_ids.infantry--步兵
			elseif self.tData.nKind == en_soldier_type.sowar then --骑
				nBuildId = e_build_ids.sowar--骑兵
			elseif self.tData.nKind == en_soldier_type.archer then --弓
				nBuildId =  e_build_ids.archer--弓
			end
			local pBuildData = Player:getBuildData():getBuildById(nBuildId)
			if pBuildData then
				local tObject = {}
				tObject.nType = e_dlg_index.camp --dlg类型
				tObject.nBuildId = nBuildId
				sendMsg(ghd_show_dlg_by_type,tObject)
			else
				--未开启
				TOAST(string.format(getConvertedStr(6, 10525), strTips))						
			end

		end)
		pDlg:showDlg(bNew)
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

-- 注册消息
function ItemOnlineHero:regMsgs( )
	-- 注册武将进阶状态刷新消息
	regMsg(self, ghd_advance_hero_rednum_update_msg, handler(self, self.refreshRedNums))
end

-- 注销消息
function ItemOnlineHero:unregMsgs(  )
	--注销武将进阶状态刷新消息
	unregMsg(self, ghd_advance_hero_rednum_update_msg)
end


--暂停方法
function ItemOnlineHero:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemOnlineHero:onResume( )
	-- body
	self:regMsgs()
end

--析构方法
function ItemOnlineHero:onDestroy(  )
	self:onPause()
	-- body
end

--设置数据 _data
function ItemOnlineHero:setCurData(_tData, _nIndex)
	if not _tData or not _nIndex then
		return
	end
	self.tData = _tData or {}
	self.nNUms = _nIndex or self.nNUms
	self:updateViews()
end

--获取Icon层
function ItemOnlineHero:getIconLayer(  )
	-- body
	if self.pLyIcon then
		return self.pLyIcon
	else
		return nil
	end
end

function ItemOnlineHero:getData( ... )
	-- body
	return self.tData
end

return ItemOnlineHero