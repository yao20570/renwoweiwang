-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-14 10:28:19 星期四
-- Description: 增益buff
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemBuff = require("app.layer.buff.ItemBuff")
local DlgBuffs = class("DlgBuffs", function ()
	-- body
	return DlgCommon.new(e_dlg_index.dlgbuffs)
end)

function DlgBuffs:ctor( )
	-- body
	self:myInit()
	self.tBuffItems = {}
	parseView("dlg_buffs", handler(self, self.onParseViewCallback))	
end

--初始化成员变量
function DlgBuffs:myInit(  )

	
end

--解析布局回调事件
function DlgBuffs:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBuffs",handler(self, self.onDestroy))
end

function DlgBuffs:setupViews( )
	-- body
	self:setTitle(getConvertedStr(6, 10642))
	self.pLayRoot = self:findViewByName("lay_buffs")
	self.pLayList = self:findViewByName("lay_list")
end

function DlgBuffs:updateViews( )
	-- body
	self.tBuffItems = {}
	local tT = luaSplit(getDisplayParam("buffItem"),";")
	--dump(tT, "tT", 100)
    if table.nums(tT) > 0 then
        for k, v in pairs (tT) do
            --先从玩家身上查找
            local tItem = Player:getBagInfo():getItemDataById(tonumber(v))
            if not tItem then --如果没有，那么从配表中查找
                tItem = getBaseItemDataByID(tonumber(v))
            end
            if tItem then
                table.insert(self.tBuffItems, tItem)
            end
        end
    end

	if not self.pListView then
	    self.pListView = MUI.MListView.new {
	        viewRect   = cc.rect(0, 0, self.pLayList:getContentSize().width, self.pLayList:getContentSize().height),
	        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {left = 0,
	            right = 0,
	            top = 5,
	            bottom = 5},
	    }
	    self.pLayList:addView(self.pListView)
	    self.pListView:setItemCallback(handler(self, self.onItemCallBack))
	    
	    self.pListView:setItemCount(#self.tBuffItems)
	    self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, #self.tBuffItems)
	end

end

function DlgBuffs:onItemCallBack( _index, _pView )
	local tTempData = self.tBuffItems[_index]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemBuff.new()
    end
	pTempView:setClickCallBack(handler(self, self.onActionClicked))
	pTempView:setCurData(tTempData)
    if tTempData then
    	if tTempData.nCt == 0 then
    		pTempView:changeExToGold()
    		pTempView:setBtnVisible(tTempData.nCanbuy == 1) 
    		local pExGold = pTempView:getExGold()
    		if pExGold then
    			pExGold:setVisible(tTempData.nCanbuy == 1)  
    		end		
    	else
    		pTempView:setBtnVisible(true)
    		pTempView:changeExToHad()
    		pTempView:getExHad():setVisible(true)  		
    	end
    end	
    return pTempView
end

function DlgBuffs:onActionClicked( _tItemInfo )
	-- body
	if _tItemInfo.nCt == 0 then
		local nCost = _tItemInfo.nPrice
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(1, 10146)},--购买并使用
	    	{color=_cc.yellow,text=_tItemInfo.sName},--名字
	    	{color=_cc.pwhite,text="?"},
	    }
	    --展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
			-- body
			--发送使用物品消息
			local tObject = {}
			tObject.useId = _tItemInfo.sTid
			tObject.useNum = 1
			tObject.type = 2--购买并使用
			sendMsg(ghd_useItems_msg,tObject)
		end)
	else
		showUseItemDlg(_tItemInfo.sTid)    	
	end	
end

function DlgBuffs:onDestroy( )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuffs:regMsgs( )
	-- body
	--buff数据刷新
	regMsg(self, gud_buff_update_msg, handler(self, self.updateViews))
	--背包数据刷新消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))	
end

-- 注销消息
function DlgBuffs:unregMsgs(  )
	-- body
	--buff数据刷新
	unregMsg(self, gud_buff_update_msg)	
	--注销背包数据刷新消息
	unregMsg(self, gud_refresh_baginfo)	
end

--暂停方法
function DlgBuffs:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgBuffs:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end
return DlgBuffs