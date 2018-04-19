-- Author: maheng
-- Date: 2017-11-21 14:26:03
-- 私聊好友

local MCommonView = require("app.common.MCommonView")
local ItemPrivateFriendChat = class("ItemPrivateFriendChat", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemPrivateFriendChat:ctor()
	-- body
	self:myInit()

	parseView("item_private_friend_chat", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPrivateFriendChat",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemPrivateFriendChat:myInit()	
	self.pData = nil --数据
	self.bSelected = false

	self.pHandler = nil
end

--解析布局回调事件
function ItemPrivateFriendChat:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemPrivateFriendChat:setupViews( )
	--ly 
	self.pLayRoot = self:findViewByName("item_private_friend_chat")
	self.pLayIcon = self:findViewByName("lay_icon")	 	
	--lb
	self.pLbName = self:findViewByName("lb_name")
	--img
	self.pImgFlag = self:findViewByName("img_flag")--国家
	self.pImgFlag:setScale(0.6)
	self.pImgSelect = self:findViewByName("img_select")
	self.pImgSelect:setVisible(false)
	self.pLayRed = self:findViewByName("lay_red")

	self.pLayRoot:setViewTouched(true)
	self.pLayRoot:setIsPressedNeedScale(false)
    self.pLayRoot:onMViewClicked(handler(self,self.onGetClick))	
end

-- 修改控件内容或者是刷新控件数据
function ItemPrivateFriendChat:updateViews(  )
	-- body
	if self.pData then
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, self.pData, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)

		self.pLbName:setString(self.pData.sName)
		local sStr = WorldFunc.getCountryFlagImg(self.pData.nInfluence)
		self.pImgFlag:setCurrentImage(WorldFunc.getCountryFlagImg(self.pData.nInfluence)) 
		self.pImgFlag:setVisible(true)	
		--红点
		showRedTips( self.pLayRed,1, Player:getPrivateChatRed(self.pData.sTid))	
		self.pLayRed:setVisible(true)	
	else
		self.pImgFlag:setVisible(false)	
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, nil, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)
		self.pLbName:setString("")
		showRedTips( self.pLayRed,1, 0)	
		self.pLayRed:setVisible(false)	
	end
end

--析构方法
function ItemPrivateFriendChat:onDestroy(  )
	-- body
end

function ItemPrivateFriendChat:isItemSelected(  )
	-- body
	return self.bSelected
end

function ItemPrivateFriendChat:setItemSelected( bSelected )
	-- body
	self.bSelected = bSelected or false
	self.pImgSelect:setVisible(self.bSelected)
end
--设置数据 _data
function ItemPrivateFriendChat:setCurData(_tData)
	self.pData = _tData or nil
	self:updateViews()
end

function ItemPrivateFriendChat:setHandler( _nHandler )
	-- body
	self.pHandler = _nHandler
end

--获得按钮回调
function ItemPrivateFriendChat:onGetClick()
	if self.pHandler then
		self.pHandler(self.pData)
	end
end
return ItemPrivateFriendChat