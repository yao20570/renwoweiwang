----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 侦查子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local nSliverId = 3 --银币id

local CityDetailDetect = class("CityDetailDetect", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CityDetailDetect:ctor(  )
	--解析文件
	parseView("layout_city_detail_detect", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CityDetailDetect:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CityDetailDetect",handler(self, self.onCityDetailDetectDestroy))
end

-- 析构方法
function CityDetailDetect:onCityDetailDetectDestroy(  )
    self:onPause()
end

function CityDetailDetect:regMsgs(  )
end

function CityDetailDetect:unregMsgs(  )
end

function CityDetailDetect:onResume(  )
	self:regMsgs()
end

function CityDetailDetect:onPause(  )
	self:unregMsgs()
end

function CityDetailDetect:setupViews(  )
	--侦查方式1
	local pTxtSuccess = self:findViewByName("txt_success1")
	pTxtSuccess:setString(getConvertedStr(3, 10024))
	setTextCCColor(pTxtSuccess, _cc.green)
	local pTxtDetectName = self:findViewByName("txt_detect_name1")
	pTxtDetectName:setString(getConvertedStr(3, 10038))
	setTextCCColor(pTxtDetectName, _cc.green)

	local pLayBtn1 = self:findViewByName("lay_btn1")
	local pBtn1 = getCommonButtonOfContainer(pLayBtn1,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10022))
	pBtn1:onCommonBtnClicked(handler(self, self.onBtn1Clicked))
	self.pBtn1 = pBtn1
	self.pBtn1:setBtnExText({tLabel = {{0}}, img = getCostResImg(nSliverId)})

	--侦查方式2
	local pTxtSuccess2 = self:findViewByName("txt_success2")
	pTxtSuccess2:setString(getConvertedStr(3, 10025))
	setTextCCColor(pTxtSuccess2, _cc.blue)
	local pTxtDetectName2 = self:findViewByName("txt_detect_name2")
	pTxtDetectName2:setString(getConvertedStr(3, 10027))
	setTextCCColor(pTxtDetectName2, _cc.blue)

	local pLayBtn2 = self:findViewByName("lay_btn2")
	local pBtn2 = getCommonButtonOfContainer(pLayBtn2,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10022) )
	pBtn2:onCommonBtnClicked(handler(self, self.onBtn2Clicked))
	self.pBtn2 = pBtn2
	self.pBtn2:setBtnExText({tLabel = {{0}}, img = getCostResImg(nSliverId)})

	--侦查方式3
	local pTxtSuccess3 = self:findViewByName("txt_success3")
	pTxtSuccess3:setString(getConvertedStr(3, 10026))
	setTextCCColor(pTxtSuccess3, _cc.yellow)
	local pTxtDetectName3 = self:findViewByName("txt_detect_name3")
	pTxtDetectName3:setString(getConvertedStr(3, 10028))
	setTextCCColor(pTxtDetectName3, _cc.yellow)

	local pLayBtn3 = self:findViewByName("lay_btn3")
	local pBtn3 = getCommonButtonOfContainer(pLayBtn3,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10022))
	pBtn3:onCommonBtnClicked(handler(self, self.onBtn3Clicked))
	self.pBtn3 = pBtn3
	self.pBtn3:setBtnExText({tLabel = {{0},{0},{0}}, img = getCostResImg(nSliverId)})

	--描述
	local pTxtTip1 = self:findViewByName("txt_tip1")
	pTxtTip1:setString(getTipsByIndex(10019))
	setTextCCColor(pTxtTip1, _cc.gray)

	-- local pTxtTip = MUI.MLabel.new({
	-- 	text = getConvertedStr(3, 10238),
	-- 	size = 20,
	-- 	align = cc.ui.TEXT_ALIGN_LEFT,
	-- 	valign = cc.ui.TEXT_VALIGN_TOP,
	-- 	dimensions = cc.size(320, 0),
	-- 	})
	-- setTextCCColor(pTxtTip, _cc.gray)
	-- pTxtTip:setPosition(cc.p(264, 100))
	-- self:addView(pTxtTip, 10)
	-- pTxtTip:setString(getTipsByIndex(10019))
end

function CityDetailDetect:updateViews(  )
	if not self.tData then
		return
	end

	local tDetectData = getWorldDetectData(self.tData.nDotLv)
	if not tDetectData then
		return
	end

	--低级侦查
	self.pBtn1:setExTextLbCnCr(1,tDetectData.juniordetect)

	--中级侦查
	self.pBtn2:setExTextLbCnCr(1,tDetectData.middetect)

	--高级侦查
	local nId, nValue = getMulitCostResOnly(tDetectData.seniordetect)
	if nId == 100121 then
		self.pBtn3:setExTextLbCnCr(1, getConvertedStr(3, 10442), getC3B(_cc.pwhite))
		self.pBtn3:setExTextLbCnCr(2, getMyGoodsCnt(nId), getC3B(_cc.green))
		self.pBtn3:setExTextLbCnCr(3, "/"..tostring(nValue))
		self.pBtn3:setExTextImg(nil)
	else
		self.pBtn3:setExTextLbCnCr(1, nValue, getC3B(_cc.pwhite))
		self.pBtn3:setExTextLbCnCr(2, "")
		self.pBtn3:setExTextLbCnCr(3, "")
		self.pBtn3:setExTextImg(getCostResImg(nId))
	end
end

--tData:tViewDotMsg
function CityDetailDetect:setData( tData )
	if not tData then
		return
	end
	self.tData = tData
	self:updateViews()
end

function CityDetailDetect:onBtn1Clicked( pView )
	self:sendDetectReq(0)
end

function CityDetailDetect:onBtn2Clicked( pView )
	self:sendDetectReq(1)
end

function CityDetailDetect:onBtn3Clicked( pView )
	self:sendDetectReq(2)
end

function CityDetailDetect:sendDetectReq( nIndex )
	--科技等级不够1
	local tScience = getWorldInitData("detectId")
	if not tScience then
		return
	end
	local tTnoly = Player:getTnolyData():getTnolyByIdFromAll(tScience.nScienceId)
	if not tTnoly then
		TOAST(getConvertedStr(3, 10354))
		return
	end
	local nLv = tScience.nLv
	if tTnoly.nLv < nLv then
		TOAST(string.format(getConvertedStr(3, 10355), getLvString(nLv)))
		return
	end

	local tDetectData = getWorldDetectData(self.tData.nDotLv)
	if not tDetectData then
		return
	end

	local nCostType = nil
	if nIndex == 0 then
		if not getIsResourceEnough(nSliverId, tDetectData.juniordetect) then
			TOAST(string.format(getConvertedStr(3, 10129), getCostResName(nSliverId), tDetectData.juniordetect))
			return
		end
	elseif nIndex == 1 then
		if not getIsResourceEnough(nSliverId, tDetectData.middetect) then
			TOAST(string.format(getConvertedStr(3, 10129), getCostResName(nSliverId), tDetectData.middetect))
			return
		end
	elseif nIndex == 2 then
		local nId, nValue = getMulitCostResOnly(tDetectData.seniordetect)
		if not getIsResourceEnough(nId, nValue) then
			TOAST(string.format(getConvertedStr(3, 10129), getCostResName(nId), nValue))
			return
		end
		-- dump(tDetectData.tCostType)
		nCostType = tDetectData.tCostType[nId]
	end
	-- dump({self.tData.nX, self.tData.nY, nIndex, nCostType})
	SocketManager:sendMsg("reqWorldDetect", {self.tData.nX, self.tData.nY, nIndex, nCostType}, nil)

	--关闭自己
	closeDlgByType(e_dlg_index.citydetail, false)
end

return CityDetailDetect


