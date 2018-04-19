-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-28 14:13:23 星期二
-- Description: 红包打开
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local ItemGetRedPocket = require("app.layer.redpocket.ItemGetRedPocket")
local DlgRedPocketCheck = class("DlgRedPocketCheck", function()
	-- body
	return MDialog.new(e_dlg_index.dlgredpocketcheck)
end)

function DlgRedPocketCheck:ctor( _pData )
	-- body	
	self:myInit(_pData)
	parseView("lay_red_pocket_open_detail", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgRedPocketCheck:myInit( _pData )
	-- body
	self.pRedID = _pData.nRpId or nil
	self.pData = _pData.pData or nil 
	self.nChatID = _pData.nChatID or nil
	self.tChatData = _pData.tChatData or nil
	--dump(_pData, "_pData", 100)
end

--解析布局回调事件
function DlgRedPocketCheck:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRedPocketCheck",handler(self, self.onDestroy))
end

--初始化控件
function DlgRedPocketCheck:setupViews(  )
	--body	
	self.pLayRoot 		= 		self:findViewByName("lay_default")
	self.pLayClose 		= 		self:findViewByName("lay_btn_close")
	self.pLbNum = self:findViewByName("lb_num")	
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLbDesc1 = self:findViewByName("lb_par_1")
	self.pLbDesc2 = self:findViewByName("lb_par_2")
	self.pLbTime = self:findViewByName("lb_time")
	local pLayList = self:findViewByName("lay_list")

	self.pLayClose:setViewTouched(true)
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:onMViewClicked(function (  )
		-- body
		self:closeDlg()
	end)
	
	local pIconData = Player:getChatAvatorById(self.nChatID)
	if not self.pIcon then
	 	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.header, pIconData, TypeIconGoodsSize.M)
	 	self.pIcon:setIconIsCanTouched(false)
	else
		self.pIcon:setCurData(pIconData)
	end

	local tInfo = self.pData.info
	
	self.pLbDesc1:setString(tInfo.bname, false)
	setTextCCColor(self.pLbDesc1, _cc.yellow)
	
	setTextCCColor(self.pLbDesc2, _cc.yellow)	

	if self.tChatData.sSenderNameIcon and self.tChatData.nTmsg == e_chat_type.sysRedPocket then   --系统红包的头像和名字走配表
		self.pIcon:setIconImg(self.tChatData.sSenderNameIcon)
		self.pLbDesc1:setString(self.tChatData.sSenderNameDb, false)
		
	end

	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10617)},
		{color=_cc.white, text=tInfo.rnum},
		{color=_cc.yellow, text="/"..tInfo.rsum},
	}
	self.pLbNum:setString(sStr, false)

	
	setTextCCColor(self.pLbTime, _cc.white) 
	self.pLbTime:setString(formatTimeToHMSWord(tInfo.life)..getConvertedStr(6, 10618))
	if tInfo.life and tInfo.life > 0 then
		self.pLbTime:setVisible(true)
	else
		self.pLbTime:setVisible(false)
	end

	self.tListData = tInfo.rec or {}
	self:updateListInfo()
	
	self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, pLayList:getWidth(), pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL
        }
    pLayList:addView(self.pListView)
	local _count = #self.tListData
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    if pTempView == nil then
	        pTempView = ItemGetRedPocket.new()                        
	        pTempView:setViewTouched(false)
	        pTempView:setIsPressedNeedScale(false)
	    end
		local tData = self.tListData[_index]
		pTempView:setCurData(tData)	
    	return pTempView
	end)	
	self.pListView:setItemCount(_count)
	self.pListView:reload()
end

--控件刷新
function DlgRedPocketCheck:updateViews(  )
	-- body
	if self.pData.get == 1 then--抢到
		self.pLbDesc2:setString(string.format(getConvertedStr(6, 10624), self:getMyRedNum(self.tListData)))
	elseif self.pData.get == 2 then--已经抢完
		self.pLbDesc2:setString(getConvertedStr(6, 10625), false)
	end
end

function DlgRedPocketCheck:updateListInfo(  )
	-- body
	--dump(self.pData, "self.pData", 100)
	local tList = copyTab(self.tListData)
	local rnum = self.pData.info.rnum --剩余红包数量
	if #tList <= 0 or rnum > 0 then
		return
	end
	table.sort( tList, function ( a, b )
		-- body
		return a.money > b.money
	end )
	local sName = tList[1].name
	for k, v in pairs(self.tListData) do
		if sName == v.name then
			v.bBest = true
		else
			v.bBest = false
		end
	end
	--dump(self.tListData, "self.tListData", 100)
end

function DlgRedPocketCheck:getMyRedNum( _tList )
	-- body
	if not _tList or #_tList <= 0 then
		return 0
	end
	for k, v in pairs(_tList) do
		if v.name == Player:getPlayerInfo().sName then
			return v.money
		end
	end
	return 0
end
--析构方法
function DlgRedPocketCheck:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgRedPocketCheck:regMsgs(  )
	-- body

end
--注销消息
function DlgRedPocketCheck:unregMsgs(  )
	-- body

end

--暂停方法
function DlgRedPocketCheck:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgRedPocketCheck:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgRedPocketCheck