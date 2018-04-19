----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 16:12:57
-- Description: 武王奖励兑换
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemWuWangExchange = require("app.layer.activityb.wuwang.ItemWuWangExchange")
local WuWangExchange = class("WuWangExchange", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function WuWangExchange:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_wuwangexchange", handler(self, self.onParseViewCallback))
end

--解析界面回调
function WuWangExchange:onParseViewCallback( pView )
	--self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WuWangExchange", handler(self, self.onWuWangExchangeDestroy))
end

-- 析构方法
function WuWangExchange:onWuWangExchangeDestroy(  )
    self:onPause()
end

function WuWangExchange:regMsgs(  )
    regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

function WuWangExchange:unregMsgs(  )
    unregMsg(self, gud_refresh_baginfo)
    
end

function WuWangExchange:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WuWangExchange:onPause(  )
	self:unregMsgs()
end

function WuWangExchange:setupViews(  )
	local pTxtTip = self:findViewByName("txt_tip")
	pTxtTip:setString(getTipsByIndex(20039))

	self.pLayListView = self:findViewByName("lay_listview")
end

function WuWangExchange:updateViews(  )
    local tData = Player:getActById(e_id_activity.wuwang)
    if tData then
        self.tExchangeVos = tData:getExchangeVos()
        self:refreshSortParam(self.tExchangeVos)
        table.sort(self.tExchangeVos, function ( a, b )
            -- body
            if a.nSort == b.nSort then
                return a.nId < b.nId
            else
                return a.nSort > b.nSort     
            end            
        end)
        if not self.pListView then
            self:createListView(#self.tExchangeVos)
        else
            self.pListView:notifyDataSetChange(false, #self.tExchangeVos)
        end
    end
end

function WuWangExchange:refreshSortParam( tData )
    -- body
    if not tData or table.nums(tData) <= 0 then
        return
    end
    local tActData = Player:getActById(e_id_activity.wuwang)
    if tActData and tActData.tExchangeMsg then
        local tExChangeInfo = tActData.tExchangeMsg
        for k, v in pairs(tData) do
            local nExchanged = tExChangeInfo:getGoodsExchanged(v.nId)
            if v.nExchangeMax - nExchanged > 0 then
                v.nSort = 1
            else
                v.nSort = 0
            end        
        end
    end

end

function WuWangExchange:onGoClicked( )

end

--创建列表
function WuWangExchange:createListView( _count )
	local pContentLayer = self.pLayListView
	local pSize = pContentLayer:getContentSize()
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    
    pContentLayer:addView(self.pListView)
    centerInView(pContentLayer, self.pListView )

    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
        -- body
        local tTempData = self.tExchangeVos[_index]
        local pTempView = _pView
        if pTempView == nil then
            pTempView = ItemWuWangExchange.new()
        end
        pTempView:setData(tTempData)
            

        return pTempView
    end)

    --上下箭头
    local pUpArrow, pDownArrow = getUpAndDownArrow()
    self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
    self.pListView:reload(false)
end

return WuWangExchange



