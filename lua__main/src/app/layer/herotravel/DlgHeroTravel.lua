-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-12-08 10:27:17 星期五
-- Description: 武将游历对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local MBtnExText = require("app.common.button.MBtnExText")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemHeroTravel = require("app.layer.herotravel.ItemHeroTravel")

local DlgHeroTravel = class("DlgHeroTravel", function ()
	return DlgCommon.new(e_dlg_index.dlgherotravel, 626, 50)
end)

--构造
function DlgHeroTravel:ctor()
	-- body
	parseView("dlg_hero_travel", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgHeroTravel:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, false)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgHeroTravel",handler(self, self.onDlgHeroTravelDestroy))
end

--初始化控件
function DlgHeroTravel:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(9, 10036))
	self.tLayQueues={}
	self.tItemQueue={}
	for i=1,2 do 
		local pLayQueue=self:findViewByName("lay_queue".. i)
		table.insert(self.tLayQueues,pLayQueue)
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgHeroTravel:updateViews()
	-- body
	self.tTravelData=Player:getHeroTravelData():getHeroTravelList()
	local nIndex=1
	for k,v in pairs(self.tTravelData) do
		if not self.tItemQueue[nIndex] then
			local pItemHeroTravel=ItemHeroTravel.new(v)
			self.tLayQueues[nIndex]:addView(pItemHeroTravel)
			table.insert(self.tItemQueue,pItemHeroTravel)
		else
			self.tItemQueue[nIndex]:setData(v)
		end
    	nIndex=nIndex+1
	end
	
end
function DlgHeroTravel:refreshData( )
	-- body
	for k,v in pairs(self.tItemQueue) do
		v:removeSelf()
		v=nil
	end
	self.tItemQueue={}
	-- dump(self.tItemQueue,"que---")
	self:updateViews()
end
--析构方法
function DlgHeroTravel:onDlgHeroTravelDestroy()
	self:onPause()
end

-- 注册消息
function DlgHeroTravel:regMsgs( )
	-- body
	regMsg(self, ghd_hero_travel_push, handler(self, self.refreshData))

end

-- 注销消息
function DlgHeroTravel:unregMsgs(  )
	-- body
	unregMsg(self, ghd_hero_travel_push)

end


--暂停方法
function DlgHeroTravel:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgHeroTravel:onResume( )
	-- body
	self:regMsgs()

end



return DlgHeroTravel
