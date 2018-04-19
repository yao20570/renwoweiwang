-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-08 19:28:23 星期一
-- Description: 主线任务领奖引导对话框
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local DlgGetReward = require("app.module.DlgGetReward")
local DlgGetTaskPrize = class("DlgGetTaskPrize", function()
	-- body
	return DlgGetReward.new(e_dlg_index.gettaskprize)
end)

function DlgGetTaskPrize:ctor(  )
	self:myInit()
end

function DlgGetTaskPrize:myInit(  )
	-- body
	self.pCurData = nil
	self.tIconGroup = nil

	--注册析构方法
	self:setDestroyHandler("DlgGetTaskPrize",handler(self, self.onDlgGetTaskPrizeDestroy))
end

--析构方法
function DlgGetTaskPrize:onDlgGetTaskPrizeDestroy(  )
	self:onPause()
end

--注册消息
function DlgGetTaskPrize:regMsgs(  )
	-- body

end
--注销消息
function DlgGetTaskPrize:unregMsgs(  )
	-- body

end

--暂停方法
function DlgGetTaskPrize:onPause( )
	-- body
	self:unregMsgs()	

	--去掉显示
	Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.task_reward_btn)
	--显示下一条顺序显示
	showNextSequenceFunc(e_show_seq.taskrward)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgGetTaskPrize:onResume( _bReshow )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgGetTaskPrize:setTaskData( _data )
 	-- body 
 	self.pCurData = _data or nil 
 	if self.pCurData then
 		local sStr = string.format(getTipsByIndex(10011), self.pCurData.sName) 
 		local tDescStr = getTextColorByConfigure(sStr)
	 	local tData = {
			sTitle = getConvertedStr(3, 10399),
			sDesc =tDescStr,
			sBanner = getConvertedStr(6, 10336),
			tGoods = getDropById(self.pCurData.nDropId),
		}
		self:__setData(tData)
	end
	self.pBtnSubmit:onCommonBtnClicked(handler(self, self.onSubmitClicked))
	--dump(self.pCurData, "self.pCurData", 100)
	if self.pCurData.sOpenCond ~= "0" then
		local function showFingerGuide()
			-- body
			--新手引导
			if self.pCurData then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnSubmit, e_guide_finer.task_reward_btn, true)
				Player:getNewGuideMgr():showNewGuideByRewordLayer(self.pCurData.sTid)
			end
		end

		doDelayForSomething(self, showFingerGuide, 0.01)
	end
end 

function DlgGetTaskPrize:__nShowHandler( )

end

function DlgGetTaskPrize:onSubmitClicked( pview )
	
	local nTaskID = nil
	if self.pCurData then
		nTaskID = self.pCurData.sTid
	end
	SocketManager:sendMsg("getTaskPrize", {nTaskID})
end

return DlgGetTaskPrize