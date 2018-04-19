-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-22 09:52:29
-- Description: 活动模板b入口
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemActModleB = require("app.layer.activityb.ItemActModleB")



local DlgActivityModleB = class("DlgActivityModleB", function()
	return DlgBase.new(e_dlg_index.actmodelb)
end)

function DlgActivityModleB:ctor(  )
	-- body
	self:myInit()
	
	parseView("dlg_activity_modleb_entrance", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function DlgActivityModleB:myInit()
	-- body
end

--刷新数据 
--nListLongFw 活动未刷新前列表个数
--nListLongBh 活动刷新列表后个数
function DlgActivityModleB:refreshData()
	-- body
	local nListLongFw = 0
	local nListLongBh = 0
	if self.tActData then
		nListLongFw = table.nums(self.tActData)
	end

	self.tActData = Player:getActModleList(2) --活动列表数据
	-- if tTGiftData then
	-- 	local tActData = {
	-- 		nId = e_id_activity.mothcard,
	-- 		sName = getConvertedStr(3, 10576),
	-- 		bIsEnter = true,
	-- 	}
	-- 	table.insert(self.tActData, tActData)
	-- end

	if self.tActData then
		nListLongBh =  table.nums(self.tActData)
	end

	return nListLongFw,nListLongBh
end

--解析布局回调事件
function DlgActivityModleB:onParseViewCallback( pView )
	-- body
	self:setTitle(getConvertedStr(5, 10201))
	self.pView = pView
	self:addContentView(pView) --加入内容层
	--注册析构方法
	self:setDestroyHandler("DlgActivityModleB",handler(self, self.onDestroy))

	self:onResume()

end


-- 每帧回调 _index 下标 _pView 视图
function DlgActivityModleB:onEveryCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tActData[_index] then
			pView = ItemActModleB.new()
			pView:setHandler(handler(self, self.clickItem))
		end
	end

	if _index and self.tActData[_index] then
		pView:setCurData(self.tActData[_index])	
	end

	return pView
end

--点击引导item回调
function DlgActivityModleB:clickItem(_pData)
	if _pData then
		local nType = 0

		if _pData.nId == e_id_activity.growthfound then --成长基金
			nType = e_dlg_index.dlggrowfound
		elseif _pData.nId == e_id_activity.firstrecharge then --首冲
			nType = e_dlg_index.dlgfirstrecharge
		elseif _pData.nId == e_id_activity.heromansion then -- 登坛拜将
			nType = e_dlg_index.heromansion
		elseif _pData.nId == e_id_activity.updateplace then --王宫升级
			nType = e_dlg_index.updateplace			
		elseif _pData.nId == e_id_activity.peoplerebate then --全民返利
			nType = e_dlg_index.peoplerebate
		-- elseif _pData.nId == e_id_activity.specialsale then --特价卖场
			-- nType = e_dlg_index.dlgspecialsale
		elseif _pData.nId == e_id_activity.snatchturn then --夺宝转盘
			nType = e_dlg_index.snatchturn
		elseif _pData.nId == e_id_activity.acttreasureshop then --珍宝阁
			nType = e_dlg_index.treasureshop
		elseif _pData.nId == e_id_activity.freebenefits then --免费福利
			nType = e_dlg_index.dlgfreebenefits
		elseif _pData.nId == e_id_activity.farmtroopsplan then --屯田计划
			nType = e_dlg_index.dlgfarmtroopsplan
		elseif _pData.nId == e_id_activity.blessworld then --福泽天下
			nType = e_dlg_index.dlgblessworld
		elseif _pData.nId == e_id_activity.consumeiron then --耗铁有礼
			nType = e_dlg_index.consumeiron
		elseif _pData.nId == e_id_activity.dayloginaward then --每日收贡
			nType = e_dlg_index.dlgactloginaward
		elseif _pData.nId == e_id_activity.wuwang then --武王讨伐
			nType = e_dlg_index.wuwang
		elseif _pData.nId == e_id_activity.dragontreasure then --寻龙夺宝
			nType = e_dlg_index.dragontreasure
		elseif _pData.nId == e_id_activity.newgrowthfound then --新版成长基金
			nType = e_dlg_index.dlgnewgrowfound
		elseif _pData.nId == e_id_activity.everydaypreference then --每日特惠
			nType = e_dlg_index.everydaypreference
		elseif _pData.nId == e_id_activity.laba then --腊八拉霸
			nType = e_dlg_index.laba
		elseif _pData.nId == e_id_activity.searchbeauty then --寻访美女
			nType = e_dlg_index.searchbeauty
        elseif _pData.nId == e_id_activity.exam then --每日答题
			nType = e_dlg_index.dlgactivityexam
		elseif _pData.nId == e_id_activity.luckystar then --福星高照
			nType = e_dlg_index.luckystar
		elseif _pData.nId == e_id_activity.mothcard then --月卡入口
			nType = e_dlg_index.dlgrecharge
		elseif _pData.nId == e_id_activity.monthweekcard then --月卡周卡入口
			nType = e_dlg_index.monthweekcard
		elseif _pData.nId == e_id_activity.nianattack then --年兽
			nType = e_dlg_index.nianattack
		elseif _pData.nId == e_id_activity.sciencepromote then --科技兴国
			nType = e_dlg_index.sciencepromote
		elseif _pData.nId == e_id_activity.tlboss then --限时Boss
			nType = e_dlg_index.tlboss
		elseif _pData.nId == e_id_activity.mingjie then --限时Boss
			nType = e_dlg_index.mingjie
		elseif _pData.nId == e_id_activity.zhouwangtrial then --纣王试炼
			nType = e_dlg_index.zhouwangtrial				
		elseif _pData.nId == e_id_activity.developgift then --发展礼包
			nType = e_dlg_index.dlgdevelopgift
		elseif _pData.nId == e_id_activity.welcomeback then --王者归来
			nType = e_dlg_index.dlgwelcomeback						
		end

		if nType > 0 then
		    local tObject = {}
		    tObject.nType = nType --dlg类型
		    sendMsg(ghd_show_dlg_by_type,tObject)
		    
		    Player:removeFirstRedNums(_pData)--移除第一次登录红点
		    _pData:setNewLocal() --移除新的标识
		    --刷新列表中的红点
		    if  self.pListView then
		    	self.pListView:notifyDataSetChange(true)
		    end
		end
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgActivityModleB:updateViews()

	local nListLongFw,nListLongBh = self:refreshData()
	--复用层
	if(not self.pLyList) then
		self.pLyList = self.pView:findViewByName("ly_list")
		self.pListView = createNewListView(self.pLyList)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:setItemCount(nListLongBh)
		self.pListView:reload(true)
	else
		self.pListView:setItemCount(nListLongBh)
		self.pListView:notifyDataSetChange(true)
	end
end


-- 析构方法
function DlgActivityModleB:onDestroy(  )
	-- body
	self:onPause()

	--更新本地进入信息
	-- Player:flushActivityNew()
end

-- 注册消息
function DlgActivityModleB:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function DlgActivityModleB:unregMsgs()
	unregMsg(self, gud_refresh_activity)
end


--暂停方法
function DlgActivityModleB:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgActivityModleB:onResume( _bReshow )
	-- body
	if(_bReshow and self.pListView) then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
	
end

return DlgActivityModleB