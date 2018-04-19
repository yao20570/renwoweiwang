----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-10 16:15:32
-- Description: 世界位置小键盘
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local KeyBoard = class("KeyBoard", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function KeyBoard:ctor( pDlg)
	self.bIsFirstSelectX = true
	self.bIsFirstSelectY = true
	self.pDlg = pDlg
	parseView("dlg_world_pos_keypad", handler(self, self.onParseViewCallback))
end

--解析界面回调
function KeyBoard:onParseViewCallback( pView )
	self.pView = pView
	self:setupViews()
	self:updateViews()
	self:onResume()
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	--注册析构方法
	self:setDestroyHandler("KeyBoard",handler(self, self.onKeyBoardDestroy))
end

-- 析构方法
function KeyBoard:onKeyBoardDestroy(  )
    self:onPause()
end

function KeyBoard:regMsgs(  )
end

function KeyBoard:unregMsgs(  )
end

function KeyBoard:onResume(  )
	self:regMsgs()
end

function KeyBoard:onPause(  )
	self:unregMsgs()
end

function KeyBoard:setupViews(  )
	local pBg = self.pView:findViewByName("view")
	pBg:setViewTouched(true)
	pBg:setIsPressedNeedScale(false)
	pBg:setIsPressedNeedColor(false)

	local pTxtXTitle = self.pView:findViewByName("txt_x_title")
	pTxtXTitle:setString("X")
	local pTxtYTitle = self.pView:findViewByName("txt_y_title")
	pTxtYTitle:setString("Y")
	local pTxtTitle = self.pView:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10160))

	local pImgClose = self.pView:findViewByName("img_close")
	pImgClose:setViewTouched(true)
	pImgClose:onMViewClicked(handler(self, self.onCloseFlowDlg))

	self.pTxtX = self.pView:findViewByName("txt_x")
	self.pTxtY = self.pView:findViewByName("txt_y")
	self.pLayInputX = self.pView:findViewByName("lay_input_x")
	self.pLayInputX:setViewTouched(true)
	self.pLayInputX:setIsPressedNeedScale(false)
	self.pLayInputX:onMViewClicked(handler(self, self.onSelectedX))
	self.pLayInputY = self.pView:findViewByName("lay_input_y")
	self.pLayInputY:setViewTouched(true)
	self.pLayInputY:setIsPressedNeedScale(false)
	self.pLayInputY:onMViewClicked(handler(self, self.onSelectedY))

	self.pLaySelected = self.pView:findViewByName("lay_selected")

	for i=0,9 do
		local pLayBtn = self.pView:findViewByName("lay_btn"..i)
		pLayBtn.nNum = i
		pLayBtn:setViewTouched(true)
		pLayBtn:onMViewClicked(handler(self, self.onInputNum))

		local pTxtNum = self.pView:findViewByName("txt_num"..i)
		pTxtNum:setString(i)
	end

	local pTxtDel = self.pView:findViewByName("txt_del")
	pTxtDel:setString(getConvertedStr(3, 10161))
	local pLayBtnDel = self.pView:findViewByName("lay_btn_del")
	pLayBtnDel:setViewTouched(true)
	pLayBtnDel:onMViewClicked(handler(self, self.onDel))

	local pTxtGo = self.pView:findViewByName("txt_go")
	pTxtGo:setString(getConvertedStr(3, 10162))
	local pLayBtnGo = self.pView:findViewByName("lay_btn_go")
	pLayBtnGo:setViewTouched(true)
	pLayBtnGo:onMViewClicked(handler(self, self.onGo))

	--默认选中x
	self:onSelectedX()
end

function KeyBoard:updateViews(  )
	self.pTxtX:setString(self:getCurrInputX())
	self.pTxtY:setString(self:getCurrInputY())
end

--获取数字X
function KeyBoard:getCurrInputX()
	local sStr = ""
	local tNumX = Player:getWorldData():getKeyBoardX()
	for i=1,#tNumX do
		sStr = sStr .. tostring(tNumX[i])
	end
	return tonumber(sStr) or ""
end

--获取数字Y
function KeyBoard:getCurrInputY()
	local sStr = ""
	local tNumY = Player:getWorldData():getKeyBoardY()
	for i=1,#tNumY do
		sStr = sStr .. tostring(tNumY[i])
	end
	return tonumber(sStr) or ""
end

function KeyBoard:onInputNum( pView )
	local nNum = pView.nNum
	if self.bIsSelectedX then
		Player:getWorldData():addKeyBoardXNum(nNum, self.bIsFirstSelectX)
		self.bIsFirstSelectX = false
		local nX = self:getCurrInputX()
		if nX < 1 or nX > WORLD_GRID then
			TOAST(getConvertedStr(3, 10353))
			Player:getWorldData():delKeyBoardXNum()
		end
	else
		Player:getWorldData():addKeyBoardYNum(nNum, self.bIsFirstSelectY)
		self.bIsFirstSelectY = false
		local nY = self:getCurrInputY()
		if nY < 1 or nY > WORLD_GRID then
			TOAST(getConvertedStr(3, 10353))
			Player:getWorldData():delKeyBoardYNum()
		end
	end
	self:updateViews()
end

function KeyBoard:onDel( pView )
	if self.bIsSelectedX then
		Player:getWorldData():delKeyBoardXNum()
	else
		Player:getWorldData():delKeyBoardYNum()
	end
	self:updateViews()
end

function KeyBoard:onGo( pView )
	local nX = tonumber(self:getCurrInputX()) or 0
	local nY = tonumber(self:getCurrInputY()) or 0
	if nX > 0 and nX <= WORLD_GRID and nY > 0 and nY <= WORLD_GRID then
		sendMsg(ghd_world_location_dotpos_msg, {nX = nX, nY = nY, isClick = true})
	else
		TOAST(getConvertedStr(3, 10435))
	end
	self:onCloseFlowDlg()
end

function KeyBoard:onSelectedX( pView )
	local fX, fY = self.pLayInputX:getPosition()
	self.pLaySelected:setPosition(fX, fY)
	self.bIsSelectedX = true
	self.bIsFirstSelectX = true
end

function KeyBoard:onSelectedY( pView )
	local fX, fY = self.pLayInputY:getPosition()
	self.pLaySelected:setPosition(fX, fY)
	self.bIsSelectedX = false
	self.bIsFirstSelectY = true
end

function KeyBoard:onCloseFlowDlg()
	self.pDlg:onCloseFlowDlg()
end

return KeyBoard