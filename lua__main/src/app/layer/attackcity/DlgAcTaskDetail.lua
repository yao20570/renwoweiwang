-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-22 15:29:17 星期一
-- Description: 攻城掠地任务详情对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgAcTaskDetail = class("DlgAcTaskDetail", function ()
	return DlgCommon.new(e_dlg_index.actaskdetail, 300, 130)
end)

--构造
function DlgAcTaskDetail:ctor(_tData,_nProcess,_nCurDay)
	-- body
	self:myInit(_tData,_nProcess,_nCurDay)
	parseView("dlg_ac_task_detail", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgAcTaskDetail:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, false)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgAcTaskDetail",handler(self, self.onDestroy))
end

function DlgAcTaskDetail:myInit( _tData,_nProcess,_nCurDay )
	-- body
	self.tData = _tData
	self.nProcess = _nProcess or 0
	self.nCurDay = _nCurDay or 0
end

--初始化控件
function DlgAcTaskDetail:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10231))

	-- self.pTxtRewardTitle2=self:findViewByName("txt_reward_title2")
	self.pLayBtn=self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7, 10170), false)
	self.pBtn:onCommonBtnClicked(handler(self, self.onGoClicked))

	local pTxtBottomTitle = self:findViewByName("txt_bottom_title")
	pTxtBottomTitle:setString(getConvertedStr(9,10115))

	self.pLayBar = self:findViewByName("lay_bar")--进度条层
	self.pTxtBar = self:findViewByName("txt_bar")

	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_yellow_9.png",barWidth = self.pLayBar:getWidth(), barHeight = 18})
	self.pProgressBar:setAnchorPoint(0,0)
	self.pLayBar:addView(self.pProgressBar)
		
	self.pProgressBar:setPositionY(self.pProgressBar:getPositionY() + 2)

	self.pTxtTitle = self:findViewByName("txt_title")
	self.pTxtDesc = self:findViewByName("txt_desc")
	self.pImgState = self:findViewByName("img_state")
	self.pTxtTip = self:findViewByName("txt_tip")
	
end

-- 修改控件内容或者是刷新控件数据
function DlgAcTaskDetail:updateViews()
	-- body

	if not self.tData then
		self:closeDlg(false)
		return
	end
	self.pProgressBar:setPercent(self.nProcess/self.tData.time*100)
	self.pTxtBar:setString(self.nProcess.."/"..self.tData.time)

	self.pTxtTitle:setString(self.tData.title)
	self.pTxtDesc:setString(self.tData.describe)


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
	        else 
	            self.pLayBtn:setVisible(false)
				self.pImgState:setVisible(false)
				self.pTxtTip:setVisible(true)
				self.pTxtTip:setString(self.tData.desc)
	        end
	    end
	end

end
function DlgAcTaskDetail:onGoClicked(  )
	-- body

	local tObject = {} 
	local tParam = luaSplit(self.tData.linked, ":")
	local nDlgID = tonumber(tParam[1])
	local tParam2 = luaSplit(tParam[2], "|")
	tObject.nType = nDlgID--dlg类型
	closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
	sendMsg(ghd_home_show_base_or_world, nDlgID - 100)--主城或世界跳转

end


--析构方法
function DlgAcTaskDetail:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgAcTaskDetail:regMsgs( )
	-- body


end

-- 注销消息
function DlgAcTaskDetail:unregMsgs(  )
	-- body
	
end


--暂停方法
function DlgAcTaskDetail:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function DlgAcTaskDetail:onResume( )
	-- body
	self:regMsgs()

end



return DlgAcTaskDetail
