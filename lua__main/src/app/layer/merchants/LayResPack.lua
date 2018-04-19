-- LayResPack.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-9 17:28:55 星期五
-- Description: 商队资源打包层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemResPack = require("app.layer.merchants.ItemResPack")

local LayResPack = class("LayResPack", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LayResPack:ctor( _tSize )
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_res_pack", handler(self, self.onParseViewCallback))
end


--初始化成员变量
function LayResPack:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
	self:initData()
end

--解析布局回调事件
function LayResPack:onParseViewCallback( pView )
	-- body
	-- self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayResPack",handler(self, self.onLayResPackDestroy))
end

--配置数据
function LayResPack:initData()
	--打包次数:消耗资源数：消耗黄金；
	local sPackCost = getBuildParam("packCost")
	local tPackCost = luaSplitMuilt(sPackCost, ";",":")
	--银币打包兑换物品
	local sSilverExchange = getBuildParam("silverExchange")
	local tSilverExchange = luaSplitMuilt(sSilverExchange, ";",":")
	--木材打包兑换物品
	local sWoodExchange = getBuildParam("woodExchange")
	local tWoodExchange = luaSplitMuilt(sWoodExchange, ";",":")
	--粮草打包兑换物品
	local sGrainExchange = getBuildParam("grainExchange")
	local tGrainExchange = luaSplitMuilt(sGrainExchange, ";",":")

	self.tShowList = {
		--银币
		[1] = 
		{
			nResId 			= e_resdata_ids.yb,
			nMaxPackCnt 	= table.nums(tPackCost),
			tPackCost 		= tPackCost,
			tExchange 		= tSilverExchange
		},
		--木材
		[2] = 
		{
			nResId 			= e_resdata_ids.mc,
			nMaxPackCnt 	= table.nums(tPackCost),
			tPackCost 		= tPackCost,
			tExchange 		= tWoodExchange
		},
		--粮草
		[3] = 
		{
			nResId 			= e_resdata_ids.lc,
			nMaxPackCnt 	= table.nums(tPackCost),
			tPackCost 		= tPackCost,
			tExchange 		= tGrainExchange
		}
	}
end

--初始化控件
function LayResPack:setupViews( )
	-- body
	self.pLayList 		= self:findViewByName("lay_list")
end


-- 修改控件内容或者是刷新控件数据
function LayResPack:updateViews(  )
	-- body
	--今日资源打包的次数(木头、银币、粮食)
	local nPw, nPc, nPf = Player:getBuildData():getResPackTimes()
	self.tShowList[1].nHasPack = nPc
	self.tShowList[2].nHasPack = nPw
	self.tShowList[3].nHasPack = nPf

	if not self.pListView then
		self.pListView = createNewListView(self.pLayList)
		self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pListView:setItemCount(table.nums(self.tShowList))
		self.pListView:reload(true)
		self.pListView:setIsCanScroll(false)
	else
		self.pListView:notifyDataSetChange(true)
	end
end

function LayResPack:onListViewItemCallBack( _index, _pView )
	-- body
 	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemResPack.new()                        
        pTempView:setViewTouched(false)   
    end   
    pTempView:setCurData(self.tShowList[_index])    	
    return pTempView	
end


-- 析构方法
function LayResPack:onLayResPackDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function LayResPack:regMsgs(  )
	-- body
	--注册资源打包刷新刷新消息
	regMsg(self, gud_refresh_res_pack, handler(self, self.updateViews))
end
--注销消息
function LayResPack:unregMsgs(  )
	-- body
	--销毁资源打包刷新刷新消息
	unregMsg(self, gud_refresh_res_pack)
end

--暂停方法
function LayResPack:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function LayResPack:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end


return LayResPack