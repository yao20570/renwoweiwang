-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-9 11:31:23 星期四
-- Description: 头像设置
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local LayIconView = require("app.layer.playerinfo.LayIconView")
local LayBoxView = require("app.layer.playerinfo.LayBoxView")
local LayTitleView = require("app.layer.playerinfo.LayTitleView")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local DlgIconSetting = class("DlgIconSetting", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgiconsetting)
end)

function DlgIconSetting:ctor( _nPage )
	-- body
	self:myInit(_nPage)
	parseView("dlg_icon_setting", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgIconSetting:myInit( _nPage )
	-- body
	self.nCurIconSelectId = nil
	self.nCurBoxSelectId = nil

	self.nCurIndex = _nPage or 1
	-- self.pIconView = nil
	-- self.pBoxView = nil
	-- self.pTitleView = nil
	self.tViewTab = {}
end

--解析布局回调事件
function DlgIconSetting:onParseViewCallback( pView )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10593))
	self:addContentView(pView) --加入内容层
	--注册析构方法
	self:setDestroyHandler("DlgIconSetting",handler(self, self.onDestroy))
    self:setupViews()
	self:onResume()
end

function DlgIconSetting:setupViews()
	-- body
	self.pRootLayer = self:findViewByName("lay_root")
    local tTitles = {
        getConvertedStr(1, 10067),
        getConvertedStr(6, 10648),
        getConvertedStr(6, 10751),
    }
	self.pTabHost = FCommonTabHost.new(self.pRootLayer,1,1,tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pRootLayer:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pRootLayer:addView(self.pTabHost,10)
	self.pTabMgr = self.pTabHost.pTabManager
	self.pTabMgr:setImgBag("#v1_btn_selected_biaoqian.png", "#v1_btn_biaoqian.png")
	self.pTabHost:setDefaultIndex(self.nCurIndex)
	self.tTabItems = self.pTabHost:getTabItems()
  	
end

function DlgIconSetting:setDlgPage( _nPage )
	-- body
	if self.pTabHost then
		self.pTabHost:setDefaultIndex(_nPage)
	end
end
--
function DlgIconSetting:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = LayIconView.new(tSize)	
		self.tViewTab[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = LayBoxView.new(tSize)
		self.tViewTab[2] = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = LayTitleView.new(tSize)
		self.tViewTab[3] = pLayer
	end
	return pLayer
end

function DlgIconSetting:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.nCurIndex = 1
	elseif _sKey == "tabhost_key_2" then
		self.nCurIndex = 2
	elseif _sKey == "tabhost_key_3" then
		self.nCurIndex = 3
	end
	if self.tViewTab[self.nCurIndex] then
		self.tViewTab[self.nCurIndex]:updateViews()
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgIconSetting:updateViews( )
	-- body
end

-- 析构方法
function DlgIconSetting:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgIconSetting:regMsgs( )
	-- body
end

-- 注销消息
function DlgIconSetting:unregMsgs(  )
	-- body

end


--暂停方法
function DlgIconSetting:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)--停止计时刷新
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgIconSetting:onResume( _bReshow )
	-- body
	-- if _bReshow and self.pListView then
	-- 	-- 如果是重新显示，定位到顶部
	-- 	self.pListView:scrollToBegin()	
	-- end
	self:updateViews(true)
	-- 注册消息
	self:regMsgs()	
end

-- function DlgIconSetting:onBtnClicked(  )
-- 	-- body
-- 	--print("更换")
-- 	--local tActorVo = Player:getPlayerInfo():getActorVo()
-- 	if self.nCurIndex == 1 then
-- 		SocketManager:sendMsg("reqChangeCharacters", {self.nCurIconSelectId, self.nCurIndex}, handler(self, self.onGetFunc)) 
-- 	else
-- 		SocketManager:sendMsg("reqChangeCharacters", {self.nCurBoxSelectId, self.nCurIndex}, handler(self, self.onGetFunc)) 
-- 	end
	
-- end

-- function DlgIconSetting:onIconClickBack( _tData )
-- 	-- body
-- 	if not _tData then
-- 		return
-- 	end
-- 	if self.nCurIconSelectId ~= _tData.sTid then
-- 		if _tData.nCd == 0 then
-- 			local tTips = luaSplit(getTipsByIndex(20061), ";")
-- 			TOAST(tTips[_tData.nSequence])
-- 			return
-- 		end
-- 		self.nCurIconSelectId = _tData.sTid
-- 		--self.pIconListView:notifyDataSetChange(false)
-- 		self:updateItemIcons()
-- 	end
-- end

-- function DlgIconSetting:onBoxClickBack( _tData )
-- 	-- body
-- 	if not _tData then
-- 		return
-- 	end
-- 	if self.nCurBoxSelectId ~= _tData.sTid then
-- 		if _tData.nCd == 0 then
-- 			TOAST(_tData.sTips)
-- 			return
-- 		end
-- 		self.nCurBoxSelectId = _tData.sTid
-- 		--self.pBoxListView:notifyDataSetChange(false)
-- 		self:updateItemBoxs()
-- 		self:refreshPrevView()
-- 	end
-- end

-- function DlgIconSetting:onGetFunc( __msg )
-- 	-- body
-- 	if __msg.head.state == SocketErrorType.success then
-- 		TOAST(getConvertedStr(6, 10596))
-- 	else
-- 		TOAST(SocketManager:getErrorStr(__msg.head.state))		
-- 	end	
-- end
return DlgIconSetting