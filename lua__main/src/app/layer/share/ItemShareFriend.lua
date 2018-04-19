-- ItemShareFriend.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-26 21:20:23 星期一
-- Description: 好友分享列表项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemShareFriend = class("ItemShareFriend", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
--_data：当前科技数据
function ItemShareFriend:ctor()
	-- body
	self:myInit()
	parseView("item_share_friend", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemShareFriend:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function ItemShareFriend:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemShareFriend",handler(self, self.onItemShareFriendDestroy))
end

--初始化控件
function ItemShareFriend:setupViews( )
	-- body
	self.pLayRoot                            =    self:findViewByName("default")
	--好友头像
	self.pLayIcon                            =    self:findViewByName("lay_friend_icon")
	self.pIcon = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL, data,TypeIconHeroSize.M)

	self.pLbLastLogin                        =    self:findViewByName("t_lastlogin")
	self.pLbLastLogin:setString(getConvertedStr(7,10068))
	--最后登录时间
	self.pLbLastLogTime                      =    self:findViewByName("t_last_log_time")
	self.pLayBtn                             =    self:findViewByName("lay_share_btn")
	--分享按钮
	self.pShareBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.O_BLUE, getConvertedStr(7,10069))
	self.pShareBtn:onCommonBtnClicked(handler(self, self.onShareClicked))
end

-- 修改控件内容或者是刷新控件数据
function ItemShareFriend:updateViews(  )
	-- body
	self.pLbLastLogTime:setString("4小时内")
	setTextCCColor(self.pLbLastLogTime, _cc.blue)
	local sName = "好友名字"
	local nLv = 88
	local sColor1 = _cc.yellow
	local sColor2 = _cc.pwhite
	local sColor3 = _cc.blue
	self:createTextTableTip(sName, "  Lv.", nLv, sColor1, sColor2, sColor3, cc.p(115, 77))
end

--分享按钮点击事件
function ItemShareFriend:onShareClicked(_pView)
	-- body
	TOAST("好友分享")
end

--好友名字和等级组合文本
function ItemShareFriend:createTextTableTip(_content1, _content2, _content3, _color1, _color2, _color3, _pos)
	-- body
	local tConTable = {}
	tConTable.tLabel = {
		{_content1, getC3B(_color1)},
		{_content2, getC3B(_color2)},
		{_content3, getC3B(_color3)},
	}
	tConTable.fontSize = 22
	local pFriendText = createGroupText(tConTable)
	self.pLayRoot:addView(pFriendText, 10)
	pFriendText:setPosition(_pos)
	pFriendText:setAnchorPoint(cc.p(0, 0.5))
	return pFriendText
end

-- 析构方法
function ItemShareFriend:onItemShareFriendDestroy(  )
	-- body
end

--设置当前数据
function ItemShareFriend:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end


return ItemShareFriend