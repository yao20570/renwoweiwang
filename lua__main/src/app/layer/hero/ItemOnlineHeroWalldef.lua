----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-25 10:53:19
-- Description: 上阵武将 城墙队列item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HeroInfoLabel = require("app.layer.hero.HeroInfoLabel")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemOnlineHeroWalldef = class("ItemOnlineHeroWalldef", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--  _tData 武将数据
-- _nNums 顺序 
-- _nTeamType 队伍类型
function ItemOnlineHeroWalldef:ctor( _tData, _nNums, _nTeamType)
	-- body
	self:myInit()

	self.tData = _tData
	self.nNUms = _nNums or 0
	self.nTeamType = _nTeamType

	local tCost = luaSplit(getBuildParam("defCost"), ":")
	self.nResCostType = tonumber(tCost[1])
	self.nResCostValue = tonumber(tCost[2])

	

	parseView("item_hero_line_up_walldef", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemOnlineHeroWalldef",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemOnlineHeroWalldef:myInit()
	-- body
	self.tData = {} --数据
	self.nNUms = 0
	self.nUnLockCost = 0 --解锁花费
end

--解析布局回调事件
function ItemOnlineHeroWalldef:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
end

--初始化控件
function ItemOnlineHeroWalldef:setupViews( )
	--兵力名字
	self.pLbSoldierN = self:findViewByName("lb_soldier_n")
	self.pLbSoldierN:setString(getConvertedStr(3, 10568))
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

	--恢复cd文字显示
	self.pLbExText = MImgLabel.new({text="", size=20, parent=self.pLyHeroMain})
	self.pLbExText:setImg("#v2_img_clock.png", 1, "left")
	self.pLbExText:followPos("left", 150, 102, 5)

	--补充耐力加号
	self.pLayBtnFill = self:findViewByName("lay_btn_add")
	self.pBtnFill = getSepButtonOfContainer(self.pLayBtnFill, TypeSepBtn.PLUS, TypeSepBtnDir.center)
	self.pBtnFill:onMViewClicked(handler(self, self.onAddNaili))
	
	--补充耐力
	local pLyBtn =  self:findViewByName("ly_btn")
	self.pBtnUp = getCommonButtonOfContainer(pLyBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7,10314),true)	
	self.pBtnUp:onCommonBtnClicked(handler(self, self.onClicked))
	-- local tConTable = {}
	-- tConTable.img = "#v2_img_clock.png"
	-- --文本
	-- local tLabel = {
	--  {"0",getC3B(_cc.white)},
	-- }
	-- tConTable.tLabel = tLabel
	-- self.pBtnUp:setBtnExText(tConTable)

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
function ItemOnlineHeroWalldef:updateViews(  )

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

		self.pIcon:setHeroType()

		self:updateNailiBar()
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
			--城防文字1
			local tDbData = getBuildParam("defenceFree")
			if tDbData then
				local tData2 = tDbData[self.nNUms]
				if tData2 then
					local nFreeLv = tData2.nLv
					self.pLbAccount:setString(string.format(getConvertedStr(3, 10562), nFreeLv))
				end
			end
			--城防文字2
			local tDbData = getBuildParam("defenceCost")
			if tDbData then
				local tData2 = tDbData[self.nNUms]
				if tData2 then
					local nNeedLv = tData2.nLv
					local nCost = tData2.nCost
					self.pLbAccount2:setString(string.format(getConvertedStr(3, 10564), nNeedLv))
					self.nUnLockCost = nCost
					self.pBtnUnLock:setExTextLbCnCr(1, self.nUnLockCost)
					--已开启数量
					local nCq = Player:getHeroInfo():getDefenseQueueNums()
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
end

-- 更换武将按钮点击响应
function ItemOnlineHeroWalldef:onClicked(pView)
	--选择武将界面
	local tObject = {}
	tObject.nType = e_dlg_index.selecthero --dlg类型
	tObject.tData = self.tData
	tObject.nTeamType = self.nTeamType
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 补充耐力点击响应
function ItemOnlineHeroWalldef:onAddNaili()
	if not self.tData then
		return
	end
	local nS = self.tData:getWalldefStamina()
	local nSMax = self.tData:getProperty(e_id_hero_att.bingli)
	--更新进度条
	local nPercent = nS / nSMax
	--更新按钮
	if nPercent >= 1 then--已满
		TOAST(getConvertedStr(3, 10581))
		return
	end

	local nCost = self.tData:getWalldefRecoverCost()
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10569)},
	}
	--展示购买对话框
	showBuyDlg(strTips,nCost,function (  )
	    SocketManager:sendMsg("reqWalldefHeroRecover", {self.tData.nId})
	end)
end

-- 英雄按钮点击回调
function ItemOnlineHeroWalldef:onHero(pView)
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
		else
			--
			self:onUnLockBtnClick() --解锁回调
		end
	end
end

--析构方法
function ItemOnlineHeroWalldef:onDestroy(  )
	-- body
	self:onPause()
end

--设置数据 _data
function ItemOnlineHeroWalldef:setCurData(_tData, _nIndex)
	if not _tData then
		return
	end

	self.tData = _tData or {}
	self.nNUms = _nIndex or self.nNUms
	self:updateViews()

end

--获取Icon层
function ItemOnlineHeroWalldef:getIconLayer(  )
	-- body
	if self.pLyIcon then
		return self.pLyIcon
	else
		return nil
	end
end

function ItemOnlineHeroWalldef:getData( ... )
	-- body
	return self.tData
end

--点击付费解锁
function ItemOnlineHeroWalldef:onUnLockBtnClick( )
	if self.pLyBtnUnLock:isVisible() then
		local nCost = self.nUnLockCost
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10567)},--扩充招募队列
		}
		--展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
		    SocketManager:sendMsg("reqUnLockTcfPos", {2})
		end, 0, true)
	end
end

--更新耐力值(注意耐力值只有放在城墙上的时候才有概念)
function ItemOnlineHeroWalldef:updateCd( bIsCurrCd, bIsStopAuto)
	if type(self.tData) == "table" then
		local nS = self.tData:getWalldefStamina()
		local nSMax = self.tData:getProperty(e_id_hero_att.bingli)
		--更新进度条
		local nPercent = nS / nSMax
		--更新按钮
		if nPercent >= 1 then--已满
			-- self.pBtnUp:setExTextVisiable(false)
			-- self.pBtnUp:setBtnEnable(false)
			-- self.pBtnUp:updateBtnText(getConvertedStr(3, 10581))
			self.pLbExText:setVisible(false)
			self.pLbExText:hideImg()
		else
			local bIsEnoughFood = getMyGoodsCnt(self.nResCostType) > self.nResCostValue
			--是当前倒计时，就显示倒计时
			if bIsCurrCd and bIsStopAuto then
				if bIsEnoughFood then
					self.pLbExText:setVisible(true)
					local nCd = self.tData:getWalldefStaminaCd()
					local tLabel = {
						{text = formatTimeToHms(nCd), color = getC3B(_cc.white)}
					}
					self.pLbExText:setString(tLabel)
					self.pLbExText:showImg()
					-- self.pBtnUp:setExTextVisiable(true)
					-- self.pBtnUp:setExTextLbCnCr(1, formatTimeToHms(nCd), getC3B(_cc.white))
					-- self.pBtnUp:setExTextImg("#v2_img_clock.png")
				else
					self.pLbExText:setVisible(true)
					-- self.pBtnUp:setExTextVisiable(true)
					-- self.pBtnUp:setExTextLbCnCr(1, getConvertedStr(3, 10579), getC3B(_cc.red))
					-- self.pBtnUp:setExTextImg(nil)
					local tLabel = {
						{text = getConvertedStr(3, 10579), color = getC3B(_cc.red)}
					}
					self.pLbExText:setString(tLabel)
					self.pLbExText:hideImg()
				end
			else
				-- self.pBtnUp:setExTextVisiable(true)
				-- self.pBtnUp:setExTextLbCnCr(1, getConvertedStr(3, 10580), getC3B(_cc.white))
				-- self.pBtnUp:setExTextImg(nil)
				self.pLbExText:setVisible(true)
				local tLabel = {
					{text = getConvertedStr(3, 10580), color = getC3B(_cc.white)}
				}
				self.pLbExText:setString(tLabel)
				self.pLbExText:hideImg()
			end
			-- self.pBtnUp:updateBtnText(getConvertedStr(3, 10582))
			-- self.pBtnUp:setBtnEnable(true)
		end
	end
end

--是否需要补耐力
function ItemOnlineHeroWalldef:getIsNeedFillNaili(  )
	if type(self.tData) == "table" then
		local nS = self.tData:getWalldefStamina()
		local nSMax = self.tData:getProperty(e_id_hero_att.bingli)
		local nPercent = nS / nSMax
		return nPercent < 1
	end
	return false
end

--刷新进度条
function ItemOnlineHeroWalldef:updateNailiBar(  )
	if type(self.tData) == "table" then
		local nS = self.tData:getWalldefStamina()
		local nSMax = self.tData:getProperty(e_id_hero_att.bingli)
		--更新进度条
		local nPercent = nS / nSMax
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
			{text=nS, color=getC3B(_cc.blue)},
			{text="/", color=getC3B(_cc.pwhite)},
			{text=nSMax, color=getC3B(_cc.white)}
		}
		self.pText:setString(tStr1)
	end
end

--当前耐力
function ItemOnlineHeroWalldef:getWalldefStamina(  )
	if type(self.tData) == "table" then
		return self.tData:getWalldefStamina()
	end
	return 0
end

--红点提示
function ItemOnlineHeroWalldef:refreshRedNums()
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
function ItemOnlineHeroWalldef:regMsgs( )
	-- 注册武将进阶状态刷新消息
	regMsg(self, ghd_advance_hero_rednum_update_msg, handler(self, self.refreshRedNums))
end

-- 注销消息
function ItemOnlineHeroWalldef:unregMsgs(  )
	--注销武将进阶状态刷新消息
	unregMsg(self, ghd_advance_hero_rednum_update_msg)
end


--暂停方法
function ItemOnlineHeroWalldef:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemOnlineHeroWalldef:onResume( )
	-- body
	self:regMsgs()
end

return ItemOnlineHeroWalldef