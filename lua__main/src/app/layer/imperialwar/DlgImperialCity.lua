----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-14 20:29:00
-- Description: 皇城详情
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local ImperialCityDetail = require("app.layer.imperialwar.ImperialCityDetail")
local ImperialWarState = require("app.layer.imperialwar.ImperialWarState")
local ImperialWarRank = require("app.layer.imperialwar.ImperialWarRank")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")

local DlgImperialCity = class("DlgImperialCity", function()
	return MDialog.new(e_dlg_index.syscitydetail)
end)


function DlgImperialCity:ctor(  )
	parseView("dlg_imperial_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgImperialCity:onParseViewCallback( pView )
	self:setContentView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgImperialCity",handler(self, self.onDlgImperialCityDestroy))
end

-- 析构方法
function DlgImperialCity:onDlgImperialCityDestroy(  )
    self:onPause()
    if b_close_imperialwar then
    else
	    local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	    SocketManager:sendMsg("stopImperWarPush",{2, nSysCityId})
	end
end

function DlgImperialCity:regMsgs(  )
	-- -- 大地图视图移动
	-- regMsg(self, ghd_world_view_pos_msg, handler(self, self.onWorldViewPosMsg))

	-- -- 区域视图点刷新
	-- regMsg(self, gud_world_block_dots_msg, handler(self, self.onWorldBlockDotsMsg))
end

function DlgImperialCity:unregMsgs(  )
	-- unregMsg(self, ghd_world_view_pos_msg)
	-- unregMsg(self, gud_world_block_dots_msg)
end

function DlgImperialCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgImperialCity:onPause(  )
	self:unregMsgs()
end

function DlgImperialCity:setupViews(  )
	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10021))
	local pImgClose = self:findViewByName("img_close")
	--层点击
	pImgClose:setViewTouched(true)
	pImgClose:setIsPressedNeedScale(false)
	pImgClose:setIsPressedNeedColor(true)
	pImgClose:onMViewClicked(function ( _pView )
	    self:closeDlg(false)
	end)

	--内容层
	self.tTitles = {
		getConvertedStr(3, 10900),
		getConvertedStr(3, 10901),
		getConvertedStr(3, 10902),
	}
	self.pLyContent 	  = 		self:findViewByName("lay_content")
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey), 1, {nLeftMarge = 2, nTopTabWidth = 556/3})
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost,10)

	self.pTabHost:setDefaultIndex(1)
end

function DlgImperialCity:updateViews(  )
end


--通过key值获取内容层的layer
function DlgImperialCity:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil
    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = ImperialCityDetail.new(tSize)
		self.pCityDetail = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = ImperialWarState.new()
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = ImperialWarRank.new()
		self.pImperWarRank = pLayer
	end
	return pLayer
end

function DlgImperialCity:onTabChanged( _sKey, _nType )
	if b_close_imperialwar then
	else
	    if _sKey == "tabhost_key_1" then
	    elseif _sKey == "tabhost_key_2" then
	    	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	    	SocketManager:sendMsg("reqImperWarFight", {nSysCityId})
	    elseif _sKey == "tabhost_key_3" then
	    	if self.pImperWarRank then
	    		sendMsg(ghd_clear_rankinfo_msg)
	    		self.pImperWarRank:reqNewData()
	    	end
	    end
	end
end


return DlgImperialCity