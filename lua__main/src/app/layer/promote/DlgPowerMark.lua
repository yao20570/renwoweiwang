-----------------------------------------------------
-- author: dengshulan
-- updatetime:  2018-1-16 13:45:55 星期二
-- Description: 战力评分对话框
-----------------------------------------------------
local DlgAlertSmall = require("app.common.dialog.DlgAlertSmall")
local PowerMarkItem = require("app.layer.promote.PowerMarkItem")

local DlgPowerMark = class("DlgPowerMark", function ()
	return DlgAlertSmall.new(e_dlg_index.dlgpowermark)
end)

--战力类型
local e_power_type  = {
	[1]				= {name = getConvertedStr(7, 10305), value = 0, color = _cc.blue},	  --总战力
	[2]				= {name = getConvertedStr(7, 10306), value = 0, color = _cc.pwhite},  --武将战力
	[3]				= {name = getConvertedStr(7, 10307), value = 0, color = _cc.pwhite},  --装备战力
	[4]				= {name = getConvertedStr(7, 10308), value = 0, color = _cc.pwhite},  --科技战力
	[5]				= {name = getConvertedStr(7, 10309), value = 0, color = _cc.pwhite},  --神兵战力
	[6]				= {name = getConvertedStr(7, 10310), value = 0, color = _cc.pwhite},  --爵位战力
}

--构造
--_bFromShare:是否从聊天分享弹过来的
function DlgPowerMark:ctor(_playerId, _sName, _nLv, _bFromShare)
	-- body
	
	--从聊天分享弹过来的不需要分享按钮
	if _bFromShare then
		self.bNeedShare = false
	else
		--如果是自己需要分享按钮
		if _playerId == tonumber(Player:getPlayerInfo().pid) then
			self.bNeedShare = true
		else
			self.bNeedShare = false
		end
	end
	self.nPlayerId = _playerId
	self.sPlayerName = _sName
	self.nPlayerLv = _nLv
	self.tData = nil
	parseView("dlg_power_mark", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgPowerMark:onParseViewCallback( pView )
	-- body
	if self.bNeedShare then
		self:addContentView(pView)
	else
		self:addContentView(pView, false)
	end
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgPowerMark",handler(self, self.onDestroy))
end

--初始化控件
function DlgPowerMark:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10304))

	--玩家昵称和等级
	self.pLbNameLv = self:findViewByName("lb_player_name")
	local str = ""

	--有分享按钮说明是玩家自己
	if self.bNeedShare then
		self.pBtnShare = self:getOnlyConfirmButton(TypeCommonBtn.M_BLUE, getConvertedStr(7, 10069))
		self:setRightHandler(handler(self, self.onShareClicked))
		str = string.format(getConvertedStr(7, 10311), Player:getPlayerInfo().sName, Player:getPlayerInfo().nLv)
	else
		str = string.format(getConvertedStr(7, 10311), self.sPlayerName, self.nPlayerLv)
	end
	self.pLbNameLv:setString(str)

	self.pLayList = self:findViewByName("lay_list")
	self.pListView = createNewListView(self.pLayList,MUI.MScrollView.DIRECTION_VERTICAL,nil,nil, 0, 0)
	self.pListView:setBounceable(false)
	self.pListView:setItemCount(table.nums(e_power_type))
	self.pListView:setItemCallback(function ( _index, _pView ) 
	 	local pTempView = _pView
	    if pTempView == nil then
	        pTempView = PowerMarkItem.new(_index)                        
	        pTempView:setViewTouched(false)   
	    end   
	    pTempView:setItemData(e_power_type[_index]) 	
	    return pTempView	
	end)

end

-- 修改控件内容或者是刷新控件数据
function DlgPowerMark:updateViews()
	-- body
	if self.tData == nil then
		return
	end
	local nTotalPower = self.tData.t or 0
	local nHeroPower = self.tData.h or 0
	local nEquipPower = self.tData.e or 0
	local nSiencePower = self.tData.s or 0
	local nAfPower = self.tData.a or 0
	local nJueweiPower = self.tData.b or 0
	for k, v in pairs(e_power_type) do
		if k == 1 then
			v.value = nTotalPower 	--总评分
		elseif k == 2 then
			v.value = nHeroPower 	--武将评分
		elseif k == 3 then
			v.value = nEquipPower   --装备评分
		elseif k == 4 then
			v.value = nSiencePower  --科技评分
		elseif k == 5 then
			v.value = nAfPower      --神兵评分
		elseif k == 6 then
			v.value = nJueweiPower  --爵位评分
		end
	end
	if self.pListView then
		self.pListView:notifyDataSetChange(false)	
	end
end

function DlgPowerMark:setCurData( _tData )
	-- body
	self.tData = _tData
	self:updateViews()
end

--分享点击按钮
function DlgPowerMark:onShareClicked(  )
	-- body
	openShare(self.pBtnShare, e_share_id.powermark, {self.nPlayerId})
end


--析构方法
function DlgPowerMark:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgPowerMark:regMsgs( )
	-- body
end

-- 注销消息
function DlgPowerMark:unregMsgs(  )
	-- body
end


--暂停方法
function DlgPowerMark:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function DlgPowerMark:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end



return DlgPowerMark
