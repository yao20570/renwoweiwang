----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-15 17:48:21
-- Description: 城市驻守撤回
-----------------------------------------------------

-- 副本主界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgCityGarrisonCall = class("DlgCityGarrisonCall", function()
	return DlgCommon.new(e_dlg_index.citygarrisoncall)
end)

function DlgCityGarrisonCall:ctor(  )
	parseView("dlg_city_garrison_call", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityGarrisonCall:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(9, 10012))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityGarrisonCall",handler(self, self.onDlgCityGarrisonCallDestroy))
end

-- 析构方法
function DlgCityGarrisonCall:onDlgCityGarrisonCallDestroy(  )
    self:onPause()
end

function DlgCityGarrisonCall:regMsgs(  )
end

function DlgCityGarrisonCall:unregMsgs(  )
end

function DlgCityGarrisonCall:onResume(  )
	self:regMsgs()
end

function DlgCityGarrisonCall:onPause(  )
	self:unregMsgs()
end

function DlgCityGarrisonCall:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")

	local pLayBarTroops = self:findViewByName("lay_bar_troops")
	local pSize = pLayBarTroops:getContentSize()
	self.pBarTroops = MCommonProgressBar.new({bar = "v1_bar_blue_1.png", barWidth = pSize.width, barHeight = pSize.height})
	self.pBarTroops:setPosition(pSize.width/2, pSize.height/2)
	pLayBarTroops:addView(self.pBarTroops)

	self.pTxtLv = self:findViewByName("txt_lv")
	setTextCCColor(self.pTxtLv, _cc.blue)
	self.pLayRichtextTip = self:findViewByName("lay_richtext_tip")
	--多文本
	local tStr = {
		{color=_cc.white,text=getConvertedStr(3, 10071)},
	    {color=_cc.blue,text="?"},
	    {color=_cc.white,text="?"},
	}
	self.pRichtextTip = getRichLabelOfContainer(self.pLayRichtextTip,tStr)

	--确定按钮
	local pLayBtnSubmit = self:findViewByName("lay_btn_submit")
	local pBtnSubmit = getCommonButtonOfContainer(pLayBtnSubmit, TypeCommonBtn.L_BLUE, getConvertedStr(1, 10059))
	pBtnSubmit:onCommonBtnClicked(handler(self, self.onRightClicked))

    local pLayBtnCancel = self:findViewByName("lay_btn_cancel")
	local pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel, TypeCommonBtn.L_RED, getConvertedStr(1, 10058))
	pBtnCancel:onCommonBtnClicked(handler(self, self.onLeftClicked))
end

function DlgCityGarrisonCall:updateViews(  )
	if not self.tData then
		return
	end

	local tHero = self.tData:getHeroData()
	if tHero then
		--图标
		getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,tHero,TypeIconHeroSize.M)
		--兵力进度条
		local nCurrTroops = self.tData.nTroops
		local nMaxTroops = self.tData.nTroopsMax
		local fTroopsRate = 0
		if nMaxTroops > 0 then
			fTroopsRate = nCurrTroops/nMaxTroops
		end
		self.pBarTroops:setPercent(fTroopsRate*100)	
		--等级
		self.pTxtLv:setString(getLvString(self.tData.nHeroLv))
		--富文本
		self.pRichtextTip:updateLbByNum(2, tHero.sName)
	end
end

--tData:  HelpMsg类型
function DlgCityGarrisonCall:setData( tData )
	self.tData = tData
	self:updateViews()
end



return DlgCityGarrisonCall