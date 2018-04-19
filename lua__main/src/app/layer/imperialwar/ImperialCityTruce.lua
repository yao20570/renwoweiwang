----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-14 20:42:00
-- Description: 皇城详情
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ImperialCityTruce = class("ImperialCityTruce", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ImperialCityTruce:ctor(  )
	parseView("layout_imperial_city_truce", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ImperialCityTruce:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ImperialCityTruce", handler(self, self.onImperialCityTruceDestroy))
end

-- 析构方法
function ImperialCityTruce:onImperialCityTruceDestroy(  )
    self:onPause()
end

function ImperialCityTruce:regMsgs(  )
end

function ImperialCityTruce:unregMsgs(  )
end

function ImperialCityTruce:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ImperialCityTruce:onPause(  )
	self:unregMsgs()
end

function ImperialCityTruce:setupViews(  )
	local pLayBg = self:findViewByName("lay_bg")
	setGradientBackground(pLayBg)
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayCityIcon = self:findViewByName("lay_city_icon")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtOwn = self:findViewByName("txt_own")
	self.pLayMiddle = self:findViewByName("lay_middle")
	local pTxtState = self:findViewByName("txt_state")
	pTxtState:setString(getConvertedStr(3, 10908))
	setTextCCColor(pTxtState, _cc.green)
	self.pTxtCd = self:findViewByName("txt_cd")


	--撤退
	local pLayBtnTreasury = self:findViewByName("lay_btn_treasury")
	local pBtnTreasury = getCommonButtonOfContainer(pLayBtnTreasury, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10910))
	pBtnTreasury:onCommonBtnClicked(handler(self, self.onTreasuryClicked))
	--屏蔽
	if b_close_imperialwar then
		pLayBtnTreasury:setVisible(false)
	end
end

function ImperialCityTruce:updateViews(  )
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	if not nSysCityId then
		return
	end
	--基本信息
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	if tViewDotMsg then
		local nCountry = tViewDotMsg:getDotCountry()
		self.pImgFlag:setCurrentImage(WorldFunc.getCountryFlagImg(nCountry))
		WorldFunc.getSysCityIconOfContainer(self.pLayCityIcon, nSysCityId, nCountry, true)
		
		self.pTxtName:setString(tViewDotMsg:getDotName() .. " Lv." .. tViewDotMsg.nDotLv)
		setTextCCColor(self.pTxtName, _cc.blue)
		local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10109)},
		    {color=_cc.green,text=getWorldPosString(tViewDotMsg.nX, tViewDotMsg.nY)},
		}
		self.pTxtPos:setString(tStr)
		local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10907)},
		    {color=getColorByCountry(nCountry),text=getCountryName(nCountry)},
		}
		self.pTxtOwn:setString(tStr)
	end

	self:updateCd()
end

function ImperialCityTruce:updateCd(  )
	--屏蔽
	if b_close_imperialwar then
		self.pTxtCd:setString(getConvertedStr(3, 10958))
	else
		local nCd = Player:getImperWarData():getOpenCd()
		local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10909)},
		    {color=_cc.yellow,text=formatTimeToHms(nCd)},
		}
		self.pTxtCd:setString(tStr)
	end
end

function ImperialCityTruce:onTreasuryClicked( )
	local tObject = {
    nType = e_dlg_index.royalbank, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end


return ImperialCityTruce
