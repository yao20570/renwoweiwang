----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 16:18:24
-- Description: 国战面板
-----------------------------------------------------

local DlgUnableTouch = require("app.common.dialog.DlgUnableTouch")
local ItemCountryWar = require("app.layer.world.ItemCountryWar")

local DlgCountryWar = class("DlgCountryWar", function ()
	return DlgUnableTouch.new()
end)

function DlgCountryWar:ctor(  )
	parseView("dlg_country_war", handler(self, self.onParseViewCallback))
end

function DlgCountryWar:onCloseClicked()
	self:closeDlg(false)
end

--解析界面回调
function DlgCountryWar:onParseViewCallback( pView )
	--设置穿透事件
	self:setContentView(pView)
	pView:setViewTouched(false)
	self.eDlgType = e_dlg_index.countrywar
	self:setCallFunc(handler(self, self.onCloseClicked))
	self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)

	--基本设置
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCountryWar",handler(self, self.onDlgCountryWarDestroy))
end

-- 析构方法
function DlgCountryWar:onDlgCountryWarDestroy(  )
    self:onPause()
end

function DlgCountryWar:regMsgs(  )
	regMsg(self, ghd_dlg_country_war_close, handler(self, self.onCloseClicked))
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))
	regMsg(self, ghd_world_country_war_support_used, handler(self, self.onSupportUsed))
end

function DlgCountryWar:unregMsgs(  )
	unregMsg(self, ghd_dlg_country_war_close)
	unregMsg(self, gud_world_dot_change_msg)
	unregMsg(self, ghd_world_country_war_support_used)
end

function DlgCountryWar:onResume(  )
	self:regMsgs()
end

function DlgCountryWar:onPause(  )
	self:unregMsgs()
end

function DlgCountryWar:setupViews(  )
	local pLayContent = self:findViewByName("lay_content")
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayContent:getContentSize().width, pLayContent:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    pLayContent:addView(self.pListView)
    centerInView(pLayContent, self.pListView )
    self.pListView:setItemCount(0)
    --禁止移动
    self.pListView:setScrollTouchEnabled(false)
	self.pListView:setBounceable(false)

	self.pItemCountryWars = {}
end

function DlgCountryWar:updateViews(  )
	
end

--tData:CityWarMsg列表
--tData2:tViewDotMsg数据
function DlgCountryWar:setData( tData, tData2)
	self.tData = tData
	self.tData2 = tData2
	
	--列表数据
	if self.pListView:getItemCount() > 0 then
	    self.pListView:removeAllItems()
	end
    self.pListView:setItemCount(#self.tData)
    self.pListView:setItemCallback(function ( _index, _pView ) 
    	local pItemData = self.tData[_index]
        local pTempView = _pView
        if pTempView == nil then
        	pTempView   = ItemCountryWar.new(tData2)
        	table.insert(self.pItemCountryWars, pTempView)
    	end
    	pTempView:setData(pItemData)
        return pTempView
	end)
	-- 载入所有展示的item
	self.pListView:reload()
end

function DlgCountryWar:onDotChange( sMsgName, pMsgObj )
	if not self.tData2 then
		return nil
	end


	--有保护cd时间就关闭
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nSystemCityId == self.tData2.nSystemCityId then
			if tViewDotMsg:getProtectCd() > 0 then
				self:closeDlg(false)
			end
		end
	end
end

--更新当前列表
function DlgCountryWar:onSupportUsed( sMsgName, pMsgObj )
	local nCityId = pMsgObj
	if nCityId then
		--更新支援次数
		for i=1,#self.tData do
			if self.tData[i].nId == nCityId then
				self.tData[i].nSupport = self.tData[i].nSupport + 1
				break
			end
		end
		--更新显示
		for i=1,#self.pItemCountryWars do
			local pItemCountryWar = self.pItemCountryWars[i]
			if not tolua.isnull(pItemCountryWar) then
				if pItemCountryWar:getCityId() == nCityId then
					pItemCountryWar:updateViews()
				end
			end
		end
	end
end

return DlgCountryWar
