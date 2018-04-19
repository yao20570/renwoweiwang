----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-03-29
-- Description: 国家互助item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
					
local ItemCountryHelp = class("ItemCountryHelp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCountryHelp:ctor( )
	-- body
	self:myInit()
	self:onResume()
	parseView("item_country_help", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemCountryHelp:onParseViewCallback( pView )
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	--注册析构方法
	self:setDestroyHandler("ItemCountryHelp",handler(self, self.onDestroy))

end
--初始化成员变量
function ItemCountryHelp:myInit(  )

end

function ItemCountryHelp:regMsgs(  )
	regMsg(self, gud_refresh_country_tnoly, handler(self, self.updateViews))
	
end

function ItemCountryHelp:unregMsgs(  )
	unregMsg(self, gud_refresh_country_tnoly)
end

function ItemCountryHelp:onResume(  )
	self:regMsgs()
end

function ItemCountryHelp:onPause(  )
	self:unregMsgs()
end

function ItemCountryHelp:setupViews(  )
	self.pLyIcon = self:findViewByName("lay_icon") --头像层
	self.pLbName = self:findViewByName("lb_name") -- 名字
	self.pLbLv = self:findViewByName("lb_lv")  --玩家等级
	self.pLbDesc = self:findViewByName("lb_decs")  --玩家等级
	setTextCCColor(self.pLbName, _cc.gjblue)
	setTextCCColor(self.pLbLv, _cc.gjblue)
	setTextCCColor(self.pLbDesc, _cc.pwhite)

	self.pLbTips = self:findViewByName("lb_tips")
	self.pLbTips:setString(getConvertedStr(1,10411))
	setTextCCColor(self.pLbTips, _cc.pwhite)

	self.pLbTimes = self:findViewByName("lb_times")
	setTextCCColor(self.pLbTimes, _cc.pwhite)

	self.pLyBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLyBtn ,TypeCommonBtn.M_BLUE,getConvertedStr(1,10412))
	self.pBtn:onCommonBtnClicked(handler(self, self.onHelp))
end

--析构方法
function ItemCountryHelp:onDestroy( )
	-- body
	self:onPause()
end

function ItemCountryHelp:updateViews(  )
	if not self.tData then
		return
	end
	self.pLbName:setString(self.tData:getName())
	self.pLbLv:setString("Lv."..self.tData:getLv())
	--说明
	self.pLbDesc:setString(self.tData:getDes())
	--数量
	self.pLbTimes:setString()

	-- getHelpNum
	local nHelpNum = self.tData:getHelpNum()
	local nHelpNumMax = self.tData:getHelpNumMax()
	if nHelpNum < tonumber(nHelpNumMax) then
		self.pLbTimes:setString(string.format(getConvertedStr(1,10415),nHelpNum).."/"..nHelpNumMax)
	else
		self.pLbTimes:setString(nHelpNum.."/"..nHelpNumMax)
	end

	local data = self:getActorVo()
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLyIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.L)
		self.pIcon:setIconIsCanTouched(false)
		--self.pIcon:setIconClickedCallBack(handler(self, self.onIconClicked))
	else
		self.pIcon:setCurData(data)
	end


	--已经帮助过和已经帮助满的屏蔽按钮
	if self.tData:isHelp() or self.tData:isHelpFull() then
		self.pBtn:setVisible(false)
	else
		self.pBtn:setVisible(true)
	end
end
 
function ItemCountryHelp:onHelp( )
	local nHelpId = self.tData:getHelpId()
	if nHelpId then
		print()
		SocketManager:sendMsg("countryhelp", {1,nHelpId})
	else
		print("no nHelpId!")
	end
end 

--_state 0-未完成，1-完成未领取，2-完成已领取
function ItemCountryHelp:setCurData( _tData )
	self.tData = _tData
	-- dump(self.tData,"ItemCountryHelp self.tData  =>")
	self:updateViews()
end


--头像
function ItemCountryHelp:getActorVo( ... )
	-- body
	if not self.pAvator then 	
 		self.pAvator = ActorVo.new() 		
 	end
 	local tAo = self.tData:getAo()
 	self.pAvator:initData(tAo.i, tAo.b, nil)
	return self.pAvator
end

return ItemCountryHelp


