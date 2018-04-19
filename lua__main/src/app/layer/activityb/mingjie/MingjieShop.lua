----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-02-26 16:17:57
-- Description: 冥界入侵积分商店
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemMingjieShop = require("app.layer.activityb.mingjie.ItemMingjieShop")
local MingjieShop = class("MingjieShop", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function MingjieShop:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_mingjie_exchange", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MingjieShop:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MingjieShop", handler(self, self.onMingjieShopDestroy))
end

-- 析构方法
function MingjieShop:onMingjieShopDestroy(  )
    self:onPause()
end

function MingjieShop:regMsgs(  )
end

function MingjieShop:unregMsgs(  )
    
end

function MingjieShop:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function MingjieShop:onPause(  )
	self:unregMsgs()
end

function MingjieShop:setupViews(  )
	local pLayCoin = self:findViewByName("lay_coin")
    local pLayTip = self:findViewByName("lay_money")

    self.pLayListView = self:findViewByName("lay_listview")

    --黄金文字
    self.pImgLabelCoin = MImgLabel.new({text="", size = 22, parent = pLayCoin})
    self.pImgLabelCoin:setImg(getCostResImg(e_type_resdata.money), 1, "left")
    self.pImgLabelCoin:followPos("center", pLayCoin:getContentSize().width/2, pLayCoin:getContentSize().height / 2, 3)

    --描述文字
    local pLbTip = MUI.MLabel.new({text = getConvertedStr(9,10162), size = 18})
    pLbTip:setAnchorPoint(0,0.5)
    pLbTip:setPosition(0,pLayTip:getHeight()/2)
    pLayTip:addView(pLbTip)
end

function MingjieShop:updateViews(  )
    local tData = Player:getActById(e_id_activity.mingjie)
    if not tData then
        -- self:closeDlg(false)
        closeDlgByType(e_dlg_index.mingjie)
        return
    end
    self.pImgLabelCoin:setString(getMyGoodsCnt(100171) )

    self.tList = tData.tSs
    local tTemp = self.tList[1]
    local tItemData= getGoodsByTidFromDB(tTemp.c[1].k)

    if tItemData then
        self.pImgLabelCoin:setImg(tItemData.sIcon, 1, "left")
    end
    if self.tList then
        if not self.pListView then
           local pSize = self.pLayListView:getContentSize()
            self.pListView = MUI.MListView.new {
                viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
                direction  = MUI.MScrollView.DIRECTION_VERTICAL,
                itemMargin = {
                    left   = 20,
                    right  = 0,
                    top    = 0, 
                    bottom = 10}
            }
            self.pLayListView:addView(self.pListView)
            local nCount = table.nums(self.tList)
            self.pListView:setItemCount(nCount)
            self.pListView:setItemCallback(function ( _index, _pView ) 
                local pTempView = _pView
                if pTempView == nil then
                    pTempView = ItemMingjieShop.new()
                end
                pTempView:setData(self.tList[_index])
                return pTempView
            end)
            local pUpArrow, pDownArrow = getUpAndDownArrow()
            self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
            self.pListView:reload()
        else
            self.pListView:notifyDataSetChange(true)
        end
    end
end
return MingjieShop



