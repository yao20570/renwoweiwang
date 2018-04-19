-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-27 15:37:17 星期六
-- Description: 福星高照奖励详情子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local const_img_name = { "#v1_img_paixingbang1.png", "#v1_img_paixingbang2.png", "#v1_img_paixingbang3.png" }
local ItemLuckyStarRank = class("ItemLuckyStarRank", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--构造
function ItemLuckyStarRank:ctor()
	-- body
	self:myInit()
	parseView("item_lucky_star_rank", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function ItemLuckyStarRank:onParseViewCallback( pView )
	-- body
	
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("ItemLuckyStarRank",handler(self, self.onDestroy))
end
function ItemLuckyStarRank:myInit(  )
	-- body
	self.tData = nil
end

--初始化控件
function ItemLuckyStarRank:setupViews()
	-- body
	self.pTxtRank= self:findViewByName("txt_rank")
	self.pTxtCountry= self:findViewByName("txt_country")
	self.pTxtName= self:findViewByName("txt_name")
	self.pTxtPoint= self:findViewByName("txt_point")
end

-- 修改控件内容或者是刷新控件数据
function ItemLuckyStarRank:updateViews()
	-- body
	if not self.tData then
		return
	end
	
	self:setRank(self.tData.x,self.pTxtRank)
	setTextCCColor(self.pTxtCountry, getColorByCountry(self.tData.c))
	self.pTxtCountry:setString(getCountryName(self.tData.c))
	self.pTxtName:setString(self.tData.n)
	self.pTxtPoint:setString(self.tData.f or 0)
end

function ItemLuckyStarRank:setRank(_nRank, _pNode)
    if _nRank > 3 then
        self.pTxtRank:setString(self.tData.x)
        self.pTxtRank:setVisible(true)
        if self.pImgRank then
        	self.pImgRank:setVisible(false)
        end
        return
    end
    if not self.pImgRank  then
        local posX, posY = _pNode:getPosition()
        self.pImgRank = MUI.MImage.new(const_img_name[_nRank])
        self.pImgRank:setPosition(posX, posY)
        self.pImgRank:setScale(0.4)
        _pNode:getParent():addView(self.pImgRank)
    else
        self.pImgRank:setCurrentImage(const_img_name[_nRank])        
    end
    self.pImgRank:setVisible(true)
    _pNode:setVisible(false)
end

function ItemLuckyStarRank:setData( _tData )
	-- body

	self.tData = _tData or self.tData
	self:updateViews()
end

--析构方法
function ItemLuckyStarRank:onDestroy()
	self:onPause()
end

-- 注册消息
function ItemLuckyStarRank:regMsgs( )
	-- body


end

-- 注销消息
function ItemLuckyStarRank:unregMsgs(  )
	-- body
	
end


--暂停方法
function ItemLuckyStarRank:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function ItemLuckyStarRank:onResume( )
	-- body
	self:regMsgs()

end



return ItemLuckyStarRank
