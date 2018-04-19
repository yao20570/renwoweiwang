-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-25 14:37:23
-- Description: 英雄培养
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local DlgHeroTrain = class("DlgHeroTrain", function()
	-- body
	return DlgCommon.new(e_dlg_index.herotrain)
end)

function DlgHeroTrain:ctor(_tData, nTeamType)
	-- body
	self:myInit()
	self.tHeroData = _tData 
	self.nTeamType = nTeamType
	self.nOldTotalTalent =  self.tHeroData:getNowTotalTalent()
	self:setTitle(getConvertedStr(5, 10017))
	parseView("dlg_hero_train", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroTrain:myInit(  )
	-- body
	self.tHeroData = nil --英雄数据
	self.tHeroListIcon = nil --英雄队列icon

	self.tLbInfoVale = nil --资质信息
	self.tLbInfoEx = nil --资质信息


	self.pTrainLBtn =nil --获得左边按钮
	self.pTrainRBtn =nil--获得右边按钮

	self.nUpVale = 0 --当前

	self.nOldTotalTalent = 0 --打开界面是的总资质

	self.tImgArrowPosX = {} --箭头选择坐标

end



--解析布局回调事件
function DlgHeroTrain:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView,true) --加入内容层

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroTrain",handler(self, self.onDestroy))
end

function DlgHeroTrain:setBottomInfoVisible( _bvisible )
	if self.pLExText then
	
		self.pLExText:setVisible(_bvisible)
	end
	if self.pRExText then
		
		self.pRExText:setVisible(_bvisible)
	end
	self:setBottomBtnVisible(_bvisible)
end


-- 修改控件内容或者是刷新控件数据
function DlgHeroTrain:updateViews()
	if not self.tHeroData then
       return
	end

	gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
		if _index == 1 then
			if not self.pLyContent then
				self.pImgArrow = self:findViewByName("img_arrow")
				self.pLyContent  = self:findViewByName("ly_content")
				--图片
				self.pImgEx = self:findViewByName("img_ex")
	

				--资质名字
				for i=1,4 do
					local pLbName = self:findViewByName("lb_info_n_"..i)
					setTextCCColor(pLbName, _cc.pwhite)
					pLbName:setString(getConvertedStr(5, 10020-1+i))
				end
			end

			--武将培养
			-- if not self.pLbTrainTitle then
			-- 	self.pLbTrainTitle = self:findViewByName("lb_train_title")
			-- 	setTextCCColor(self.pLbTrainTitle, _cc.white)
			-- 	self.pLbTrainTitle:setString(getConvertedStr(5, 10017))
			-- end





			if not self.tLbInfoVale then
				self.tLbInfoVale = {} --资质信息
				for i=1,4 do
					self.tLbInfoVale[i] = self:findViewByName("lb_info_v_"..i)
					setTextCCColor(self.tLbInfoVale[i], _cc.blue)
				end
			end
			--资质
			for k,v in pairs(self.tLbInfoVale) do
				local str = ""
				if k == 1 then
					str = self.tHeroData:getBaseTotalTalent()
				elseif k == 2 then
					str = self.tHeroData.nTa
				elseif k == 3 then
					str = self.tHeroData.nTd
				elseif k == 4 then
					str = self.tHeroData.nTr
				end
				if k == 1 then
					v:setString(str,false)
				else
					v:setString(str)
				end
			end

			--额外资质
			self.pExTalent =  self:findViewByName("lb_add")
			setTextCCColor(self.pExTalent, _cc.green)
			local strExToTn = ""
			-- if self.tHeroData:getExTotalTalent() > 0 then
				strExToTn = "+"..self.tHeroData:getExTotalTalent()
			-- end
			self.pExTalent:setString(strExToTn)
			self.pExTalent:setPositionX(self.tLbInfoVale[1]:getPositionX()+self.tLbInfoVale[1]:getWidth())


			--bar
			if not self.tBar then
				self.tBar = {}
				for i=1,4 do
					local pBar = self:findViewByName("ly_bar_info_"..i)
					self.tBar[i] = MCommonProgressBar.new({bar = "v1_bar_blue_3.png",barWidth = 142, barHeight = 14})
					pBar:addView(self.tBar[i],100)
					centerInView(pBar,self.tBar[i])
				end
			end

			--额外信息
			if not self.tLbInfoEx then
				self.tLbInfoEx = {} --资质额外信息
				for i=1,4 do
					self.tLbInfoEx[i] = self:findViewByName("lb_info_ex_"..i)
					self.tLbInfoEx[i]:setZOrder(10+i)
					setTextCCColor(self.tLbInfoEx[i], _cc.green)
				end	
			end

			--当前界面提升的值
			-- if self.nUpVale > 0 then
			-- 	self.pImgEx:setVisible(true)
			-- 	self.tLbInfoEx[1]:setVisible(true)
			-- 	self.tLbInfoEx[1]:setString(self.nUpVale)
			-- else
			-- 	self.pImgEx:setVisible(false)
			-- 	self.tLbInfoEx[1]:setVisible(false)
			-- 	self.tLbInfoEx[1]:setString(self.nUpVale)
			-- end

			-- 英雄名字
			if not self.pText then
				local tConTable = {}
				--文本
				local tLb= {
					{self.tHeroData.sName,getC3B(getColorByQuality(self.tHeroData.nQuality))},
					{getLvString(self.tHeroData.nLv),getC3B(_cc.blue)},
				}
				tConTable.tLabel = tLb
				self.pText =  createGroupText(tConTable)
				self.pText:setAnchorPoint(0.5,0.5)
				self.pLyContent:addView(self.pText,10)
				self.pText:setPosition(250, 260)
			end

			--英雄名字
			if self.pText then
				self.pText:setLabelCnCr(1, self.tHeroData.sName, getC3B(getColorByQuality(self.tHeroData.nQuality)))
				self.pText:setLabelCnCr(2, getLvString(self.tHeroData.nLv))
			end


			--培养时间
			if not self.pLbTrainTime then
				-- self.pLbTrainTime = self:findViewByName("lb_time")
				-- self.pLbTrainTime:setPosition(250, -46)
				-- setTextCCColor(self.pLbTrainTime, _cc.red)
				self.pLbTrainTime = MUI.MLabel.new({text = "(21:00:00)", color = getC3B(_cc.red), size = 20})
				self.pLayBottom:addView(self.pLbTrainTime, 10)
				self.pLbTrainTime:setPosition(self.pLayBottom:getWidth()/2, self.pLayBottom:getHeight()/2)
			end
		


			--武将队列
			if not self.tHeroListIcon then
				--todo
				self.tHeroListIcon = {} --英雄队列icon
				for i=1,4 do
					local nIconType = TypeIconHero.NORMAL --武将icon类型
					local nIconData = nil 
					local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nTeamType) --上阵队列
					local nIconScale = TypeIconHeroSize.L --当前算中后做放大处理
					local bThisHero = false


					local pLyHero = self:findViewByName("ly_hero_"..i)
					if tHeroOnlineList[i] then
						nIconData = tHeroOnlineList[i]
						if tHeroOnlineList[i].nId == self.tHeroData.nId then --当前武将
							bThisHero = true
						end
					else
						--锁住类型待添加
						if i> Player:getHeroInfo():getOnLineNumsByTeam(self.nTeamType) then
							nIconType = TypeIconHero.LOCK
						else
							nIconType = TypeIconHero.ADD
						end
					end


					if nIconType ==  TypeIconHero.NORMAL then
						self.tHeroListIcon[i] =  getIconHeroByType(pLyHero,nIconType,nIconData,nIconScale)
					else
						self.tHeroListIcon[i] =  getIconHeroByType(pLyHero,nIconType,nil,nIconScale)
					end

					if self.tHeroListIcon[i] then
						self.tHeroListIcon[i]:setIconClickedCallBack(function ( tHero )
							self:onIconClicked(tHero, i)
						end)

					end

					--记录需要显示位置
					self.tImgArrowPosX[i] = pLyHero:getPositionX()+pLyHero:getWidth()/2 +self.pImgArrow:getWidth()/4

					if bThisHero then
						self.pImgArrow:setPositionX(pLyHero:getPositionX()+pLyHero:getWidth()/2 +self.pImgArrow:getWidth()/4 )
					end

				end
			end

			local tHeroOnlineList = Player:getHeroInfo():getHeroOnlineQueueByTeam(self.nTeamType) --上阵队列
			for k,v in pairs(tHeroOnlineList) do
				if type(v) == "table" then
					self.tHeroListIcon[k]:setIconHeroType(TypeIconHero.NORMAL)
					self.tHeroListIcon[k]:setCurData(v)
					self.tHeroListIcon[k]:setHeroType()
				else
					self.tHeroListIcon[k]:setIconHeroType(v)
					if v == TypeIconHero.ADD then
						--如果没有可上阵武将.将加号变灰
						if not Player:getHeroInfo():bHaveHeroUpByTeam(self.nTeamType) then 
							self.tHeroListIcon[k]:stopAddImgAction()
						end
					end
				end
			end


			-- 底部按钮部分
			if not self.pTrainLBtn then
				self.pTrainLBtn = self:getLeftButton( ) --获得左边按钮
				self.pTrainRBtn = self:getRightButton( )--获得右边按钮

				self.pTrainLBtn:setButton(TypeCommonBtn.L_BLUE,getConvertedStr(5, 10107))
				self.pTrainRBtn:setButton(TypeCommonBtn.L_YELLOW,getConvertedStr(5, 10108))

				
				--在底部按钮成添加红点层
				self.pLayTrainL = self.pLayLeft
				self.pRedLay = MUI.MLayer.new()
				self.pRedLay:setLayoutSize(20, 20)
				local x = self.pLayTrainL:getPositionX() + self.pLayTrainL:getWidth() - 40
				local y = self.pLayTrainL:getPositionY() + self.pLayTrainL:getHeight() - self.pRedLay:getHeight()/2 - 30
				self.pRedLay:setPosition(x, y)
				self.pLayBottom:addView(self.pRedLay, 99)

				local tBtnLTable = {}
				--文本
				local tLLabel = {
					{getConvertedStr(5, 10106),getC3B(_cc.pwhite)},
					{0,getC3B(_cc.blue)},
					{"/",getC3B(_cc.pwhite)},
					{getHeroInitData("trainFreeMax"),getC3B(_cc.pwhite)},

				}
				tBtnLTable.tLabel = tLLabel


				local tBtnRTable = {}
				--文本
				local tRLabel = {
					{getHeroInitData("trainGoldCost"),getC3B(_cc.blue)},

				}
				tBtnRTable.tLabel = tRLabel
				tBtnRTable.img = "#v1_img_qianbi.png"


				self.pLExText =  self.pTrainLBtn:setBtnExText(tBtnLTable)
				self.pRExText =  self.pTrainRBtn:setBtnExText(tBtnRTable)

				self:setLeftHandler(handler(self, self.onLeftClicked))
				self:setRightHandler(handler(self, self.onRightClicked))
			end
			--更新按钮
			local nTrainTime = Player:getHeroInfo().tFe.f
			--设置培养次数
			if  nTrainTime > 0 then
				self.pLExText:setLabelCnCr(2,nTrainTime,getC3B(_cc.blue))
				self.pTrainLBtn:setBtnEnable(true)
				if nTrainTime >= tonumber(getHeroInitData("trainFreeMax")) then
					self.pRedLay:setVisible(true)
					showRedTips(self.pRedLay, 0, 1)
				else
					showRedTips(self.pRedLay, 0, 0)
				end
			else
				self.pTrainLBtn:setBtnEnable(false)
				self.pLExText:setLabelCnCr(2,0,getC3B(_cc.red))
				showRedTips(self.pRedLay, 0, 0)
			end

				--隐藏培养按钮
			if self.tHeroData.nQuality and self.tHeroData.nQuality == 1 then
				
				self:setBottomInfoVisible(false)
				if self.pLbTrainTime then
					self.pLbTrainTime:setVisible(true)
					local strText =  getTextColorByConfigure(getTipsByIndex(10050))
					self.pLbTrainTime:setString(strText)
					self.pLbTrainTime:setPosition(self.pLayBottom:getWidth()/2, self.pLayBottom:getHeight()/2)
				end
				self.pRedLay:setVisible(false)	
			else
				--显示一下时间
				self:updateCd()
				self:setBottomInfoVisible(true)
				if self.pLbTrainTime then
					self.pLbTrainTime:setPosition(self.pLayBottom:getWidth()/2 - 30 , self.pLayBottom:getHeight()/2 + 43)
				end
				
			end
			--显示一下时间
			self:updateCd()


			-- print("self.tHeroData:getNowTotalTalent()=", self.tHeroData:getNowTotalTalent())
			-- print("self.nOldTotalTalent=", self.nOldTotalTalent)
			self.nUpVale = self.tHeroData:getNowTotalTalent() - self.nOldTotalTalent

			--当前界面提升的值
			if self.nUpVale > 0 then
				self.pImgEx:setVisible(true)
				self.tLbInfoEx[1]:setVisible(true)
				self.tLbInfoEx[1]:setString(self.nUpVale)
			else
				self.pImgEx:setVisible(false)
				self.tLbInfoEx[1]:setVisible(false)
				self.tLbInfoEx[1]:setString(self.nUpVale)
			end

			for k,v in pairs(self.tBar) do
				local nMin = 0
				local nMax = 1
				if k == 1 then
					nMin = self.tHeroData:getNowTotalTalent()
					nMax = self.tHeroData.nTalentLimitSum
				elseif k == 2 then
					nMin = self.tHeroData.nTa
					nMax = self.tHeroData.nTalentLimitAtk
				elseif k == 3 then
					nMin = self.tHeroData.nTd
					nMax = self.tHeroData.nTalentLimitDef
				elseif k == 4 then
					nMin = self.tHeroData.nTr
					nMax = self.tHeroData.nTalentLimitTrp
				end



				local nPercent = nMin / nMax

				local nPar = math.floor(nPercent*100)
				
				if nPercent <= 0.1 then
					v:setBarImage("ui/bar/v1_bar_red1.png")
					if k ~=1 then
						self.tLbInfoEx[k]:setString("")
					end
				elseif nPercent > 0.1 and nPercent < 1 then
					v:setBarImage("ui/bar/v1_bar_blue_3.png")
					if k ~=1 then
						self.tLbInfoEx[k]:setString("")
					end
				elseif nPercent >= 1 then
					v:setBarImage("ui/bar/v1_bar_yellow_8.png")
					if k == 1 then --如果第一项已满的时候,不显示箭头
						self.pImgEx:setVisible(false)
					end
					self.tLbInfoEx[k]:setVisible(true)
					self.tLbInfoEx[k]:setString(getConvertedStr(5, 10105))
				end

				v:setPercent(nPar)


			end

		end
	end)
	
end

--上阵英雄列表点击
function DlgHeroTrain:onIconClicked(pHero, nIndex)
	self.nSelecedNullIndex = nil
	if pHero and (type(pHero) == "table") then
		self:setCurData(pHero)
	else
		if pHero == TypeIconHero.ADD then  --加号
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			tObject.nTeamType = self.nTeamType
			sendMsg(ghd_show_dlg_by_type,tObject)
			self.nSelecedNullIndex = nIndex
		end
	end
end

--设置数据
function DlgHeroTrain:setCurData(_tData)
	-- body
	local tData = _tData
	if tData then
		self.tHeroData = tData
		self.nOldTotalTalent =  self.tHeroData:getNowTotalTalent()
		self:setArrowImg(tData)	
		self:updateViews()
	end
end

--设置指示图标
function DlgHeroTrain:setArrowImg(_tData)
	-- body
	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nTeamType) --上阵队列
	if tHeroOnlineList and table.nums(tHeroOnlineList)>0 then
		for k,v in pairs(tHeroOnlineList) do
			if v.nId == _tData.nId then
				if self.tImgArrowPosX[k] then
					self.pImgArrow:setPositionX(self.tImgArrowPosX[k])
				end
			end
		end
	end

end



--更新时间
function DlgHeroTrain:updateCd()
	-- body
	local nCd = Player:getHeroInfo():getTrainTime()

	if self.tHeroData.nQuality and self.tHeroData.nQuality == 1 then
		-- self.pLbTrainTime:setVisible(false)
	else
		if nCd and nCd > 0 then
			if self.pLbTrainTime then
				self.pLbTrainTime:setVisible(true)
				self.pLbTrainTime:setString("("..formatTimeToHms(nCd)..")")
			end
		else
			if self.pLbTrainTime then
				self.pLbTrainTime:setVisible(false)
			end
		end
	end

end

--点击回调
function DlgHeroTrain:onLeftClicked(pView)
	self:sendTrain(0)
end


--点击回调
function DlgHeroTrain:onRightClicked(pView)
	showBuyDlg({{color=_cc.pwhite,text=getConvertedStr(5, 10109)}},tonumber(getHeroInitData("trainGoldCost")),
	function ()
		self:sendTrain(1)
	end)
end

--发起培养 _nType
function DlgHeroTrain:sendTrain(_nType)
	if _nType then
		self.nOldTotalTalent =  self.tHeroData:getNowTotalTalent()
		SocketManager:sendMsg("trainHero", {self.tHeroData.nId,_nType}, handler(self, self.onGetDataFunc))
	end
end


--接收服务端发回的登录回调
function DlgHeroTrain:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.trainHero.id then
        	--self:updateViews()
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

-- 析构方法
function DlgHeroTrain:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroTrain:regMsgs( )
	-- body

	regUpdateControl(self, handler(self, self.updateCd))
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.refreshHeroData))

end

--刷新武将数据
function DlgHeroTrain:refreshHeroData( )
	--选择了空武将且上阵
	if self.nSelecedNullIndex then
		local tHeroList = Player:getHeroInfo():getHeroOnlineQueueByTeam(self.nTeamType)
		local pHero = tHeroList[self.nSelecedNullIndex]
		if pHero then
			self:onIconClicked(pHero, self.nSelecedNullIndex)
			return 
		end
	end
	self:updateViews()
end

-- 注销消息
function DlgHeroTrain:unregMsgs(  )
	-- body
	unregUpdateControl(self)
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)

end


--暂停方法
function DlgHeroTrain:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgHeroTrain:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgHeroTrain