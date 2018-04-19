----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-02-26 16:13:57
-- Description: 冥界入侵属性兑换
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemMingjieExchange = require("app.layer.activityb.mingjie.ItemMingjieExchange")
local MingjieExchange = class("MingjieExchange", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function MingjieExchange:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_mingjie_exchange", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MingjieExchange:onParseViewCallback( pView )
	--self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MingjieExchange", handler(self, self.onWuWangExchangeDestroy))
end

-- 析构方法
function MingjieExchange:onWuWangExchangeDestroy(  )
    self:onPause()
end

function MingjieExchange:regMsgs(  )
    regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

function MingjieExchange:unregMsgs(  )
    unregMsg(self, gud_refresh_baginfo)
    
end

function MingjieExchange:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function MingjieExchange:onPause(  )
	self:unregMsgs()
end

function MingjieExchange:setupViews(  )
    local pLayCoin = self:findViewByName("lay_coin")
    local pLayMoney = self:findViewByName("lay_money")

	--金币文字
    self.pImgLabelCoin = MImgLabel.new({text="", size = 22, parent = pLayCoin})
    local tItemData = getGoodsByTidFromDB(100170)
    if tItemData then
        self.pImgLabelCoin:setImg(tItemData.sIcon, 0.35, "left")
    end
    
    self.pImgLabelCoin:followPos("center", pLayCoin:getContentSize().width/2, pLayCoin:getContentSize().height / 2, 3)

    --黄金文字
    self.pImgLabelMoney = MImgLabel.new({text="", size = 22, parent = pLayMoney})
    self.pImgLabelMoney:setImg(getCostResImg(e_type_resdata.money), 1, "left")
    self.pImgLabelMoney:followPos("center", pLayMoney:getContentSize().width/2, pLayMoney:getContentSize().height / 2, 3)

	self.pLayListView = self:findViewByName("lay_listview")
end

function MingjieExchange:updateViews(  )
    local tData = Player:getActById(e_id_activity.mingjie)
    if not tData then
        -- self:closeDlg(false)
        closeDlgByType(e_dlg_index.mingjie)
        return
    end
    self.pImgLabelCoin:setString(getMyGoodsCnt(100170) )
    self.pImgLabelMoney:setString(getMyGoodsCnt(e_type_resdata.money))

    self.tList = tData.tAts
    if self.tList then
        if not self.pListView then
            self:createListView()
        else
            self.pListView:notifyDataSetChange(true)
        end
    end
    -- if tData then
    --     self.tExchangeVos = tData:getExchangeVos()
    --     self:refreshSortParam(self.tExchangeVos)
    --     table.sort(self.tExchangeVos, function ( a, b )
    --         -- body
    --         if a.nSort == b.nSort then
    --             return a.nId < b.nId
    --         else
    --             return a.nSort > b.nSort     
    --         end            
    --     end)
    --     if not self.pListView then
    --         self:createListView(#self.tExchangeVos)
    --     else
    --         self.pListView:notifyDataSetChange(false, #self.tExchangeVos)
    --     end
    -- end
end


--创建列表
function MingjieExchange:createListView( )
	local pContentLayer = self.pLayListView
	local pSize = pContentLayer:getContentSize()
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left =  20,
                right =  0,
                top =  0, 
                bottom =  10},
    }
    
    pContentLayer:addView(self.pListView)
    centerInView(pContentLayer, self.pListView )

    --列表数据
    self.pListView:setItemCount(#self.tList)
    self.pListView:setItemCallback(function ( _index, _pView ) 
        -- body
        local tTempData = self.tList[_index]
        local pTempView = _pView
        if pTempView == nil then
            pTempView = ItemMingjieExchange.new()
        end
        pTempView:setData(tTempData)
            

        return pTempView
    end)

    --上下箭头
    local pUpArrow, pDownArrow = getUpAndDownArrow()
    self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
    self.pListView:reload()
end

return MingjieExchange



