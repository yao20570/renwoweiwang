-- Author: xiesite
-- Date: 2017-12-26 16:23:23
-- 武将队列item

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local ItemHeroAttrOne = class("ItemHeroAttrOne", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_tData 数据
function ItemHeroAttrOne:ctor(_tData, _nTeamType, bIsShowLuo)
	-- body
	self:myInit()


	self.tHeroData = _tData
	self.nTeamType = _nTeamType
	self.bIsShowLuo = bIsShowLuo

	parseView("dlg_hero_arr_1", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroAttrOne",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroAttrOne:myInit()
	-- body
	self.tHeroData = {} --数据
end

--解析布局回调事件
function ItemHeroAttrOne:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:updateViews()

end

--初始化控件
function ItemHeroAttrOne:updateViews( )
	if not self.pLyAttr then
		self.pLyAttr = self:findViewByName("lay_attr")
	end

    --等级进度条 
	if not self.pLyLvBg then
		self.pLyLvBg				= 		self:findViewByName("ly_bar_1")
		self.pBarLv 				= 		MCommonProgressBar.new({bar = "v2_bar_yellow_wujing.png",barWidth = 121, barHeight = 16})
		self.pLyLvBg:addView(self.pBarLv,100)
		centerInView(self.pLyLvBg,self.pBarLv)
	end
	--刷新等级进度条
	self.pBarLv:setPercent(self.tHeroData.nLv/Player:getPlayerInfo().nLv*100)
	local strTips2 = {
		{color=_cc.blue,text=tostring(self.tHeroData.nLv)},
		{color=_cc.white,text="/"..Player:getPlayerInfo().nLv},
	}			
	self.pBarLv:setProgressBarText(strTips2, false)
	--资质数据显示
	if not self.tTalentInfo then
		self.tTalentInfo = {}
		for i=1,3 do
			local pView = self:findViewByName("ly_att_"..i)
			self.tTalentInfo[i] = ItemHeroInfoLb.new(i)
			pView:addView(self.tTalentInfo[i],100)
		end
	end

	if self.tTalentInfo[1] then
		if self.bIsShowLuo then
			self.tTalentInfo[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), self.tHeroData:getAtkMax())
		else
			local nValue = self.tHeroData:getAtkLuo()
			local nValueEx = self.tHeroData:getAtkMax() - nValue	
			self.tTalentInfo[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), nValue, nValueEx)
		end
	end
			--防御
	if self.tTalentInfo[2] then
		if self.bIsShowLuo then
			self.tTalentInfo[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), self.tHeroData:getDefMax())
		else
			local nValue = self.tHeroData:getDefLuo()
			local nValueEx = self.tHeroData:getDefMax() - nValue
			self.tTalentInfo[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), nValue, nValueEx)
		end
	end
	--兵力
	if self.tTalentInfo[3] then
		if self.bIsShowLuo then
			self.tTalentInfo[3]:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), self.tHeroData:getTroopsMax())
		else
			local nValue = self.tHeroData:getTroopsLuo()
			local nValueEx = self.tHeroData:getTroopsMax() - nValue
			self.tTalentInfo[3]:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), nValue, nValueEx)
		end
	end

			--纯文字
	if not self.pLbL1 then
		self.pLbL1 = self:findViewByName("lb_l_1") --
		self.pLbL2 = self:findViewByName("lb_l_2") --
		self.pLbL3 = self:findViewByName("lb_l_3") --
		self.pLbL4 = self:findViewByName("lb_l_4") --

		self.pLbM1 = self:findViewByName("lb_m_1") -- 攻资质
		self.pLbM2 = self:findViewByName("lb_m_2") -- 防资质
		self.pLbM3 = self:findViewByName("lb_m_3") -- 兵资质
		setTextCCColor(self.pLbM1, _cc.pwhite)
		setTextCCColor(self.pLbM2, _cc.pwhite)
		setTextCCColor(self.pLbM3, _cc.pwhite)

		self.pLbR1 = self:findViewByName("lb_r_1") --

		self.pLbAt = self:findViewByName("lb_at") -- 
		self.pLbDe = self:findViewByName("lb_de") --
		self.pLbSo = self:findViewByName("lb_so") --

		self.pLbL1:setString(getConvertedStr(5, 10020))
		self.pLbL2:setString(getConvertedStr(5, 10021))
		self.pLbL3:setString(getConvertedStr(5, 10022))
		self.pLbL4:setString(getConvertedStr(5, 10023))
		self.pLbR1:setString(getConvertedStr(5, 10024))
		self.pLbAt:setString(getConvertedStr(5, 10021))
		self.pLbDe:setString(getConvertedStr(5, 10022))
		self.pLbSo:setString(getConvertedStr(5, 10023))
	end
	self.pLbM1:setString(self.tHeroData.nTa)--攻资质
	self.pLbM2:setString(self.tHeroData.nTd)--防资质
	self.pLbM3:setString(self.tHeroData.nTr)--兵资质

	if not self.pImgShuxing  then
		self.pImgShuxing = self:findViewByName("img_shuxing") --属性背景图
		self.pImgShuxing:setVisible(false)
	end

	--武将升级入口
	self.pLyAdd 	    = 		self:findViewByName("ly_add")
	showRedTips(self.pLyAdd, 0, 0)
	self.pLyAddLevel 	= 		getSepButtonOfContainer(self.pLyAdd,TypeSepBtn.PLUS,TypeSepBtnDir.center)
	self.pLyAddLevel:onMViewClicked(handler(self, self.onAddLevelClicked))


	if not self.pRichViewTips1 then
		self.pRichViewTips1 =  MUI.MLabel.new({text="", size=20})
		self.pRichViewTips1:setPosition(111,self.pLbL1:getPositionY())
		self.pRichViewTips1:setAnchorPoint(cc.p(0,0.5))
		self.pLyAttr:addView(self.pRichViewTips1,10)
	end
    --总资质
	local nTotalVal = 0
	local nBaseVal = self.tHeroData:getBaseTotalTalent()
	local nExVal = 0
	local strTips1 = nil
	nExVal = self.tHeroData:getExTotalTalent()
	strTips1 = {
		{color=_cc.blue,text=nBaseVal},
		{color=_cc.green,text="+"..nExVal},
	}
	self.pRichViewTips1:setString(strTips1)

	
	--3个资质进度条
	self:createThreeAttrBar()

	-- self:createPolygon()

	--教你玩引导升级按钮
	Player:getGirlGuideMgr():setGirlGuideFinger(self.pLyAdd, e_guide_finer.hero_lvup_btn)
end

--3个资质进度条
function ItemHeroAttrOne:createThreeAttrBar()
	-- body
	if not self.tAttrBars then
		self.tAttrBars = {}
		for i = 1, 3 do
			local pLayBar = self:findViewByName("lay_m_bar_"..i)
			local nBarWidth, nBarHeight = pLayBar:getWidth(), pLayBar:getHeight()
			local pBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/bar/v1_bar_b1.png",
		   	 	button="ui/update_bin/v1_ball.png",
		    	barfg="ui/bar/v1_bar_blue_3.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
			pBar:setSliderValue(0)	--设置滑动条值默认为0
		    pBar:setSliderSize(nBarWidth, nBarHeight)
		    pBar:align(display.LEFT_BOTTOM)
		    pBar:setViewTouched(false)
			pLayBar:addView(pBar, 10)
			self.tAttrBars[i] = pBar
		end
	end
	local nAttScale = self.tHeroData.nTa / self.tHeroData.nTalentLimitAtk --攻击比例
	local nDefScale = self.tHeroData.nTd / self.tHeroData.nTalentLimitDef --防御比例
	local nTrpScale = self.tHeroData.nTr / self.tHeroData.nTalentLimitTrp --兵力比例
	--兼容无敌武将
	if nAttScale > 1 then
		nAttScale = 1
	end
	if nDefScale > 1 then
		nDefScale = 1
	end
	if nTrpScale > 1 then
		nTrpScale = 1
	end

	self.tAttrBars[1]:setSliderValue(nAttScale*100)
	self.tAttrBars[2]:setSliderValue(nDefScale*100)
	self.tAttrBars[3]:setSliderValue(nTrpScale*100)
	if nAttScale >= 1 then
		self.tAttrBars[1]:setSliderImage("ui/bar/v1_bar_yellow_8.png")
	else
		self.tAttrBars[1]:setSliderImage("ui/bar/v1_bar_blue_3.png")
	end
	if nDefScale >= 1 then
		self.tAttrBars[2]:setSliderImage("ui/bar/v1_bar_yellow_8.png")
	else
		self.tAttrBars[2]:setSliderImage("ui/bar/v1_bar_blue_3.png")
	end
	if nTrpScale >= 1 then
		self.tAttrBars[3]:setSliderImage("ui/bar/v1_bar_yellow_8.png")
	else
		self.tAttrBars[3]:setSliderImage("ui/bar/v1_bar_blue_3.png")
	end
end

--能力图
function ItemHeroAttrOne:createPolygon()
	-- body
	if not self.tHeroData then
		return
	end

	if not self.tHeroData.nTa then
		return
	end

	if not self.tHeroData.nTd then
		return
	end

	if not self.tHeroData.nTr then
		return
	end

	local pLine = self.pImgShuxing:getChildByTag(7864644)

	if pLine then
		pLine:removeFromParent(true)
		self.pNodePolygon = nil
	end

		--创建能力分布图
	local nAttScale = self.tHeroData.nTa / getHeroInitData("initAttrNum") --攻击比例
	local nDefScale = self.tHeroData.nTd / getHeroInitData("initAttrNum") --防御比例
	local nTrpScale = self.tHeroData.nTr / getHeroInitData("initAttrNum") --兵力比例

	--中心点(65,37)
	--顶点(65,108)
	--左下点(3,2)
	--右下点(126,2)
	local tPoint = {{65- 63*nDefScale,37-35*nDefScale},{65,37+nAttScale*72},{65+nTrpScale*61,37-35*nTrpScale}}
	local tColor = {fillColor = cc.c4f(101/255,113/255,145/255,255/255),
    borderWidth  = 1,
    borderColor  = cc.c4f(101/255,113/255,145/255,255/255)}
-- dump(getC4B(657191), "getC4B(657191)", 100) 

	self.pNodePolygon =  display.newPolygon(tPoint,tColor)
	self.pNodePolygon:setTag(7864644)
	self.pNodePolygon.bc = 1
	self.pImgShuxing:addChild(self.pNodePolygon,100)
end
 
function ItemHeroAttrOne:onAddLevelClicked()
	local DlgHeroUpdate = require("app.layer.hero.DlgHeroUpdate")
	local pDlg, bNew = getDlgByType(e_dlg_index.heroupdate)
	if not pDlg then
		pDlg = DlgHeroUpdate.new(self.tHeroData, self.nTeamType)
	end
	pDlg:showDlg(bNew)

	Player:getGirlGuideMgr():setGirlGuideFingerClicked(e_guide_finer.hero_lvup_btn)
end

--析构方法
function ItemHeroAttrOne:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemHeroAttrOne:setCurData(_tData, _nTeamType)
	if not _tData then
		return
	end

	self.tHeroData = _tData or {}
	self.nTeamType = _nTeamType

	self:updateViews()


end

return ItemHeroAttrOne