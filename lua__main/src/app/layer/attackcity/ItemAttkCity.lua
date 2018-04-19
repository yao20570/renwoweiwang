----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-22 11:21:20
-- Description: 攻城掠地任务子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemAttkCity = class("ItemAttkCity", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemAttkCity:ctor(  )
	--解析文件
	parseView("item_attk_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemAttkCity:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemAttkCity", handler(self, self.onItemAttkCityDestroy))
end

function ItemAttkCity:myInit()
	
end

-- 析构方法
function ItemAttkCity:onItemAttkCityDestroy(  )
end

function ItemAttkCity:setupViews(  )
	self.pTxtTitle = self:findViewByName('txt_title')
	setTextCCColor(self.pTxtTitle,_cc.pwhite)
	self.pTxtTip = self:findViewByName('txt_tip')
	self.pTxtPoint = self:findViewByName('txt_point')
	self.pImgState = self:findViewByName('img_state')
	self.pTxtTip:setVisible(false)
	self.pImgState:setVisible(false)

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)

	self:onMViewClicked(handler(self, self.onItemClicked))

	self.pLayBtn=self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7, 10170))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pLayBar = self:findViewByName("lay_bar")--进度条层

	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_yellow_9.png",barWidth = self.pLayBar:getWidth(), barHeight = 18})
	self.pProgressBar:setAnchorPoint(0,0)
	self.pLayBar:addView(self.pProgressBar)	
	
	self.pProgressBar:setPositionY(self.pProgressBar:getPositionY() + 2)
	-- self.pProgressBar:setPositionX(250)
	self.pTxtBar = self:findViewByName("txt_bar")

	self.pImgIcon = self:findViewByName("img_icon")


end

function ItemAttkCity:updateViews(  )
	-- body
	-- self.pTxtTitle:setString()
	if not self.tData then
		return
	end
	self.pImgIcon:setCurrentImage("#" .. self.tData.icon .. ".png")

	local tStr =getTextColorByConfigure(string.format(getConvertedStr(9,10120),self.tData.score))
	self.pTxtPoint:setString(tStr)

	self.pProgressBar:setPercent(self.nProcess/self.tData.time*100)
	
	self.pTxtBar:setString(self.nProcess.."/"..self.tData.time)
	-- print(self.tData.day)
	-- print(self.tData.day)
	if self.nProcess == self.tData.time then
		
		self.pLayBtn:setVisible(false)
		self.pImgState:setVisible(true)
		self.pTxtTip:setVisible(false)
		self.pImgState:setCurrentImage("#v2_fonts_yidadao.png")
	end
	if self.tData.day > self.nCurDay then
		
		self.pLayBtn:setVisible(false)
		self.pImgState:setVisible(true)
		self.pTxtTip:setVisible(false)
		self.pImgState:setCurrentImage("#v2_fonts_weikaiqi.png")
	elseif self.tData.day <= self.nCurDay then

		local tParam = luaSplit(self.tData.limit, ":")

    	if tParam and #tParam >= 2 then
	        local nKey = tonumber(tParam[1])
	        local nValue = tonumber(tParam[2])
	        local bIsOpen = true
	        if nKey == 1 then
	            bIsOpen = Player:getPlayerTaskInfo():getTaskIsUnLock(nValue)
	        elseif nKey == 2 then
	            bIsOpen = Player:getPlayerInfo().nLv >= nValue
	        elseif nKey == 3 then
	            local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
	            if pPalacedata and not pPalacedata:getIsLocked() then
	                bIsOpen = pPalacedata.nLv >= nValue
	            else
	                bIsOpen = false --王宫未开启
	            end
	        end
	        if bIsOpen then
	            self.pLayBtn:setVisible(true)
				self.pImgState:setVisible(false)
				self.pTxtTip:setVisible(false)

	        else 
	            self.pLayBtn:setVisible(false)
				self.pImgState:setVisible(false)
				self.pTxtTip:setVisible(true)
				self.pTxtTip:setString(self.tData.desc)
	        end
	    end
	end

	 self.pTxtTitle:setString(self.tData.title)
end

function ItemAttkCity:setData( _tData ,_nProcess,_nCurDay)
	-- body
	self.tData=_tData or self.tData
	self.nProcess = _nProcess or 0
	self.nCurDay = _nCurDay or 0
	self:updateViews()

end

function ItemAttkCity:onBtnClicked( )
	-- body
	-- if  self.tData.b == 0 then
	-- 	TOAST(getConvertedStr(9,10086))
	-- 	return
	-- else
	-- 	local tRechargeData=getRechargeDataByKey(self.tData.r)
	-- 	if tRechargeData then
	-- 		-- dump(tRechargeData)
	-- 		reqRecharge(tRechargeData)
	-- 	end
	-- end
	local tObject = {} 
	local tParam = luaSplit(self.tData.linked, ":")
	local nDlgID = tonumber(tParam[1])
	local tParam2 = luaSplit(tParam[2], "|")
	tObject.nType = nDlgID--dlg类型
	closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
	sendMsg(ghd_home_show_base_or_world, nDlgID - 100)--主城或世界跳转
	-- sendMsg(ghd_show_dlg_by_type,tObject)
end
function ItemAttkCity:onItemClicked(  )
	-- body
	local tObject = {} 
	tObject.nType = e_dlg_index.actaskdetail --dlg类型
	tObject.tData = self.tData
	tObject.nCurDay = self.nCurDay
	tObject.nProcess = self.nProcess
	sendMsg(ghd_show_dlg_by_type,tObject)
end

return ItemAttkCity


