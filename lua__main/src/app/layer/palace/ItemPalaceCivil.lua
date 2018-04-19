-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-18 15:12:23 星期二
-- Description: 王宫界面文官面板  应用于王宫界面和文官雇用界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemPalaceCivil = class("ItemPalaceCivil", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemPalaceCivil:ctor(_type, _bAuto)
	-- body
	self:myInit(_type, _bAuto)
	if self.bIsIconAuto then
		parseView("item_civilpanel", handler(self, self.onParseViewCallback))
	else
		parseView("item_civilpanel_m", handler(self, self.onParseViewCallback))
	end
	--注册析构方法
	self:setDestroyHandler("ItemPalaceCivil",handler(self, self.onItemPalaceCivilDestroy))
	
end

--初始化参数
function ItemPalaceCivil:myInit(_type, _bAuto)
	-- body
	self.bisHaveCivil = false --是否使用文官
	--self.type        = _type or 1
	self.nEmployType = _type or e_hire_type.official--1文官--2研究员 --3铁匠
	self.bIsIconAuto = _bAuto or false --icon自动调整
	self.iconhandler = handler(self, self.onJumpToCivilEmploy)

	self.bCanHire = false    --是否可雇佣
end

--解析布局回调事件
function ItemPalaceCivil:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemPalaceCivil:setupViews( )
	self.pLyRoot =  self:findViewByName("root") 

	--ly
	self.pLyKuang =  self:findViewByName("lay_civil_kuang")--头像层  

	self.pIcon = getIconHeroByType(self.pLyKuang, TypeIconHero.NORMAL, nil, TypeIconHeroSize.L)	 
	self.pIcon:setIconIsCanTouched(false)    

	self.pLyCivil =  self:findViewByName("lay_civil_value")--文官信息层 
	self.pLyCivil:setVisible(true)
	self.pLyStatus = self:findViewByName("lay_status")		--雇用状态层
	self.pLyStatus:setVisible(true)
	self.pLyCivilNil =  self:findViewByName("lay_civil_nil")--无文官时候的指导层
	self.pLyCivilNil:setVisible(false)
	self.pLyRS = self:findViewByName("lay_researcher_value")--研究员信息层

	--
	--文官信息层之下的标签
	self.pLbCivilName = self:findViewByName("lb_civil_name")--文官名字
	self.pLbCivilName:setString("")
	setTextCCColor(self.pLbCivilName, _cc.green)

	self.pLbCivilLv = self:findViewByName("lb_civil_lv")--文官等级
	self.pLbCivilLv:setString("")
	setTextCCColor(self.pLbCivilLv, _cc.blue)

	self.pLbFunc1 = self:findViewByName("lb_func1")--功能1
	self.pLbFunc1:setString(getConvertedStr(6, 10083))
	setTextCCColor(self.pLbFunc1, _cc.pwhite)
	self.pLbFunc1Value = self:findViewByName("lb_func1_value")--功能1值	
	self.pLbFunc1Value:setString(getConvertedStr(6, 10149))
	setTextCCColor(self.pLbFunc1Value, _cc.green)
	
	self.pLbFunc2 = self:findViewByName("lb_func2")--功能2
	setTextCCColor(self.pLbFunc2, _cc.pwhite)
	self.pLbFunc2:setString(getConvertedStr(6, 10084))
	self.pLbFunc2Value = self:findViewByName("lb_func2_value")--功能2值
	setTextCCColor(self.pLbFunc2Value, _cc.blue)
	self.pLbFunc2Value:setString(getConvertedStr(6, 10149))

	--研究员信息层
	self.pLbRsName = self:findViewByName("lb_rs_name")--研究员名字
	setTextCCColor(self.pLbRsName, _cc.green)
	self.pLbRsLv = self:findViewByName("lb_rs_lv")--研究员等级
	setTextCCColor(self.pLbRsLv, _cc.blue)
	self.pLayRsFunc = self:findViewByName("lb_func3")--研究员功能说明
	self.pLbTime = self:findViewByName("lb_time")

	--倒计时显示层
	self.pLbRelayTime = self:findViewByName("lb_relaytime")--剩余时间 倒计时用
	setTextCCColor(self.pLbRelayTime, _cc.red)
	-- self.pLbStatus1 = self:findViewByName("lb_status1")--文官状态雇用中
	-- self.pLbStatus1:setString(getConvertedStr(6, 10085))
	-- setTextCCColor(self.pLbStatus1, _cc.red)


	--self.pLyCivilNil之下的标签
	local pLbExplain = self:findViewByName("lb_explain")--文官功能说明
	self.pLbExplain = MUI.MLabel.new(
		{
			text = "",
			size = 20,
			anchorpoint = cc.p(0, 0.5), 
			dimensions = cc.size(316, 0)
		}
	)
	self.pLyCivilNil:addView(self.pLbExplain, 10)
	self.pLbExplain:setPosition(pLbExplain:getPosition())
	self.pLbExplain:setString(getConvertedStr(6, 10088))
	setTextCCColor(self.pLbExplain, _cc.pwhite) 
	-- self.pLbStatus2 = self:findViewByName("lb_status2")--文官状态未雇用
	-- self.pLbStatus2:setString(getConvertedStr(6, 10086))
	-- setTextCCColor(self.pLbStatus2, _cc.red) 
	self.pImgStatus2 = self:findViewByName("img_status2")--文官状态未雇用

	self:setViewTouched(false)
	self:onMViewClicked(handler(self, self.onJumpToCivilEmploy))
	self:setIsPressedNeedScale(false)

end

--隐藏底部背景图
function ItemPalaceCivil:hideDiBg()
	-- body
	self.pLyRoot:setBackgroundImage("ui/daitu.png",{scale9 = true, capInsets=cc.rect(63,65, 1, 1)})	
end

--重置大小和位置
function ItemPalaceCivil:resetSize()
	-- body
	self.pIcon:setScale(0.85)
	self.pLyKuang:setPositionX(self.pLyKuang:getPositionX() + 30)
	self.pLyCivil:setPositionX(self.pLyCivil:getPositionX() + 10)
	self.pLbExplain:setPositionX(self.pLbExplain:getPositionX() + 10)
	self.pImgStatus2:setPositionX(self.pImgStatus2:getPositionX() - 45)
	self.pLyStatus:setPositionX(360)
	self.pLyRS:setPositionX(140)
end

-- 修改控件内容或者是刷新控件数据
function ItemPalaceCivil:updateViews(  )
	-- body
	local buildLv = 0
	if self.nEmployType ==  e_hire_type.official then
		buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv				
		if buildLv < getOfficiclLimit() then--雇用对象对应建筑等级低于6显示带锁的未雇用显示			
			--设置无法雇用的状态		
			self:setFreeExplainText(getOfficiclLimit(), false)	
			self:showNotEmployed(2)--显示未雇用状态	
			return
		end
	elseif self.nEmployType == e_hire_type.researcher then
		buildLv = Player:getBuildData():getBuildById(e_build_ids.tnoly).nLv		
		if buildLv <  getResearcherLimit() then--雇用对象对应建筑等级低于6显示带锁的未雇用显示			
			--设置无法雇用的状态		
			self:setFreeExplainText(getResearcherLimit(), false)	
			self:showNotEmployed(2)--显示未雇用状态	
			return
		end
	elseif self.nEmployType == e_hire_type.smith then
		buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv		
		if buildLv < getBlackSmithLimit() then--雇用对象对应建筑等级低于6显示带锁的未雇用显示
			--设置无法雇用的状态	
			self:setFreeExplainText(getBlackSmithLimit(), false)	
			self:showNotEmployed(2)--显示未雇用状态	
			return
		end
	end	
	
	--当前雇用文官的基本数据
	local officaldata = Player:getBuildData():getBuildById(e_build_ids.palace):getOfficalBaseData()
	local researcherData = Player:getTnolyData():getResearcherBaseData()
	local BlackSmithdata = Player:getEquipData():getSmithConfigData()		
	--dump(BlackSmithdata,"BlackSmithdata=",100)
	self.bisHaveCivil = true
	if officaldata and self.nEmployType == e_hire_type.official then--刷新文官信息
		self:refreshOfficalInfo(officaldata) 			
	elseif researcherData and self.nEmployType == e_hire_type.researcher then--刷新研究员信息
		self:refreshResearcherInfo(researcherData)	
	elseif BlackSmithdata and self.nEmployType == e_hire_type.smith then--刷新铁匠信息
		self:refreshBlackSmithInfo(BlackSmithdata)				
	else
		self.bisHaveCivil = false
		self:showNotEmployed(1)--显示未雇用状态	
		self:setFreeExplainText(nil, true)
	end
end

--析构方法
function ItemPalaceCivil:onItemPalaceCivilDestroy(  )
	-- body
	unregUpdateControl(self)--取消秒刷新
end

function ItemPalaceCivil:onUpdateTime()
	--body
	local nCd = 0
	if self.nEmployType == e_hire_type.official then
		nCd = Player:getBuildData():getBuildById(e_build_ids.palace):getOfficalLeftCD()
	elseif self.nEmployType == e_hire_type.researcher then
		nCd = Player:getTnolyData():getCurResearcherCD()
	elseif self.nEmployType == e_hire_type.smith then
		nCd = Player:getEquipData():getSmithRemainCd()
	end
	self.pLbRelayTime:setString(formatTimeToHms(nCd, false, true))
	-- self.pLbRelayTime:setString(getTimeFormatCn(nCd))
	if nCd <= 0 then		
		unregUpdateControl(self)--停止计时刷新
		self:showNotEmployed(1)--显示未雇用状态
		if self.nEmployType == e_hire_type.smith then
			sendMsg(gud_equip_smith_hire_msg)
		elseif  self.nEmployType == e_hire_type.researcher then
			sendMsg(ghd_refresh_researcher_msg)
		end
	end
end

--跳转到文官雇用界面事件回调
function ItemPalaceCivil:onJumpToCivilEmploy( pView)
	-- body				
	local tObject = {}
	tObject.nType = e_dlg_index.civilemploy --dlg类型
	tObject.nEmployType = self.nEmployType--雇用类型
	sendMsg(ghd_show_dlg_by_type,tObject)

	--新手引导已点击打开雇佣界面
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pIcon)
end

--设置是否根据数据自动调整Icon
function ItemPalaceCivil:setIsIconAuto( _bAuto )
	-- body
	self.bIsIconAuto = _bAuto or false
	self:updateViews()
end
--设置雇用空闲状态下的提示信息
function ItemPalaceCivil:setFreeExplainText(lv, isOpen )
	-- body
	local open = false
	if not isOpen then
		open = false
	end
	open = isOpen
	local str = nil
	if self.nEmployType == e_hire_type.official then
		if open == false then
			str = string.format(getTipsByIndex(10027), lv) 
			self.pLbExplain:setString(str, false)
		else
			str = getTipsByIndex(10030)
			self.pLbExplain:setString(str, false)
		end
	elseif self.nEmployType == e_hire_type.researcher then
		if open == false then
			str = string.format(getTipsByIndex(10029), lv) 
			self.pLbExplain:setString(str, false)
		else
			str = getTipsByIndex(10032)
			self.pLbExplain:setString(str, false)
		end
	elseif self.nEmployType == e_hire_type.smith then
		if open == false then
			str = string.format(getTipsByIndex(10028), lv) 
			self.pLbExplain:setString(str, false)
		else
			str = getTipsByIndex(10031)
			self.pLbExplain:setString(str, false)
		end
	else
		self.pLbExplain:setString("")
	end	
end
--刷新文官数据 _data 当前雇用文官的基础数据
function ItemPalaceCivil:refreshOfficalInfo( _data )
	-- body
	--对应布局的显示隐藏
	self.pLyCivil:setVisible(true)
	self.pLyStatus:setVisible(true)
	self.pLyCivilNil:setVisible(false)
	self.pLyRS:setVisible(false)
	--icon刷新
	--dump(_data, "_data", 100)
	self.pIcon:setIconHeroType(TypeIconHero.NORMAL)	
	self.pIcon:setCurData(_data)
	self:setViewTouched(self.bIsIconAuto)
	setLbTextColorByQuality(self.pLbCivilName, _data.nQuality)
	if self.bIsIconAuto then 

		self:refreshEmployCivilRed()
	end
	self.pLbCivilName:setString(_data.sName)--文官名字
	--self.pLbCivilLv:setString(getLvString(_data.nLv, false))
	local str = {
		{color=getColorByQuality(_data.nQuality), text=_data.sName.." "},
		-- {color=_cc.blue, text=getLvString(_data.nLv, false)}
	}
	self.pLbCivilName:setString(str, false)
	local rate = _data.nRate*100
	self.pLbFunc1Value:setString("+"..tostring(rate)..getConvertedStr(6, 10170))
	if _data.nQuality == 1 then
		self.pLbFunc2Value:setString(getConvertedStr(6, 10149))
	elseif _data.nQuality == 4 then
		self.pLbFunc2Value:setString(getConvertedStr(6, 10150))
	end	
	unregUpdateControl(self)--停止计时刷新
	regUpdateControl(self, handler(self, self.onUpdateTime))
end
--刷新研究员数据
function ItemPalaceCivil:refreshResearcherInfo( _data )
	-- body
	self.pLyCivil:setVisible(false)
	self.pLyStatus:setVisible(true)
	self.pLyCivilNil:setVisible(false)
	self.pLyRS:setVisible(true)

	-- dump(_data, "_data", 100)
	self.pIcon:setIconHeroType(TypeIconHero.NORMAL)	
	self.pIcon:setCurData(_data)
	self:setViewTouched(self.bIsIconAuto)
	self.pLbRsName:setString(_data.sName)
	setLbTextColorByQuality(self.pLbRsName, _data.nQuality)
	
	if self.bIsIconAuto then 

		self:refreshEmployCivilRed()
	end
	-- self.pLbRsLv:setString(getLvString(_data.nLv, false))
	local tStr = ""
	if _data.nQuality > 1 then
		tStr = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10206)},
			{color=_cc.blue,text=getTimeFormatCn(_data.nTime)},
			{color=_cc.pwhite,text=getConvertedStr(6, 10674)}		
		}	
	else
		tStr = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10206)},
			{color=_cc.blue,text=getTimeFormatCn(_data.nTime)}	
		}	
	end
	
	self.pLayRsFunc:setString(tStr, false)
	unregUpdateControl(self)--停止计时刷新
	regUpdateControl(self, handler(self, self.onUpdateTime))
end
--刷新铁匠数据
function ItemPalaceCivil:refreshBlackSmithInfo(_data)
	self.pLyCivil:setVisible(false)
	self.pLyStatus:setVisible(true)
	self.pLyCivilNil:setVisible(false)
	self.pLyRS:setVisible(true)

	--dump(_data, "_data", 100)
	self.pIcon:setIconHeroType(TypeIconHero.NORMAL)	
	self.pIcon:setCurData(_data)
	self:setViewTouched(self.bIsIconAuto)
	self.pLbRsName:setString(_data.sName)
	setLbTextColorByQuality(self.pLbRsName, _data.nQuality)

	if self.bIsIconAuto then 

		self:refreshEmployCivilRed()
	end
	-- self.pLbRsLv:setString(getLvString(_data.nLv, false))
	-- local tStr = {
	-- 	{color=_cc.pwhite,text=getConvertedStr(6, 10523)},
	-- 	{color=_cc.blue,text=getTimeFormatCn(_data.nRate)},		
	-- }	
	local sStr = getTextColorByConfigure(string.format(getTipsByIndex(20104), getTimeFormatCn(_data.nRate)))
	self.pLayRsFunc:setString(sStr, false)
	local tStr1 = ""
	--是否是免费雇佣的
	local bIsfree = Player:getEquipData():getIsSmithFree()
	if bIsfree == true then
		tStr1 = {
			{color=_cc.blue,text=getConvertedStr(7, 10447)},   --免费铁匠
			{color=_cc.pwhite,text=getConvertedStr(7, 10448)}, --持续时间为
			{color=_cc.blue,text=getTimeFormatCn(_data.nTime)},		
		}
	else
		--花钱雇佣的
		tStr1 = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10539)},
			{color=_cc.blue,text=getTimeFormatCn(_data.nGoldTime)},		
		}
	end
	self.pLbTime:setString(tStr1)

	unregUpdateControl(self)--停止计时刷新
	regUpdateControl(self, handler(self, self.onUpdateTime))

end
--显示雇用人员信息为空
--_type 1 默认显示需要响应的Icon 2显示带锁的不需要响应的Icon
function ItemPalaceCivil:showNotEmployed( _type )
	-- body
	local ntype = _type or 1
	self.pLyCivil:setVisible(false)
	self.pLyStatus:setVisible(false)
	self.pLyCivilNil:setVisible(true)
	self.pLyRS:setVisible(false)
	if self.bIsIconAuto then--根据当前数据情况自动调整Icon
		if ntype == 2 then--未开启功能
			--头像			
			self.pIcon:setCurData(nil)
			self.pIcon:setIconHeroType(TypeIconHero.LOCK)	
			self:setViewTouched(false)
			-- self.pLbStatus2:setString(getConvertedStr(6, 10451))	--未解锁	
			self.pImgStatus2:setCurrentImage("#v2_fonts_weijiesuo.png")
			self.bCanHire = false
		else			
			self.pIcon:setCurData(nil)
			self.pIcon:setIconHeroType(TypeIconHero.ADD)
			self:setViewTouched(true)
			-- self.pLbStatus2:setString(getConvertedStr(6, 10086))	--未雇用
			self.pImgStatus2:setCurrentImage("#v2_fonts_weiguyong.png")

			self.bCanHire = true
		end
	else
		self:setViewTouched(false)		
		self.pIcon:setCurData(nil)
		self.pIcon:setIconHeroType(TypeIconHero.ADD)
		self.pIcon:stopAddImgAction()

		self.bCanHire = true
	end	
end

function ItemPalaceCivil:setGuideFinger()
	-- body
	--新手引导雇佣入口
	-- if self.bCanHire then
		Player:getNewGuideMgr():setNewGuideFinger(self.pIcon, e_guide_finer.recruit_smith_btn)
	-- end
end

function ItemPalaceCivil:setEmployType( _nEmployType )
	-- body
	self.nEmployType = _nEmployType or e_hire_type.official
end

function ItemPalaceCivil:refreshEmployCivilRed( )
	-- body
	local isShowRed=isShowHireSmithRed(self.nEmployType)
	if isShowRed then
		self.pIcon:setRedTipState(1)
	else
		self.pIcon:setRedTipState(0)
	end

end

return ItemPalaceCivil