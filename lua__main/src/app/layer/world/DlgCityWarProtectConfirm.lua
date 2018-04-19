----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 11:39:07
-- Description: 发起城战有保护状态确认界面
-----------------------------------------------------

-- 副本主界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgCityWarProtectConfirm = class("DlgCityWarProtectConfirm", function()
	return DlgCommon.new(e_dlg_index.citywarprotectconfirm)
end)

function DlgCityWarProtectConfirm:ctor(  )
	parseView("dlg_city_war_in_my_protect", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityWarProtectConfirm:onParseViewCallback( pView )
	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(3, 10039))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityWarProtectConfirm",handler(self, self.onDlgCityWarProtectConfirmDestroy))
end

-- 析构方法
function DlgCityWarProtectConfirm:onDlgCityWarProtectConfirmDestroy(  )
    self:onPause()
end

function DlgCityWarProtectConfirm:regMsgs(  )
end

function DlgCityWarProtectConfirm:unregMsgs(  )
end

function DlgCityWarProtectConfirm:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function DlgCityWarProtectConfirm:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgCityWarProtectConfirm:setupViews(  )
	local pTxtTip = self:findViewByName("txt_content_str")
	pTxtTip:setString(getConvertedStr(3, 10040))
	local pTxtCdTitle = self:findViewByName("txt_cd_title")
	pTxtCdTitle:setString(getConvertedStr(3, 10041))
	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.red)
	local pLayBtnCancel = self:findViewByName("lay_btn_cancel")
	local pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel,TypeCommonBtn.L_RED,getConvertedStr(1,10058))
	pBtnCancel:onCommonBtnClicked(handler(self, self.onLeftClicked))

	local pLayBtnSubmit = self:findViewByName("lay_btn_sumbilt")
	local pBtnSubmit = getCommonButtonOfContainer(pLayBtnSubmit,TypeCommonBtn.L_BLUE,getConvertedStr(1,10059))
	pBtnSubmit:onCommonBtnClicked(handler(self, self.onSubmitClicked))
end

function DlgCityWarProtectConfirm:updateViews(  )
	self:updateCd()
end

function DlgCityWarProtectConfirm:updateCd(  )
	local nTime = Player:getWorldData():getProtectCD()
	if nTime then
		self.pTxtCd:setString(formatTimeToHms(nTime))
	end
end

-- nHandler：回调方法
function DlgCityWarProtectConfirm:setData( nHandler)
	self.nCallBackFunc = nHandler
end

function DlgCityWarProtectConfirm:onSubmitClicked(  )
	if self.nCallBackFunc then
		self.nCallBackFunc()
	end
	self:closeCommonDlg()
end

return DlgCityWarProtectConfirm