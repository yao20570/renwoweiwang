-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-11 16:17:23 星期二
-- Description: 玩家基础信息
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local MBtnExText = require("app.common.button.MBtnExText")


local DlgPlayerInfo = class("DlgPlayerInfo", function()
	-- body
	return DlgBase.new(e_dlg_index.playerinfo)
end)

function DlgPlayerInfo:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_playerinfo", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgPlayerInfo:myInit(  )
	-- body
	self.nEnergyMax = tonumber(getGlobleParam("initEnergy") or 100)
end

--解析布局回调事件
function DlgPlayerInfo:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	-- self:addContentTopSpace()
	--注册析构方法
	self:setDestroyHandler("DlgPlayerInfo",handler(self, self.onDlgPlayerInfoDestroy))
	self:onResume()
end

-- 修改控件内容或者是刷新控件数据
function DlgPlayerInfo:updateViews( )
	-- 分帧执行实际的刷新
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			-- body
			--设置标题
			self:setTitle(getConvertedStr(1,10061))
			if not self.pImgShadeR then
				self.pImgShadeR =  self:findViewByName("img_shade_r")
				self.pImgShadeR:setFlippedX(true)
			end

			--头像
			if(not self.pLayIcon) then
				self.pLayIcon = self:findViewByName("lay_icon")
			end
			--头像(临时处理，等有了头像系统，这里需要修改)
			local data = Player:getPlayerInfo():getActorVo()
			-- data.nGtype = e_type_goods.type_head --头像
			-- data.sIcon = Player:getPlayerInfo().sTx
			-- data.nQuality = 100
			local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
			pIconHero:setIconIsCanTouched(true)
			pIconHero:setIconClickedCallBack(handler(self,self.onLeftClicked))

			--原画				
			if not self.pImgHero then
				self.pImgHero = self:findViewByName("img_hero")
			end
			if not self.pLayViewHero then
				self.pLayViewHero = self:findViewByName("view_hero")
			end
			local pIconData = Player:getPlayerInfo():getIconDataById(data.sI)
			if pIconData.nSequence == 1 then
				self.pImgHero:setVisible(true)
				self.pLayViewHero:setVisible(false)
			else
				self.pLayViewHero:setVisible(true)
				self.pImgHero:setVisible(false)
				if not self.pHeroView then
					self.pHeroView = creatHeroView(pIconData.sImg)
					self.pLayViewHero:addView(self.pHeroView)
				else				
					self.pHeroView:updateHeroView(pIconData.sImg)
				end
			end
			--玩家名字
			if(not self.pLayName) then
				self.pLayName =  self:findViewByName("lay_name")
				self.pLayName:setViewTouched(true)
				self.pLayName:setIsPressedNeedScale(false)
				self.pLayName:onMViewClicked(handler(self, self.onRefreshClicked))
			end
			if(not self.pLbName) then
				self.pLbName = self:findViewByName("lb_name")
				setTextCCColor(self.pLbName, _cc.blue)
			end
			--玩家名字
			self.pLbName:setString(Player:getPlayerInfo().sName)

			--刷新按钮
			if(not self.pBtnRefresh) then
				local pRefreshLayer = self:findViewByName("lay_refresh")
				self.pBtnRefresh = getSepButtonOfContainer(pRefreshLayer,TypeSepBtn.REFRESH)
				self.pBtnRefresh:onMViewClicked(handler(self, self.onRefreshClicked))
			end

			--新手引导改名按钮
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnRefresh, e_guide_finer.change_name_btn)

			--体力进度条背景
			if(not self.pLayEnergy) then
				self.pLayEnergy 				= 		self:findViewByName("lay_bar_bg_energy")
				self.pLayEnergy:setViewTouched(true)
				self.pLayEnergy:setIsPressedNeedScale(false)
				self.pLayEnergy:onMViewClicked(handler(self, self.onJumpEnergyClicked))
			end
			--体力进度条
			if(not self.pBarEnergy) then
				self.pBarEnergy = MCommonProgressBar.new({bar = "v1_bar_blue_3.png",barWidth = 142, barHeight = 14})
				self.pLayEnergy:addView(self.pBarEnergy,100)
				centerInView(self.pLayEnergy,self.pBarEnergy)
			end
		elseif(_index == 2) then
			--等级进度条背景
			if(not self.pLayLv) then
				self.pLayLv = self:findViewByName("lay_bar_bg_lv")
			end
			--等级进度条
			if(not self.pBarLv) then
				self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_yellow_8.png",barWidth = 142, barHeight = 14})
				self.pLayLv:addView(self.pBarLv,100)
				centerInView(self.pLayLv,self.pBarLv)
			end
			--计算等级进度
			--等级
			local tLvUp = getAvatarLvUpByLevel(Player:getPlayerInfo().nLv)
			local nPercentLv = math.floor(Player:getPlayerInfo().nExp / tLvUp.exp * 100)
			self.pBarLv:setPercent(nPercentLv)
			--VIP跳转按钮
			if(not self.pJumpVip) then
				local pLayJumpVip = self:findViewByName("lay_jump_vip")
				self.pJumpVip = getSepButtonOfContainer(pLayJumpVip,TypeSepBtn.PLUS,TypeSepBtnDir.center)
				self.pJumpVip:onMViewClicked(handler(self, self.onJumpVipClicked))
			end
			--体力跳转按钮
			if(not self.pJumpEnergy) then
				local pLayJumpEnergy = self:findViewByName("lay_jump_energy")
				self.pJumpEnergy = getSepButtonOfContainer(pLayJumpEnergy,TypeSepBtn.PLUS,TypeSepBtnDir.center)
				self.pJumpEnergy:onMViewClicked(handler(self, self.onJumpEnergyClicked))
			end
			--体力值
			-- if(not self.pBtnExTextEnergy) then
			-- 	self.pBtnExTextEnergy = MUI.MLabel.new({text="", size = 20})
			-- 	self.pBtnExTextEnergy:setViewTouched(true)
			-- 	self.pBtnExTextEnergy:setIsPressedNeedScale(false)
			-- 	self.pBtnExTextEnergy:onMViewClicked(handler(self, self.onJumpEnergyClicked))
			-- 	self.pLayEnergy:addView(self.pBtnExTextEnergy)
			-- 	self.pBtnExTextEnergy:setPosition(self.pLayEnergy:getPositionX(),
			-- 		self.pLayEnergy:getPositionY()+self.pLayEnergy:getHeight()+5)
			-- 	-- centerInView(self.pLayLv,self.pBtnExTextEnergy)
			-- end
			-- --获得体力上限值
			-- local nEnergyMax = tonumber(getGlobleParam("initEnergy") or 100)
			-- self.pBtnExTextEnergy:setString(
			-- {
			--  	{text=Player:getPlayerInfo().nEnergy,color=getC3B(_cc.blue)},
			--  	{text="/",color=getC3B(_cc.pwhite)},
			--  	{text=nEnergyMax,color=getC3B(_cc.pwhite)}
			-- })
			--设置体力进度
			local nPercentE = math.floor(Player:getPlayerInfo().nEnergy / self.nEnergyMax * 100)
			if nPercentE > 100 then
				nPercentE = 100
			end
			self.pBarEnergy:setPercent(nPercentE)
			--等级
			-- if(not self.pBtnExTextLv) then
			-- 	self.pBtnExTextLv = MUI.MLabel.new({text="", size = 20})
			-- 	self.pLayLv:addView(self.pBtnExTextLv, 99)
			-- 	centerInView(self.pLayLv,self.pBtnExTextLv)
			-- end
			--等级
			local tLvUp = getAvatarLvUpByLevel(Player:getPlayerInfo().nLv)
			-- self.pBtnExTextLv:setString(
			local str =
			{
			 	{text=Player:getPlayerInfo().nExp,color=getC3B(_cc.blue)},
			 	{text="/",color=getC3B(_cc.pwhite)},
			 	{text=tLvUp.exp,color=getC3B(_cc.pwhite)}
			}
			self.pBarLv:setProgressBarText(str)
			-- self.pBtnExTextLv:setPositionX(self.pLayLv:getPositionX())
			--旗帜
			if(not self.pImgFlag) then
				self.pImgFlag = self:findViewByName("img_flag")
				self.pImgFlag:setCurrentImage("ui/daitu.png")
			end
			--旗帜
			self.pImgFlag:setCurrentImage(getBigCountryFlagImg(Player:getPlayerInfo().nInfluence))
			
			--排行
			if(not self.pLbRank) then
				self.pLbRank  =  self:findViewByName("lb_param_1")
				setTextCCColor(self.pLbRank, _cc.pwhite)
			end
			--排行
			local nWorldRank = Player:getRankInfo():getWorldRank()
			if nWorldRank then
				if nWorldRank == -1 then
					self.pLbRank:setString(getConvertedStr(3, 10303))
					setTextCCColor(self.pLbRank, _cc.red)
				else
					self.pLbRank:setString(nWorldRank)
					setTextCCColor(self.pLbRank, _cc.pwhite)
				end
			end			
			--爵位
			if(not self.pLbDuke) then
				self.pLbDuke = self:findViewByName("lb_param_2")
				setTextCCColor(self.pLbDuke, _cc.pwhite)
			end
			--爵位
			self.pLbDuke:setString(Player:getPlayerInfo().sBanneret)
			--战功
			if(not self.pLbLocation) then
				self.pLbLocation = self:findViewByName("lb_param_3")
				setTextCCColor(self.pLbLocation, _cc.pwhite)
			end
			-- 刷新当前位置
			-- self:updateLocation()
			--战功
			self.pLbLocation:setString(formatCountToStr(Player:getPlayerInfo().nPrestige))
			--VIP等级
			if(not self.pLbVip) then
				local pLayVipLb = self:findViewByName("lay_vip_lb")

				self.pLbVip=self:getShowVipLabelAtlas()
				pLayVipLb:addView(self.pLbVip)
				self.pLbVip:setScale(0.45)
				-- self.pLbVip = self:findViewByName("lb_param_4")
				-- setTextCCColor(self.pLbVip, _cc.yellow)
			end
			--VIP
			local nVipLv = Player:getPlayerInfo().nVip
			if nVipLv and nVipLv > 0 then
				self.pLbVip:setString(nVipLv)
			else
				self.pLbVip:setString(0)
			end
			--远近视角相机的时候描边会有问题，暂时注释掉，以后有时间想办法解决
			self.pLbVip:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1))
		elseif(_index == 3) then
			if(not self.pBtnRight) then
				--三个按钮
				self.pLayA = self:findViewByName("lay_btn_a")
				self.pLayB = self:findViewByName("lay_btn_b") 
				self.pLayC = self:findViewByName("lay_btn_c") 

				self.pBtnLeft = getCommonButtonOfContainer(self.pLayA,TypeCommonBtn.L_BLUE,getConvertedStr(6,10757))
				self.pBtnCenter = getCommonButtonOfContainer(self.pLayB,TypeCommonBtn.L_BLUE,getConvertedStr(1,10068))
				self.pBtnRight = getCommonButtonOfContainer(self.pLayC,TypeCommonBtn.L_YELLOW,getConvertedStr(1,10069))

				--左边按钮点击事件
				self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
			    --右边按钮点击事件
				self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
				--中间按钮点击事件
				self.pBtnCenter:onCommonBtnClicked(handler(self, self.onCenterClicked))

				--屏蔽头像挂饰按钮
				-- self.pLayA:setVisible(false)
				-- self.pLayB:setPositionX(self.pLayB:getPositionY())
			end
			--国际化文字
			if(not self.pLbtmp) then
				-- self.pLbtmp = self:findViewByName("lb_cur_location")
				-- self.pLbtmp:setString(getConvertedStr(1,10060))
				-- setTextCCColor(self.pLbtmp, _cc.pwhite)
				self.pLbtmp  = self:findViewByName("lb_tip_1")
				self.pLbtmp:setString(getConvertedStr(1,10064))
				setTextCCColor(self.pLbtmp, _cc.pwhite)
				self.pLbtmp = self:findViewByName("lb_tip_2")
				self.pLbtmp:setString(getConvertedStr(1,10065))
				setTextCCColor(self.pLbtmp, _cc.pwhite)
				self.pLbtmp = self:findViewByName("lb_tip_3")
				self.pLbtmp:setString(getConvertedStr(7,10257))
				setTextCCColor(self.pLbtmp, _cc.pwhite)
				self.pLbtmp  = self:findViewByName("lb_tip_4")
				self.pLbtmp:setString(getConvertedStr(7,10151))
				setTextCCColor(self.pLbtmp, _cc.pwhite)
				self.pLbtmp = self:findViewByName("lb_tip_5")
				self.pLbtmp:setString(getConvertedStr(1,10062))
				setTextCCColor(self.pLbtmp, _cc.pwhite)				
			end

			if not self.pLbLv then
				self.pLbLv = self:findViewByName("lb_tip_6")					
				setTextCCColor(self.pLbLv, _cc.pwhite)							
			end
			self.pLbLv:setString(getLvString(Player:getPlayerInfo().nLv, false))
			--战力层
			if(not self.pLayFight) then
				self.pLayFight = self:findViewByName("lay_fight")
				self.pLayFightC = self:findViewByName("lay_c_f")
				self.pImgFinght = self:findViewByName("img_fight")
				self.pImgFinght:setPosition(69 - self.pImgFinght:getWidth()/2 - 3, 28)
				self.pLbFight = MUI.MLabelAtlas.new({text="4", 
			        png="ui/atlas/v1_img_zhanlishuzi.png", pngw=13, pngh=19, scm=48})
				self.pLbFight:setPosition(69+5, 28)
				self.pLbFight:setAnchorPoint(cc.p(0, 0.5))
			    self.pLayFightC:addView(self.pLbFight, 1000)

				self.pLayFight:setViewTouched(true)
				self.pLayFight:setIsPressedNeedScale(false)
				self.pLayFight:onMViewClicked(function ( _pView )
					if not b_open_ios_shenpi then
						local tObject = {}
						tObject.nType = e_dlg_index.fcpromote --dlg类型
						sendMsg(ghd_show_dlg_by_type,tObject)	
					end
				end)
			end
		end 
		if(_bEnd) then
			--体力
			self:setPlayerEnergy()
			--设置战力值
			self:setFightValue()
		end
	end)
end

-- 更新位置
function DlgPlayerInfo:updateLocation(  )
	local nBlockId = Player:getWorldData():getMyCityBlockId()
	if nBlockId then
		local tMapData = getWorldMapDataById(nBlockId)
		if tMapData then
			self.pLbLocation:setString(tMapData.name)
		end
	end
end

-- 析构方法
function DlgPlayerInfo:onDlgPlayerInfoDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgPlayerInfo:regMsgs( )
	-- body
	-- 注册玩家基础信息刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.refreshPlayerInfo))
	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.refreshPlayerInfo))
	-- 注册玩家城池位置变化的消息
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.refreshPlayerInfo))	

	regMsg(self, gud_fc_promote_my_rank_info, handler(self, self.onMyRankInfo))
end

-- 注销消息
function DlgPlayerInfo:unregMsgs(  )
	-- body
	-- 销毁玩家基础信息刷新消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 销毁玩家能量刷新消息
	unregMsg(self, ghd_refresh_energy_msg)
	-- 销毁玩家城池位置变化的消息
	unregMsg(self, gud_world_my_city_pos_change_msg)

	unregMsg(self, gud_fc_promote_my_rank_info)
end


--暂停方法
function DlgPlayerInfo:onPause( )
	-- body
	self:unregMsgs()
	--能量恢复倒计时
	unregUpdateControl(self)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgPlayerInfo:onResume( _bReshow )
	-- body
	self:updateViews(true)
	-- 注册消息
	self:regMsgs()
	regUpdateControl(self, handler(self, self.checkReq))
	--请求检测
	self:checkReq()
end

--设置玩家能量
function DlgPlayerInfo:setPlayerEnergy(  )
	-- body
	local str =
	{
	 	{text=Player:getPlayerInfo().nEnergy,color=getC3B(_cc.blue)},
	 	{text="/",color=getC3B(_cc.pwhite)},
	 	{text=self.nEnergyMax,color=getC3B(_cc.pwhite)}
	}

	--设置倒计时时间显示
	local nLeftTime = Player:getPlayerInfo():getEnergyLeftTime() or 0
	if nLeftTime > 0 then
		table.insert(str, {text=getSpaceStr(2)..formatTimeToHms(nLeftTime, true, false),color=getC3B(_cc.green)})
	end
	self.pBarEnergy:setProgressBarText(str)
	--能量恢复倒计时
	unregUpdateControl(self)
	if Player:getPlayerInfo().nEnergyUT > 0 then
		regUpdateControl(self, handler(self, self.onUpdate))
	end
end

--设置战力值
function DlgPlayerInfo:setFightValue(  )
	-- body
	self.pLbFight:setString(Player:getPlayerInfo().nScore)
	self.pLayFightC:setLayoutSize(self.pLbFight:getPositionX() + self.pLbFight:getWidth(), self.pLayFightC:getHeight())
	--居中显示
	centerInView(self.pLayFight,self.pLayFightC)
end

--玩家基础信息刷新回调
function DlgPlayerInfo:refreshPlayerInfo( sMsgName, pMsgObj )
	-- body
	self:updateViews()
end

--修改名字刷新按钮
function DlgPlayerInfo:onRefreshClicked( pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.rename --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
	
	--新手引导点击改名按钮完成
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnRefresh)
end

--体力跳转事件
function DlgPlayerInfo:onJumpEnergyClicked( pView )
	-- body
	openDlgBuyEnergy()
		
end

--Vip跳转事件
function DlgPlayerInfo:onJumpVipClicked( pView )
	-- body
	--TOAST("VIP")
	local tObject = {}
	tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

--左边按钮点击事件
function DlgPlayerInfo:onLeftClicked( pView )
	-- body
	--TOAST("头像挂饰")
	local tObject = {}
	tObject.nType = e_dlg_index.dlgiconsetting --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

--右边按钮点击事件
function DlgPlayerInfo:onRightClicked( pView )
	-- body
	--TOAST("设置")
	local tObject = {}
	tObject.nType = e_dlg_index.dlgsettingmain --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

--中间按钮点击事件
function DlgPlayerInfo:onCenterClicked( pView )
	-- body
	-- TOAST("反馈")
	--帮助中心入口
	local tObject = {}
	tObject.nType = e_dlg_index.dlghelpcenter --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--每秒刷新
function DlgPlayerInfo:onUpdate(  )
	-- body
	--设置倒计时时间显示
	local str =
	{
	 	{text=Player:getPlayerInfo().nEnergy,color=getC3B(_cc.blue)},
	 	{text="/",color=getC3B(_cc.pwhite)},
	 	{text=self.nEnergyMax,color=getC3B(_cc.pwhite)}
	}

	--设置倒计时时间显示
	local nLeftTime = Player:getPlayerInfo():getEnergyLeftTime() or 0
	if nLeftTime == 0 then
		unregUpdateControl(self)
	else
		table.insert(str, {text=getSpaceStr(2)..formatTimeToHms(nLeftTime, true, false),color=getC3B(_cc.green)})
	end
	self.pBarEnergy:setProgressBarText(str)
end

--请求检测
function DlgPlayerInfo:checkReq()
	--发送请求终止自更新
	if Player:getRankInfo():getIsNeedReqMyRankInfo() then
		SocketManager:sendMsg("getMyRankInfo", {})
		unregUpdateControl(self)
	end
end

function DlgPlayerInfo:onMyRankInfo( )
	regUpdateControl(self, handler(self, self.checkReq))
	self:updateViews()
end

--获得一个数字标签
function DlgPlayerInfo:getShowVipLabelAtlas(  )
	-- body
	local pLabelAtlas = MUI.MLabelAtlas.new({text=":100", 
		png="ui/atlas/v2_img_chufalibaodazhe.png", pngw=32, pngh=60, scm=48,anchorpoint=cc.p(0,0)})
	return pLabelAtlas
end
return DlgPlayerInfo