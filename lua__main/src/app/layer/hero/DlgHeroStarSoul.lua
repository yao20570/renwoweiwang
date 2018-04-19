-- DlgHeroStarSoul.lua
-----------------------------------------------------
-- author: dshulan
-- Date: 2017-03-05 19:57:23
-- Description: 武将星魂
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemStarSoul = require("app.layer.hero.ItemStarSoul")

local nDistanceTime = 2000 --按钮延时响应(单位毫秒)

local DlgHeroStarSoul = class("DlgHeroStarSoul", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgherostarsoul)
end)

local tSoulItemPos = {
	[1]  = {x = 27,  y = 125},
	[2]  = {x = 70,  y = 247},
	[3]  = {x = 165, y = 190},
	[4]  = {x = 112, y = 46},
	[5]  = {x = 215, y = 44},
	[6]  = {x = 254, y = 161},
	[7]  = {x = 330, y = 68},
	[8]  = {x = 373, y = 157},
	[9]  = {x = 297, y = 249},
	[10] = {x = 429, y = 247}
}

function DlgHeroStarSoul:ctor(_tData, _nTeamType)
	-- body
	self:myInit()
	self.tHeroData = _tData 
	self.nTeamType = _nTeamType
	self:setTitle(getConvertedStr(7, 10350))
	parseView("dlg_hero_star_soul", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroStarSoul:myInit(  )
	-- body
	self.tHeroData = nil --英雄数据
	self.tImgArrowPosX = {} --箭头选择坐标
	self.tHeroListIcon = {} --英雄队列icon
	self.tSoulItems = {} --10个龙图
	self.tImgLines = {}  --9根线
	self.nActionType = nil --操作类型(1为激活, 2为突破)
	self.nHeroId = nil

	self.pBreakFontEffect={}

	self.bIsRecover = false
	self.pLineEffect={}
end

--解析布局回调事件
function DlgHeroStarSoul:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView,true) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroStarSoul",handler(self, self.onDestroy))
end

function DlgHeroStarSoul:setupViews()
	--只有一个按钮
	self:setOnlyConfirm()

	self.pLyContent 		= self:findViewByName("lay_con")
	self.pLbName 			= self:findViewByName("lb_name")

	local pLbRecover 		= self:findViewByName("lb_recover")
	pLbRecover:setString(getConvertedStr(7, 10352))

	--星魂龙图层
	self.pLaySoulItems 		= self:findViewByName("lay_soul_items")
	--路线层 
	self.pLayLines 			= self:findViewByName("lay_lines")
	--突破效果层
	self.pLayBreak 			= self:findViewByName("lay_break")
	self.pLayBreak:setVisible(false)
	--突破效果艺术字
	self.pImgFont 			= self:findViewByName("img_fonts_tpxg")
	--突破效果层中间的文字
	self.pLbBreak 			= self:findViewByName("lb_break_add")
	self.pImgBreakBg 		= self:findViewByName("img_break_di")

	--还原按钮
	self.pLayRecover 		= self:findViewByName("lay_btn_recover")
	self.pLayRecover:setViewTouched(true)
	self.pLayRecover:setIsPressedNeedScale(false)
	self.pLayRecover:onMViewClicked(handler(self, self.onRecoverClicked))

	self.pImgArrow = self:findViewByName("img_select")
	local nFx = self.pImgArrow:getHeight()

	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nTeamType) --上阵队列
	for i=1,4 do
		local nIconType = TypeIconHero.NORMAL --武将icon类型
		local nIconData = nil 
		local nIconScale = TypeIconHeroSize.L --当前算中后做放大处理
		local bThisHero = false


		if tHeroOnlineList[i] then
			nIconData = tHeroOnlineList[i]
			if tHeroOnlineList[i].nId == self.tHeroData.nId then --当前武将
				bThisHero = true
			end
		else
			--锁住类型待添加
			if i > Player:getHeroInfo():getOnLineNumsByTeam(self.nTeamType) then
				nIconType = TypeIconHero.LOCK
			else
				nIconType = TypeIconHero.ADD
			end
		end

		local pLyHero = self:findViewByName("ly_hero_"..i)

		if nIconType ==  TypeIconHero.NORMAL then
			self.tHeroListIcon[i] =  getIconHeroByType(pLyHero,nIconType,nIconData,nIconScale)
		else
			self.tHeroListIcon[i] =  getIconHeroByType(pLyHero,nIconType,nil,nIconScale)
		end

		if self.tHeroListIcon[i] then
			self.tHeroListIcon[i]:setIconClickedCallBack(function ( tHero )
				self:onIconClicked(tHero, i)
			end)

			self.tHeroListIcon[i]:setStarSoulLayer(true,i)

		end


		--记录需要显示位置
		self.tImgArrowPosX[i] = 14 + (nFx + 3) * (i - 1)

		if bThisHero then
			self.pImgArrow:setPositionX(self.tImgArrowPosX[i])
		end

	end

	--10个星魂
	for i = 1, 10 do
		local pItem = ItemStarSoul.new()
		pItem:setLineEffectHandler(handler(self,self.showLineEffect))
		if i == 1 then
			pItem:setAddStarEffectHandler(handler(self,self.showAddStarEffect))
		end
		pItem:setLineEffectHandler(handler(self,self.showLineEffect))
		self.pLaySoulItems:addView(pItem, 10)
		pItem:setPosition(tSoulItemPos[i].x, tSoulItemPos[i].y)
		self.tSoulItems[i] = pItem
	end
	--9根线
	for i = 1, 9 do
		local pImgLine = self:findViewByName("line_"..i)
		self.tImgLines[i] = pImgLine
	end

	self.pBtn = self:getRightButton( )--获得右边按钮
	self.pLayRight:setPositionY(7)
	self:setRightHandler(handler(self, self.onRightClicked))

	--按钮上的文字
	self.pBtnImgLb = MImgLabel.new({text="", size=20, parent=self.pLayBottom})
	self.pBtnImgLb:setImg("#v1_img_qianbi.png", 1, "left")
	self.pBtnImgLb:followPos("center", self.pLayRight:getPositionX()+self.pLayRight:getWidth()/2, 
		10+self.pLayRight:getHeight(), 3)

	--新手教程
	sendMsg(ghd_guide_finger_show_or_hide, true)
	Player:getNewGuideMgr():setNewGuideFinger(self.pBtn, e_guide_finer.hssoul_active_btn)
end

-- 修改控件内容或者是刷新控件数据
function DlgHeroStarSoul:updateViews()
	-- dump(self.tHeroData.tSoulActAttrs, "self.tHeroData.tSoulActAttrs 配表 ==", 100)
	-- dump(self.tHeroData.tSoulBreakAttrs, "self.tHeroData.tSoulBreakAttrs 配表 ==", 100)
	-- dump(self.tHeroData.tSoulList, "self.tHeroData.tSoulList ==", 100)
	-- dump(self.tHeroData.tSoulBreakList, "self.tHeroData.tSoulBreakList ==", 100)
	if not self.tHeroData then
       return
	end
	local nOriginId= self.nHeroId 
	local nOriActionType= self.nActionType 
	self.nHeroId = self.tHeroData.nId
	--武将名字和等级
	local tNameStr = {
		{text = self.tHeroData.sName, color = getColorByQuality(self.tHeroData.nQuality)},
		{text = getLvString(self.tHeroData.nLv), color = _cc.blue}
	}
	self.pLbName:setString(tNameStr)

	--武将上阵列表
	local tHeroOnlineList = Player:getHeroInfo():getHeroOnlineQueueByTeam(self.nTeamType) --上阵队列
	for k, v in pairs(tHeroOnlineList) do
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

	local n = table.nums(self.tHeroData.tSoulList)
	local tStageData = self.tHeroData.tSoulList[n]
	if tStageData == nil then return end
	self.nActionType = 1
	local nMaxStage = table.nums(self.tHeroData.tSoulBreakAttrs)
	if n%10 == 1 or n/10 == nMaxStage then
		local tData = self.tHeroData.tSoulList[n-1]
		if tData and self.tHeroData.tSoulBreakDic[tData.st] == e_hero_soul_state.opened then
			tStageData = self.tHeroData.tSoulList[n-1]
			self.nActionType = 2
		end
	end
	--是否满星魂(是否突破所有星魂阶段)
	local bIsFull = self.tHeroData:isFullStage()
	if bIsFull then
		self.nActionType = 2
	end
	--当前最新阶段
	self.nStage = tStageData.st
	self.nOpenPos = tStageData.pos

	-- for k, v in pairs(self.tSoulItems) do
	-- 	v:setCurData(self.tHeroData, k)
	-- end
	--同一个英雄 但是显示类型变了，证明是突破成功的转变
	if nOriActionType ~= self.nActionType and nOriginId == self.nHeroId and not self.bIsRecover then
		-- self:showBreakBgSuccessEffect()
	else
		for i=2, #self.tSoulItems do
			local nState = self.tHeroData.tSoulDic[self.nStage][i]
			local line = self.tImgLines[i-1]
			if nState and nState==e_hero_soul_state.actived then
				line:setToGray(false)
			else
				line:setToGray(true)
			end
		end
	end
	--同一个英雄 但是显示类型变了，而且不是还原，那就是突破成功的转变,这里是补充最后一颗星的突破效果
	if nOriActionType==2 and self.nActionType == 2 and nOriginId == self.nHeroId and not self.bIsRecover and bIsFull then
		for k, v in pairs(self.tHeroListIcon) do
			local tData = v:getCurData()
			if tData and type(tData) == "table" then
				if tData.nId == self.tHeroData.nId then
					v:showSoulStarEffect(self.nStage)
				end
			end
		end
		--显示升星效果
		local callback = cc.CallFunc:create(function (  )
			-- body
			self:showBreakBgSuccessEffect()
		end)
		local delayTime = cc.DelayTime:create(0.75)
		self:runAction(cc.Sequence:create(delayTime,callback))
	end	

	--获取星魂消耗
	local tAdvCost = self.tHeroData:getSoulCost(self.nStage)
	--设置底部按钮
	if self.nActionType == 1 then --激活

		--同一个英雄 但是显示类型变了，而且不是还原，那就是突破成功的转变
		if nOriActionType ~= self.nActionType and nOriginId == self.nHeroId and not self.bIsRecover then
			for k, v in pairs(self.tHeroListIcon) do
				local tData = v:getCurData()
				if tData and type(tData) == "table" then
					if tData.nId == self.tHeroData.nId then
						v:showSoulStarEffect(self.nStage - 1)
					end
				end
			end
			--显示升星效果
			local callback = cc.CallFunc:create(function (  )
			    -- body
				self:showBreakBgSuccessEffect()
			end)
			local delayTime = cc.DelayTime:create(0.75)
			self:runAction(cc.Sequence:create(delayTime,callback))
			-- self:showBreakBgSuccessEffect()
		else
			self:showSoulItem()
		end
	elseif self.nActionType == 2 then --突破
		
		self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(7, 10331))--突破
		-- --隐藏路线和星魂图
		-- self.pLaySoulItems:setVisible(false)
		-- self.pLayLines:setVisible(false)
		-- --显示突破效果层
		-- self.pLayBreak:setVisible(true)
		--已突破所有星魂阶段
		if bIsFull then
			-- --显示突破效果层
			self.pLayBreak:setVisible(true)

			self.pLbBreak:setSystemFontSize(24)
			setTextCCColor(self.pLbBreak, _cc.white)
			self.pLbBreak:setString(getConvertedStr(7, 10361)) --已突破所有星魂阶段！
			self.pImgFont:setVisible(false) --隐藏艺术字"突破效果"
			self.pBtnImgLb:hideImg() 		--突破按钮上的内容清空
			self.pBtnImgLb:setString("") 	--突破按钮上的内容清空
			self:setRightBtnEnabled(false)  --设置按钮不可点击

			self.pLaySoulItems:setVisible(false)
			self.pLayLines:setVisible(false)
		else

			self.pLbBreak:setSystemFontSize(20)
			self.pImgFont:setVisible(true)
			self.pBtnImgLb:showImg()
			self:setRightBtnEnabled(true)

			local nCostId = tonumber(tAdvCost.tBreakCost[1])
			local tGood = getGoodsByTidFromDB(nCostId)
			self.pBtnImgLb:setImg(tGood.sIcon, 0.4, "left")
			--当前拥有
			local nHasNum = getMyGoodsCnt(nCostId)
			--需要消耗
			local nNeedCostNum = tonumber(tAdvCost.tBreakCost[2])
			self.bCanAdv = true
			local sColor = _cc.green
			if nHasNum < nNeedCostNum then
				sColor = _cc.red
				self.bCanAdv = false
			end
			--武将当前等级
			local nCurHeroLv = self.tHeroData.nLv
			--武将需求等级
			local nNeedHeroLv = tAdvCost.nNeedHeroLv
			local sLvColor = _cc.green
			if nCurHeroLv < nNeedHeroLv then
				sLvColor = _cc.red
				self.bCanAdv = false
			end
			local sBtnTxt = {
				{text = formatCountToStr(nHasNum), color = sColor},  --当前拥有
				{text = "/"..formatCountToStr(nNeedCostNum), color = _cc.white}, 
				{text = getSpaceStr(2)..getConvertedStr(7, 10353), color = _cc.white}, 
				{text = nCurHeroLv, color = sLvColor},  --当前拥有
				{text = "/"..nNeedHeroLv, color = _cc.white}
			}
			self.pBtnImgLb:setString(sBtnTxt)

			local tAddAttr = self.tHeroData.tSoulBreakAttrs[self.nStage]
			if type(tAddAttr[1]) == "table" then --突破效果属性有多个
				local tStr = {
					{text = getConvertedStr(7, 10360), color = _cc.white},
				}
				for k, v in pairs(tAddAttr) do
					if v[1] and v[2] then
						local nAttrId = tonumber(v[1])
						local nValue = tonumber(v[2]) * 100
						local tAttrData = getBaseAttData(nAttrId)
						table.insert(tStr, {text = tAttrData.sName, color = _cc.white})
						table.insert(tStr, {text = nValue.."%", color = _cc.white})
						table.insert(tStr, {text = "，", color = _cc.white})
					else
						table.remove(tStr, #tStr)
					end
				end
				--突破效果提升
				self.pLbBreak:setString(tStr)
			else --只有一个效果属性
				local nAttrId = tonumber(tAddAttr[1])
				local nValue = tonumber(tAddAttr[2]) * 100
				local tAttrData = getBaseAttData(nAttrId)
				local tStr = {
					{text = getConvertedStr(7, 10360), color = _cc.white},
					{text = tAttrData.sName, color = _cc.white},
					{text = nValue.."%", color = _cc.white}
				}
				--突破效果提升
				self.pLbBreak:setString(tStr)
			end
			if nOriginId == self.nHeroId then
				sendMsg(ghd_star_soul_preview_state)
				local callback = cc.CallFunc:create(function (  )
					-- body
					--隐藏路线和星魂图
					self.pLaySoulItems:setVisible(false)
					self.pLayLines:setVisible(false)
					--显示突破效果层
					self.pLayBreak:setVisible(true)
					self:showFirstBreakAction()
				end)
				local delayTime = cc.DelayTime:create(2.25)
				self:runAction(cc.Sequence:create(delayTime,callback))
				-- self:showFirstBreakAction()
			else
				--隐藏路线和星魂图
				self.pLaySoulItems:setVisible(false)
				self.pLayLines:setVisible(false)
				--显示突破效果层
				self.pLayBreak:setVisible(true)
			end
			-- self:showFirstBreakAction()
		end

	end
end
function DlgHeroStarSoul:showSoulItem(  )
	-- body
	for k, v in pairs(self.tSoulItems) do
		v:setCurData(self.tHeroData, k)
	end
	self.bIsRecover = false   --显示路线的时候重置一下还原状态
	local tAdvCost = self.tHeroData:getSoulCost(self.nStage)
	self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(7, 10351))--激活
	local nCostId = tonumber(tAdvCost.tActivateCost[1])
	local tGood = getGoodsByTidFromDB(nCostId)
	self.pBtnImgLb:setImg(tGood.sIcon, 0.4, "left")
	--当前拥有
	local nHasNum = getMyGoodsCnt(nCostId)
	--需要消耗
	local nNeedCostNum = tonumber(tAdvCost.tActivateCost[2])
	local sColor = _cc.green
	self.bCanAdv = true
	if nHasNum < nNeedCostNum then
		sColor = _cc.red
		self.bCanAdv = false
	end
	local sBtnTxt = {
		{text = formatCountToStr(nHasNum), color = sColor},  --当前拥有
		{text = "/"..formatCountToStr(nNeedCostNum), color = _cc.white}, 
	}
	self.pBtnImgLb:setString(sBtnTxt)
	self.pBtnImgLb:showImg()

	--显示路线和星魂图
	self.pLaySoulItems:setVisible(true)
	self.pLayLines:setVisible(true)
	--隐藏突破效果层
	self.pLayBreak:setVisible(false)
	self:setRightBtnEnabled(true)
end

function DlgHeroStarSoul:removeBreakFontEffect(  )
	-- body
	for k,v in pairs(self.pBreakFontEffect) do
 			v:removeSelf()
 			v= nil
 		end
 		self.pBreakFontEffect = {}
end

--上阵英雄列表点击
function DlgHeroStarSoul:onIconClicked(pHero, nIndex)
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
function DlgHeroStarSoul:setCurData(_tData)
	-- body
	local tData = _tData
	if tData then
		self.tHeroData = tData
		self:setArrowImg(tData)	
		self:updateViews()
	end
end

--设置指示图标
function DlgHeroStarSoul:setArrowImg(_tData)
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
--达到突破时的动画
function DlgHeroStarSoul:showFirstBreakAction(  )
	-- body
	self.pImgBreakBg:setVisible(false)
	self.pImgBreakBg:setScale(1,0)
	self.pLbBreak:setOpacity(0)
	if not self.pBreakFontEffect[1] then
	 	self.pBreakFontEffect[1] = MUI.MImage.new("#v2_fonts_tpxg.png")
	 	self.pBreakFontEffect[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	self.pLayBreak:addView(self.pBreakFontEffect[1],10)
	 	self.pBreakFontEffect[1]:setPosition(self.pImgFont:getPositionX(),self.pImgFont:getPositionY())
	 end
	 if not self.pBreakFontEffect[2] then
	 	self.pBreakFontEffect[2] = MUI.MImage.new("#v2_fonts_tpxg.png")
	 	self.pBreakFontEffect[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	self.pLayBreak:addView(self.pBreakFontEffect[2],11)
	 	self.pBreakFontEffect[2]:setPosition(self.pImgFont:getPositionX(),self.pImgFont:getPositionY())
	 end

	local action1 = cc.ScaleTo:create(0, 2.5)
	local action2 = cc.ScaleTo:create(0.2, 1)

	local callback1 = cc.CallFunc:create(function (  )
		-- body
		--底框的展开动画
		self:showBreakBgAction()

	end)

	local action3 = cc.FadeTo:create(0, 255)
	local action4 = cc.FadeTo:create(0.1, 255*0.5)
	local action5 = cc.FadeTo:create(0.75, 0)

	local action6_1 = cc.FadeTo:create(0, 255 * 0.5)
	local action6_2 = cc.ScaleTo:create(0, 1.1)
	local action6 = cc.Spawn:create(action6_1,action6_2)

	local action7_1 = cc.FadeTo:create(0.55, 0)
	local action7_2 = cc.ScaleTo:create(0.55, 1.18)
	local action7 = cc.Spawn:create(action7_1,action7_2)

	self.pImgFont:runAction(cc.Sequence:create(action1,action2,callback1))
	self.pBreakFontEffect[1]:runAction(cc.Sequence:create(action3,action4,action5))
	self.pBreakFontEffect[2]:runAction(cc.Sequence:create(action6,action7))


end
function DlgHeroStarSoul:showBreakBgAction(  )
	-- body
	self.pImgBreakBg:setVisible(true)
	local action1 = cc.ScaleTo:create(0,1,0.33)
	local action2_1 = cc.ScaleTo:create(0.25, 1,1.02)

	local callback = cc.CallFunc:create(function (  )
		-- body
		local action5 = cc.FadeTo:create(0, 0)
		local action6 = cc.FadeTo:create(0.2, 255)
		
		self.pLbBreak:runAction(cc.Sequence:create(action5,action6))
		self:showBreakBgLightEffect()

	end)
	local action2 = cc.Spawn:create(action2_1,callback)

	local action3 = cc.ScaleTo:create(0.15, 1,0.98)
	local action4 = cc.ScaleTo:create(0.1, 1,1)
	self.pImgBreakBg:runAction(cc.Sequence:create(action1,action2,action3,action4))

	
end
--底板扫光
function DlgHeroStarSoul:showBreakBgLightEffect(  )
	-- body
	addTextureToCache("tx/other/rwww_kksg_wjxh")
	addTextureToCache("tx/other/rwww_xh_sg_xsxg")
	local tArmData1  = {
		nFrame = 12, -- 总帧数
		pos = {0, 47}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
			nPerFrameTime = 1/18, -- 每帧播放时间（24帧每秒）
			tActions = {
			{
				nType = 1, -- 序列帧播放
				sImgName = "rwww_kksg_wjxh_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 12, -- 结束帧下标
				tValues = nil, 
			},
		},
	}
	local pArm1 = MArmatureUtils:createMArmature(
		tArmData1, 
		self.pImgBreakBg, 
		99, 
		cc.p(self.pImgBreakBg:getWidth()/2, self.pImgBreakBg:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm1 then
		pArm1:play(1)
	end

	local tArmData2 = {
		nFrame = 12, -- 总帧数
		pos = {0, -47}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		fScaleX = -1,
        fScaleY = 1,
		nBlend = 1, -- 需要加亮
		nPerFrameTime = 1/18, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 1, --序列帧播放
				sImgName = "rwww_kksg_wjxh_",
				nSFrame = 1,
				nEFrame = 12,
				tValues = nil,
			}
		},
	}
	local pArm2 = MArmatureUtils:createMArmature(
		tArmData2, 
		self.pImgBreakBg,  
		99, 
		cc.p(self.pImgBreakBg:getWidth()/2, self.pImgBreakBg:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm2 then
		pArm2:play(1)
	end
	local tArmData3 = {
		nFrame = 30, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
		nPerFrameTime = 1/20, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 8, --序列帧播放
				sImgName = "rwww_xh_sg_xsxg_003",
				nSFrame = 1,
				nEFrame = 5,
				tValues = {
					{-200, 0}, -- 移动前坐标
					{-38, 0}, -- 移动后坐标
					{0, 255}, -- 开始, 结束透明度值
				},
			},
			{
				nType = 8, -- 移动+透明度
				sImgName = "rwww_xh_sg_xsxg_003",
				nSFrame = 6,
				nEFrame = 12,
				tValues = {-- 参数列表
					{-4, 0}, -- 移动前坐标
					{200, 0}, -- 移动后坐标
					{218, 0}, -- 开始, 结束透明度值
				},
			},

		},
	}
	local pArm3 = MArmatureUtils:createMArmature(
		tArmData3, 
		self.pImgBreakBg,  
		99, 
		cc.p(self.pImgBreakBg:getWidth()/2, self.pImgBreakBg:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm3 then
		pArm3:play(1)
	end
end
--突破升星 空心变实心的动画
function DlgHeroStarSoul:showBreakStarEffect(  )
	-- body
	addTextureToCache("tx/other/rwww_xh_sxtx")
	for i=1, 3 do
		if not self.pStarEffect[i] then
		 	self.pBreakFontEffect[1] = MUI.MImage.new("#v2_fonts_tpxg.png")
		 	self.pBreakFontEffect[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		 	self.pLayBreak:addView(self.pBreakFontEffect[1],10)
		 
		 end
	end
	if not self.pStarEffect[1] then
	 	self.pBreakFontEffect[1] = MUI.MImage.new("#v2_fonts_tpxg.png")
	 	self.pBreakFontEffect[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	self.pLayBreak:addView(self.pBreakFontEffect[1],10)
	 	self.pBreakFontEffect[1]:setPosition(self.pImgFont:getPositionX(),self.pImgFont:getPositionY())
	 end
	 if not self.pBreakFontEffect[2] then
	 	self.pBreakFontEffect[2] = MUI.MImage.new("#v2_fonts_tpxg.png")
	 	self.pBreakFontEffect[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	self.pLayBreak:addView(self.pBreakFontEffect[2],11)
	 	self.pBreakFontEffect[2]:setPosition(self.pImgFont:getPositionX(),self.pImgFont:getPositionY())
	 end

	local action1 = cc.ScaleTo:create(0, 2.5)
	local action2 = cc.ScaleTo:create(0.2, 1)

	local callback1 = cc.CallFunc:create(function (  )
		-- body
		--底框的展开动画
		self:showBreakBgAction()

	end)


	local action3 = cc.FadeTo:create(0, 255)
	local action4 = cc.FadeTo:create(0.1, 255*0.5)
	local action5 = cc.FadeTo:create(0.75, 0)

	local action6_1 = cc.FadeTo:create(0, 255 * 0.5)
	local action6_2 = cc.ScaleTo:create(0, 1.1)
	local action6 = cc.Spawn:create(action6_1,action6_2)

	local action7_1 = cc.FadeTo:create(0.55, 0)
	local action7_2 = cc.ScaleTo:create(0.55, 1.18)
	local action7 = cc.Spawn:create(action7_1,action7_2)

	self.pImgFont:runAction(cc.Sequence:create(action1,action2,callback1))
	self.pBreakFontEffect[1]:runAction(cc.Sequence:create(action3,action4,action5))
	self.pBreakFontEffect[2]:runAction(cc.Sequence:create(action6,action7))

end

--突破成功火花
function DlgHeroStarSoul:showBreakBgSuccessEffect(  )
	-- body
	addTextureToCache("tx/other/rwww_hddj_fkxg")
	addTextureToCache("tx/other/rwww_xh_xsxg")
	local tArmData1  = {
		nFrame = 19, -- 总帧数
		pos = {-42, 27}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
			nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
			tActions = {
			{
				nType = 1, -- 序列帧播放
				sImgName = "rwww_hddj_fkxg_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 19, -- 结束帧下标
				tValues = nil, 
			},
		},
	}
	local pArm1 = MArmatureUtils:createMArmature(
		tArmData1, 
		self.pImgBreakBg, 
		99, 
		cc.p(self.pImgBreakBg:getWidth()/2, self.pImgBreakBg:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm1 then
		pArm1:play(1)
	end

	local tArmData2 = {
		nFrame = 19, -- 总帧数
		pos = {42, 28}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		fScaleX = -1.1,
        fScaleY = 1,
		nBlend = 1, -- 需要加亮
		nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 1, --序列帧播放
				sImgName = "rwww_hddj_fkxg_",
				nSFrame = 1,
				nEFrame = 19,
				tValues = nil,
			}
		},
	}
	local pArm2 = MArmatureUtils:createMArmature(
		tArmData2, 
		self.pImgBreakBg,  
		99, 
		cc.p(self.pImgBreakBg:getWidth()/2, self.pImgBreakBg:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil

			-- self:showSoulItem()
		end, Scene_arm_type.normal)
	if pArm2 then
		pArm2:play(1)
	end
	local tArmData3 = {
		nFrame = 12, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
		nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, --序列帧播放
				sImgName = "rwww_xh_xsxg_002",
				nSFrame = 1,
				nEFrame = 12,
				tValues = {
					{2.3, 2.5},-- 开始, 结束缩放值
					{255, 0},-- 开始, 结束透明度值
				},
			},
		},
	}
	local pArm3 = MArmatureUtils:createMArmature(
		tArmData3, 
		self.pImgBreakBg,  
		99, 
		cc.p(self.pImgBreakBg:getWidth()/2, self.pImgBreakBg:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil

			if self.nActionType == 1 then

				self:showSoulItem()
			end
			setToastNCState(2)
		    --战斗结束后播放战力变化
 			Player:getPlayerInfo():playFCChangeTx()

		end, Scene_arm_type.normal)
	if pArm3 then
		pArm3:play(1)
	end
end

function DlgHeroStarSoul:showLineEffect( _nIndex )
	-- body
	-- print("nindex",_nIndex)
	if not self.tImgLines[_nIndex-1] then
		return
	end
	local pImgLine = self.tImgLines[_nIndex-1]
	local tAnPos = pImgLine:getAnchorPoint()
	if not self.pLineEffect[1] then
	 	self.pLineEffect[1] = MUI.MImage.new("#v2_line_longx.png")--,{ scale9 = true, capInsets = cc.rect(1, 5, 1, 1) })

	 	self.pLayLines:addView(self.pLineEffect[1],10)

	 end
	 if not self.pLineEffect[2] then
	 	self.pLineEffect[2] = MUI.MImage.new("#v2_line_longx.png")--,{ scale9 = true, capInsets = cc.rect(1, 5, 1, 1) })
	 	self.pLineEffect[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	self.pLayLines:addView(self.pLineEffect[2],11)
	 end
	self.pLineEffect[1]:setScale(0)
	self.pLineEffect[1]:setPosition(pImgLine:getPositionX(),pImgLine:getPositionY())
	self.pLineEffect[1]:setContentSize(pImgLine:getWidth()+5, pImgLine:getHeight())
    self.pLineEffect[1]:setIgnoreOtherHeight(true)
    	
    self.pLineEffect[1]:setAnchorPoint(cc.p(tAnPos.x, tAnPos.y))
	self.pLineEffect[1]:setRotation(pImgLine:getRotation())

	self.pLineEffect[2]:setScale(0)
	self.pLineEffect[2]:setPosition(pImgLine:getPositionX(),pImgLine:getPositionY())
	self.pLineEffect[2]:setContentSize(pImgLine:getWidth()+5, pImgLine:getHeight())
    self.pLineEffect[2]:setIgnoreOtherHeight(true)
    	
    self.pLineEffect[2]:setAnchorPoint(cc.p(tAnPos.x, tAnPos.y))
	self.pLineEffect[2]:setRotation(pImgLine:getRotation())



	-- local action1 = cc.ScaleTo:create(0, 1,0)
	local action2 = cc.ScaleTo:create(0.25, 1,1)

	local action4 = cc.ScaleTo:create(0.25, 1,1)


	local action5 = cc.FadeTo:create(0.6, 0)

	self.pLineEffect[1]:runAction(cc.Sequence:create(action2))
	self.pLineEffect[2]:runAction(cc.Sequence:create(action4,action5))

end

function DlgHeroStarSoul:showAddStarEffect( )
	-- body
	for k, v in pairs(self.tHeroListIcon) do
		local tData = v:getCurData()
		if tData and type(tData) == "table" then
			if tData.nId == self.tHeroData.nId then
				v:showAddStarEffect()
			end
		end
	end
end


--还原按钮点击响应
function DlgHeroStarSoul:onRecoverClicked()
	if table.nums(self.tHeroData.tSoulList) > 1 then
		local tStr = {
			{color = _cc.pwhite, text = getConvertedStr(7, 10359)}
		}
		local nRecoverCost = tonumber(getHeroInitData("soulReset"))
		showBuyDlg(tStr, nRecoverCost, handler(self, self.reqRecoverSoul), 0, true)
	else
		TOAST(getConvertedStr(7, 10358)) --激活星魂后才可进行还原
	end
end

--请求还原星魂
function DlgHeroStarSoul:reqRecoverSoul()
	-- body
	SocketManager:sendMsg("reqHeroSoulRecover", {self.tHeroData.nId},
		function(__msg, __oldMsg)
			-- body
			self.bIsRecover = true
		end
	)
end
--激活(突破)按钮点击回调
function DlgHeroStarSoul:onRightClicked(pView)
	--新手引导武将星魂
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtn)

	if self.nLastClickTime then
		local nCurTime = getSystemTime(false)
		if (nCurTime - self.nLastClickTime) < nDistanceTime then
			return
		end
	end
	self.nLastClickTime = getSystemTime(false)
	if not self.bCanAdv then
		if self.nActionType == 1 then
			TOAST(getConvertedStr(7, 10356))
		else
			TOAST(getConvertedStr(7, 10357))
		end
		return
	end
	if self.nActionType  == 2 then
		setToastNCState(1)   --为了突破动画播完后才飘战力增加动画
	end
	SocketManager:sendMsg("reqHeroSoulActive", {self.tHeroData.nId,self.nActionType,self.nStage,self.nOpenPos},
		function(__msg, __oldMsg)
			-- body
			if  __msg.head.state == SocketErrorType.success then
				if __oldMsg[2] == 1 then
    				TOAST(getConvertedStr(7, 10354))
				elseif __oldMsg[2] == 2 then
    				TOAST(getConvertedStr(7, 10355))
				end
			end
		end
	)
end

--接收服务端发回的登录回调
function DlgHeroStarSoul:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
    	TOAST(getConvertedStr(7, 10354))
    end
end

-- 析构方法
function DlgHeroStarSoul:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroStarSoul:regMsgs( )
	-- body
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.refreshHeroData))

end

--刷新武将数据
function DlgHeroStarSoul:refreshHeroData( )
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
function DlgHeroStarSoul:unregMsgs(  )
	-- body
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
end


--暂停方法
function DlgHeroStarSoul:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgHeroStarSoul:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgHeroStarSoul