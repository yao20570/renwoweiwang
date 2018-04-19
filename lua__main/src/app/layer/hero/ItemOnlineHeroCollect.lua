----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-25 10:53:19
-- Description: 上阵武将 采集队列item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HeroInfoLabel = require("app.layer.hero.HeroInfoLabel")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local ItemOnlineHeroCollect = class("ItemOnlineHeroCollect", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--  _tData 武将数据
-- _nNums 顺序 
-- _nTeamType 队伍类型
function ItemOnlineHeroCollect:ctor( _tData, _nNums, _nTeamType)
	-- body
	self:myInit()

	self.tData = _tData
	self.nNUms = _nNums or 0
	self.nTeamType = _nTeamType

	parseView("item_hero_line_up_collect", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemOnlineHeroCollect",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemOnlineHeroCollect:myInit()
	-- body
	self.tData = {} --数据
	self.nNUms = 0
	self.nUnLockCost = 0 --解锁花费
end

--解析布局回调事件
function ItemOnlineHeroCollect:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
end

--初始化控件
function ItemOnlineHeroCollect:setupViews( )
	--兵力名字
	self.pLbSoldierN = self:findViewByName("lb_soldier_n")
	self.pLbSoldierN:setString(getConvertedStr(5, 10027))
	setTextCCColor(self.pLbSoldierN,_cc.pwhite)

	--武将层
	self.pLyHeroMain = self:findViewByName("ly_have_hero")
	
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

	--补兵加号
	self.pLayBtnFill = self:findViewByName("lay_btn_add")
	self.pBtnFill = getSepButtonOfContainer(self.pLayBtnFill, TypeSepBtn.PLUS, TypeSepBtnDir.center)
	self.pBtnFill:onMViewClicked(handler(self, self.onAddSoldier))
	
	--补充兵力
	local pLyBtn =  self:findViewByName("ly_btn")
	self.pBtnUp = getCommonButtonOfContainer(pLyBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7,10314),true)	
	self.pBtnUp:onCommonBtnClicked(handler(self, self.onClicked))

	--解锁按钮
	local pLyBtnUnLock =  self:findViewByName("lay_btn_unlock")
	self.pLyBtnUnLock = pLyBtnUnLock
	self.pBtnUnLock = getCommonButtonOfContainer(pLyBtnUnLock, TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10563), true)	
	self.pBtnUnLock:onCommonBtnClicked(handler(self, self.onUnLockBtnClick))
	local tConTable = {}
	tConTable.img = getCostResImg(e_type_resdata.money)
	--文本
	local tLabel = {
	 {"0",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	self.pBtnUnLock:setBtnExText(tConTable)


	--武将状态，名字
	self.pLbState = self:findViewByName("lb_state")

	--武将状态图片
	self.pImgState = self:findViewByName("img_state")

	--说明文字
	self.pLbAccount = self:findViewByName("lb_account")
	self.pLbAccount2 = self:findViewByName("lb_account2")

	--兵力文字显示
	self.pText =  MUI.MLabel.new({text="", size=18})
	self.pLyHeroMain:addView(self.pText,10)
	self.pText:setPosition(80, 18)
	self.pText:setAnchorPoint(0, 0)

	--进度条
	self.pLyBar = self:findViewByName("ly_bar")
	self.pBarSoldier = 	nil
	self.pBarSoldier = MCommonProgressBar.new({bar = "v1_bar_blue_3.png",barWidth = 142, barHeight = 14})
	self.pLyBar:addView(self.pBarSoldier,100)
	centerInView(self.pLyBar,self.pBarSoldier)

	--图片层
	self.pLyIcon = self:findViewByName("ly_icon")

	--选择武装将
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onHero))
end

-- 修改控件内容或者是刷新控件数据
function ItemOnlineHeroCollect:updateViews(  )

	if not self.tData then
		return
	end

	--数据为表格，有武将数据
	if type(self.tData) == "table" then
		self.pLyHeroMain:setVisible(true)
		self.pLbAccount:setVisible(false)
		self.pLbAccount2:setVisible(false)
		self.pLyBtnUnLock:setVisible(false)
		self.pBtnUnLock:setExTextVisiable(false)
		--头像点击
		self.pIcon  =  getIconHeroByType(self.pLyIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(handler(self, self.onHero))

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

		--兵力
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

	else --空武将数据
		self.pIcon  =  getIconHeroByType(self.pLyIcon, self.tData, nil, TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(handler(self, self.onHero))

		self.pLyHeroMain:setVisible(false)
		self.pLbAccount:setVisible(true)
		
		if self.tData == TypeIconHero.ADD then
			self.pLbAccount:setPosition(135, 65)
			self.pLbAccount2:setVisible(false)
			self.pLyBtnUnLock:setVisible(false)
			self.pBtnUnLock:setExTextVisiable(false)
			self.pLbAccount:setString(getConvertedStr(5, 10101))

			--如果没有可上阵武将.将加号变灰
			if not Player:getHeroInfo():bHaveHeroUpByTeam(self.nTeamType) then 
				self.pIcon:stopAddImgAction()
			else
				self.pIcon:setIconBgToGray(false)
			end
		else
			self.pLbAccount:setPosition(135, 79)
			self.pLbAccount2:setVisible(true)
			
			--显示解锁按钮
			local bIsShowUnLockBtn = false
			--采集文字1
			local tDbData = getBuildParam("collectionFree")
			if tDbData then
				local tData2 = tDbData[self.nNUms]
				if tData2 then
					local nFreeLv = tData2.nLv
					self.pLbAccount:setString(string.format(getConvertedStr(3, 10562), nFreeLv))
					self.pBtnUnLock:setExTextVisiable(true)
				end
			end
			--采集文字2
			local tDbData = getBuildParam("collectionCost")
			if tDbData then
				local tData2 = tDbData[self.nNUms]
				if tData2 then
					local nNeedLv = tData2.nLv
					local nCost = tData2.nCost
					self.pLbAccount2:setString(string.format(getConvertedStr(3, 10564), nNeedLv))
					self.nUnLockCost = nCost
					self.pBtnUnLock:setExTextLbCnCr(1, self.nUnLockCost)
					self.pBtnUnLock:setExTextVisiable(true)
					--已开启数量
					local nCq = Player:getHeroInfo():getCollectQueueNums()
					if self.nNUms == nCq + 1 then
						if Player:getPlayerInfo().nLv >= nNeedLv then
							bIsShowUnLockBtn = true
						end
					end
				end
			end
			if bIsShowUnLockBtn then
				self.pLyBtnUnLock:setVisible(true)
				self.pBtnUnLock:setExTextVisiable(true)
			else
				self.pLyBtnUnLock:setVisible(false)
				self.pBtnUnLock:setExTextVisiable(false)
			end
		end
	end
	--新手引导设置入口
	local function guide()
		-- body
		if self.nNUms == 1 then
			if self.tData == TypeIconHero.ADD then
				Player:getNewGuideMgr():setNewGuideFinger(self.pIcon, e_guide_finer.first_cteam_add)
			end
		end
	end

	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.3),
    	cc.CallFunc:create(guide)
	}))

end

-- 更换武将按钮点击响应
function ItemOnlineHeroCollect:onClicked(pView)
	--选择武将界面
	local tObject = {}
	tObject.nType = e_dlg_index.selecthero --dlg类型
	tObject.tData = self.tData
	tObject.nTeamType = self.nTeamType
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 补充兵力点击响应
function ItemOnlineHeroCollect:onAddSoldier()
	--出征状态不能补
	if self.tData.nW ~= 0 then
		TOAST(getConvertedStr(3, 10559))
		return
	end
	if self.tData.nLt >= self.tData:getTroopsMax() then
		TOAST(getConvertedStr(3, 10558))
		return
	end
	local nLeftNums = 0
	local strTips = ""
	
	if self.tData.nKind == en_soldier_type.infantry then --步
		nLeftNums = Player:getPlayerInfo().nInfantry 
		strTips = getConvertedStr(5, 10033)			
	elseif self.tData.nKind == en_soldier_type.sowar then --骑
		nLeftNums = Player:getPlayerInfo().nSowar
		strTips = getConvertedStr(5, 10032)			
	elseif self.tData.nKind == en_soldier_type.archer then --弓
		nLeftNums = Player:getPlayerInfo().nArcher
		strTips = getConvertedStr(5, 10034)			
	end
	if nLeftNums > 0 then
		--请求甲兵
		if self.tData.nId then
			SocketManager:sendMsg("heroAddSoldier", {self.tData.nId}, handler(self, self.onGetDataFunc))
		end
	else			
		--补兵
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
	end
end

-- 英雄按钮点击回调
function ItemOnlineHeroCollect:onHero(pView)
	if type(self.tData) == "table"  then
		local tObject = {} 
		tObject.tData = self.tData --当前武将数据
		tObject.nType = e_dlg_index.heromain --dlg类型
		tObject.nTeamType = self.nTeamType
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		--存在添加回调就添加英雄回调
		if self.tData == TypeIconHero.ADD then
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			tObject.nTeamType = self.nTeamType
			sendMsg(ghd_show_dlg_by_type,tObject)
			--新手引导
			Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.first_cteam_add)
		else
			--
			self:onUnLockBtnClick() --解锁回调
		end
	end
end

--接收服务端发回的登录回调
function ItemOnlineHeroCollect:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.heroAddSoldier.id then
        	--打开新的界面
        	-- dump(__msg.body,"__msg.body")
		    -- sendMsg(gud_refresh_hero) --通知刷新界面
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


--析构方法
function ItemOnlineHeroCollect:onDestroy(  )
	-- body
	self:onPause()
end

--设置数据 _data
function ItemOnlineHeroCollect:setCurData(_tData, _nIndex)
	if not _tData then
		return
	end

	self.tData = _tData or {}
	self.nNUms = _nIndex or self.nNUms
	self:updateViews()

end

--获取Icon层
function ItemOnlineHeroCollect:getIconLayer(  )
	-- body
	if self.pLyIcon then
		return self.pLyIcon
	else
		return nil
	end
end

function ItemOnlineHeroCollect:getData( ... )
	-- body
	return self.tData
end

--点击付费解锁
function ItemOnlineHeroCollect:onUnLockBtnClick( )
	if self.pLyBtnUnLock:isVisible() then
		local nCost = self.nUnLockCost
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10565)},--扩充招募队列
		}
		--展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
		    SocketManager:sendMsg("reqUnLockTcfPos", {1})
		end, 0, true)
	end
end


--红点提示
function ItemOnlineHeroCollect:refreshRedNums()
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


-- 注册消息
function ItemOnlineHeroCollect:regMsgs( )
	-- 注册武将进阶状态刷新消息
	regMsg(self, ghd_advance_hero_rednum_update_msg, handler(self, self.refreshRedNums))
end

-- 注销消息
function ItemOnlineHeroCollect:unregMsgs(  )
	--注销武将进阶状态刷新消息
	unregMsg(self, ghd_advance_hero_rednum_update_msg)
end


--暂停方法
function ItemOnlineHeroCollect:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemOnlineHeroCollect:onResume( )
	-- body
	self:regMsgs()
end

return ItemOnlineHeroCollect