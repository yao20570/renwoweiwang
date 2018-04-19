-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-1-18 9:44:23 星期四
-- Description: 竞技场 奖励预览
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ArenaFunc = require("app.layer.arena.ArenaFunc")
local DlgAlert = require("app.common.dialog.DlgAlert")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local ArenaRecordListLayer = require("app.layer.arena.ArenaRecordListLayer")
local DlgArenaBattleRecord = class("DlgArenaBattleRecord", function()
	-- body
	return DlgBase.new(e_dlg_index.arenabattlerecord)
end)

function DlgArenaBattleRecord:ctor(  )
	-- body
	self:myInit()
	parseView("layout_battle_record", handler(self, self.onParseViewCallback))
	
end

function DlgArenaBattleRecord:myInit(  )
	-- body	
	self.pMyRecords = nil
	self.pTops 	= nil
	self.nCurIdx = 0
end

--解析布局回调事件
function DlgArenaBattleRecord:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	--设置标题
	self:setTitle(getConvertedStr(6,10679))
	self:setupView()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgArenaBattleRecord",handler(self, self.onDestroy))
end

function DlgArenaBattleRecord:setupView(  )
	-- body		
	self.LayMain = self:findViewByName("lay_main")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pLbNullTip = self:findViewByName("lb_null_tip")
	self.pLbNullTip:setIgnoreOtherHeight(true)
	centerInView(self.pLbNullTip:getParent(), self.pLbNullTip)
	setTextCCColor(self.pLbNullTip, _cc.pwhite)	
	self.pImg = MUI.MImage.new("#v1_img_biaoqing.png", {scale9=false})
	self.pImg:setVisible(false)
    self.pImg:setIgnoreOtherHeight(true)
	self.pImg:setPosition(self.pLbNullTip:getPositionX(), self.pLbNullTip:getPositionY() + self.pLbNullTip:getHeight()/2 + self.pImg:getHeight()/2 + 20)	
	self.pLbNullTip:getParent():addView(self.pImg)				

	self.pLayTab = self:findViewByName("lay_tab")
	local tTitles = {getConvertedStr(6, 10697), getConvertedStr(6, 10698)}
	self.pTabHost = FCommonTabHost.new(self.pLayTab,1,1,tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLayTab:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLayTab:addView(self.pTabHost, 10)
	self.pTabItems =  self.pTabHost:getTabItems()
	self.pTabHost:setDefaultIndex(1)	

	self.tTabItems = self.pTabHost:getTabItems()

	self.pReportBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.L_BLUE,getConvertedStr(1, 10196), false)	
	self.pReportBtn:onCommonBtnClicked(handler(self, self.onReadAllBtnClicked))	
end


function DlgArenaBattleRecord:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then --我的战报
		pLayer = ArenaRecordListLayer.new(tSize, 1)
		self.pMyRecords = pLayer	
	elseif (_sKey == _tKeyTabLt[2] ) then--前十大神战报
		pLayer = ArenaRecordListLayer.new(tSize, 2)
		self.pTops 	= pLayer
	end
	return pLayer
end

function DlgArenaBattleRecord:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.nCurIdx = 1
		if self.pMyRecords then
			self.pMyRecords:updateViews()	
		end		
	elseif _sKey == "tabhost_key_2" then
		self.nCurIdx = 2
		self:refreshGodFightData()
		if self.pTops then
			self.pTops:updateViews()
		end
		
	end
end

--控件刷新
function DlgArenaBattleRecord:updateViews(  )
	local pData = Player:getArenaData()	
	if not pData then
		return
	end	
	if self.pMyRecords then
		self.pMyRecords:updateViews()
	end
	if self.pTops then
		self.pTops:updateViews()
	end
	local pTabLayer = self.tTabItems[1]
	if pTabLayer then
		showRedTips(pTabLayer:getRedNumLayer(), 0, pData:getMyFightRed(), 2)			
	end
end

--全部已读按钮回调
function DlgArenaBattleRecord:onReadAllBtnClicked( _pView )
	-- body
	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContent(getConvertedStr(6, 10825))
    pDlg:setRightHandler(function (  )            
 		ArenaFunc.readArenaReport(0, 2, self.nCurIdx)
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew)   
    return pDlg	
end

--获取最新的大神记录
function DlgArenaBattleRecord:refreshGodFightData( ... )
	-- body
	SocketManager:sendMsg("checkArenaRecord", {})
end

--析构方法
function DlgArenaBattleRecord:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgArenaBattleRecord:regMsgs(  )
	-- body
	--注册战斗记录红点
	regMsg(self, ghd_refresh_my_arena_red_msg, handler(self, self.updateViews))		
	regMsg(self, ghd_refresh_god_fight_data_msg, handler(self, self.updateViews))
	regMsg(self, ghd_arena_record_change_msg, handler(self, self.updateViews))
end
--注销消息
function DlgArenaBattleRecord:unregMsgs( )
	-- body
	--注销排行数据刷新新消息
	unregMsg(self, ghd_refresh_my_arena_red_msg)
	unregMsg(self, ghd_refresh_god_fight_data_msg)
	unregMsg(self, ghd_arena_record_change_msg)
end

--暂停方法
function DlgArenaBattleRecord:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgArenaBattleRecord:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end



return DlgArenaBattleRecord