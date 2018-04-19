-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-19 9:45:40 星期四
-- Description: 每日任务积分面板
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local TaskBox = require("app.layer.task.TaskBox")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ScoreBox = require("app.layer.country.data.ScoreBox")
local DailyTaskScoreLayer = class("DailyTaskScoreLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function DailyTaskScoreLayer:ctor(  )
	-- body
	self:myInit()
	parseView("lay_deily_task", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function DailyTaskScoreLayer:myInit(  )
	-- body
	self.tDailyTaskScore = nil
	self.tScoreBoxs = nil
end

--解析布局回调事件
function DailyTaskScoreLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemResPrize",handler(self, self.onDailyTaskScoreLayerDestroy))
end

--初始化控件
function DailyTaskScoreLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_deily_task")
	self.pLayContent = self.pLayRoot:findViewByName("lay_content")
	self.pLbMyScore = self:findViewByName("lb_myS")--我的积分
	
	self.pLbReSetTime = self:findViewByName("lb_refreshT")--积分系统刷新时间
	
	self.pLayBar = self:findViewByName("lay_bar_bg")--进度条层

	self.pProgressBar = MCommonProgressBar.new({bar = "v2_bar_yellow_11.png",barWidth = 515, barHeight = 20})
	self.pLayBar:addView(self.pProgressBar)
	centerInView(self.pLayBar, self.pProgressBar)	
	self.pProgressBar:setPositionY(self.pProgressBar:getPositionY() + 1)
	self:initTickAndBox()


end

--修改控件内容或者是刷新控件数据
function DailyTaskScoreLayer:updateViews( )
	-- body
	--积分刷新
	local nCurDp = Player:getPlayerTaskInfo().nDp
	local nMaxScore = self.tDailyTaskScore[#self.tDailyTaskScore].nScore
	self.pProgressBar:setPercent(nCurDp/nMaxScore*100)
	local tScoreStr = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10555)},
		{color=_cc.yellow,text=nCurDp},
	}
	self.pLbMyScore:setString(tScoreStr, false)

	--倒计时刷新
	unregUpdateControl(self)
	local nleftTime = Player:getPlayerTaskInfo():getDailyResetCD()
	if nleftTime > 0 then
		regUpdateControl(self, function ( ... )
			--刷新倒计时
			local nLeft  = Player:getPlayerTaskInfo():getDailyResetCD()
			if nLeft > 0 then
				local tCDStr = {
					{color=_cc.pwhite,text=getConvertedStr(6, 10556)},
					{color=_cc.yellow,text=formatTimeToHms(nLeft)},
					{color=_cc.pwhite,text=getConvertedStr(6, 10557)},
				}
				self.pLbReSetTime:setString(tCDStr, false)
			else
				unregUpdateControl(self)
			end
		end)
	else
		self.pLbReSetTime{""}	
	end
	self:updateScoreBoxs()
end

function DailyTaskScoreLayer:updateScoreBoxs(  )
	-- body
	if self.tScoreBoxs then
		for k, v in pairs(self.tScoreBoxs) do
			local nScore = self.tDailyTaskScore[k].nScore
			v:setStatus(Player:getPlayerTaskInfo():getBoxStatus(nScore))
		end
	end
end

function DailyTaskScoreLayer:getScoreBoxPrize( pBox )
	-- body	
	if pBox then
		local pScoreBox = ScoreBox.new()
		pScoreBox:refreshDataByDB({pBox.nScoreID, self.tDailyTaskScore[pBox.nScoreID].nScore, self.tDailyTaskScore[pBox.nScoreID].nDropId})
		pScoreBox.bIsGetAward = (pBox.nStatus == e_box_status.opened)
		if pBox.nStatus == e_box_status.prize then
			showDlgPrizeProgress(pScoreBox, function (  )
				-- body
				SocketManager:sendMsg("getDailyScorePrize", {self.tDailyTaskScore[pBox.nScoreID].nScore},handler(self, self.onGetCallBack))	
			end)			
		else
			showDlgPrizeProgress(pScoreBox)
		end
	end	
end
--
function DailyTaskScoreLayer:onGetCallBack( __msg, __old )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.getDailyScorePrize.id then
     --    	local pScoreBox = ScoreBox.new()
     --    	for k, v in pairs(self.tDailyTaskScore) do
     --    		if v.nScore == __old[1] then
  			-- 		pScoreBox:refreshDataByDB({k, v.nScore, v.nDropId})
					-- pScoreBox.bIsGetAward = true
		   --      	showDlgPrizeProgress(pScoreBox)   
		   --      	return   			
     --    		end
     --    	end
        	closeDlgByType(e_dlg_index.taskprizeprogress)
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end	
end
--创建进度条刻度和宝箱
function DailyTaskScoreLayer:initTickAndBox(  )
	-- body
	if not self.tDailyTaskScore then
		self.tDailyTaskScore = getDailyTaskParam()
		self.tScoreBoxs = {}
	end
	--dump(self.tDailyTaskScore, "self.tDailyTaskScore", 100)	
	local nTWidth = 515 -- self.pLayBar:getWidth() 
	local nSY = self.pLayBar:getHeight()/2 + 2
	local nMaxScore = self.tDailyTaskScore[#self.tDailyTaskScore].nScore
	for k, v in pairs(self.tDailyTaskScore) do
		local nX = v.nScore/nMaxScore*nTWidth + (self.pLayBar:getWidth() - nTWidth)/2
		local nTickY = nSY
		local nLableY = nSY
		local nBoxY = nSY
		if k%2 == 0 then
			nTickY = nSY - 10
			nLableY = nSY - 26
			nBoxY = nSY - 75
		else
			nTickY = nSY + 10
			nLableY = nSY + 26
			nBoxY = nSY + 75
		end

		--刻度线
		if k <  #self.tDailyTaskScore then--
			local pImg = MUI.MImage.new("#v1_line_blue3.png", {scale9 = true,capInsets=cc.rect(1,5, 1, 1)})
			pImg:setLayoutSize(2, 28)

			pImg:setPosition(nX + 1, nTickY)
			self.pLayBar:addView(pImg, 9)	
		end

		--刻度标签
	    local pLabel = MUI.MLabel.new({
	        text="("..v.nScore..")",
	        size=16,
	        anchorpoint=cc.p(0.5, 0.5)
	    })
	    pLabel:setPosition(nX, nLableY)
	    self.pLayBar:addView(pLabel, 9)


	    --宝箱    
	    local box = TaskBox.new(k)		
	    box:onMViewClicked(handler(self, function (  )
			-- body
			self:getScoreBoxPrize(box)
		end))
	    box:setViewTouched(true)
	    box:setVisible(true)
	    if k%2 == 0 then
	    	box:setAnchorPoint(0.5, 1)
	    else
			box:setAnchorPoint(0.5, 0)
	    end
	    
	    if k < #self.tDailyTaskScore then
	    	box:setPosition(nX - box:getWidth()/2, nBoxY - box:getHeight()/2)	   
	    else
	    	box:setPosition(nX - box:getWidth(), nBoxY - box:getHeight()/2)	   
	    end
	    
	    self.pLayBar:addView(box, 20)
	    self.tScoreBoxs[k] = box

	end
end
--析构方法
function DailyTaskScoreLayer:onDailyTaskScoreLayerDestroy(  )
	-- body
	unregUpdateControl(self)
end

return DailyTaskScoreLayer