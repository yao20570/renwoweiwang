----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:14:59
-- Description: 商店系统
-----------------------------------------------------
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local VipShop = require("app.layer.shop.VipShop")
local MaterialShop = require("app.layer.shop.MaterialShop")
local ItemShop = require("app.layer.shop.ItemShop")
local VipGift = require("app.layer.shop.VipGift")
-- 商店系统
local DlgBase = require("app.common.dialog.DlgBase")
local DlgShop = class("DlgShop", function()
	return DlgBase.new(e_dlg_index.shop)
end)

--定位到某个物品id
--nGoodsId:物品id
function DlgShop:ctor( nGoodsId ,nIndex)
	self.nGoodsId = nGoodsId
	self.nDefIndex= nIndex
	parseView("dlg_shop", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgShop:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	--self:addContentTopSpace(7)
	
	self:setTitle(getConvertedStr(3, 10318))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgShop",handler(self, self.onDlgShopDestroy))
end

-- 析构方法
function DlgShop:onDlgShopDestroy(  )
    self:onPause()
end

function DlgShop:regMsgs(  )
end

function DlgShop:unregMsgs(  )
end

function DlgShop:onResume(  )
	self:regMsgs()
end

function DlgShop:onPause(  )
	self:unregMsgs()
end

function DlgShop:setupViews(  )
	local pLayContent = self:findViewByName("lay_content")

	--头顶横条(banner)
	local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
	setMBannerImage(pBannerImage,TypeBannerUsed.sd)
	
	--初次进来
	self.nIndex = 1
	self.nSubIndex = nil
	local tShopData = getShopDataById(self.nGoodsId)
	--记录初次进入的引导信息
	if tShopData then
		self.nIndex = tShopData.kind
	end

	if self.nDefIndex then
		self.nIndex = self.nDefIndex
	end

	-- self.pCurLayers = {}
	self.tTitles = {
		getConvertedStr(3, 10319),
		getConvertedStr(3, 10320),
		getConvertedStr(3, 10321),
		getConvertedStr(3, 10322),
	}
	self.pTabHost = FCommonTabHost.new(pLayContent,1,1,self.tTitles, handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(pLayContent:getLayoutSize())
    self.pTabHost:setIgnoreOtherHeight(true)
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	pLayContent:addView(self.pTabHost)
	centerInView(pLayContent, self.nTabHost)
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))

	self.pTabHost:setDefaultIndex(self.nIndex)

	--红点层
	self.pVipRedLay = MUI.MLayer.new()
	self.pVipRedLay:setLayoutSize(20, 20)
	local x = pLayContent:getWidth() - 20
	local y = pLayContent:getHeight() - 20
	self.pVipRedLay:setPosition(x, y)
	pLayContent:addView(self.pVipRedLay, 99)
end

function DlgShop:updateViews(  )
	showRedTips(self.pVipRedLay,0,Player:getPlayerInfo():getVipGiftRedNum())
end

--通过key值获取内容层的layer
function DlgShop:getLayerByKey( _sKey, _tKeyTabLt )
    local pLayer = nil
    local pdata = {}
    local tSize = self.pTabHost:getCurContentSize()
    --dump(tSize, "tSize", 100)
    if( _sKey == _tKeyTabLt[1] ) then
    	if self.nIndex ~= 1 then
    		self.nGoodsId = nil
    	end
        pLayer = VipShop.new(tSize, self.nGoodsId)  
    elseif (_sKey == _tKeyTabLt[2] ) then
    	if self.nIndex ~= 2 then
    		self.nGoodsId = nil
    	end
        pLayer = MaterialShop.new(tSize, self.nGoodsId)            
    elseif (_sKey == _tKeyTabLt[3] ) then       
        pLayer = ItemShop.new(tSize)
    elseif (_sKey == _tKeyTabLt[4] ) then
        pLayer = VipGift.new(tSize)
    end 
    self.pCurLayer = pLayer
    return pLayer
end

--切换时监听
function DlgShop:onTabChanged( skey )	
	if skey == "tabhost_key_4" then--清理Vip红点		
		Player:getPlayerInfo():clearVipGiftRedNum()
		self:updateViews()
	end
end

-- --更新子界面
-- function DlgShop:updateSubView()
-- 	--统一子界面更新
-- 	if self.pCurLayer then
-- 		self.pCurLayer:updateViews()
-- 	end
-- end

return DlgShop