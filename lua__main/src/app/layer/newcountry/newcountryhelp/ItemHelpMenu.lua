----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-04-11
-- Description: 国家互助主界面按钮
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
					
local ItemHelpMenu = class("ItemHelpMenu", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemHelpMenu:ctor( )
	-- body
	self:setupViews()
	self:onResume()
	self:setDestroyHandler("ItemHelpMenu",handler(self, self.onDestroy))
end

function ItemHelpMenu:regMsgs(  )
	regMsg(self, gud_refresh_countryhelp, handler(self, self.updateViews))
end

function ItemHelpMenu:unregMsgs(  )
	unregMsg(self, gud_refresh_countryhelp)
end

function ItemHelpMenu:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemHelpMenu:onPause(  )
	self:unregMsgs()
end

function ItemHelpMenu:setupViews(  )
	if not self.pHelpImage then
	 	self.pHelpImage = MUI.MImage.new("#v2_img_zjm_huzhu.png")
	 	local tSize = self.pHelpImage:getContentSize()
	 	self.pHelpImage:setAnchorPoint(cc.p(0.5,0.5))
	 	self.pHelpImage:setPosition(tSize.width/2, tSize.height/2)
	 	self:setContentSize(tSize)
	 	self:addView(self.pHelpImage)
		self.pHelpImage:setViewTouched(true)
	    self.pHelpImage:setIsPressedNeedScale(true)
	    self.pHelpImage:onMViewClicked(handler(self, self.onHelp))
	end

end

--析构方法
function ItemHelpMenu:onDestroy( )
 
end

function ItemHelpMenu:updateViews(  )
 	local tData = Player:getCountryHelpData()
 	if tData and tData:haveHelps() then
 		self.pHelpImage:setVisible(true)
 	else
 		self.pHelpImage:setVisible(false)
 	end
end
 
function ItemHelpMenu:onHelp( )
	SocketManager:sendMsg("countryhelp", {2})
end 

 

return ItemHelpMenu


