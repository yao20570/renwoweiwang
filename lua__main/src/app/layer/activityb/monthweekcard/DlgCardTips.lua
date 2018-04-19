-----------------------------------------------------
-- author: xiesite
-- Date: 2017-03-05 15:08:23
-- Description: 月卡提示
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")

local DlgCardTips = class("DlgCardTips", function()
	-- body
	return DlgCommon.new(e_dlg_index.cardTips)
end)

function DlgCardTips:ctor(_tData)
	-- body
	self:myInit()
	self.tData = _tData
	parseView("dlg_card_tips", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgCardTips:myInit(  )
 
end



--解析布局回调事件
function DlgCardTips:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView,true) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCardTips",handler(self, self.onDestroy))
end

-- 修改控件内容或者是刷新控件数据
function DlgCardTips:updateViews()
	if not self.tData then
       return
	end

	-- 10372
	local tChargeInfo = getRechargeDataByKey(self.tData.pid)
 	self.pLbTips1:setString(string.format(getConvertedStr(1,10372), tChargeInfo.gold))

	self.pLbTips2:setString(string.format(getConvertedStr(1,10373), self.tData.day))

	local tAwards = self.tData.awards
	local nLv = Player:getPlayerInfo().nLv
	local tAward = nil
	for k,v in ipairs(tAwards) do
		if v["start"] <= nLv and v["end"] >= nLv then
		 	tAward = v.award
		 	break
		end
	end

	local tCurDatas = getRewardItemsFromSever(tAward) 
 	gRefreshHorizontalIcons(self.pLyIcon, tCurDatas, 10, true)
end

function DlgCardTips:setupViews()
	self.pLbTips1 = self:findViewByName("lb_tips1")
	self.pLbTips2 = self:findViewByName("lb_tips2")
	self.pLyIcon  = self:findViewByName("ly_icon")
end
 
--设置数据
function DlgCardTips:setCurData(_tData)
	-- body
	local tData = _tData
	if tData then
		self:updateViews()
	end
end

-- 析构方法
function DlgCardTips:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgCardTips:regMsgs( )

end

-- 注销消息
function DlgCardTips:unregMsgs(  )

end


--暂停方法
function DlgCardTips:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgCardTips:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgCardTips