-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-7 15:41:23 星期三
-- Description: 将军任免对话框
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local GeneralRenmianLayer = require("app.layer.country.GeneralRenmianLayer")


local DlgGeneralRenmian = class("DlgGeneralRenmian", function()
	-- body
	return DlgBase.new(e_dlg_index.dlggeneralrenmian)
end)

function DlgGeneralRenmian:ctor(  )
	-- body
	self:myInit()
	--设置标题
	self:setTitle(getConvertedStr(6,10341))	
	--self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgGeneralRenmian",handler(self, self.onDlgGeneralRenmianDestroy))	
end

function DlgGeneralRenmian:myInit(  )
	-- body
	self.tLbTitles = {}
	self.tCurData = nil
end


--初始化控件
function DlgGeneralRenmian:setupViews(  )
	-- body	
	--设置标题
	self:setTitle(getConvertedStr(6,10341))

	self.pLayContent = MUI.MLayer.new()
	self.pLayContent:setLayoutSize(640, 1066)
	self:addContentView(self.pLayContent) --加入内容层	
	

	--罢免层 	
	self.pGeneralRecallLayer = GeneralRenmianLayer.new(0)
	local x = (self.pLayContent:getWidth() - self.pGeneralRecallLayer:getWidth())/2
	local y = self.pLayContent:getHeight() - 20 - self.pGeneralRecallLayer:getHeight()
	self.pGeneralRecallLayer:setPosition(x, y)
	self.pLayContent:addView(self.pGeneralRecallLayer, 10)	
	--雇用层
	self.pGeneralAppointLayer = GeneralRenmianLayer.new(1)	
	local y = y - self.pGeneralAppointLayer:getHeight()
	self.pGeneralAppointLayer:setPosition(x, y)
	self.pLayContent:addView(self.pGeneralAppointLayer, 10)

	
    self.pLbTip = MUI.MLabel.new({
    text=getTipsByIndex(20002),
    size=20,
    anchorpoint=cc.p(0.5, 0.5)
    })
    setTextCCColor(self.pLbTip, _cc.pwhite)
    self.pLbTip:setPosition(self.pLayContent:getWidth()/2, y - 20)
    self.pLayContent:addView(self.pLbTip, 10)
	--获取将军候选人数据
    SocketManager:sendMsg("getGeneralCandidate", {})    
end	

--控件刷新
function DlgGeneralRenmian:updateViews(  )
	-- body	
	if not self.pLayContent then
		self.pLayContent = MUI.MLayer.new()
		self.pLayContent:setLayoutSize(640, 1066)
		self:addContentView(self.pLayContent) --加入内容层	
		
		--罢免层 	
		self.pGeneralRecallLayer = GeneralRenmianLayer.new(0)
		local x = (self.pLayContent:getWidth() - self.pGeneralRecallLayer:getWidth())/2
		local y = self.pLayContent:getHeight() - 20 - self.pGeneralRecallLayer:getHeight()
		self.pGeneralRecallLayer:setPosition(x, y)
		self.pLayContent:addView(self.pGeneralRecallLayer, 10)	
		--雇用层
		self.pGeneralAppointLayer = GeneralRenmianLayer.new(1)	
		local y = y - self.pGeneralAppointLayer:getHeight()
		self.pGeneralAppointLayer:setPosition(x, y)
		self.pLayContent:addView(self.pGeneralAppointLayer, 10)

		
	    self.pLbTip = MUI.MLabel.new({
	    text=getTipsByIndex(20002),
	    size=20,
	    anchorpoint=cc.p(0.5, 0.5)
	    })
	    setTextCCColor(self.pLbTip, _cc.pwhite)
	    self.pLbTip:setPosition(self.pLayContent:getWidth()/2, y - 20)
	    self.pLayContent:addView(self.pLbTip, 10)    
		--获取将军候选人数据
	    SocketManager:sendMsg("getGeneralCandidate", {}) 	
	end
	--设置将军数据	
	self.pGeneralRecallLayer:setCurData(Player:getCountryData():getGeneralsData())
	--设置将军候选人数据
	self.pGeneralAppointLayer:setCurData(Player:getCountryData():getGeneralCandidate())	
end

--析构方法
function DlgGeneralRenmian:onDlgGeneralRenmianDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgGeneralRenmian:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_generalrenmian_msg, handler(self, self.updateViews))	
	
end
--注销消息
function DlgGeneralRenmian:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_generalrenmian_msg)
end

--暂停方法
function DlgGeneralRenmian:onPause( )
	-- body		
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgGeneralRenmian:onResume( _bReshow )
	-- body		
	if _bReshow then
		--获取将军候选人数据
	    SocketManager:sendMsg("getGeneralCandidate", {}) 	
	end
	self:updateViews()
	self:regMsgs()
end
return DlgGeneralRenmian