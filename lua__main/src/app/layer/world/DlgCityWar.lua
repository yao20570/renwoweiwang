----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 16:18:24
-- Description: 城战面板
-----------------------------------------------------

local DlgUnableTouch = require("app.common.dialog.DlgUnableTouch")
local ItemCityWar = require("app.layer.world.ItemCityWar")
local DlgCityWar = class("DlgCityWar", function ()
	return DlgUnableTouch.new(e_dlg_index.citywar)
end)

function DlgCityWar:ctor(  )
	parseView("dlg_city_war", handler(self, self.onParseViewCallback))
end

function DlgCityWar:onCloseClicked()
	self:closeDlg(false)
end

--解析界面回调
function DlgCityWar:onParseViewCallback( pView )
	--设置穿透事件
	self:setContentView(pView)
	pView:setViewTouched(false)
	self.eDlgType = e_dlg_index.citywar
	self:setCallFunc(handler(self, self.onCloseClicked))
	self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)

	--基本设置
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityWar",handler(self, self.onDlgCityWarDestroy))
end

-- 析构方法
function DlgCityWar:onDlgCityWarDestroy(  )
    self:onPause()
end

function DlgCityWar:regMsgs(  )
	regMsg(self, ghd_world_city_war_support_used, handler(self, self.onSupportUsed))
	regMsg(self, ghd_ghost_war_support_used, handler(self, self.onGhostSupportUsed))
end

function DlgCityWar:unregMsgs(  )
	unregMsg(self, ghd_world_city_war_support_used)
	unregMsg(self, ghd_ghost_war_support_used)
end

function DlgCityWar:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function DlgCityWar:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgCityWar:setupViews(  )
	local pLayContent = self:findViewByName("lay_content")
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayContent:getContentSize().width, pLayContent:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    pLayContent:addView(self.pListView)
    centerInView(pLayContent, self.pListView )
    self.pItemCityWars = {}
end

function DlgCityWar:updateViews(  )
end

--倒计时函数
function DlgCityWar:updateCd(  )
	local nDelay = 1
	for i=1,#self.pItemCityWars do
		local pItemCityWar = self.pItemCityWars[i]
		pItemCityWar:updateCd()
		--其中一个到达倒计时就关掉
		if pItemCityWar:getCityWarCd() == 0 then
			self:onCloseClicked()
			break
		end
	end
end

--tData:CityWarMsg列表
--tData2:CityClickLayer传送的数据
function DlgCityWar:setData( tData, tData2)
	self.tData = tData
	self.tData2 = tData2

	--列表数据
    self.pListView:setItemCount(#self.tData)
    self.pListView:setItemCallback(function ( _index, _pView ) 
    	local pItemData = self.tData[_index]
        local pTempView = _pView
        if pTempView == nil then
        	pTempView   = ItemCityWar.new(self.tData2, self)
        	table.insert(self.pItemCityWars, pTempView)
    	end
    	pTempView:setData(pItemData)
        return pTempView
	end)
	-- 载入所有展示的item
	self.pListView:reload()
end

--更新当前列表
function DlgCityWar:onSupportUsed( sMsgName, pMsgObj )
	local sWarId = pMsgObj
	if sWarId then

		--更新支援次数
		for i=1,#self.tData do
			if self.tData[i].nType == 1 and self.tData[i].tWarData.sWarId == sWarId then
				self.tData[i].tWarData.nSupport = self.tData[i].tWarData.nSupport + 1
				break
			end
		end
		--更新显示
		for i=1,#self.pItemCityWars do
			local pItemCityWar = self.pItemCityWars[i]
			if not tolua.isnull(pItemCityWar) then
				if pItemCityWar:getWarId() == sWarId then
					pItemCityWar:updateViews()
				end
			end
		end
	end
end

--更新当前列表
function DlgCityWar:onGhostSupportUsed( sMsgName, pMsgObj )
	--更新支援次数
	for i=1,#self.tData do
		if self.tData[i].nType == 2 then
			self.tData[i].tWarData.nSupport = self.tData[i].tWarData.nSupport + 1
			break
		end
	end
	--更新显示
	for i=1,#self.pItemCityWars do
		local pItemCityWar = self.pItemCityWars[i]
		if not tolua.isnull(pItemCityWar) then
			if pItemCityWar:getWarType() == 2 then
				pItemCityWar:updateViews()
			end
		end
	end
end

return DlgCityWar
