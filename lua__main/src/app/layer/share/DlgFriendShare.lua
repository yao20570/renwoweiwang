-- DlgFriendShare.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-26 20:35:23 星期一
-- Description: 分享小弹窗
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemShareFriend = require("app.layer.share.ItemShareFriend")

local DlgFriendShare = class("DlgFriendShare", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgfriendshare)
end)

function DlgFriendShare:ctor()
	-- body
	self:myInit()
	parseView("lay_share_list", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgFriendShare:myInit()
	-- body
	self.tMyFriendList = nil                           -- 我的好友列表
end

--解析布局回调事件
function DlgFriendShare:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgFriendShare",handler(self, self.onDlgFriendShareDestroy))
end

--初始化控件
function DlgFriendShare:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7,10067))
	--列表层
	self.pLayShareListView             = self:findViewByName("lay_list")

	--列表层
	self.pShareListView = MUI.MListView.new{
        viewRect = cc.rect(0, 0, self.pLayShareListView:getWidth(), self.pLayShareListView:getHeight()),
        direction = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {
        	left =  0,
        	right =  0,
        	top =  10,
        	bottom =  2
        },
	}
	self.pLayShareListView:addView(self.pShareListView)
	self.pShareListView:setBounceable(true)
    self.pShareListView:setItemCount(6)      
    self.pShareListView:setItemCallback(function ( _index, _pView )
        local pTempView = _pView
    	if pTempView == nil then
        	pTempView = ItemShareFriend.new()                        
        end
        return pTempView
    end)
    self.pShareListView:reload()
end

function DlgFriendShare:updateViews()
	-- body
	if self.tMyFriendList then
		self.pShareListView:setItemCount(table.nums(self.tMyFriendList) or 0) 
		self.pShareListView:reload()
	end
end

--向下箭头是否可见
function DlgFriendShare:setDownArrow(_bIsShow)
	-- body
	self.pImgDownArrow:setVisible(_bIsShow)
	self.pImgUpArrow:setVisible(not _bIsShow)
end

-- 析构方法
function DlgFriendShare:onDlgFriendShareDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgFriendShare:regMsgs(  )
	-- body
end
--注销消息
function DlgFriendShare:unregMsgs(  )
	-- body
end

-- 暂停方法
function DlgFriendShare:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgFriendShare:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgFriendShare