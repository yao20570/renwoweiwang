----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-14 20:42:00
-- Description: 皇城详情
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ImperialCityNew = require("app.layer.imperialwar.ImperialCityNew")
local ImperialCityTruce = require("app.layer.imperialwar.ImperialCityTruce")
local ImperialCityDetail = class("ImperialCityDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ImperialCityDetail:ctor( _tSize )
	local pView = MUI.MLayer.new()
	pView:setContentSize(_tSize)
	self:onParseViewCallback(pView)
end

--解析界面回调
function ImperialCityDetail:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self.pView = pView

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ImperialCityDetail", handler(self, self.onImperialCityDetailDestroy))
end

-- 析构方法
function ImperialCityDetail:onImperialCityDetailDestroy(  )
    self:onPause()
end

function ImperialCityDetail:regMsgs(  )
	regMsg(self, ghd_imperialwar_open_state, handler(self, self.onOpenStateChange))
end

function ImperialCityDetail:unregMsgs(  )
	unregMsg(self, ghd_imperialwar_open_state)
end

function ImperialCityDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
	regUpdateControl(self, handler(self, self.updateCd))
end

function ImperialCityDetail:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function ImperialCityDetail:setupViews(  )
end

function ImperialCityDetail:updateViews(  )	
	--1.判断是否休战期是就显示休战期画面，或者执行下面或者到达时间执行下面
	if Player:getImperWarData():getImperWarIsOpen() then
		if self.pCityTruce then
			self.pCityTruce:setVisible(false)
		end
		if self.pCity then
			self.pCity:setVisible(true)
			self.pCity:updateViews()
		else
			self.pCity = ImperialCityNew.new()
			self.pView:addView(self.pCity)
		end
	else
		if self.pCity then
			self.pCity:setVisible(false)
		end
		if self.pCityTruce then
			self.pCityTruce:setVisible(true)
			self.pCityTruce:updateViews()
		else
			self.pCityTruce = ImperialCityTruce.new()
			self.pView:addView(self.pCityTruce)
		end
	end
end

function ImperialCityDetail:updateCd( )
	--活动期更新时间
	if self.pCity and self.pCity:isVisible() then
		self.pCity:updateCd()
	end
	--休闲期更新时间
	if self.pCityTruce and self.pCityTruce:isVisible() then
		self.pCityTruce:updateCd()
	end
end

function ImperialCityDetail:onOpenStateChange( )
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	if not nSysCityId then
		return
	end
	SocketManager:sendMsg("reqImperBattlefield", {nSysCityId},function (__msg)
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.reqImperBattlefield.id then
				local ImperialWarVo = require("app.layer.imperialwar.data.ImperialWarVo")
				local tImperialWarVo2 = ImperialWarVo.new(__msg.body)
				--设置当前打开的界面主要数据
				Player:getImperWarData():setCurrImperWarData(nSysCityId, tImperialWarVo2)
				--更新面板
				if self.updateViews then
					--更新界面
					self:updateViews()
				end
			end
		else
	        TOAST(SocketManager:getErrorStr(__msg.head.state))
	    end
	end)
end

return ImperialCityDetail
