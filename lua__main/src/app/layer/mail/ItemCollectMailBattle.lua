----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:05:13
-- Description: 采集资源 战斗玩家列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")

local ItemCollectMailBattle = class("ItemCollectMailBattle", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCollectMailBattle:ctor(  )
	--解析文件
	parseView("item_collect_mail_battle", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCollectMailBattle:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	pView:setViewTouched(true)
	pView:setIsPressedNeedScale(false)
	pView:setIsPressedNeedColor(false)
	pView:onMViewClicked(handler(self, self.showMailDetail))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCollectMailBattle",handler(self, self.onItemCollectMailBattleDestroy))
end

-- 析构方法
function ItemCollectMailBattle:onItemCollectMailBattleDestroy(  )
    self:onPause()
end

function ItemCollectMailBattle:regMsgs(  )
end

function ItemCollectMailBattle:unregMsgs(  )
end

function ItemCollectMailBattle:onResume(  )
	self:regMsgs()
end

function ItemCollectMailBattle:onPause(  )
	self:unregMsgs()
end

function ItemCollectMailBattle:setupViews(  )
	self.pTxtTime = self:findViewByName("txt_time")

	self.pImgAtkResult = self:findViewByName("img_atk_result")
	self.pTxtAtkCountry = self:findViewByName("txt_atk_country")
	self.pTxtAtkName = self:findViewByName("txt_atk_name")
	setTextCCColor(self.pTxtAtkName, _cc.blue)
	self.pLayAtkIcon = self:findViewByName("lay_atk_icon")
	local pTxtAtkPowerTitle = self:findViewByName("txt_atk_power_title")
	pTxtAtkPowerTitle:setString(getConvertedStr(3, 10224))
	self.pTxtAtkPower = self:findViewByName("txt_atk_power")
	setTextCCColor(self.pTxtAtkPower, _cc.green)
	local pTxtAtkTroopsTitle = self:findViewByName("txt_atk_troops_title")
	pTxtAtkTroopsTitle:setString(getConvertedStr(3, 10124))
	self.pTxtAtkTroops = self:findViewByName("txt_atk_troops")
	local pTxtAtkLoseTitle = self:findViewByName("txt_atk_lose_title")
	pTxtAtkLoseTitle:setString(getConvertedStr(3, 10225))
	self.pTxtAtkLose = self:findViewByName("txt_atk_lose")
	setTextCCColor(self.pTxtAtkLose, _cc.red)

	self.pImgDefResult = self:findViewByName("img_def_result")
	self.pTxtDefCountry = self:findViewByName("txt_def_country")
	self.pTxtDefName = self:findViewByName("txt_def_name")
	setTextCCColor(self.pTxtDefName, _cc.blue)
	self.pLayDefIcon = self:findViewByName("lay_def_icon")
	self.pTxtDefPowerTitle = self:findViewByName("txt_def_power_title")
	self.pTxtDefPowerTitle:setString(getConvertedStr(3, 10224))
	self.pTxtDefPower = self:findViewByName("txt_def_power")
	setTextCCColor(self.pTxtDefPower, _cc.green)
	self.pTxtDefTroopsTitle = self:findViewByName("txt_def_troops_title")
	self.pTxtDefTroopsTitle:setString(getConvertedStr(3, 10124))
	self.pTxtDefTroops = self:findViewByName("txt_def_troops")
	self.pTxtDefLoseTitle = self:findViewByName("txt_def_lose_title")
	self.pTxtDefLoseTitle:setString(getConvertedStr(3, 10225))
	self.pTxtDefLose = self:findViewByName("txt_def_lose")
	setTextCCColor(self.pTxtDefLose, _cc.red)
end

function ItemCollectMailBattle:updateViews(  )
	if not self.tFightDetail then
		return
	end

	self.pTxtTime:setString(formatTime(self.tFightDetail.nTime))

	if self.tFightDetail.bIsWin then
		self.pImgAtkResult:setCurrentImage("#v1_img_sheng_yx.png")
		self.pImgDefResult:setCurrentImage("#v1_img_bai_yx.png")
	else
		self.pImgDefResult:setCurrentImage("#v1_img_sheng_yx.png")
		self.pImgAtkResult:setCurrentImage("#v1_img_bai_yx.png")
	end

	self.pTxtAtkCountry:setString(getCountryShortName(self.tFightDetail.nAtkCountry, true))
	setTextCCColor(self.pTxtAtkCountry, getColorByCountry(self.tFightDetail.nAtkCountry))
	-- if self.tFightDetail.tAtkHeros and #self.tFightDetail.tAtkHeros>0 then 
	-- 	print("hhhhh")
	-- 	self.pTxtAtkName:setString(self.tFightDetail.tAtkHeros[1].sPlayerName)
	-- else
	-- 	print("eeeee")
	-- 	self.pTxtAtkName:setString(self.tFightDetail.sAtkName)
	-- end
	
	self.pTxtAtkName:setString(self.tFightDetail.sAtkName)
	self.pTxtAtkName:setPositionX(self.pTxtAtkCountry:getPositionX()+self.pTxtAtkCountry:getWidth()+10)
	self.pTxtAtkPower:setString("+"..tostring(self.tFightDetail.nAtkLoseTroops))
	self.pTxtAtkTroops:setString(self.tFightDetail.nAtkTroops)
	self.pTxtAtkLose:setString("-"..tostring(self.tFightDetail.nAtkLoseTroops))

	self.pTxtDefCountry:setString(getCountryShortName(self.tFightDetail.nDefCountry, true))
	setTextCCColor(self.pTxtDefCountry, getColorByCountry(self.tFightDetail.nDefCountry))

	-- if self.tFightDetail.tDefHeros and #self.tFightDetail.tDefHeros>0 then 
	-- 	self.pTxtDefName:setString(self.tFightDetail.tDefHeros[1].sPlayerName)
	-- else
	-- 	self.pTxtDefName:setString(self.tFightDetail.sDefName)
	-- end
	self.pTxtDefName:setString(self.tFightDetail.sDefName)
	local layRight=self:findViewByName("lay_right")
	-- self.pTxtDefName:setPositionX(layRight:getWidth()-self.pTxtDefCountry:getPositionX()+self.pTxtDefCountry:getWidth()+10)
	self.pTxtDefCountry:setPositionX(self.pTxtDefName:getPositionX()-self.pTxtDefName:getWidth()-10)

	self.pTxtDefPower:setString("+"..tostring(self.tFightDetail.nDefLoseTroops))
	self.pTxtDefTroops:setString(self.tFightDetail.nDefTroops)
	self.pTxtDefLose:setString("-"..tostring(self.tFightDetail.nDefLoseTroops))

	--调整右边的属性的位置
	self.pTxtDefPowerTitle:setPositionX(self.pTxtDefPower:getPositionX()-self.pTxtDefPower:getWidth())
	self.pTxtDefTroopsTitle:setPositionX(self.pTxtDefTroops:getPositionX()-self.pTxtDefTroops:getWidth())
	self.pTxtDefLoseTitle:setPositionX(self.pTxtDefLose:getPositionX()-self.pTxtDefLose:getWidth())

	self:setIcon()
end

--setData: tFightDetail
function ItemCollectMailBattle:setData( tFightDetail )
	self.tFightDetail = tFightDetail
	self:updateViews()
end

function ItemCollectMailBattle:showMailDetail( )
	if not self.tFightDetail then
		return
	end
	local sAtkName = self.tFightDetail.sAtkName
	if sAtkName ~= Player:getPlayerInfo().sName then
		return
	end

	if not self.tFightDetail.sJumpMail then
		return
	end

	--显示邮件
	local function func( tMailMsg )
		local tObject = {
		    nType = e_dlg_index.maildetail, --dlg类型
		    tMailMsg = tMailMsg,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end

	local tMailMsg =  Player:getMailData():getMailMsg(self.tFightDetail.sJumpMail)
	if tMailMsg then
		func(tMailMsg)
	else
		--请求
		SocketManager:sendMsg("reqMailDetail", {self.tFightDetail.sJumpMail}, function( __msg )
			if  __msg.head.state == SocketErrorType.success then 
	            if __msg.head.type == MsgType.reqMailDetail.id then
	            	if __msg.body then
	            		local tMailMsg = Player:getMailData():createMailMsg(__msg.body)
	            		func(tMailMsg)
	            	end
	            end
	        else
	            TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end
		end)
	end
end

function ItemCollectMailBattle:setIcon( )
	-- body
	--设置图片
	local pActorVo = ActorVo.new()
	pActorVo:initData(self.tFightDetail.sAtkSid, nil, nil)
	local pIconAtk = getIconGoodsByType(self.pLayAtkIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)

	local pActorVoDef=ActorVo.new()
	pActorVoDef:initData(self.tFightDetail.sDefSid,nil,nil)
	local pIconDef = getIconGoodsByType(self.pLayDefIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVoDef, TypeIconHeroSize.M)

end

return ItemCollectMailBattle


