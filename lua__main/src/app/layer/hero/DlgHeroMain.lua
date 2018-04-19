--
-- Author: liangzhaowei
-- Date: 2017-04-21 09:45:07
-- 英雄主要信息界面

local DlgBase = require("app.common.dialog.DlgBase")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local DlgHeroInfo = require("app.layer.hero.DlgHeroInfo")
local DlgSelectHero = require("app.layer.hero.DlgSelectHero")
local ItemHeroAttrOne = require("app.layer.hero.ItemHeroAttrOne")
local ItemHeroAttrTwo = require("app.layer.hero.ItemHeroAttrTwo")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")


local DlgHeroMain = class("DlgHeroMain", function()
	return DlgBase.new(e_dlg_index.heromain)
end)


--英雄信息 _tData
function DlgHeroMain:ctor(_tData, nTeamType)
	-- body
	self:myInit()

	self.tHeroData = _tData
	self.nTeamType = nTeamType

	self.bIsAdvance	= true  --是否开启武将进阶
	self:setTitle(getConvertedStr(5, 10015)) --设置标题

	parseView("dlg_hero_main", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("DlgHeroMain",handler(self, self.onDestroy))
	
end

--初始化参数
function DlgHeroMain:myInit()
	
	self.tHeroData = nil --英雄数据
	self.pRichViewTips1 = nil --富文本1
	self.pRichViewTips2 = nil --富文本2
	self.tHeroListIcon = {} --英雄队列icon
	self.tOnlineHeroPos = {} --上阵队列英雄位置
	self.tImgHero = {} 		--英雄图片列表
	self.tItemAttr = {}		--属性item列表
	self.nRealIdx = 1                           --实际页
	self.nCurIndex = nil

	self.tStarIcon = {}

	--顶部切换列表标题
	self.tTitles = {getConvertedStr(9,10049),getConvertedStr(9,10050),getConvertedStr(9,10051)}	
	
end


--解析布局回调事件
function DlgHeroMain:onParseViewCallback( pView )

	self:addContentView(pView) --加入内容层
	self.tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nTeamType)
	self.nUpHeroCnt = #self.tHeroList
	self:onResume()
end


--刷新数据
-- _tData
function DlgHeroMain:setCurData(_tData, nTeamType)
	if not _tData then
 		return
	end

	self.tHeroData = _tData 
	self.nTeamType = nTeamType
	self:updateViews()
end

function DlgHeroMain:updatePageInfo( tHeroData )
	if not tHeroData  then
		return 
	end
	--英雄名字
	local str = self:getNameStr(tHeroData.sName)
	self.pLHeroName:setString(str)
	if tHeroData.nIg == 1 then
		self.pImgIg:setVisible(true)
	else
		self.pImgIg:setVisible(false)
	end

	--英雄品质图片
	self:setNameBgByQuality(tHeroData.nQuality)
	--兵种类型图片标识
	self:setKindImg(tHeroData.nKind)
	--星级
	self:refreshStarIcon(tHeroData.tSoulStar)
	--刷新等级进度条
	-- self.pBarLv:setPercent(tHeroData.nLv/Player:getPlayerInfo().nLv*100)
	-- local strTips2 = {
	-- 	{color=_cc.blue,text=tostring(tHeroData.nLv)},
	-- 	{color=_cc.white,text="/"..Player:getPlayerInfo().nLv},
	-- }			
	-- self.pBarLv:setProgressBarText(strTips2, false)
	--刷新资质数据
	-- for k,v in pairs(self.tTalentInfo) do
	-- 	local tData = tHeroData.tAttList[k]
	-- 	if tData then
	-- 		v:setCurData(tData)
	-- 	end
	-- end
	--攻击
	-- if self.tTalentInfo[1] then
	-- 	local nValue = tHeroData:getProperty(e_id_hero_att.gongji)
	-- 	local nValueEx = tHeroData:getAtkMax() - nValue
	-- 	self.tTalentInfo[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), nValue, nValueEx)
	-- end
	-- --防御
	-- if self.tTalentInfo[2] then
	-- 	local nValue = tHeroData:getProperty(e_id_hero_att.fangyu)
	-- 	local nValueEx = tHeroData:getDefMax() - nValue
	-- 	self.tTalentInfo[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), nValue, nValueEx)
	-- end
	-- --兵力
	-- if self.tTalentInfo[3] then
	-- 	local nValue = tHeroData:getProperty(e_id_hero_att.bingli)
	-- 	local nValueEx = tHeroData:getTroopsMax() - nValue
	-- 	self.tTalentInfo[3]:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), nValue, nValueEx)
	-- end



	-- self.pLbM1:setString(tHeroData.nTa)--攻资质
	-- self.pLbM2:setString(tHeroData.nTd)--防资质
	-- self.pLbM3:setString(tHeroData.nTr)--兵资质

	local nBaseVal = tHeroData:getBaseTotalTalent()
	local nExVal = tHeroData:getExTotalTalent()
	
    -- local strTips1  = {
    -- 	{color=_cc.blue,text=nBaseVal},
    -- 	{color=_cc.green,text="+"..nExVal},
    -- }
    
    -- if self.pRichViewTips1 then
    -- 	self.pRichViewTips1:setString(strTips1)
    -- end
	
 	local strTips2 = {
    	{color=_cc.blue,text=tostring(tHeroData.nLv)},
    	{color=_cc.white,text="/"..Player:getPlayerInfo().nLv},
    }
	
	 if self.pRichViewTips2 then
    	self.pRichViewTips2:setString(strTips2)
    end

	--更新装备信息
	self:updateEquips()
	--刷新红点
	self:refreshRedNums()

	self:updateAttrItem()

	--刷新按钮显示
	self:updateBtnR()
end

--刷新武将属性信息
function DlgHeroMain:updateAttrItem()
	for k , v in pairs(self.tItemAttr) do
		v:setCurData(self.tHeroData, self.nTeamType)
	end
end


-- 修改控件内容或者是刷新控件数据
function DlgHeroMain:updateViews()

	 
	
	if not self.tHeroData then
		return
	end
	self.nIndex = self:getHeroIndex() or self.nIndex
	self.nRealIdx = self:getHeroIndex() or self.nRealIdx
	-- print("self.nRealIdx ==== ", self.nRealIdx)
	self.nCurIndex = nil	
	gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
		if _index == 1 then
			if not self.pImgCircle2 then

				self.pImgCircle2 = self:findViewByName("img_circle2")
				self.pImgCircle2:setFlippedX(true)
			end
			--ly-----------------------------------
			if not self.pLyContent then
				self.pLyContent = self:findViewByName("ly_content") --内容层
			end
			if not self.pLbHeroAttr then
				self.pLbHeroAttr = self:findViewByName("lb_hero_attr") 
				self.pLbHeroAttr:setString(getConvertedStr(8, 10037))
			end
			if not self.pLbBaseAttr then
				self.pLbBaseAttr = self:findViewByName("lb_base_attr") 
				self.pLbBaseAttr:setString(getConvertedStr(8, 10036))
			end

			if not self.pLayTopTab then
				self.pLayTopTab = self:findViewByName("lay_top_tab")
				self.pTabHost = TCommonTabHost.new(self.pLayTopTab,1,1,self.tTitles, handler(self, self.onIndexSelected))
				self.pLayTopTab:addView(self.pTabHost, 10)
				self.pTabHost:setLayoutSize(self.pLayTopTab:getLayoutSize())
				self.pTabHost:removeLayTmp1()
				centerInView(self.pLayTopTab, self.nTabHost)
			end
			self:tabLockUpdate()

			--

			--英雄位置layer
			-- if not self.pLyHero then
			-- 	self.pLyHero={}
			-- 	for i=1,4 do
			-- 		self.pLyHero[i] = self:findViewByName("ly_hero_"..i)
			-- 		self.tOnlineHeroPos[i] = cc.p(self.pLyHero[i]:getPositionX(),self.pLyHero[i]:getPositionY())
			-- 	end
			-- end
			--刷新上阵武将队列
			-- self:refreshOnlineHeroList()


			--刷新英雄名字
			if not self.pLHeroName then
				self.pLHeroName = self:findViewByName("lb_hero_name") --英雄名字
				self.pLHeroName:setZOrder(99)
			end
			if self.tHeroData.sName then
				
			end	

			if not self.pImgIg then
				self.pImgIg = self:findViewByName("img_ig")
				self.pImgIg:setVisible(false)
			end

			--英雄品质图片
			if not self.pImgBgQuality then 
				self.pImgBgQuality = self:findViewByName("img_bg_state")
			end	
			self:setNameBgByQuality(self.tHeroData.nQuality)
			--兵种类型图片标识
			if not self.pImgKind then 
				self.pImgKind = self:findViewByName("img_soldier")
			end	
			self:setKindImg(self.tHeroData.nKind)
			--左右切换按钮
			if not self.pImgLeft then
				self.pImgLeft = self:findViewByName("img_turn_left")
				self.pImgLeft:setViewTouched(true)
				self.pImgLeft:setIsPressedNeedScale(false)
			    self.pImgLeft:onMViewClicked(handler(self,self.onLeftClick))
			    self:showLeftArrowTx()
			end
			if not self.pImgRight then
				self.pImgRight = self:findViewByName("img_turn_right")
				self.pImgRight:setFlippedX(true)
				self.pImgRight:setViewTouched(true)
				self.pImgRight:setIsPressedNeedScale(false)
			    self.pImgRight:onMViewClicked(handler(self,self.onRightClick))
			    self:showRightArrowTx()
			end

			if not self.pLayStar then
				self.pLayStar = self:findViewByName("lay_bg_star")
			end
			for i=1,5 do
				if not self.tStarIcon[i] then
					self.tStarIcon[i] = self:findViewByName("img_star"..i)
					self.tStarIcon[i]:setVisible(false)
				end
				
			end
			self:refreshStarIcon(self.tHeroData.tSoulStar)

			--英雄形象图
			-- if not self.pLyHeroBg then
			--     self.pLyHeroBg = creatHeroView(self.tHeroData.sImg)
			--     self.pLyHeroBg:setPosition(0, 430)
			--     self.pLyContent:addView(self.pLyHeroBg)
			-- 	--英雄图点击
			-- 	self.pLyHeroBg:setViewTouched(true)
			-- 	self.pLyHeroBg:setIsPressedNeedScale(false)
			--     self.pLyHeroBg:onMViewClicked(handler(self,self.onInfoClick))
			-- end
			-- if self.tHeroData.sImg then
			-- 	self.pLyHeroBg:updateHeroView(self.tHeroData.sImg)
			-- end
		
			

		elseif _index == 2 then

			--按钮
			if not self.pLyBtnL then
				--下方按钮
				self.pLyBtnL = self:findViewByName("ly_down_btn_l")
				self.pLyBtnM = self:findViewByName("ly_down_btn_m")
				self.pLyBtnR = self:findViewByName("ly_down_btn_r")
				self.pLyBtnCd = self:findViewByName("ly_down_btn_cd")

				self.pLyBtnCd:setPositionY(48)			
				self.pLyBtnL:setPositionY(48)			
				self.pLyBtnM:setPositionY(48)
				self.pLyBtnR:setPositionY(48)

				showRedTips(self.pLyBtnL, 0, 0)
				showRedTips(self.pLyBtnR, 0, 0)
				showRedTips(self.pLyBtnM, 0, 0)

				-- self.pLyBtnL:setPositionX(90)
				-- self.pLyBtnM:setPositionX(395)
				self.pBtnL =  getCommonButtonOfContainer(self.pLyBtnL,TypeCommonBtn.L_BLUE,getConvertedStr(5,10017))
				self.pBtnL:onCommonBtnClicked(handler(self, self.onDnBtnLClicked))
				self.pBtnM =  getCommonButtonOfContainer(self.pLyBtnM,TypeCommonBtn.L_BLUE,getConvertedStr(7,10350))
				self.pBtnM:onCommonBtnClicked(handler(self, self.onDnBtnMClicked))
				--进阶按钮
				self.pBtnR =  getCommonButtonOfContainer(self.pLyBtnR,TypeCommonBtn.L_YELLOW,getConvertedStr(5,10018))
				self.pBtnR:onCommonBtnClicked(handler(self, self.onDnBtnRClicked))
				--判断是否开启进阶按钮

				--一键穿戴按钮	
				self.pBtnWear = getCommonButtonOfContainer(self.pLyBtnCd,TypeCommonBtn.L_YELLOW,getConvertedStr(7,10226))


			    --武将升级入口
				-- self.pLyAdd 	    = 		self:findViewByName("ly_add")
				-- showRedTips(self.pLyAdd, 0, 0)
				-- self.pLyAddLevel 	= 		getSepButtonOfContainer(self.pLyAdd,TypeSepBtn.PLUS,TypeSepBtnDir.center)
				-- self.pLyAddLevel:onMViewClicked(handler(self, self.onAddLevelClicked))

				--图片按钮
				
				self.pLyBtnShare = self:findViewByName("ly_share") --分享
				self.pLyBtnInfo = self:findViewByName("ly_info") --属性
				-- self.pLyBtnWear = self:findViewByName("ly_wear") --穿戴

				self.pLyBtnShare:setViewTouched(true)
			    self.pLyBtnShare:onMViewClicked(handler(self,self.onShareClick))

				self.pLyBtnInfo:setViewTouched(true)
			    self.pLyBtnInfo:onMViewClicked(handler(self,self.onInfoClick))

				-- self.pLyBtnWear:setViewTouched(true)
			 --    self.pLyBtnWear:onMViewClicked(handler(self,self.onWearClick))

				-- self.pImgWear = self:findViewByName("img_wear") --一键装备或脱下

				--分享点基层和武将属性层
				self.pLayShare = self:findViewByName("lay_base")
				self.pLayBaseAttr = self:findViewByName("lay_hero")

				self.pLayShare:setViewTouched(true)
			    self.pLayShare:onMViewClicked(handler(self,self.onShareClick))

				self.pLayBaseAttr:setViewTouched(true)
			    self.pLayBaseAttr:onMViewClicked(handler(self,self.onInfoClick))
			end

			self:updateBtnR()


		elseif _index == 3 then


			--初始化装备入口
			if not self.tEquipIcon then
				self.tEquipIcon = {}
				for i=1,6 do
					local pLyEquip = self:findViewByName("ly_equip_"..i)
					pLyEquip:setZOrder(2)
					local pIcon = getIconEquipByType(pLyEquip, TypeIconEquip.ADD, i, nil, TypeIconGoodsSize.L)
					pIcon:setIconClickedCallBack(handler(self, self.onEquipIconClicked))
					pIcon:setCallBackParam(i)
					table.insert(self.tEquipIcon, pIcon)
				end
			end

			if not self.pImgbg2  then
				self.pImgbg2 = self:findViewByName("img_bg2") --属性背景图
				self.pImgbg2:setVisible(false)
				self.pImgbg2:setZOrder(1)
			    --防止穿透
				self.pImgbg2:setViewTouched(true)
				self.pImgbg2:setIsPressedNeedColor(false)
				self.pImgbg2:setIsPressedNeedScale(false)
			end


						--左右切换按钮
			if not self.pImgItemLeft then
				self.pImgItemLeft = self:findViewByName("img_arr_left")
				self.pImgItemLeft:setViewTouched(true)
				self.pImgItemLeft:setIsPressedNeedScale(false)
			    self.pImgItemLeft:onMViewClicked(handler(self,self.onLeftItemClick))
			    self:showAttrLeftArrowTx()
			end
			if not self.pImgItemRight then
				self.pImgItemRight = self:findViewByName("img_arr_right")
				self.pImgItemRight:setFlippedX(true)
				self.pImgItemRight:setViewTouched(true)
				self.pImgItemRight:setIsPressedNeedScale(false)
			    self.pImgItemRight:onMViewClicked(handler(self,self.onRightItemClick))
			    self:showAttrRightArrowTx()
			end

		    

		    --等级
			-- if not self.pRichViewTips2 then
			--     self.pRichViewTips2 = MUI.MLabel.new({text="", size=20})
			--     self.pRichViewTips2:setPosition(567,self.pLbR1:getPositionY())
			--     self.pRichViewTips2:setAnchorPoint(cc.p(0.5,0.5))
			--     self.pLyContent:addView(self.pRichViewTips2,10)
			-- end
		 --    local strTips2 = {
		 --    	{color=_cc.blue,text=tostring(self.tHeroData.nLv)},
		 --    	{color=_cc.white,text="/"..Player:getPlayerInfo().nLv},
		 --    }
			-- self.pRichViewTips2:setString(strTips2)
			if not self.pLyAttrList then
				self.pLyAttrList = self:findViewByName("lay_attr_list")
				-- self.itemtest = ItemHeroAttrTwo.new(self.tHeroData)
				-- self.pLyAttrList:addView(self.itemtest)
				self.pPageAttrView     = MUI.MPageView.new{viewRect = cc.rect(0, 0, self.pLyAttrList:getWidth(), self.pLyAttrList:getHeight())}
				self.pPageAttrView:setCirculatory(true)
				self.pLyAttrList:addView(self.pPageAttrView) 
				self.pPageAttrView:loadDataAsync(2, 1 , function(_pView, _index)
					-- body
					local item = self.pPageAttrView:newItem()
					
					local pAttrItem = nil
					if _index == 1 then
						pAttrItem = ItemHeroAttrOne.new(self.tHeroData, self.nTeamType, true)
					elseif _index == 2 then
						pAttrItem = ItemHeroAttrTwo.new(self.tHeroData)
					end
					
					if pAttrItem then
				  		item:addView(pAttrItem)
						-- centerInView(item, pAttrItem)
					end
					self.tItemAttr[_index] = pAttrItem

					
					return item
				end, function(_pView)	
					self.pPageAttrView:gotoPage(Player:getHeroInfo():getAttrIndex())
				end )
				self.pPageAttrView:onTouch(function(event)
					if event.name == "pageChange" then
						if not event.pageIdx then
							return 
						end
						self:setChangePoint(event.pageIdx)
						self.bAttrChanging = false
					end
				end)
			end

		elseif _index == 4 then
			
			if not self.pLayPageView then
				--翻页层
				self.pLayPageView  = self:findViewByName("lay_pageview")	
				self.pPageView     = MUI.MPageView.new{viewRect = cc.rect(0, 0, self.pLayPageView:getWidth(), self.pLayPageView:getHeight())}
				self.pPageView:setCirculatory(true)
				self.pLayPageView:addView(self.pPageView)
				self.pPageView:loadDataAsync(self.nUpHeroCnt, 1, function(_pView, _index)
					-- body
					local item = self.pPageView:newItem()
					local nIndex = _index
					if _index == 1 then
						nIndex = self.nRealIdx
					end
					local pImg = self.tHeroList[nIndex].sImg
					local pHero = creatHeroView(pImg)
					item:addView(pHero)
					centerInView(item, pHero)
					pHero:setName(self.tHeroList[_index].sName)
					self.tImgHero[_index] = pHero
					if _index == 1 then
						self:updateCurPage()
					end
					return item
				end, function(_pView)	
					self.pPageView:gotoPage(self.nRealIdx)
				end )
				self.pPageView:onTouch(function(event)
					if event.name == "pageChange" then
						if not event.pageIdx then
							return 
						end
						self.bChanging = false
						self.nCurIndex = event.pageIdx
						-- print("event.pageIdx======",event.pageIdx)
						local pData  = self.tHeroList[event.pageIdx]
						self.tHeroData = pData
							
						self.tImgHero[event.pageIdx]:updateHeroView(pData.sImg)
						self:updatePageInfo(pData)
					end
				end)
			else
				if not self.nCurIndex then  --对当前页的数据进行刷新，当进行穿戴或者更换的时候，因为页没有变动，所以只刷新当前页
					if self.pPageView:getPageCount() < table.nums(self.tHeroList) then --重新加载数据
						self.pPageView:removeAllItems()
						self.pPageView:loadDataAsync(self.nUpHeroCnt, 1, function(_pView, _index)
							-- body
							local item = self.pPageView:newItem()
						
							local pImg = self.tHeroList[_index].sImg
							
							local pHero = creatHeroView(pImg)
							
					  		item:addView(pHero)
							centerInView(item, pHero)
							
							pHero:setName(self.tHeroList[_index].sName)
							self.tImgHero[_index] = pHero

							
							return item
						end, function(_pView)	
										
							self.pPageView:gotoPage(self.nRealIdx,true)
						end )
					else
						
						self:updateCurPage()
						self.pPageView:gotoPage(self.nRealIdx,true)
					end
					
				end
								
			end
			--更新装备信息
			self:updateEquips()
			--刷新红点
			self:refreshRedNums()

			--新手引导设置入口
			sendMsg(ghd_guide_finger_show_or_hide, true)
			Player:getNewGuideMgr():setNewGuideFinger(self.tEquipIcon[1], e_guide_finer.hero_first_equip)
			Player:getNewGuideMgr():setNewGuideFinger(self.tEquipIcon[2], e_guide_finer.hero_second_equip)
			Player:getNewGuideMgr():setNewGuideFinger(self.tEquipIcon[3], e_guide_finer.hero_third_equip)
			Player:getNewGuideMgr():setNewGuideFinger(self.tEquipIcon[4], e_guide_finer.hero_forth_equip)
			Player:getNewGuideMgr():setNewGuideFinger(self.tEquipIcon[5], e_guide_finer.hero_fifth_equip)
			Player:getNewGuideMgr():setNewGuideFinger(self.tEquipIcon[6], e_guide_finer.hero_sixth_equip)
			--新手引导一键穿戴
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.hero_wear_all_btn)

			--新手引导武将更换
			-- Player:getNewGuideMgr():setNewGuideFinger(self.pBtnL, e_guide_finer.change_hero_btn)

			--武将星魂
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnM, e_guide_finer.hero_starsoul_btn)

		end
		
	end)


end

function DlgHeroMain:reloadPageView()
	if self.pPageView then
		if self.nUpHeroCnt > 0 then
			self.pPageView:removeAllItems()
			self.pPageView:loadDataAsync(self.nUpHeroCnt, 1, function(_pView, _index)
				-- body
				local item = self.pPageView:newItem()
		
				local pImg = self.tHeroList[_index].sImg
				
				local pHero = creatHeroView(pImg)
				
				item:addView(pHero)
				centerInView(item, pHero)
				
				pHero:setName(self.tHeroList[_index].sName)
				self.tImgHero[_index] = pHero

				
				return item
			end, function(_pView)	
						
				self.pPageView:gotoPage(self.nRealIdx)
			end )
		else
			TOAST(getConvertedStr(7, 10280))
		end
	end
end

--分页切换
function DlgHeroMain:onIndexSelected(nIndex)
	-- body
	if self.nCurrTab ~= nIndex then
		self.nCurrTab = nIndex
		-- if self.nCurrTab == e_hero_team_type.collect then
		-- 	self.tHeroList = Player:getHeroInfo():getCollectHeroList()
		-- 	self.nUpHeroCnt = #self.tHeroList
		-- 	print("self.nUpHeroCnt ------------------",self.nUpHeroCnt )
		-- elseif self.nCurrTab == e_hero_team_type.walldef then
		-- 	self.tHeroList = Player:getHeroInfo():getDefenseHeroList()
		-- 	self.nUpHeroCnt = #self.tHeroList
		-- else
		-- 	self.tHeroList = Player:getHeroInfo():getOnlineHeroList()
		-- 	self.nUpHeroCnt = #self.tHeroList
		-- end
		self.tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nCurrTab)
		self.nUpHeroCnt = #self.tHeroList
		
		-- if not self.bFirstEnter then
		-- 	self:setCurData(self.tHeroData, self.nCurrTab)
		-- else
		if type(self.tHeroList[1]) == "table" then
			self:setCurData(self.tHeroList[1], self.nCurrTab)
		end
		-- end
		
		self:reloadPageView()

	end
end

--切换片上锁设置
function DlgHeroMain:tabLockUpdate( )
	if not self.pTabHost then
		return
	end
	
	local bIsLock = true
	local tBuildData=Player:getBuildData():getBuildById(e_build_ids.tcf)
	if tBuildData then
		bIsLock = false
	end

	--采集
	local pTabItem = self.pTabHost.tTabItems[2]
	if pTabItem then
		if bIsLock then
			pTabItem:showTabLock()
			pTabItem:setViewEnabled(false)
			pTabItem:onMViewDisabledClicked(handler(self, function (  )
			    -- body
			    local nNeedLv = 0
			    local tBuild = getBuildDatasByTid(e_build_ids.tcf)
			    if tBuild then
			    	local tData = luaSplit(tBuild.open, ":") 
			    	if tData[2] and tonumber(tData[2]) then
			    		nNeedLv = tonumber(tData[2])
			    	end
			    end
			    TOAST(string.format(getTipsByIndex(20086), nNeedLv))
			end))
		else
			--采集队列
			local tHeroList = Player:getHeroInfo():getCollectHeroList()
			if #tHeroList == 0 then
				pTabItem:setViewEnabled(false)
				pTabItem:onMViewDisabledClicked(handler(self, function (  )
			   		TOAST(getConvertedStr(7, 10280)) 	--未上阵采集队列
			   	end))	
			elseif #tHeroList > 0 then
				pTabItem:setViewEnabled(true)
			end
			pTabItem:hideTabLock()
		end
	end

	local bIsLock = true
	if tBuildData and tBuildData.nLv >= tsf_open_citydef_team_lv then
		bIsLock = false
	end
	--城防队列
	local pTabItem = self.pTabHost.tTabItems[3]
	if pTabItem then
		if bIsLock then
			pTabItem:showTabLock()
			pTabItem:setViewEnabled(false)
			pTabItem:onMViewDisabledClicked(handler(self, function (  )
			    -- body
			    TOAST(getTipsByIndex(20087))
			end))
		else
			--城防队列
			local tHeroList = Player:getHeroInfo():getDefenseHeroList()
			if #tHeroList == 0 then
				pTabItem:setViewEnabled(false)
				pTabItem:onMViewDisabledClicked(handler(self, function (  )
			   		TOAST(getConvertedStr(7, 10281)) 	--未上阵城防队列
			   	end))
			elseif #tHeroList > 0 then
				pTabItem:setViewEnabled(true)
			end             
			pTabItem:hideTabLock()
		end
	end
end

function DlgHeroMain:updateCurPage(  )
	-- body
	local pCurPage = self.tImgHero[self.nCurIndex or self.nRealIdx]
	local pData  = self.tHeroList[self.nCurIndex or self.nRealIdx]
	if pData then
		self.tHeroData = pData
		self:updatePageInfo(pData)
		if pCurPage then
			pCurPage:updateHeroView(pData.sImg)
		end
	end
end

function DlgHeroMain:getHeroIndex()
	if not self.tHeroList  or not  self.tHeroData then
		return 
	end
	
	for k,v in pairs(self.tHeroList or {}) do
		if self.tHeroData then
			if v and v.nKey == self.tHeroData.nKey then
				
				return k
			end
		end
	end

end

--设置背景属性框根据品质
function DlgHeroMain:setNameBgByQuality(_nQuality )
	_nQuality = _nQuality or 1 
	_nQuality = _nQuality or 1
	local sBgName = "#v2_img_pelgbai.png"
	if _nQuality == 1 then
		sBgName = "#v2_img_pelgbai.png"
	elseif _nQuality == 2 then
		sBgName = "#v2_img_pelglu.png"
	elseif _nQuality == 3 then
		sBgName = "#v2_img_pelglan.png"
	elseif _nQuality == 4 then
		sBgName = "#v2_img_pelgzi.png"
	elseif _nQuality == 5 then
		sBgName = "#v2_img_pelgcheng.png"
	elseif _nQuality == 6 then
		sBgName = "#v2_img_pelghong.png"
	end
	if self.pImgBgQuality then
		self.pImgBgQuality:setCurrentImage(sBgName)
	end
end
--根据兵种设置图片
-- 1步兵 2.骑兵 3.弓兵
function DlgHeroMain:setKindImg( _nKind)
	_nKind = _nKind or 1
	local sBgName = "#v2_img_bu.png"
	if _nKind == 1 then
		sBgName = "#v2_img_bu.png"
	elseif _nKind == 2 then
		sBgName = "#v2_img_qi.png"
	elseif _nKind == 3 then
		sBgName = "#v2_img_gong.png"

	end
	if self.pImgKind then
		self.pImgKind:setCurrentImage(sBgName)
	end
end

function DlgHeroMain:refreshStarIcon( _tStar  )
	-- _nStar = _nStar or 1
	local nStar = _tStar.nSolidNum + _tStar.nHollowNum
	for i=1,5 do
		if i <= nStar then
			self.tStarIcon[i]:setVisible(true)
		else
			self.tStarIcon[i]:setVisible(false)
		end
		if i <= _tStar.nSolidNum then --实心
			self.tStarIcon[i]:setCurrentImage("#v1_img_star5a.png")
		else 							--空心
			self.tStarIcon[i]:setCurrentImage("#v1_img_star5b.png")
		end
	end
	self.pLayStar:setVisible(nStar ~= 0)
end
--获取包含空格的名字
function DlgHeroMain:getNameStr(_sName )
	if not _sName then
		return ""
	end
	local nStrLen = string.utf8len(_sName)
	local sNewName = ""
	if nStrLen > 2 then
		return _sName
	end
	for i=1,nStrLen do
		local name = string.subUTF8String(_sName, i, 1)
		
		if i == 1 then
			--todo
			sNewName = name  .. getSpaceStr(2)

		else
			sNewName = sNewName .. name .. getSpaceStr(2)
		end
		
	end
	
	return sNewName
end
--左边翻页按钮点击事件
function DlgHeroMain:onLeftClick(pview)
	if self.bChanging then
		return
	end
	local nCurPageIdx = self.pPageView:getCurPageIdx()
	nCurPageIdx = nCurPageIdx - 1
	if nCurPageIdx == 0 then
		nCurPageIdx = self.nUpHeroCnt
	end
	self.bChanging = true
	self.pPageView:gotoPage(nCurPageIdx, true)
	
end

--右边翻页按钮点击事件
function DlgHeroMain:onRightClick(pview)

	if self.bChanging then
		return
	end
	local nCurPageIdx = self.pPageView:getCurPageIdx()
	nCurPageIdx = nCurPageIdx + 1
	if nCurPageIdx > self.nUpHeroCnt then
		nCurPageIdx = nCurPageIdx - self.nUpHeroCnt
	end
	self.bChanging = true
	self.pPageView:gotoPage(nCurPageIdx, true)
	
end

--属性ITEM翻页事件(左)
function DlgHeroMain:onLeftItemClick(pview)
	if self.bAttrChanging then
		return
	end
	local nCurPageIdx = self.pPageAttrView:getCurPageIdx()
	nCurPageIdx = nCurPageIdx - 1
	if nCurPageIdx == 0 then
		nCurPageIdx = 2
	end
	self.bAttrChanging = true
	self.pPageAttrView:gotoPage(nCurPageIdx, true)
end

--属性ITEM翻页事件(右)
function DlgHeroMain:onRightItemClick(pview)
	if self.bAttrChanging then
		return
	end
	local nCurPageIdx = self.pPageAttrView:getCurPageIdx()
	nCurPageIdx = nCurPageIdx + 1
	if nCurPageIdx > 2 then
		nCurPageIdx = nCurPageIdx - 2
	end
	self.bAttrChanging = true
	self.pPageAttrView:gotoPage(nCurPageIdx, true)
end

--刷新红点
function DlgHeroMain:refreshRedNums()
	-- body

	if not self.tHeroData then
		return
	end

	local nTrainTime = Player:getHeroInfo().tFe.f
	local nFreeMax = tonumber(getHeroInitData("trainFreeMax"))

	local bMaxTalent = true--是否达到最大资质 (true 为没有达到)
	if self.tHeroData and self.tHeroData.nTalentLimitSum and self.tHeroData.getNowTotalTalent then
		if self.tHeroData:getNowTotalTalent() >= self.tHeroData.nTalentLimitSum then
			bMaxTalent = false
		end
	end
	--设置培养次数
	if  (nTrainTime >= nFreeMax) and self.tHeroData.nQuality and (self.tHeroData.nQuality~= 1) and bMaxTalent then
		showRedTips(self.pLyBtnL, 0, 1, 1)
	else
		showRedTips(self.pLyBtnL, 0, 0, 1)
	end

    --设置进阶红点
	if self.tHeroData:advanceRedNum() then
		showRedTips(self.pLyBtnR, 0, 1, 1)
	else
		showRedTips(self.pLyBtnR, 0, 0, 1)
	end

	--设置武将星魂红点
	if self.tHeroData:getSoulIsCanActivateOrBreak() then
		showRedTips(self.pLyBtnM, 0, 1, 1)
	else
		showRedTips(self.pLyBtnM, 0, 0, 1)
	end


	showRedTips(self.pLyAdd, 0, self.tHeroData:getUpDateRedNums())
end

--刷新上阵武将队列
function DlgHeroMain:refreshOnlineHeroList()

	--武将队列
	self.tHeroListIcon = {} --英雄队列icon
	--可上阵位置数
	local nOnlineNums = 0
	-- local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroList() --上阵队列
	local tHeroOnlineList = nil
	if self.nTeamType == e_hero_team_type.collect then
		tHeroOnlineList = Player:getHeroInfo():getCollectHeroList()
		nOnlineNums = Player:getHeroInfo():getCollectQueueNums()
	elseif self.nTeamType == e_hero_team_type.walldef then
		tHeroOnlineList = Player:getHeroInfo():getDefenseHeroList()
		nOnlineNums = Player:getHeroInfo():getDefenseQueueNums()
	else
		tHeroOnlineList = Player:getHeroInfo():getOnlineHeroList()
		nOnlineNums = Player:getHeroInfo().nOnlineNums
	end
	
	--设置头像
	for i=1,4 do
		local nIconType = TypeIconHero.NORMAL --武将icon类型
		local nIconData = nil 
		local nIconScale = TypeIconHeroSize.L --当前算中后做放大处理

		if tHeroOnlineList[i] then
			nIconData = tHeroOnlineList[i]
			if tHeroOnlineList[i].nId == self.tHeroData.nId then
				nIconScale = TypeIconHeroSize.XL
				--放大后重设位置
				self.pLyHero[i]:setPosition(self.tOnlineHeroPos[i].x -0.11*self.pLyHero[i]:getWidth()/2,
				self.tOnlineHeroPos[i].y-0.2*self.pLyHero[i]:getHeight()/2)
			else
				self.pLyHero[i]:setPosition(self.tOnlineHeroPos[i].x,self.tOnlineHeroPos[i].y)
			end
		else
			--锁住类型待添加
			if i> nOnlineNums then
				nIconType = TypeIconHero.LOCK
			else
				nIconType = TypeIconHero.ADD
			end
		end


		if nIconType ==  TypeIconHero.NORMAL then
			self.tHeroListIcon[i] =  getIconHeroByType(self.pLyHero[i],nIconType,nIconData,nIconScale)
			self.tHeroListIcon[i]:setIconHeroType(TypeIconHero.NORMAL)
			self.tHeroListIcon[i]:setHeroType()
		else
			self.tHeroListIcon[i] =  getIconHeroByType(self.pLyHero[i],nIconType,nil,nIconScale)

			if nIconType == TypeIconHero.ADD then
				--如果没有可上阵武将.将加号变灰
				if not Player:getHeroInfo():bHaveHeroUp() then 
					self.tHeroListIcon[i]:stopAddImgAction()
				end
			end
		end
		if self.tHeroListIcon[i] then
			self.tHeroListIcon[i]:setIconClickedCallBack(handler(self, self.onIconClicked))
		end
	end

end

--上阵英雄列表点击
function DlgHeroMain:onIconClicked(pHero)

	if pHero and (type(pHero) == "table") then
		self:setCurData(pHero, self.nTeamType)
	else
		if pHero and pHero == TypeIconHero.ADD then
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			tObject.nTeamType = self.nTeamType
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
	end
end


--更新武将装备
function DlgHeroMain:updateEquips()
	if not self.tHeroData then
		return
	end

	local nHeroId = self.tHeroData.nId

	local EquipData = Player:getEquipData()

	--获取更好的装备
	local tBettleEquipVos = EquipData:getHeroBetterEquipVos(nHeroId)

	--刷新装备
	local tEquipVos = EquipData:getEquipVosByKindInHero(nHeroId)
	for i=1,#self.tEquipIcon do
		local pIcon = self.tEquipIcon[i]
		local tEquipVo = tEquipVos[i]
		if tEquipVo then
			pIcon:setCurData(tEquipVo:getConfigData())
			pIcon:setIconType(TypeIconEquip.NORMAL)
			--设置强化等级
			pIcon:setStrengthLv(tEquipVo.nStrenthLv)
			local tDarkLights = tEquipVo:getStarDarkLights()
			pIcon:initStarLayer(#tDarkLights, 0, tDarkLights)
		


			--如果背包有更好的装备则显示红点提示
			local bRedTip = false
			for j=1,#tBettleEquipVos do
				local tEquipData = tBettleEquipVos[j]:getConfigData()
				if tEquipData then
					if tEquipData.nKind == i then
						bRedTip = true
						break
					end
				end
			end
			--如果装备可强化或可洗炼显示红点
			if not bRedTip then
				if getIsReachOpenCon(20, false) and EquipData:isCanStrengthen(tEquipVo) then
					bRedTip = true
				end
				if not bRedTip then
					if getIsReachOpenCon(21, false) and EquipData:isCanRefine(tEquipVo) then
						bRedTip = true
					end
				end
			end
			if bRedTip then
				pIcon:setRedTipState(1)
			else
				pIcon:setRedTipState(0)
			end
		else
			pIcon:setRedTipState(0)
			pIcon:setIconType(TypeIconEquip.ADD)
			--如果有更新可以装备就要显示动态否则显示灰色
			local bIsAddImgAction = false
			for j=1,#tBettleEquipVos do
				local tEquipData = tBettleEquipVos[j]:getConfigData()
				if tEquipData then
					if tEquipData.nKind == i then
						bIsAddImgAction = true
						break
					end
				end
			end
			if bIsAddImgAction then
				pIcon:addImgAction()
			else
				pIcon:stopAddImgAction()
			end
		end
	end
	--更新一键装备显示按钮
	if EquipData:getIsHasBetterEquip(nHeroId) then
		-- self.pImgWear:setCurrentImage("#v1_btn_chaundai.png")
		-- self.pLyBtnWear:onMViewClicked(handler(self,self.onWearClick))

		self.pBtnWear:updateBtnType(TypeCommonBtn.L_YELLOW)
		self.pBtnWear:updateBtnText(getConvertedStr(7, 10226))  --一键穿戴
		self.pBtnWear:onCommonBtnClicked(handler(self, self.onWearClick))
	else
		-- self.pImgWear:setCurrentImage("#v1_btn_xiexia.png")
		-- self.pLyBtnWear:onMViewClicked(handler(self,self.onTakeOffClick))

		self.pBtnWear:updateBtnType(TypeCommonBtn.L_BLUE)
		self.pBtnWear:updateBtnText(getConvertedStr(7, 10227))  --一键卸下
		self.pBtnWear:onCommonBtnClicked(handler(self, self.onTakeOffClick))
	end

end

--下方左边按钮
function DlgHeroMain:onDnBtnLClicked(pView)

	-- local tObject = {}
	-- tObject.nType = e_dlg_index.selecthero --dlg类型
	-- tObject.tData = self.tHeroData
	-- tObject.nTeamType = self.nTeamType
	-- sendMsg(ghd_show_dlg_by_type,tObject)

	-- --新手引导武将更换按钮已点击
	-- Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnL)

	local DlgHeroTrain = require("app.layer.hero.DlgHeroTrain")
	local pDlg, bNew = getDlgByType(e_dlg_index.herotrain)
	if not pDlg then
		pDlg = DlgHeroTrain.new(self.tHeroData, self.nTeamType)
	end
	pDlg:showDlg(bNew)
end

--下方中间按钮
function DlgHeroMain:onDnBtnMClicked(pView)
	-- print("武将星魂 ~~~~~")
	--判断是否已开启星魂功能
	local bOpen = getIsReachOpenCon(25, true)
	if not bOpen then
		return
	end

	--新手引导武将星魂
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnM)

	local tObject = {} 
	tObject.nType = e_dlg_index.dlgherostarsoul --dlg类型
	tObject.tData = self.tHeroData
	tObject.nTeamType = self.nTeamType
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

--下方右边按钮
function DlgHeroMain:onDnBtnRClicked(pView)
	--神将进阶
	if self.tHeroData.nQuality == 6  then
		local DlgHeroAdvanceM = require("app.layer.hero.DlgHeroAdvanceM")
		local pDlg, bNew = getDlgByType(e_dlg_index.mheroadvance)
		if not pDlg then
			pDlg = DlgHeroAdvanceM.new(self.tHeroData)
		end
		pDlg:showDlg(bNew)
	--普通进阶
	else
		local DlgHeroAdvance = require("app.layer.hero.DlgHeroAdvance")
		local pDlg, bNew = getDlgByType(e_dlg_index.nheroadvance)
		if not pDlg then
			pDlg = DlgHeroAdvance.new(self.tHeroData)
		end
		pDlg:showDlg(bNew)
	end

end

--分享按钮回调
function DlgHeroMain:onShareClick(pView)
	pView.nDlgIndex = e_dlg_index.heromain
	openShare(pView, e_share_id.hero, {"c^g_"..self.tHeroData.nId,self.tHeroData.nLv}, self.tHeroData.nId)
end

--属性按钮回调
function DlgHeroMain:onInfoClick(pView)
	if self.tHeroData then
		local tObject = {}
		tObject.nType = e_dlg_index.heroinfo --dlg类型
		tObject.tData = self.tHeroData
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--穿戴按钮回调
function DlgHeroMain:onWearClick(pView)
	-- print("onWearClick")
	if not self.tHeroData then
		return
	end
	local nHeroId = self.tHeroData.nId
	local tEquipVos = Player:getEquipData():getHeroBetterEquipVos(nHeroId)
	local sUuids = ""
	for i=1,#tEquipVos do
		local sUuid = tEquipVos[i].sUuid
		if i == 1 then
			sUuids = sUuid
		else
			sUuids  = sUuids .. ";" .. sUuid
		end
	end
	if sUuids ~= "" then
		SocketManager:sendMsg("reqEquipWear", {sUuids, nHeroId}, handler(self, self.onBtnReqCallBack))
	end

	--新手引导一键穿戴按钮已点击
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnWear)
end

--脱下按钮回调
function DlgHeroMain:onTakeOffClick(pView)
	if not self.tHeroData then
		return
	end
	local nHeroId = self.tHeroData.nId
	local tEquipVos = Player:getEquipData():getEquipVosByHero(nHeroId)
	--判断背包是否即将满
	local nNum = table.nums(tEquipVos)
	local bIsWillFull = Player:getEquipData():isEquipWillFull(nNum)
	if bIsWillFull then
		sendMsg(ghd_equipBag_fulled_msg)
		return
	end

	local sUuids = ""
	local i = 1
	for sUuid,v in pairs(tEquipVos) do
		if i == 1 then
			sUuids = sUuid
		else
			sUuids = sUuids .. ";" .. sUuid
		end
		i = i + 1
	end
	if sUuids ~= "" then
		SocketManager:sendMsg("reqEquipTakeOff", {sUuids, nHeroId}, handler(self, self.onBtnReqCallBack))
	end
end

function DlgHeroMain:onBtnReqCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then
		if __msg.head.type == MsgType.reqEquipWear.id then--一键穿戴
			TOAST(getConvertedStr(5, 10288))
		elseif __msg.head.type == MsgType.reqEquipTakeOff.id then--一键卸下		
			TOAST(getConvertedStr(5, 10289))
		end
	end
end

--武将升级按钮回调
function DlgHeroMain:onAddLevelClicked(pView)
	local DlgHeroUpdate = require("app.layer.hero.DlgHeroUpdate")
	local pDlg, bNew = getDlgByType(e_dlg_index.heroupdate)
	if not pDlg then
		pDlg = DlgHeroUpdate.new(self.tHeroData, self.nTeamType)
	end
	pDlg:showDlg(bNew)
end

--替换英雄
function DlgHeroMain:replaceHero(msgName,pMsg)
	if pMsg and pMsg.pHero then
		self.tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nTeamType)
		self:setCurData(pMsg.pHero, self.nTeamType)
	end
end



--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgHeroMain:onResume( _bReshow )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

-- 注册消息
function DlgHeroMain:regMsgs( )
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.updateViews))
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
	-- 注册替换英雄消息
	regMsg(self, gud_replace_hero, handler(self, self.replaceHero))
	-- 注册装备变化消息
	-- regMsg(self, gud_equip_hero_equip_change, handler(self, self.refreshRedNums))
	-- 注册背包物品变化消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.refreshRedNums))	
	-- 注册武将进阶状态刷新消息
	regMsg(self, ghd_advance_hero_rednum_update_msg, handler(self, self.refreshRedNums))	
end



-- 注销消息
function DlgHeroMain:unregMsgs(  )
	unregMsg(self, gud_equip_hero_equip_change)
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
	-- 注销替换英雄消息
	unregMsg(self, gud_replace_hero)
	-- 注销装备变化消息
	-- unregMsg(self, gud_equip_hero_equip_change)
	-- 注销背包物品变化消息
	unregMsg(self, gud_refresh_baginfo)
	--注销武将进阶状态刷新消息
	unregMsg(self, ghd_advance_hero_rednum_update_msg)
end


--暂停方法
function DlgHeroMain:onPause( )
	-- body
	self:unregMsgs()
	if not gIsNull(self.pLyHeroBg) then
		self.pLyHeroBg:onPause()
	end
end


--析构方法
function DlgHeroMain:onDestroy(  )

	--移除能力图
	if not tolua.isnull(self.pNodePolygon) then
		self.pNodePolygon:removeFromParent(true)
	end
	Player:getHeroInfo():setAttrIndex(self.pPageAttrView:getCurPageIdx())
end

function DlgHeroMain:onEquipIconClicked( pView, nKind ) 
	local sUuid = nil
	local tEquipVos = Player:getEquipData():getEquipVosByKindInHero(self.tHeroData.nId)
	local tEquipVo = tEquipVos[nKind]
	if tEquipVo then
		sUuid = tEquipVo.sUuid
	end
	if sUuid == nil then
		local tObject = {
		    nType = e_dlg_index.equipbag, --dlg类型
		    nKind = nKind,
		    sUuid = sUuid,
		    nHeroId = self.tHeroData.nId,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	else
		local tObject = {
		    nType = e_dlg_index.dlgequipinfo, --dlg类型
		    nKind = nKind,
		    sUuid = sUuid,
		    nHeroId = self.tHeroData.nId,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end

	if nKind then
		--新手引导
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG DlgHeroMain 装备框点击回调")
		end
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.tEquipIcon[nKind])
	end
end

--箭头特效
--_type类型，1-指向左边，2-指向右边
function DlgHeroMain:updateArrowAction(_type)
	-- body
	_type = _type or 1;
	local tImgArrow = nil;
	local pParView = nil;
	if _type == 1 then
		tImgArrow = {}
		pParView = self.pImgLeft
	elseif _type == 2 then
		tImgArrow = {}
		pParView = self.pImgRight
	elseif _type == 3 then
		tImgArrow = {}
		pParView = self.pImgItemLeft		
	elseif _type == 4 then
		tImgArrow = {}
		pParView = self.pImgItemRight	
	end

	local posX = pParView:getPositionX()
	local posY = pParView:getPositionY()
	if _type == 1 or  _type == 3 then
		nTargetX = posX - 5
	elseif _type == 2 or _type == 4 then
		nTargetX = posX + 5
	end
	local pSeq = cc.Sequence:create({
	    cc.MoveTo:create(0.4, cc.p(nTargetX, posY)),
	    cc.MoveTo:create(0.6, cc.p(posX, posY))
	})
	pParView:runAction(cc.RepeatForever:create(pSeq))

	local pImgArrow = MUI.MImage.new("#v1_btn_jiantou.png")
	if _type == 2 or _type == 4 then
		pImgArrow:setFlippedX(true)
	end
	pParView:getParent():addChild(pImgArrow, 10)
	pImgArrow:setPosition(posX, posY)
	pImgArrow:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgArrow:setOpacity(0)
	local pSequence = cc.Sequence:create({
	    cc.Spawn:create({
	        cc.FadeTo:create(0.4, 255*0.3),
	        cc.MoveTo:create(0, cc.p(nTargetX, posY)),
	        }),
	    cc.Spawn:create({
	        cc.FadeTo:create(0.6, 0),
	        cc.MoveTo:create(0.6, cc.p(posX, posY)),
	        })
		})
	pImgArrow:runAction(cc.RepeatForever:create(pSequence))
	
end

--显示左边箭头特效
function DlgHeroMain:showLeftArrowTx()
	-- body
	self:updateArrowAction(1)
end

--显示右边箭头特效
function DlgHeroMain:showRightArrowTx()
	-- body                                                       
	self:updateArrowAction(2)
end

--显示左边箭头特效
function DlgHeroMain:showAttrLeftArrowTx()
	-- body
	self:updateArrowAction(3)
end

--显示右边箭头特效
function DlgHeroMain:showAttrRightArrowTx()
	-- body                                                       
	self:updateArrowAction(4)
end


--刷新进阶按钮
function DlgHeroMain:updateBtnR()
	if not self.bIsAdvance then
		self.pBtnR:setVisible(false)
	else
		if (self.tHeroData.nQuality > 2 and self.tHeroData.nQuality < 6) 
				or (self.tHeroData.nQuality == 6 and self.tHeroData.nIg == 0) then
			self.pBtnR:setVisible(true)
			if self.tHeroData.nQuality == 6 then
				self.pBtnR:updateBtnText(getConvertedStr(1,10311))

			elseif self.tHeroData.nQuality == 5 then
				self.pBtnR:updateBtnText(getConvertedStr(1,10284))

			elseif self.tHeroData.nQuality == 4 or self.tHeroData.nQuality == 3 then
				self.pBtnR:updateBtnText(getConvertedStr(1,10283))

			else
				self.pBtnR:updateBtnText(getConvertedStr(1,10311))
			end
		else
			self.pBtnR:setVisible(false)
		end
	end

	if self.pBtnR:isVisible() == false then
		self.pLyBtnL:setScale(1)				
		self.pLyBtnM:setScale(1)
		self.pLyBtnCd:setScale(1)
		self.pLyBtnL:setPositionX(221)			
		self.pLyBtnM:setPositionX(444)
		self.pLyBtnR:setPositionX(640)
	else
		self.pLyBtnL:setScale(0.9)				
		self.pLyBtnM:setScale(0.9)
		self.pLyBtnR:setScale(0.9)
		self.pLyBtnCd:setScale(0.9)
		self.pLyBtnCd:setPositionX(-6)			
		self.pLyBtnL:setPositionX(146)			
		self.pLyBtnM:setPositionX(297)
		self.pLyBtnR:setPositionX(450)
	end
end

function DlgHeroMain:setChangePoint(_nIndex)
	if not _nIndex then
		return
	end
	if not self.imgHuanyeList then
		self.imgHuanyeList = {}
		for i=1, 2 do
			local pImg = self:findViewByName("img_huanye_"..i)
			table.insert(self.imgHuanyeList, pImg)
		end
	end
	for i=1, 2 do
		if _nIndex == i then
			self.imgHuanyeList[i]:setCurrentImage("#v1_img_huanyedian2.png")
		else
			self.imgHuanyeList[i]:setCurrentImage("#v1_img_huanyedian1.png")
		end
	end
end

return DlgHeroMain