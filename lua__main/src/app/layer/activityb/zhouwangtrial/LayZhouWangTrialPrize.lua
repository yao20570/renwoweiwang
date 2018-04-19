-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-14 11:57:23 星期三
-- Description: 纣王试炼积分奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemZhouWangTrialPrize = require("app.layer.activityb.zhouwangtrial.ItemZhouWangTrialPrize")
local LayZhouWangTrialPrize = class("LayZhouWangTrialPrize", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayZhouWangTrialPrize:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("layout_zhouwang_trial_prize", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayZhouWangTrialPrize:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayZhouWangTrialPrize",handler(self, self.onDestroy))
end

-- --初始化参数
function LayZhouWangTrialPrize:myInit()
	-- body
	self.tDatas = {}
end

--初始化控件
function LayZhouWangTrialPrize:setupViews( )
	-- body	
	self.pLayList = self:findViewByName("lay_list")

end


-- 修改控件内容或者是刷新控件数据
function LayZhouWangTrialPrize:updateViews(  )
	-- body
	local pData = Player:getActById(e_id_activity.zhouwangtrial)
	if not pData then
		return
	end
	self.tDatas = pData.tPras
	local nItemCnt = #self.tDatas
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(20, 0, self.pLayList:getWidth() - 40, self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 5 ,
            bottom = 5 }
        }
        self.pListView:setBounceable(true) --是否回弹
        self.pListView:setItemCallback(handler(self, self.onEveryCallback))	        
        self.pLayList:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self:refreshTopItem()
		self.pListView:setItemCount(nItemCnt)		
		self.pListView:reload(false)	
	else
		self:refreshTopItem()
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end		
end

function LayZhouWangTrialPrize:onEveryCallback ( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemZhouWangTrialPrize.new(2)	
	end
	if self.tDatas[_index] then
		pView:setCurData(self.tDatas[_index])	
	end	
	return pView
end

--刷新队列数据
function LayZhouWangTrialPrize:refreshTopItem(  )
	-- body
	--国家奖励
	local pData = Player:getActById(e_id_activity.zhouwangtrial)
	if pData then
		self:addTopView()			
	else		
		self:removeTopView()
	end
end

function LayZhouWangTrialPrize:addTopView(  )
	-- body
	if not self.pTopView then	
		local ItemInfo = require("app.module.ItemInfo")	
		self.pTopView = ItemZhouWangTrialPrize.new(1)
		self.pListView:addHeaderView(self.pTopView)
	end
	local pData = Player:getActById(e_id_activity.zhouwangtrial)
	self.pTopView:setCurData(pData)	
end

function LayZhouWangTrialPrize:removeTopView(  )
	-- body
	self.pListView:removeHeaderView()
	self.pTopView = nil	
end

--析构方法
function LayZhouWangTrialPrize:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayZhouWangTrialPrize:regMsgs( )
	-- body	
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function LayZhouWangTrialPrize:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
end
--暂停方法
function LayZhouWangTrialPrize:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayZhouWangTrialPrize:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayZhouWangTrialPrize
