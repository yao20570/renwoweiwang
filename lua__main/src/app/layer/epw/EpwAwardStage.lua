----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-27 13:48:00
-- Description: 皇城战排行
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemEpwAwardStage = require("app.layer.epw.ItemEpwAwardStage")
local EpwAwardStage = class("EpwAwardStage", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function EpwAwardStage:ctor( _tSize )
	--解析文件
	self:setContentSize(_tSize)
	parseView("layout_epw_award_stage", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EpwAwardStage:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EpwAwardStage", handler(self, self.onEpwAwardStageDestroy))
end

-- 析构方法
function EpwAwardStage:onEpwAwardStageDestroy(  )
    self:onPause()
end

function EpwAwardStage:regMsgs(  )
	regMsg(self, gud_imperialwar_score_refresh, handler(self, self.updateViews))
end

function EpwAwardStage:unregMsgs(  )
	unregMsg(self, gud_imperialwar_score_refresh)
end

function EpwAwardStage:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function EpwAwardStage:onPause(  )
	self:unregMsgs()
end

function EpwAwardStage:setupViews(  )
	self.pTxtMyScore = self:findViewByName("txt_my_score")
	self.pTxtCountryScore = self:findViewByName("txt_country_score")
	self.pLayList = self:findViewByName("lay_listview")
end

function EpwAwardStage:updateViews(  )
	self.tListData = getEpangWarInitData("levelReward")
	if not self.tListData then
		return
	end
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL,
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemEpwAwardStage.new()  
		    end
		    pTempView:setData(self.tListData[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(nCnt)
		self.pListView:reload(false)		
	else
		self.pListView:notifyDataSetChange(false, nCnt)		
	end

	self:updateScore()
end

--更新积分
function EpwAwardStage:updateScore(  )
	--更新我的积分
	self.nMyScore =  Player:getImperWarData():getMyWarScore()
	local tStr = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10931)},
	    {color=_cc.green,text=getResourcesStr(self.nMyScore)}, 
	}
	self.pTxtMyScore:setString(tStr)

	--更新国家的积分
	self.nCountryScore = Player:getImperWarData():getCountryWarScore()
	local tStr = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10964)},
	    {color=_cc.green,text=getResourcesStr(self.nCountryScore)}, 
	}
	self.pTxtCountryScore:setString(tStr)
end

return EpwAwardStage


