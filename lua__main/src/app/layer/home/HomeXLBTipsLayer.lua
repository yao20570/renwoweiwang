--
-- Author: tanqian
-- Date: 2017-10-19 10:55:40
--主界面巡逻兵提示语layer
local MCommonView = require("app.common.MCommonView")
local HomeXLBTipsLayer = class("HomeXLBTipsLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function HomeXLBTipsLayer:ctor()
	
	parseView("layout_home_xlb_bubble", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function HomeXLBTipsLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
	self:onResume()
	self:updateViews()
	-- self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("HomeXLBTipsLayer",handler(self, self.onDestroy))
end


function HomeXLBTipsLayer:setupViews(  )
	self.pLyMain = self:findViewByName("default")		
	self.pLbTmp =  MUI.MLabel.new({text="", size=20})
	--self.pLbTmp:setVisible(false)
	self.pLbTmp:setAnchorPoint(0,1)
	self.pLbTmp:setDimensions(160,0)
	self.pLbTmp:setPosition(5, self.pLyMain:getHeight() - 10)
	self.pLyMain:addView(self.pLbTmp, 5)
end

function HomeXLBTipsLayer:setTips( _sTips )
	if not _sTips then
		return 
	end
	self.pLbTmp:setString(_sTips, false)
	-- self.pLbTmp:updateContent()
	-- local tChildrens = self.pLbTmp:getChildren()
	-- if tChildrens[1] then
	-- 	local pLbTexture = tChildrens[1]:getTexture()
	-- 	--pLbTexture:generateMipmap()
	-- 	--pLbTexture:setTexParameters(gl.LINEAR_MIPMAP_LINEAR, gl.LINEAR, gl.CLAMP_TO_EDGE, gl.CLAMP_TO_EDGE)
	-- 	if not self.pLbTip then
	-- 	    --名字
	-- 	    self.pLbTip = cc.Sprite:createWithTexture(pLbTexture,cc.rect(0,0,self.pLbTmp:getContentSize().width,self.pLbTmp:getContentSize().height))
	-- 	    self.pLbTip:setAnchorPoint(0,1)
	-- 	    self.pLbTip:setPosition(5, self.pLyMain:getHeight() - 10)
	-- 	    self.pLyMain:addChild(self.pLbTip,20)
	-- 	else
	-- 		self.pLbTip:setTexture(pLbTexture)
	-- 		self.pLbTip:setTextureRect(cc.rect(0,0,self.pLbTmp:getContentSize().width,self.pLbTmp:getContentSize().height))
	-- 		self.pLbTip:setPosition(5, self.pLyMain:getHeight() - 10)
	-- 	end		
	-- end
	--if self.pLbTip then
		local nwidth ,nHeight = self.pLbTmp:getWidth(),self.pLbTmp:getHeight()
		if nHeight < 40 then
			nHeight = 54
		else
			nHeight = nHeight + 30
		end
			-- nHeight = nHeight + 20

		self.pLyMain:setLayoutSize(self:getWidth(), nHeight)
		self:setLayoutSize(self:getWidth(), nHeight)
		self.pLbTmp:setPositionY(nHeight - 6)	
	--end
end
function HomeXLBTipsLayer:onResume()
	-- regUpdateControl(self, handler(self, self.onUpdateTime))
end




function HomeXLBTipsLayer:updateViews(  )

end
-- 析构方法
function HomeXLBTipsLayer:onDestroy(  )
	-- unregUpdateControl(self)--停止计时刷新
end
return HomeXLBTipsLayer
