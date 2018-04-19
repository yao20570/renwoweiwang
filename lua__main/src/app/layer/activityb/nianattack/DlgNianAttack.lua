----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-1-24 20:02:21
-- Description: 年兽来袭
-----------------------------------------------------
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local DlgBase = require("app.common.dialog.DlgBase")
local NianAttackDetail = require("app.layer.activityb.nianattack.NianAttackDetail")
local NianHurtRank = require("app.layer.activityb.nianattack.NianHurtRank")
local NianRankAward = require("app.layer.activityb.nianattack.NianRankAward")
local DlgNianAttack = class("DlgNianAttack", function()
	return DlgBase.new(e_dlg_index.nianattack)
end)

function DlgNianAttack:ctor(  )
	parseView("dlg_nian_attack", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgNianAttack:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgNianAttack",handler(self, self.onDlgNianAttackDestroy))
end

-- 析构方法
function DlgNianAttack:onDlgNianAttackDestroy(  )
    self:onPause()
end

function DlgNianAttack:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function DlgNianAttack:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function DlgNianAttack:onResume(  )
	self:regMsgs()
	self:updateViews()
	--刷新进程
	regUpdateControl(self, handler(self, self.reqNianHpData))	
end

function DlgNianAttack:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgNianAttack:setupViews(  )
	local tActData = Player:getActById(e_id_activity.nianattack)
	if tActData then
		--标题
		self:setTitle(tActData.sName)
	end
	self.nPrevTime = nil
	--内容层
	self.tTitles = {
		getConvertedStr(3, 10706),
		getConvertedStr(3, 10707),
		getConvertedStr(3, 10708),
	}

	--初始化红点
	self.pLyContent = self:findViewByName("view")
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setTopZoder(1)
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost)
	self.nFirstTabIndex = 1
	self.pTabHost:setDefaultIndex(self.nFirstTabIndex)

	self:reqNianHpData()
end

function DlgNianAttack:updateViews(  )
	local tActData = Player:getActById(e_id_activity.nianattack)
	if not tActData then
		self:closeDlg(false)
		return
	end
end

--通过key值获取内容层的layer
function DlgNianAttack:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil
    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = NianAttackDetail.new(tSize)	
		self.pNianDetail = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = NianHurtRank.new(tSize)
		self.pNianHurtRank = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = NianRankAward.new(tSize)
		self.pNianRankAward = pLayer
	end
	return pLayer
end

function DlgNianAttack:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
	elseif _sKey == "tabhost_key_2" then
		if self.pNianHurtRank then
			self.pNianHurtRank:reqCountryHurtRank()
			self.pNianHurtRank:reqPlayerHurtRank()
		end
	elseif _sKey == "tabhost_key_3" then
		
	end
end

function DlgNianAttack:reqNianHpData(  )
	-- body
	--2秒刷新
	local bNeedReq = false
	if not self.nPrevTime then
		bNeedReq = true
	else
		local nCurTime = getSystemTime(true)
		if nCurTime - self.nPrevTime >= 2 then
			bNeedReq = true
		end 
	end
	if bNeedReq then
		SocketManager:sendMsg("reqNianHp", {}, function (__msg)
		end, -1)
		self.nPrevTime = getSystemTime(true)
	end
end

return DlgNianAttack