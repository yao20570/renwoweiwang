---------------------------------------------
-- Author: dshulan
-- Date: 2017-06-27 20:03:24
-- 成长基金购买对话框
---------------------------------------------

local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgBuyGrowthFound = class("DlgBuyGrowthFound", function ()
	return DlgAlert.new(e_dlg_index.dlgbuygrowthfound)
end)

--构造
function DlgBuyGrowthFound:ctor(_tData)
	-- body
	self:myInit(_tData)
	parseView("lay_buy_founds", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuyGrowthFound:myInit(_tData)
	-- body
	self.tData = _tData
end
  
--解析布局回调事件
function DlgBuyGrowthFound:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgBuyGrowthFound",handler(self, self.onDlgBuyGrowthFoundDestroy))
end

--初始化控件
function DlgBuyGrowthFound:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10079))
	self.pLayRoot = self:findViewByName("default")
	local nNeedCost = self.tData.tCost[1].v
	local nVip = self.tData.nVip
	--设置内容
	self:setRightHandler(function()
		if nNeedCost then
			-- 跳到充值界面
			if Player:getPlayerInfo().nMoney < nNeedCost then
		 		local tObject = {}
			    tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
			    sendMsg(ghd_show_dlg_by_type,tObject)
		 	elseif Player:getPlayerInfo().nVip < nVip then
		 		-- TOAST(getConvertedStr(7, 10094))
		 		self:gotoRecharge()
		 	else
		 		SocketManager:sendMsg("reqBuyGrowFounds", {}, function(__msg)
		 			if __msg.head.state == SocketErrorType.success then
		 				TOAST(getConvertedStr(7, 10135))
		 			else
		 				TOAST(SocketManager:getErrorStr(__msg.head.state))
		 			end
		 		end)          
		 	end
		else
			print("nNeedCost 读取错误")
		end
	    self:closeAlertDlg()
	end)
	--组合文字(是否花费1000黄金购买成长基金，购买后升级)
	local tConTable = {}
	tConTable.tLabel= {
		{getConvertedStr(7, 10035), getC3B(_cc.white)},
		{nNeedCost, getC3B(_cc.yellow)},
		{getConvertedStr(7, 10036), getC3B(_cc.yellow)},
		{getConvertedStr(7, 10091), getC3B(_cc.white)},
	}
	local pCostText1 = createGroupText(tConTable)
	pCostText1:setPosition(cc.p(220, 118))
	pCostText1:setAnchorPoint(cc.p(0.5, 0.5))
	self.pLayRoot:addView(pCostText1)
	--组合文字(可获15倍返利)
	local tConTable = {}
	tConTable.tLabel= {
		{getConvertedStr(7, 10092), getC3B(_cc.white)},
		{getConvertedStr(7, 10093), getC3B(_cc.yellow)},
	}
	local pCostText2 = createGroupText(tConTable)
	pCostText2:setPosition(cc.p(220, 88))
	pCostText2:setAnchorPoint(cc.p(0.5, 0.5))
	self.pLayRoot:addView(pCostText2)
end


--vip等级不足跳转
function DlgBuyGrowthFound:gotoRecharge()
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(7, 10034))
    pDlg:setContent(getConvertedStr(7, 10094))
 	pDlg:setRightHandler(function (  )            
        local tObject = {}
        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
        sendMsg(ghd_show_dlg_by_type,tObject)  
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew) 
end

-- 修改控件内容或者是刷新控件数据
function DlgBuyGrowthFound:updateViews()
	-- body
	
end

--析构方法
function DlgBuyGrowthFound:onDlgBuyGrowthFoundDestroy()
	self:onPause()
end

-- 注册消息
function DlgBuyGrowthFound:regMsgs( )
	-- body
end

-- 注销消息
function DlgBuyGrowthFound:unregMsgs(  )
	-- body
end


--暂停方法
function DlgBuyGrowthFound:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyGrowthFound:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgBuyGrowthFound
