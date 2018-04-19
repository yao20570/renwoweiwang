-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-13 21:37:23 星期二
-- Description: 过关斩将
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local KillHeroFightLayer = require("app.layer.passkillhero.KillHeroFightLayer")
local KillHeroReportLayer = require("app.layer.passkillhero.KillHeroReportLayer")
local KillHeroShopLayer = require("app.layer.passkillhero.KillHeroShopLayer")

local DlgPassKillHero = class("DlgPassKillHero", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgpasskillhero)
end)

function DlgPassKillHero:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_passkillhero", handler(self, self.onParseViewCallback))
end

function DlgPassKillHero:myInit(  )
	-- body
	--默认选择分页下标
	self.nCurIndex 	= 1
	self.tTabItems = {}
	self.nCurKey = nil
	--3个分页层
	self.tItemLays = {}
	self.classes = {KillHeroFightLayer, KillHeroReportLayer, KillHeroShopLayer}
 	self.tTitles = {getConvertedStr(7, 10370), getConvertedStr(7, 10371), getConvertedStr(7, 10372)}
end

--解析布局回调事件
function DlgPassKillHero:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	--设置标题
	self:setTitle(getConvertedStr(7, 10373))
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgPassKillHero",handler(self, self.onDlgRankDestroy))
end

--初始化控件
function DlgPassKillHero:setupViews()
	self.pLyTab   = self:findViewByName("lay_tab")
	self.pTabHost = FCommonTabHost.new(self.pLyTab,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLyTab:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyTab:addView(self.pTabHost,10)

	self.pTabHost:setDefaultIndex(self.nCurIndex)
end

function DlgPassKillHero:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = self.classes[1].new(tSize)	
		self.tItemLays[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = self.classes[2].new(tSize)
		self.tItemLays[2] = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = self.classes[3].new(tSize)
		self.tItemLays[3] = pLayer
	end
	return pLayer
end

function DlgPassKillHero:onTabChanged( _sKey, _nType )
	if self.nCurKey == _sKey then
		return
	end
	self.nCurKey = _sKey
	if _sKey == "tabhost_key_1" then
		self.tItemLays[1]:onReset()
	elseif _sKey == "tabhost_key_2" then
		self.tItemLays[2]:updateViews()
	elseif _sKey == "tabhost_key_3" then
		self.tItemLays[3]:updateViews()
	end
end


--设置默认打开分页
function DlgPassKillHero:setDefOpenIndex(_index)
	self.pTabHost:setDefaultIndex(_index)
end

--控件刷新
function DlgPassKillHero:updateViews( _name, _data )
	for k, v in pairs(self.tItemLays) do
		if k == 1 and _data and v.onReset then
			v:onReset(_data)
		else
			v:updateViews()
		end	
	end
end


--析构方法
function DlgPassKillHero:onDlgRankDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgPassKillHero:regMsgs(  )
	-- body
	--注册过关斩将数据刷新消息
	regMsg(self, gud_refresh_pass_kill_hero_msg, handler(self, self.updateViews))		
end
--注销消息
function DlgPassKillHero:unregMsgs( )
	-- body
	--注销过关斩将数据刷新消息
	unregMsg(self, gud_refresh_pass_kill_hero_msg)
end

--暂停方法
function DlgPassKillHero:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgPassKillHero:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgPassKillHero