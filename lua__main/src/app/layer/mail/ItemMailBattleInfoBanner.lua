----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2017-11-20 10:56:21
-- Description: 邮件战斗攻打的信息
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemMailBattleInfoBanner = class("ItemMailBattleInfoBanner", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMailBattleInfoBanner:ctor( _tInfo )
	--解析文件

	self.tInfo=_tInfo
	parseView("item_mail_battle_info_banner", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMailBattleInfoBanner:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMailBattleInfoBanner",handler(self, self.onMailDetailAtkDefBannerDestroy))
end

-- 析构方法
function ItemMailBattleInfoBanner:onMailDetailAtkDefBannerDestroy(  )
    self:onPause()
end

function ItemMailBattleInfoBanner:regMsgs(  )
end

function ItemMailBattleInfoBanner:unregMsgs(  )
end

function ItemMailBattleInfoBanner:onResume(  )
	self:regMsgs()
end

function ItemMailBattleInfoBanner:onPause(  )
	self:unregMsgs()
end

function ItemMailBattleInfoBanner:setupViews(  )
	-- local pTxtAtkTitle = self:findViewByName("txt_atk_title")
	-- pTxtAtkTitle:setString(getConvertedStr(3, 10249))
	-- local pTxtDefTitle = self:findViewByName("txt_def_title")
	-- pTxtDefTitle:setString(getConvertedStr(3, 10250))
	self.pLayBg=self:findViewByName("lay_bg")
	self.pTxtInfo=self:findViewByName("txt_info")
end

function ItemMailBattleInfoBanner:updateViews(  )
	--居中显示
	-- local pDetailLayer = MUI.MLayer.new()
	-- self.pLayBg:addView(pDetailLayer)
	-- -- pDetailLayer:setLayoutSize(self.pLayContent:getWidth(),self.pLayContent:getHeight())
	-- pDetailLayer:setAnchorPoint(0,0)

	-- local nPosX=0
	-- local nTxtWidth=0
	-- local nHeight=self.pLayBg:getHeight()
	-- if self.tInfo then
	-- 	for i, v in pairs(self.tInfo) do
	-- 		local pTxt=MUI.MLabel.new({text = v.sStr or "", size = v.nFontSize})
	-- 		pTxt:setColor(getC3B(v.sColor) or getC3B(_cc.white))
	-- 		-- pTxt:updateTexture()
	-- 		pTxt:setAnchorPoint(0,0)
	-- 		local nPosY=(nHeight-pTxt:getHeight())/2
	-- 		pTxt:setPosition(nPosX,nPosY)
	-- 		nPosX=nPosX+pTxt:getWidth()+5
	-- 		pDetailLayer:addView(pTxt,10)
	-- 		nTxtWidth=nTxtWidth+pTxt:getWidth()+3
	-- 		pDetailLayer:setContentSize(nTxtWidth,nHeight)

	-- 	end
	-- centerInView(self.pLayBg,pDetailLayer)
	-- end

	if self.tInfo then
		self.pTxtInfo:setString(self.tInfo)
	end
end

return ItemMailBattleInfoBanner


