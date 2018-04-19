-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-25 20:30:38
-- Description: 英雄升级
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local MBtnExText = require("app.common.button.MBtnExText")
local DlgAlert = require("app.common.dialog.DlgAlert")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ADDTIME = 2/0.01 --目前是两秒

local DlgHeroUpdate = class("DlgHeroUpdate", function()
	-- body
	return DlgCommon.new(e_dlg_index.heroupdate)
end)

function DlgHeroUpdate:ctor(_tData, _nTeamType)
	-- body
	self:myInit()
	self.tHeroData = _tData 
	self.nTeamType = _nTeamType or 1

	-- dump(self.tHeroData)

	self:refreshData()
	self:setTitle(getConvertedStr(5, 10110))
	parseView("dlg_hero_update", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroUpdate:myInit(  )
	-- body
	self.tHeroData = nil --英雄数据
	self.tHeroListIcon = {} --英雄队列icon

	self.tHeroQueueData = {} --英雄队列
	self.tCopyHeroQueueData ={}--保存的英雄队列(用于升级特效)
	self.tExpGoods = {} --经验丹
	self.nFinalLeftExp = 0 --最终剩余经验
	self.nFinalLv =  0 --最终升级的等级
	self.nNowSelectIndex = 1 --当前选择下标

	self.nNowPercent = 1 --当前经验比例
	self.fNowPercent = 1 --当前经验比例(含小数值)
	self.nUpPercent =  1 --升级后的经验比例
	self.fUpPercent =  1 --升级后的经验比例(含小数值)

	self.tFinalInfo = {} --升级后的属性值

	self.tImgArrowPosX = {} --箭头选择坐标

	self.nOverExp = 0 --溢出的经验

	self.bMaxLevel = false --是否为最高级

	self.nUpFwLv = 0 --升级前等级
	self.nUpFnLv = 0 --升级后等级
	self.nUpNowFnLv = 0 --升级时的当前等级
	self.nUpNowPercent = 0--升级过程中当前等级
	self.nUpFwPercent = 0--升级前的百分比
	self.nUpFnPercent = 0--升级后的百分比
	self.nEvenPercent = 0--每次升级的百分比
	self.nUpIngFnPercent = 0 --升级中最后的百分比

	self.bCanUping = true --是否可以播放进度条效果

	self.bUpBeforeLv = 0 --记录每次升级后的等级
	self.bUpExp	= 0 --记录每次升级后的等级
	-- self.tFinalInfoData = {} --升级后的属性

	self._nstuffs 		= 		2		--物品总量
	self._nselect 		=		0		--玩家当前选定的购买次数
	self.bRedoneSV 		= 		true 	--是否重算滑动条变化	

	self.bUse 			= 		false --是否使用
	self.nTopLv 		= tonumber(getGlobleParam("levelLimit"))
end

--初始化数据
function DlgHeroUpdate:refreshData()
	if not self.tHeroData then
        return
	end

	if self.bUpBeforeLv == self.tHeroData.nLv and self.bUpExp == self.tHeroData.nE then
		return
	end
	self.pHeroInfo = Player:getHeroInfo()

	--用于升级特效的数据处理
	self:updataTx(self.tCopyHeroQueueData,self.pHeroInfo:getHeroOnlineQueueByTeam(self.nTeamType))
	if  self.bCanUping then
		self:upDateCnt(self.tCopyHeroQueueData,self.pHeroInfo:getHeroOnlineQueueByTeam(self.nTeamType))
	end
	self.tCopyHeroQueueData = copyTab(self.pHeroInfo:getHeroOnlineQueueByTeam(self.nTeamType))

	self.tHeroQueueData = self.pHeroInfo:getHeroOnlineQueueByTeam(self.nTeamType)  --英雄队列
	-- dump(self.tHeroQueueData, "self.tHeroQueueData ==")
	--升级经验丹
	for i=1,3 do
		self.tExpGoods[i] = getGoodsByTidFromDB(e_id_item.expItemS -1+i)
	end


	--获得最终的经验与等级
	self:getFinalData()

end

--升级数据
function DlgHeroUpdate:upDateCnt(_tOrData,_tFnData)
	for k,v in pairs(_tFnData) do
		if type(_tOrData[k]) == "table" then
			if _tOrData[k] and _tOrData[k].nE  and (v.nE ~= _tOrData[k].nE) then
				--todo
				self.nUpFwLv = _tOrData[k].nLv --升级前等级
				self.nUpFnLv = v.nLv --升级后等级
				self.nUpNowFnLv = self.nUpFwLv

				self.nUpFwPercent = math.floor(_tOrData[k].nE /_tOrData[k]:getLvExpByLv(_tOrData[k].nLv)*100) --升级前的百分比
				self.nUpNowPercent = self.nUpFwPercent
				self.nUpFnPercent =  math.floor( v.nE /v:getLvExpByLv(v.nLv)*100)--升级后的百分比

				local nPercent = 0
				if _tOrData[k].nLv == v.nLv then
					self.nEvenPercent = 1
					self.nUpIngFnPercent = self.nUpFnPercent
				else
					self.nUpIngFnPercent = 100
					nPercent = self.nUpFwPercent
					for i=(_tOrData[k].nLv+1),v.nLv do
						if i<v.nLv then
							nPercent = nPercent + 100
						else
							nPercent = nPercent + self.nUpFnPercent
						end
					end
				end

				if nPercent/ADDTIME <1 then
					self.nEvenPercent = 1
				else
					self.nEvenPercent = nPercent/ADDTIME
				end

				-- self.tBarFin:setVisible(false)
				-- self.pLyArrowUp:setVisible(false) 
				-- self.pLyArrowDown:setVisible(false)
				self:onUpdataEffect()

			end
		end
	end
end


--升级效果
function DlgHeroUpdate:onUpdataEffect( )

	if not self.bCanUping then
		return
	end


	local fDelayTime = 0.01
	self.tBarNow:setPercent(self.nUpNowPercent)
	if self.nUpNowPercent < self.nUpIngFnPercent then
		self.nUpNowPercent = self.nUpNowPercent +self.nEvenPercent
	    self:runAction( -- 延时调用
			cc.Sequence:create(cc.DelayTime:create(fDelayTime),
			cc.CallFunc:create(handler(self, self.onUpdataEffect))))
	else
		if self.nUpNowFnLv then
			if (self.nUpNowFnLv+1) < self.nUpFnLv then --如果还没有达到最后的等级
				self.nUpNowFnLv = self.nUpNowFnLv +1
				self.nUpNowPercent = self.nEvenPercent
				self.nUpIngFnPercent = 100
				self:onUpdataEffect()
			else
				self.nUpNowFnLv = nil
				if self.nUpFwLv~= self.nUpFnLv then
					self.nUpIngFnPercent = self.nUpFnPercent
					self.nUpNowPercent = self.nEvenPercent
					self:onUpdataEffect()--越级升级时,需要继续调用
				else
					--显示比例
					-- self.tBarFin:setVisible(true)
					-- self.pLyArrowUp:setVisible(true) 
					-- self.pLyArrowDown:setVisible(true)
					self.tBarNow:setPercent(self.nUpFnPercent)
				end
			end
		else
			--显示比例
			-- self.tBarFin:setVisible(true)
			-- self.pLyArrowUp:setVisible(true) 
			-- self.pLyArrowDown:setVisible(true)
			self.tBarNow:setPercent(self.nUpFnPercent)
		end
	end

end



--显示升级特效
function DlgHeroUpdate:updataTx(_tOrData,_tFnData)
	if _tOrData and _tFnData and table.nums(_tOrData)>0 and table.nums(_tFnData)>0  then
		for k,v in pairs(_tFnData) do
			if  (type(v) == "table") and (type(_tOrData[k]) == "table")  then
				if v.nLv and _tOrData[k] and  _tOrData[k].nLv  then
					if v.nLv >  _tOrData[k].nLv then
						if self.tHeroListIcon[k] then
							playUpDefenseArm(self.tHeroListIcon[k])
							Sounds.playEffect(Sounds.Effect.lvup)
						end
					end
				end
			end
		end
	end
end

--获得最终的经验与等级
function DlgHeroUpdate:getFinalData()
	-- body
	self.bMaxLevel = false
	self.nFinalLeftExp = 0 --最终剩余经验
	self.nFinalLv =  0 --最终升级的等级


	local nItemExp = 0 --物品经验
	if self.tExpGoods[self.nNowSelectIndex] then
		nItemExp = tonumber(self.tExpGoods[self.nNowSelectIndex].sParam)*self._nselect
	end

	local nUpExp = self.tHeroData:getLvExpByLv(self.tHeroData.nLv) - self.tHeroData.nE --获取剩余升级经验
	self.nNowPercent = math.floor(self.tHeroData.nE /self.tHeroData:getLvExpByLv(self.tHeroData.nLv)*100)  --当前经验比例
    self.fNowPercent = self.tHeroData.nE /self.tHeroData:getLvExpByLv(self.tHeroData.nLv)
    self.nFinalLv = self.tHeroData.nLv -- 记录当前等级
	if nItemExp >= nUpExp   then --可升级
		self:crossUpdata(nItemExp,nUpExp)
	else
		self.nOverExp = 0 --没有溢出经验
		self.nFinalLeftExp = self.tHeroData.nE + nItemExp

		self.nFinalLv = self.nFinalLv +1
	end
end

--越级升级  _nHaveExp,(当前拥有经验) _nNextUpExp (离下一级升级剩余经验)
function DlgHeroUpdate:crossUpdata(_nHaveExp,_nNextUpExp)
	local nHaveExp    = tonumber(_nHaveExp)
	local nNextUpExp  = tonumber(_nNextUpExp)

	while (nHaveExp >= nNextUpExp) do
		if self.nFinalLv < Player:getPlayerInfo().nLv then
			self.nFinalLv = self.nFinalLv +1
			nHaveExp = nHaveExp - nNextUpExp
			nNextUpExp = tonumber(self.tHeroData:getLvExpByLv(self.nFinalLv))
			self.nFinalLeftExp = nHaveExp
			self.nOverExp = 0 --没有溢出经验
		else
			self.nFinalLv = Player:getPlayerInfo().nLv
			self.nOverExp = nHaveExp - nNextUpExp
			self.nFinalLeftExp =  tonumber(self.tHeroData:getLvExpByLv(self.nFinalLv))
			if self.nOverExp == nHaveExp or self:getIsTopLv() then --不可升级
				self.bMaxLevel = true --已经是最高级
			end
			break
		end
	end
end

--计算预览等级
function DlgHeroUpdate:calPreviewLv()
    self.nFinalLv = self.tHeroData.nLv -- 记录当前等级
	local nItemExp = 0 --物品经验
	if self.tExpGoods[self.nNowSelectIndex] then
		nItemExp = tonumber(self.tExpGoods[self.nNowSelectIndex].sParam)*self._nselect
	end
	--获取剩余升级经验
	local nNextUpExp = self.tHeroData:getLvExpByLv(self.tHeroData.nLv) - self.tHeroData.nE
	if nItemExp >= nNextUpExp then --可升级
		while (nItemExp >= nNextUpExp) do
			if self.nFinalLv < Player:getPlayerInfo().nLv then
				self.nFinalLv = self.nFinalLv + 1
				nItemExp = nItemExp - nNextUpExp
				--下一等级所需经验
				nNextUpExp = tonumber(self.tHeroData:getLvExpByLv(self.nFinalLv))
			else
				self.nFinalLv = Player:getPlayerInfo().nLv
				break
			end
		end
	else
		self.nFinalLv = self.nFinalLv +1
	end
end

--解析布局回调事件
function DlgHeroUpdate:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView, true) --加入内容层
	--只有一个按钮
	self:setOnlyConfirm()
	-- self:setNeedBottomBg(false)
	self:setupViews()
	-- self.pLayDown:removeSelf()
	-- self:setBottomView(self.pLayDown)
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroUpdate",handler(self, self.onDestroy))
end

--初始化控件
function DlgHeroUpdate:setupViews( )

	if not self.tHeroData then
		return
	end

	--img
	self.pImgArrow = self:findViewByName("img_arrow")

	--ly------------------
	self.pLyContent     = self:findViewByName("ly_content")
	-- self.pLyArrowUp 	= self:findViewByName("ly_arrow_up")
	-- self.pLyArrowDown 	= self:findViewByName("ly_arrow_down")

	-- self.pLySelect = self:findViewByName("ly_select")

	-- self.pLayDown = self:findViewByName("ly_down")

	self.playMinusTimes 				= 		self:findViewByName("lay_reduce")	
	self.playPlusTimes 					= 		self:findViewByName("lay_increase")	
	self.pLaySelectNum 					= 		self:findViewByName("lay_num")
	self.pLbLvFull 						= 		self:findViewByName("lb_lv_full")
	self.pLbLvFull:setString(getConvertedStr(7, 10032))
	setTextCCColor(self.pLbLvFull, _cc.red)

	--经验丹图标
	self.tExpIconItem = {}
	for i=1,3 do
		local pItem = self:findViewByName("ly_icon_"..i)
		self.tExpIconItem[i] = getIconGoodsByType(pItem, TypeIconGoods.HADMORE, type_icongoods_show.itemnum,
		self.tExpGoods[i], TypeIconGoodsSize.L)
		self.tExpIconItem[i]:setIconClickedCallBack(handler(self, self.onExpIconClicked))
		--隐藏品质特效
		self.tExpIconItem[i]:setIsShowBgQualityTx(false)
	end
	--优先选中拥有数量大于0的道具, 否则默认选中第一个
	for k, v in pairs(self.tExpGoods) do
		local nNums = getMyGoodsCnt(v.sTid) --拥有该物品的个数
		if nNums > 0 then
			self.nNowSelectIndex = k
			break
		end
	end
	--设置选中框特效
	self.tExpIconItem[self.nNowSelectIndex]:setIconSelected(true, true)

	--点击范围区域
	self.tClickZore = {}
	-- for i=1,3 do
	-- 	self.tClickZore[i] = self:findViewByName("ly_click_"..i)
	-- 	self.tClickZore[i]:setViewTouched(true)
	-- 	self.tClickZore[i]:setIsPressedNeedScale(false)
	-- 	self.tClickZore[i]:onMViewClicked(handler(self,self.onViewClick))
	-- end


	self:setRightHandler(handler(self, self.onUseClicked))
	

	self.tHeroListIcon = {} --英雄队列icon
	for k,v in pairs(self.tHeroQueueData) do
		local pLyHero = self:findViewByName("ly_hero_"..k)
		local bThisHero = false

		if type(v) == "table" then
			if v.nId == self.tHeroData.nId then --当前武将
				bThisHero = true
				-- nIconScale = TypeIconHeroSize.XL
				-- --放大后重设位置
				-- pLyHero:setPosition(pLyHero:getPositionX() -0.1*pLyHero:getWidth()/2,
				-- pLyHero:getPositionY()-0.1*pLyHero:getHeight()/2)
			end
			self.tHeroListIcon[k] =  getIconHeroByType(pLyHero,TypeIconHero.NORMAL,v,TypeIconHeroSize.L)
		else
			self.tHeroListIcon[k] =  getIconHeroByType(pLyHero,v,nil,TypeIconHeroSize.L)
		end

		if self.tHeroListIcon[k] then
			self.tHeroListIcon[k]:setIconClickedCallBack(function ( tHero )
				self:onIconClicked(tHero, k)
			end)
		end

		--记录需要显示位置
		local nPosX = pLyHero:getPositionX()+pLyHero:getWidth()/2 +self.pImgArrow:getWidth()/4
		self.tImgArrowPosX[k] = nPosX

		if bThisHero then
			self.pImgArrow:setPositionX(nPosX)
		end
	end

	--进度条
	self.pLyBar = self:findViewByName("ly_bar")
	self.tBarNow = MCommonProgressBar.new({bar = "v1_bar_blue_5loiu.png",barWidth = 488, barHeight = 16})
	self.tBarFin = MCommonProgressBar.new({bar = "v1_bar_yellow_7.png",barWidth = 490, barHeight = 14})
	self.pLyBar:addView(self.tBarNow,100)
	centerInView(self.pLyBar,self.tBarNow)

	self.pLyBar:addView(self.tBarFin,101)
	centerInView(self.pLyBar,self.tBarFin)
	self.tBarFin:setVisible(false)



	--lb------------------------------
	self.pLbSecTitle = self:findViewByName("lb_update_title")
	setTextCCColor(self.pLbSecTitle, getColorByQuality(self.tHeroData.nQuality))
	self.pLbSecTitle:setString(self.tHeroData.sName)


	local pLbShowExp = self:findViewByName("lb_show_exp")--显示当前升级经验
	-- self.pLbShowExp:enableOutline(cc.c4b(0, 0, 0, 255*0.6), 1)

    local RichTextEx = require("app.common.richview.RichTextEx")
    local pRichText = RichTextEx.new({align = 1})
    pRichText:setPosition(pLbShowExp:getPosition())
    pRichText:setAnchorPoint(0.5, 0.5)
    pRichText:setOutline(cc.c4b(0, 0, 0, 255*0.6), 1)
	self.pLbShowExp = pRichText
    pLbShowExp:getParent():addChild(self.pLbShowExp, 10)


	self.tFinalInfo = {} --升级后的属性值
	for i=1,3 do
		-- 右英雄名字
		local tConTable = {}
		--文本
		local tLb= {
			{getConvertedStr(5, 10025-1+i),getC3B(_cc.pwhite)},
			{0,getC3B(_cc.green)},
		}
		tConTable.tLabel = tLb
		self.tFinalInfo[i] =  createGroupText(tConTable)
		-- self.tFinalInfo[i]:setAnchorPoint(0.5,0.5)
		self.pLyContent:addView(self.tFinalInfo[i],10)
		self.tFinalInfo[i]:setPosition(354, 320-(i-1)*32)
	end


	--标杆百分比
	self.pLbPercentUp   = self:findViewByName("lb_percent_up")
	self.pLbPercentDown = self:findViewByName("lb_percent_down")
	self.pLbPercentUp:setZOrder(11)
	self.pLbPercentDown:setZOrder(11)

	--资质数据显示
	self.tTalentInfo = {}
	for i=1,3 do
		local pView = self:findViewByName("ly_tl_l_"..i)
		self.tTalentInfo[i] = ItemHeroInfoLb.new(i)
		pView:addView(self.tTalentInfo[i],100)
	end


	--当前等级
	self.pLbCurLv = self:findViewByName("lb_cur_lv")
	--预览等级
	self.pLbAfterLv = self:findViewByName("lb_after_lv")
	--本次提升经验
	self.pLbAddExp = self:findViewByName("lb_add_exp")

	--当前选择的物品数量
	self.pLbItemNum 		= 		self:findViewByName("lb_item_num")

	--数量选择进度条
	self.playSliderBar				= 			self:findViewByName("lay_bar_select")
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_3.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(300, 18)
	self.pSliderBar:setSliderValue(50)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)

	--减少按钮
	self.playMinusTimes:setViewTouched(true)
	self.playMinusTimes:setIsPressedNeedScale(true)		
	self.playMinusTimes:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮
	self.playPlusTimes:setViewTouched(true)
	self.playPlusTimes:setIsPressedNeedScale(true)		
	self.playPlusTimes:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--数值层
	self.pLaySelectNum:setViewTouched(true)
	self.pLaySelectNum:setIsPressedNeedScale(true)
	self.pLaySelectNum:onMViewClicked(handler(self, self.onOpenSetNum))

end

-- 修改控件内容或者是刷新控件数据
function DlgHeroUpdate:updateViews()
	if not self.tHeroData then
       return
	end

	self:refreshData()

	if self.bUpBeforeLv == self.tHeroData.nLv and self.bUpExp == self.tHeroData.nE then
		return 
	end


	self:updateExpItemNums()--更新物品数据

	setTextCCColor(self.pLbSecTitle, getColorByQuality(self.tHeroData.nQuality))
	self.pLbSecTitle:setString(self.tHeroData.sName)
	--当前等级
	local str = {
		{text = getConvertedStr(7, 10346), color = _cc.pwhite},
		{text = getLvString(self.tHeroData.nLv, false), color = _cc.blue}
	}
	self.pLbCurLv:setString(str)

	-- self.pLbPercentUp:setString(self.nNowPercent.."%")  
	-- self.tBarNow:setPercent(self.nNowPercent)


	--刷新属性
	for k,v in pairs(self.tTalentInfo) do
		local tData = self.tHeroData.tAttList[k]
		if tData then
			-- v:setCurData(tData,3)
			if k == 1 then
				v:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), self.tHeroData:getAtkLuo())
			elseif k == 2 then
				v:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), self.tHeroData:getDefLuo())
			elseif k == 3 then
				v:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), self.tHeroData:getTroopsLuo())
			end
		end
	end

	self:refreshUseBtn()


	for k,v in pairs(self.tHeroQueueData) do
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

	self.bUpBeforeLv = self.tHeroData.nLv
	self.bUpExp = self.tHeroData.nE
end


--上阵英雄列表点击
function DlgHeroUpdate:onIconClicked(pHero, nIndex)
	self.nSelecedNullIndex = nil
	if pHero and (type(pHero) == "table") then
		self:setCurData(pHero)
	else
		if pHero == TypeIconHero.ADD then  --加号
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			tObject.nTeamType = self.nTeamType
			sendMsg(ghd_show_dlg_by_type,tObject)
		-- else
		-- 	if self.tCurData and pView then
		-- 		openIconInfoDlg(pView,self.tCurData)
		-- 	end
			self.nSelecedNullIndex = nIndex
		end
	end

end

--设置数据
function DlgHeroUpdate:setCurData(_tData)
	-- body
	local tData = _tData
	if tData then
		self.tHeroData = tData
		self:setArrowImg(tData)	

		self.bUpBeforeLv = 0  --记录每次升级后的等级
		self.bUpExp	= 0 	  --记录每次升级后的等级

		--切换武将是不允许进度条移动
		self.bCanUping = false
		self:updateViews()
		doDelayForSomething(self, function( )
			self.bCanUping = true
		end, 0.5)
	end
end

--设置指示图标
function DlgHeroUpdate:setArrowImg(_tData)
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


--点击回调
function DlgHeroUpdate:onUseClicked(pView)
	-- body

	if self.bMaxLevel then
 		TOAST(getConvertedStr(5, 10247))    --等级上限
 	end

 	--打开溢出经验提示框
 -- 	if self.nOverExp > 0 then
	-- 	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	--     if(not pDlg) then
	--         pDlg = DlgAlert.new(e_dlg_index.alert)
	--     end
	--     pDlg:setTitle(getConvertedStr(3, 10091))
	--     local strTip = {
	--     {text= getConvertedStr(5, 10250),color= _cc.pwhite},
	--     {text= formatCountToStr(self.nOverExp),color= _cc.red},
	--     {text= getConvertedStr(5, 10251),color= _cc.pwhite},
	-- 	}


	--     local pLabel = MUI.MLabel.new({
	--         text="",
	--         size=20,
	--         anchorpoint=cc.p(0.5, 0.5),
	--         dimensions = cc.size(380, 0),
	--         })
	-- 	pLabel:setString(strTip, false)
	--     pDlg:addContentView(pLabel)
	--     pDlg:setRightHandler(function ()

	--     	self:useProp()
	--     	pDlg:closeAlertDlg()

	    	
	--     end)
	--     pDlg:showDlg(bNew)
	-- else
		self:useProp()
 -- 	end


end

--使用道具
function DlgHeroUpdate:useProp()
	-- body
	if self._nselect <= 0 then
		TOAST(getConvertedStr(7, 10348))
		return
	end
	local nHv = self:getExpItemNums()
	local nUseType = 0 --使用方式: 0使用已有道具 1是金币购买并使用
	local nItemId = self.tExpGoods[self.nNowSelectIndex].sTid

	if (nHv > 0) then
		nUseType = 0
	else
		nUseType = 1
	end

	if self.tHeroData and self.tHeroData.nId and nItemId and nUseType then
		if nUseType == 1 then
			local tItem = getGoodsByTidFromDB(nItemId)
			local strTips ={
				{color = _cc.pwhite,text = getConvertedStr(7, 10079)},--购买
				{color = getColorByQuality(tItem.nQuality),text = tItem.sName},--道具名字
			}
			local nPrice = self.tExpGoods[self.nNowSelectIndex].nPrice * self._nselect
			--展示购买对话框
			showBuyDlg(strTips, nPrice, function ()        
				SocketManager:sendMsg("useExpElixir", {self.tHeroData.nId,nItemId,nUseType,self._nselect}, handler(self, self.onGetDataFunc))
			end, 0, false)
		else
			SocketManager:sendMsg("useExpElixir", {self.tHeroData.nId,nItemId,nUseType,self._nselect}, handler(self, self.onGetDataFunc))
		end
	end


end

--经验丹回调
function DlgHeroUpdate:onExpIconClicked(pData)

	if pData and pData.sTid then

		if pData.sTid == e_id_item.expItemS then
			self.nNowSelectIndex = 1
		elseif pData.sTid == e_id_item.expItemM then
			self.nNowSelectIndex = 2
		elseif pData.sTid == e_id_item.expItemB then
			self.nNowSelectIndex = 3
		end

		self:refreshSelectState()-- 更新选择状态

	end
end
 
--更新经验丹个数
function DlgHeroUpdate:updateExpItemNums()

	for k,v in pairs(self.tExpIconItem) do
		local nItemId = self.tExpGoods[k].sTid
		nNums = getMyGoodsCnt(nItemId) --拥有该物品的个数	
		v:setNumber(nNums, false, true)
	end

end

--获得当前选择经验丹拥有个数
function DlgHeroUpdate:getExpItemNums()
	local nNums = 0
	local nItemId = self.tExpGoods[self.nNowSelectIndex].sTid
	nNums = getMyGoodsCnt(nItemId) --拥有该物品的个数

	return nNums
end


--接收服务端发回的登录回调
function DlgHeroUpdate:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.useExpElixir.id then
        	--打开新的界面
        	-- dump(__msg.body,"__msg.body")
       		TOAST(getConvertedStr(5, 10252))
        end

    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


-- 析构方法
function DlgHeroUpdate:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroUpdate:regMsgs( )
	-- body

	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.refreshHeroData))
	--注册刷新背包消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateExpItemNums))
	-- 注册数字编辑数字消息
	regMsg(self, ghd_inputnum_setting_num_msg, handler(self, self.onSettingSelectNum))

end

-- 注销消息
function DlgHeroUpdate:unregMsgs(  )
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
	--注销刷新背包消息
	unregMsg(self, gud_refresh_baginfo)
	-- 注销数字编辑数字消息
	unregMsg(self, ghd_inputnum_setting_num_msg)

end

-- 点击层回调
function DlgHeroUpdate:onViewClick(pView)
	-- body
	local strName = pView:getName()

	if strName == "ly_click_1" then
		self.nNowSelectIndex = 1
	elseif strName == "ly_click_2" then
		self.nNowSelectIndex = 2
	elseif strName == "ly_click_3" then
		self.nNowSelectIndex = 3
	end

	self:refreshSelectState()-- 更新选择状态


end

-- 更新选择状态
function DlgHeroUpdate:refreshSelectState()

	-- self.pLySelect:setPositionX(self.tClickZore[self.nNowSelectIndex]:getPositionX())
	--刷新当前显示选中
	for k, v in pairs(self.tExpIconItem) do
		local bSelected = k == self.nNowSelectIndex
		v:setIconSelected(bSelected, bSelected)
	end

	self:getFinalData()
	self:refreshUseBtn()
end

--更新使用按钮
function DlgHeroUpdate:refreshUseBtn()

	local nHv = self:getExpItemNums() --拥有该物品的个数

	if self:getIsTopLv() then --到达满级
		for k,v in pairs(self.tFinalInfo) do
			v:setLabelCnCr(1," ")
			v:setLabelCnCr(2," ")
		end
		self:setRightBtnEnabled(false)
		--MAX
		self.pLbShowExp:setString(getConvertedStr(7, 10349))
		self.pLbAfterLv:setString("")
	else
		self:setRightBtnEnabled(true)		
	end


	--当前选中的物品
	local pData = self:getSelectedItem()

	local nNeed = math.ceil(self:getLeftExp()/tonumber(pData.sParam or 0))
	if nHv > 0 then
		self._nstuffs = math.min(nHv, nNeed, 100)
		self.bUse = true
		self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(6, 10739))--使用道具
	else
		self._nstuffs = math.min(nNeed, 100)
		self.bUse = false
		self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(7, 10265))--购买道具
	end
	if self._nstuffs <= 0 then--容错处理
		self._nstuffs = 1
	end
	if self.bUse then--大于0时候默认选择最大值
		self._nselect = self._nstuffs
	else
		self._nselect = 0
	end

	self.nLastUpExp = 0 --上次升级经验重置为0

	--更新进度条显示	
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
	self:refreshSelected()

end

--刷新武将数据
function DlgHeroUpdate:refreshHeroData( )
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

--滑动条释放消息回调
function DlgHeroUpdate:onSliderBarRelease( pView )
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	self._nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
	if self._nselect < 0 then
		self._nselect = 0
	end
	curvalue = self._nselect/self._nstuffs*100
	self.pSliderBar:setSliderValue(curvalue)		
end

--滑动滑动消息回调
function DlgHeroUpdate:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
		if nselect < 0 then
			nselect = 0
		end
		self._nselect = nselect
	else
		self.bRedoneSV = true
	end
	self:refreshSelected()
end
--minusBtn减少按钮点击回调事件
function DlgHeroUpdate:onMinusBtnClicked( pView )
	-- body	
	local nselect = self._nselect - 1
	if nselect < 0  then
		nselect = 0		
	end
	self._nselect = nselect
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--plusBtn增加按钮点击回调事件
function DlgHeroUpdate:onPlusBtnClicked( pView )
	-- body
	local nselect = self._nselect + 1
	if nselect > self._nstuffs then
		nselect = self._nstuffs		
	end
	self._nselect = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--获取选择的物品
function DlgHeroUpdate:getSelectedItem( )
	-- body
	return self.tExpGoods[self.nNowSelectIndex]
end

--获取升级剩余需要多少经验
function DlgHeroUpdate:getLeftExp()
	local nUpExp = 0  --升到可升等级需要的经验
	for i = self.tHeroData.nLv, Player:getPlayerInfo().nLv-1 do
		nUpExp = nUpExp + self.tHeroData:getLvExpByLv(i)
	end
	local nLeft = nUpExp - self.tHeroData.nE
	return nLeft
end

function DlgHeroUpdate:refreshSelected(  )
	-- body
	self.pLbItemNum:setString(self._nselect)
	local pData = self:getSelectedItem()
	if not pData then
		return
	end
	--刷新当前预览等级
	self:calPreviewLv()

	
	local nPrice = pData.nPrice * self._nselect
	if not self.pBtnRightExTop then
		local tBtnTable = {}
		tBtnTable.parent = self:getRightButton()		
		--文本
		tBtnTable.tLabel = {
			{0,getC3B(_cc.blue)},
			{"/",getC3B(_cc.white)},
			{"0",getC3B(_cc.white)}
		}
		tBtnTable.awayH = 5
		self.pBtnRightExTop = MBtnExText.new(tBtnTable)
	end	

	--使用道具
	if self.bUse then
	else
		local sColor = _cc.blue
		local nMyMoney = getMyGoodsCnt(e_type_resdata.money)
		if nPrice > nMyMoney then
			sColor = _cc.red
		end
		self.pBtnRightExTop:setImg("#v1_img_qianbi.png")
		self.pBtnRightExTop:setLabelCnCr(1, nMyMoney, getC3B(sColor))
		self.pBtnRightExTop:setLabelCnCr(3, nPrice, getC3B(_cc.white))		
	end
	self.pBtnRightExTop:setVisible(not self.bUse)



	local nAddExp = tonumber(pData.sParam or 0)*self._nselect

	if not self:getIsTopLv() then
		--获取经验进度数据
		local numerator, nPreviewLv = self:getExpProgress(pData)
		local denominator = self.tHeroData:getLvExpByLv(nPreviewLv)
		local tShowExpLb = {
			{text= formatCountToStr(numerator), color = _cc.white},
			{text= "/"..formatCountToStr(denominator), color = _cc.white}
		}
		--经验条上的进度
		self.pLbShowExp:setString(tShowExpLb)
		--预览等级
		local str = {
			{text = getConvertedStr(7, 10347), color = _cc.pwhite},
			{text = getLvString(self.nFinalLv, false), color = _cc.green}
		}
		self.pLbAfterLv:setString(str)
		--右边英雄属性
		for k,v in pairs(self.tFinalInfo) do
			local nType = e_id_hero_att.gongji
			local nValue = 0
			if k == 1 then
				nType = e_id_hero_att.gongji --攻击
			elseif k==2 then
				nType = e_id_hero_att.fangyu --防御
			elseif k==3 then
				nType = e_id_hero_att.bingli --兵力
			end
			nValue = self.tHeroData:getBasePropertyByAndLv(nType, self.nFinalLv)
			nValue = math.floor(nValue)
			v:setLabelCnCr(2," "..nValue)
			v:setLabelCnCr(1,getConvertedStr(5, 10025-1+k))
		end

		self.tBarNow:setPercent(math.floor(numerator/denominator*100)) --当前经验比例
	end

	if self:getIsTopLv() then
		self.pLbAddExp:setString("")
		self.pLbLvFull:setVisible(true)
		self.tBarNow:setPercent(100) --满等级
	else
		--本次提升经验
		local tStr = {
			{text= getConvertedStr(7, 10345), color = _cc.pwhite},
			{text= formatCountToStr(nAddExp), color = _cc.green}
		}
		self.pLbAddExp:setString(tStr)
		self.pLbLvFull:setVisible(false)
	end

end

--获取经验进度数据
function DlgHeroUpdate:getExpProgress(pData)
	--当前经验(武将本身经验和使用道具增加的经验)和下个升级进度条的预览等级
	local nLeftExp, nPreviewLv = 0, 0
	local nAddExp = tonumber(pData.sParam or 0)*self._nselect
	--当前武将经验值加使用道具所增加的经验值
	local nCurExp = self.tHeroData.nE + nAddExp
	local nCurLv = self.tHeroData.nLv
	nLeftExp = nCurExp
	while true do
		nCurExp = nCurExp - self.tHeroData:getLvExpByLv(nCurLv)
		if nCurExp < 0 then
			break
		else
			nCurLv = nCurLv + 1
			nLeftExp = nCurExp
		end
	end
	nPreviewLv = nCurLv
	return nLeftExp, nPreviewLv
end

--打开数字键盘
function DlgHeroUpdate:onOpenSetNum( pView )
	-- body
	showNumInputBoard(self._nselect, self._nstuffs)
end

function DlgHeroUpdate:onSettingSelectNum( sMsgName, pMsgObj )
	-- body
	local nNum = pMsgObj or 1
	--更新进度条显示	
	self.bRedoneSV = true
	self._nselect = nNum
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
	self:refreshSelected()
end

--武将是否到达了最高等级
function DlgHeroUpdate:getIsTopLv()
	return self.tHeroData.nLv and self.tHeroData.nLv >= self.nTopLv
end


--暂停方法
function DlgHeroUpdate:onPause( )
	-- body
	removeTextureFromCache("tx/other/sg_tx_jmtx_smjsj")
	self:unregMsgs()
end

--继续方法
function DlgHeroUpdate:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	addTextureToCache("tx/other/sg_tx_jmtx_smjsj")
	
end

return DlgHeroUpdate