-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-20 17:7:40 星期五
-- Description: 好友选择
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemFriendSelect = class("ItemFriendSelect", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemFriendSelect:ctor(  )
	-- body
	self:myInit()
	parseView("item_friend_select", handler(self, self.onParseViewCallback))
	
end

--初始化成员变量
function ItemFriendSelect:myInit(  )
	-- body
	self.nShowType 			= 	1                   --好友信息界面
	self.tCurData 			= 	nil 				--当前数据	
end

--解析布局回调事件
function ItemFriendSelect:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemFriendSelect",handler(self, self.onItemFriendSelectDestroy))
end

--初始化控件
function ItemFriendSelect:setupViews( )
	-- body
	self.pLayRoot 	= self:findViewByName("item_friend_select")
	self.pLayRoot:setViewTouched(true)
	self.pLayRoot:setIsPressedNeedScale(false)
	self.pLayRoot:onMViewClicked(handler(self, self.onChatCallBack))	

	self.pLayIcon 	= self:findViewByName("lay_icon") --玩家头像层
	self.pLbParam1 	= self:findViewByName("lb_pram_1")--玩家名字等级	
	self.pLbParam2 	= self:findViewByName("lb_pram_2")--玩家战力
	self.pLbParam3 	= self:findViewByName("lb_pram_3")--国家势力
	self.pLayRed = self:findViewByName("lay_red")
	local pLbTime = self:findViewByName("lb_time")

	self.pLbTime = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(295, 54),
		})
	self.pLbTime:setPosition(420, self.pLayRoot:getHeight()/2)
	self.pLayRoot:addView(self.pLbTime, 10)
	setTextCCColor(self.pLbTime, _cc.pwhite)

	self.pImgJiantou = self:findViewByName("img_jiantou")
end

-- 修改控件内容或者是刷新控件数据
function ItemFriendSelect:updateViews( )
	-- body
	if not self.tCurData then
		print("玩家数据异常！")
		return
	end
	--dump(self.tCurData, "self.tCurData", 100)
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, self.tCurData, TypeIconHeroSize.M)
		self.pIcon:setIconClickedCallBack(function (  )
			-- body
			local pMsgObj = {}
			pMsgObj.nplayerId = self.tCurData.sTid
			pMsgObj.bToChat = false
			--发送获取其他玩家信息的消息
			sendMsg(ghd_get_playerinfo_msg, pMsgObj)			
		end)
	else
		self.pIcon:setCurData(self.tCurData)
	end
	--玩家名字等级
	self.pLbParam1:setString(self.tCurData.sName..getLvString(self.tCurData.nLv, true), false)
	setTextCCColor(self.pLbParam1, getColorByQuality(self.tCurData.nQuality))

	--战力
	local tStr2 = {
		{color=_cc.pwhite, text=getConvertedStr(3, 10233)},
		{color=_cc.white, text=formatCountToStr(self.tCurData.nPower)},
	}
	self.pLbParam2:setString(tStr2, false)
	--国家
	local tStr3 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10241)},
		{color=_cc.white, text=getCountryShortName(self.tCurData.nInfluence, false)},
	}
	self.pLbParam3:setString(tStr3, false)

	--self.pLbTime:setString(self:formatShowTime(self.tCurData.nSt))
	self.pLbTime:setString(self:formatShowTime(self.tCurData.nSt))
	--红点
	showRedTips( self.pLayRed,1, Player:getPrivateChatRed(self.tCurData.sTid))
end

function ItemFriendSelect:formatShowTime( fTime )
	local sStr = ""
	local tData = os.date("*t", fTime/1000)
	local fCurTime = getSystemTime()
	local tCurData = os.date("*t", fCurTime)
	local fDisTime = fTime/1000 - fCurTime
	if(tCurData.year == tData.year and tData.yday == tCurData.yday) then -- 同一天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = getConvertedStr(5, 10134) .. "\n" .. tData.hour .. ":" .. tData.min
	elseif(tCurData.year == tData.year and tCurData.yday-tData.yday == 1) then -- 昨天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = getConvertedStr(5, 10135) .. "\n" .. tData.hour .. ":" .. tData.min
	else
		sStr = formatTime(fTime, "%Y.%m.%d\n%H:%M:%S")
	end
	return sStr
end

-- 析构方法
function ItemFriendSelect:onItemFriendSelectDestroy(  )
	-- body
end

--_data :FriendVo
function ItemFriendSelect:setCurData( _data )
	-- body	
	self.tCurData 		= 	_data or nil
	self:updateViews()
end

function ItemFriendSelect:getData(  )
	-- body
	return self.tCurData
end
--聊天
function ItemFriendSelect:onChatCallBack(  )
	-- body
	print("聊天")
	
	if not self.tCurData then
		return
	end

	--打开聊天界面加请求聊天信息
	local pMsgObj = {}
	pMsgObj.pData = self.tCurData
	--发送获取其他玩家信息的消息
	sendMsg(ghd_selected_redpocket_msg, pMsgObj)
	--半闭自己
	closeDlgByType(e_dlg_index.dlgfriendselect, false)
end

return ItemFriendSelect