----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-20 14:38:29
-- Description: 触发式礼包 pageView
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemTriggerGift = require("app.layer.triggergift.ItemTriggerGift")
local ItemTriggerGiftPageView = class("ItemTriggerGiftPageView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTriggerGiftPageView:ctor( nPid, nGid )
	self.nPid = nPid
	self.nGid = nGid
	--解析文件
	parseView("item_trigger_gift_pageview", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemTriggerGiftPageView:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemTriggerGiftPageView", handler(self, self.onItemTriggerGiftPageViewDestroy))
end

-- 析构方法
function ItemTriggerGiftPageView:onItemTriggerGiftPageViewDestroy(  )
    self:onPause()
end

function ItemTriggerGiftPageView:regMsgs(  )
end

function ItemTriggerGiftPageView:unregMsgs(  )
end

function ItemTriggerGiftPageView:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemTriggerGiftPageView:onPause(  )
	self:unregMsgs()
end

function ItemTriggerGiftPageView:setupViews(  )
	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.yellow)

	self.pLayBanner = self:findViewByName("lay_banner")

	local pTxtLimitBuy = self:findViewByName("txt_limit_buy")
	pTxtLimitBuy:setString(getConvertedStr(3, 10525))

	self.pLbMyRank = MUI.MLabelAtlas.new({text="0", 
        png="ui/atlas/v2_shuzizhekou.png", pngw=31, pngh=42, scm=48})	
	self.pLbMyRank:setAnchorPoint(0, 0.5)
	self.pLbMyRank:setPosition(134, 73)
	-- self.pLbMyRank:setScale(2.1)
    self.pLayBanner:addView(self.pLbMyRank,5)

    self.pImgText = self:findViewByName("img_banner_text")

    self.pLayContent = self:findViewByName("lay_content")

    self.pImgTitle = self:findViewByName("img_title")
end

function ItemTriggerGiftPageView:updateViews(  )
	if not self.nPid or not self.nGid then
		return
	end
	local tConf = getTpackData(self.nPid, self.nGid)
	if tConf then
		--设置banner图
		if tConf.banner ~= self.sBanner then
			if self.pBanner then
				self.pBanner:removeFromParent()
			end
		end
		self.pBanner = setMBannerImage(self.pLayBanner,TypeBannerUsed.tg, "ui/banner_ui/"..tConf.banner..".jpg")
		self.sBanner = tConf.banner
		-- banner:setOpacity(255*0.3)
		self.pLbMyRank:setString(tostring(tConf.discount), false)
		-- self.pLayBanner:setBackgroundImage("#"..tConf.icon..".jpg",{scale9 = false})
		-- self.pImgText:setCurrentImage("#"..tConf.art..".png")
    	self.pImgTitle:setCurrentImage("#"..tConf.icon..".png")
	end
	self:updateListView()
	self:updateCd()
end

function ItemTriggerGiftPageView:updateCd( )
	if not self.nPid or not self.nGid then
		return
	end
	local tTriGitRes = Player:getTriggerGiftData():getPlayTpack(self.nPid, self.nGid)
	if tTriGitRes then
		self.pTxtCd:setString(formatTimeToHms(tTriGitRes:getCd()))
	end
end

--更新ListView
function ItemTriggerGiftPageView:updateListView( )
	if not self.nPid or not self.nGid then
		return
	end

	local tConf = getTpackData(self.nPid, self.nGid)
	if not tConf then
		return
	end

	self.tGoodsList = getDropById(tConf.dropid)
	if self.tGoodsList then
		if not self.pListView then
		    self:createListView(#self.tGoodsList)
		else
		    self.pListView:notifyDataSetChange(true, #self.tGoodsList)
		end
	end
end

--创建listView
function ItemTriggerGiftPageView:createListView(_count)
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, self.pLayContent:getWidth(), self.pLayContent:getHeight()),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  12},
    }
    
    local pContentLayer = self.pLayContent
    pContentLayer:addView(self.pListView)
    centerInView(pContentLayer, self.pListView )

    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
        local pTempView = _pView
        if pTempView == nil then
            pTempView   = ItemTriggerGift.new()
        end
        pTempView:setData(self.tGoodsList[_index])
        return pTempView
    end)
    self.pListView:reload()
    --上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
end

function ItemTriggerGiftPageView:setData( nPid, nGid ) 
	self.nPid = nPid
	self.nGid = nGid
	self:updateViews()
end

function ItemTriggerGiftPageView:getPidGid( )
	return self.nPid, self.nGid
end

return ItemTriggerGiftPageView