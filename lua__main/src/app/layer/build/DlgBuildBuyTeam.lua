-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-28 11:57:24 星期五
-- Description: 购买建筑队列
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemInfo = require("app.module.ItemInfo")

local DlgBuildBuyTeam = class("DlgBuildBuyTeam", function()
	-- body
	return DlgCommon.new(e_dlg_index.buildbuyteam)
end)

function DlgBuildBuyTeam:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_build_buyteam", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuildBuyTeam:myInit(  )
	-- body
	self.tTeamDatas 		= 	{} 		--建筑队伍数据
end

--解析布局回调事件
function DlgBuildBuyTeam:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView) --加入内容层

	self:initDatas()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBuildBuyTeam",handler(self, self.onDlgBuildBuyTeamDestroy))
end

--初始化控件
function DlgBuildBuyTeam:setupViews( )
	-- body
	self:setTitle(getConvertedStr(1, 10116))
	--内容层
	self.pLayContent 	= 		self:findViewByName("default")
	--顶部背景层
	self.pLayTop 		= 		self:findViewByName("lay_tips")

	--提示语
	self.pLbTips 		= 		self:findViewByName("lb_tips")
	setTextCCColor(self.pLbTips,_cc.yellow)
	--小型建筑队
	self.pItemTeamS  	= 		ItemInfo.new(TypeItemInfoSize.M) 
	self.pItemTeamS:setPosition(self.pLayTop:getPositionX(), 
		self.pLayTop:getPositionY() - self.pItemTeamS:getHeight() - 10 )
	self.pLayContent:addView(self.pItemTeamS)
	self.pItemTeamS:setClickCallBack(handler(self, self.onBtnClicked))

	--大型建筑队
	self.pItemTeamL  	= 		ItemInfo.new(TypeItemInfoSize.M) 
	self.pItemTeamL:setPosition(self.pLayTop:getPositionX(), 
		self.pItemTeamS:getPositionY() - self.pItemTeamL:getHeight() - 10 )
	self.pLayContent:addView(self.pItemTeamL)
	self.pItemTeamL:setClickCallBack(handler(self, self.onBtnClicked))


end

-- 修改控件内容或者是刷新控件数据
function DlgBuildBuyTeam:updateViews(  )
	-- body
	if self.tTeamDatas and table.nums(self.tTeamDatas) > 0 then
		--提示语
		local tReturn = luaSplit(getBuildParam("firstReturn"), ",")		
		if Player:getBuildData().nBuyTeamCt == 0 then 			--首次购买
			self.pLbTips:setString(string.format(getConvertedStr(1,10115), tReturn[1]))
		elseif Player:getBuildData().nBuyTeamCt == 1 then 		--第二次购买
			self.pLbTips:setString(string.format(getConvertedStr(1,10168), tReturn[2]))
		else 													--第二次以后
			self.pLbTips:setString(getConvertedStr(1,10169))
		end
		--dump(self.tTeamDatas, "self.tTeamDatas", 100)
		for k, v in pairs (self.tTeamDatas) do
			local nNum = 0
			local pData = Player:getBagInfo():getItemDataById(v.sTid)
			if pData then
				nNum = pData.nCt
			end	
			if v.sTid == e_item_ids.xxjzd then
				self.pItemTeamS:setCurData(v)
			
				if nNum == 0 then
					self.pItemTeamS:changeExToGold()
				else
					self.pItemTeamS:changeExToHad()
				end
				
				local pActionBtn = self.pItemTeamS:getAcionBtn()
				pActionBtn:updateBtnText(getConvertedStr(1, 10117))
			elseif v.sTid == e_item_ids.dxjzd then
				self.pItemTeamL:setCurData(v)

				if nNum == 0 then
					self.pItemTeamL:changeExToGold()
				else
					self.pItemTeamL:changeExToHad()
				end								
				local pActionBtn = self.pItemTeamL:getAcionBtn()
				pActionBtn:updateBtnText(getConvertedStr(1, 10117))
			end
		end
	end
end

-- 析构方法
function DlgBuildBuyTeam:onDlgBuildBuyTeamDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuildBuyTeam:regMsgs( )
	-- body
	--注册刷新背包消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

-- 注销消息
function DlgBuildBuyTeam:unregMsgs(  )
	-- body
	--注销刷新背包消息
	unregMsg(self, gud_refresh_baginfo)		
end


--暂停方法
function DlgBuildBuyTeam:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgBuildBuyTeam:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--初始化数据
function DlgBuildBuyTeam:initDatas(  )
	-- body
	local tTeams = luaSplit(getDisplayParam("queueItem") or "", ";")
	if tTeams and table.nums(tTeams) > 0 then
		for k, v in pairs (tTeams) do
			local pItem = getBaseItemDataByID(tonumber(v))					
			if pItem then
				table.insert(self.tTeamDatas, pItem)
			end
		end
	end
end

--按钮点击回调
function DlgBuildBuyTeam:onBtnClicked( _data )
	-- body
	if _data then
		local nNum = 0
		local pData = Player:getBagInfo():getItemDataById(_data.sTid)
		if pData then
			nNum = pData.nCt
		end			
		local nDay = 1
		if _data.sTid == e_item_ids.xxjzd then
			nDay = 1
		elseif _data.sTid == e_item_ids.dxjzd then
			nDay = 7
		end
		if nNum == 0 then
			local nCost = _data.nPrice
		    local strTips = {
		    	{color=_cc.pwhite,text=getConvertedStr(6, 10095)},--雇用
		    	{color=_cc.pwhite,text=_data.sName},--名字
		    }
		    --展示购买对话框
			showBuyDlg(strTips,nCost,function (  )
				-- body
				--请求协议
				SocketManager:sendMsg("buyBuildTeam", {nDay}, handler(self, self.onBuyTeamResponse))
			end)
		else
			showUseItemDlg(_data.sTid)  
		end

	end

end

--建筑升级队列购买回调
function DlgBuildBuyTeam:onBuyTeamResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.buyBuildTeam.id then 			
		if __msg.head.state == SocketErrorType.success then
			TOAST(getConvertedStr(1, 10161))
			if __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)				
			end
			self:closeCommonDlg()
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end

return DlgBuildBuyTeam