-- Author: maheng
-- Date: 2017-11-30 17:50:54
--红包

local MCommonView = require("app.common.MCommonView")
local MailData = require("app.layer.mail.data.MailData")
local ItemRedPocketRecord = class("ItemRedPocketRecord", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemRedPocketRecord:ctor( _data)
	-- body
	self:myInit()
	self.pData = _data
	parseView("item_catch_rp_record_layer",handler(self, self.onParseViewCallback))--红包

	--注册析构方法
	self:setDestroyHandler("ItemRedPocketRecord",handler(self, self.onDestroy))
	
end

function ItemRedPocketRecord:regMsgs(  )
	
end
function ItemRedPocketRecord:unregMsgs(  )

end

--初始化参数
function ItemRedPocketRecord:myInit()
	self.pData = {} --数据
	self.pView = nil --item
	self.nType = 1 --聊天类型
	self.bIsUseRichText = false
end

--解析布局回调事件
function ItemRedPocketRecord:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self.pView = pView
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemRedPocketRecord:setupViews( )
	-- body
	self.pLayLbBg = self:findViewByName("lay_main")
	self.pLbCon = self:findViewByName("lb_con")		
end
--添加头像
function ItemRedPocketRecord:addIcon(  )
	-- body
	--头像
	-- v1_img_headlaba.png
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL,
	type_icongoods_show.header, nil,0.8)
	self.pIcon:setPosition(self.pLayIcon:getWidth()*(0.8-1),self.pLayIcon:getHeight()*(0.8-1))
	self.pIcon:setIconClickedCallBack(handler(self, self.onItemClicked))

end

function ItemRedPocketRecord:setHandler(_handler )
	-- body
	if _handler then
		self.pHandler = _handler
	end
end


-- 修改控件内容或者是刷新控件数据
function ItemRedPocketRecord:updateViews()
	-- body
	self.pLbCon:setString(self.pData.sCnt, false)
	local nWidth = self.pLbCon:getPositionX() + self.pLbCon:getWidth() 
	if nWidth < 180 then
		nWidth = 180
	end
	self.pLayLbBg:setLayoutSize(nWidth + 20, self.pLayLbBg:getHeight())
end

--点击回调
function ItemRedPocketRecord:onItemClicked(pView)
	if self.pData and self.pData.nSid then
		--系统消息不打开
		if self.pData.nTmsg == e_chat_type.sys then
			return
		end
		local pMsgObj = {}
		pMsgObj.nplayerId = self.pData.nSid
		pMsgObj.tChatData = self.pData
		pMsgObj.bToChat = false
		--发送获取其他玩家信息的消息
		sendMsg(ghd_get_playerinfo_msg, pMsgObj)
	end
end

--获取当前item数据
function ItemRedPocketRecord:getData()
	local tData = nil
	if self.pData then
		tData = self.pData
	end	
	return tData
end

--设置数据
function ItemRedPocketRecord:setCurData(_data)
	if not _data then
       return 
	end
	--dump(_data, "_data", 100)
	self.pData = _data
	self:updateViews()
end

--析构方法
function ItemRedPocketRecord:onDestroy(  )
	-- body
	self:unregMsgs()
end



return ItemRedPocketRecord