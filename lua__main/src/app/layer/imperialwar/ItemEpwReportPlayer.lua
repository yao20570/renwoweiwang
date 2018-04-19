----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-28 17:38:00
-- Description: 决战阿房宫战报玩家
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemEpwReportPlayer = class("ItemEpwReportPlayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemEpwReportPlayer:ctor(  )
	--解析文件
	parseView("item_epw_report_player", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemEpwReportPlayer:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemEpwReportPlayer", handler(self, self.onItemEpwReportPlayerDestroy))
end

-- 析构方法
function ItemEpwReportPlayer:onItemEpwReportPlayerDestroy(  )
    self:onPause()
end

function ItemEpwReportPlayer:regMsgs(  )
end

function ItemEpwReportPlayer:unregMsgs(  )
end

function ItemEpwReportPlayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemEpwReportPlayer:onPause(  )
	self:unregMsgs()
end

function ItemEpwReportPlayer:setupViews(  )
	--左边
	self.pLayPlayerLeft = self:findViewByName("lay_player_left")
	self.pTxtNameLeft = self:findViewByName("txt_name_left")
	self.pTxtTroopsLeft = self:findViewByName("txt_troops_left")
	self.pTxtLoseTroopsLeft = self:findViewByName("txt_lose_troops_left")
	self.pImgFlagLeft = self:findViewByName("img_flag_left")


	--右边
	self.pLayPlayerRight = self:findViewByName("lay_player_right")
	self.pTxtNameRight = self:findViewByName("txt_name_right")
	self.pTxtTroopsRight = self:findViewByName("txt_troops_right")
	self.pTxtLoseTroopsRight = self:findViewByName("txt_lose_troops_right")
	self.pImgFlagRight = self:findViewByName("img_flag_right")
	--

	self.pImgPlay = self:findViewByName("img_play")
	local pLayBtnReplay = self:findViewByName("lay_btn_replay")
	pLayBtnReplay:setViewTouched(true)
	pLayBtnReplay:setIsPressedNeedScale(false)
	pLayBtnReplay:setIsPressedNeedColor(false)
	pLayBtnReplay:onMViewClicked(function ( _pView )
		if not self.tData then
			return
		end
	    SocketManager:sendMsg("reqMailFightReplay", {self.tData:getFightRid()})
	end)
end

function ItemEpwReportPlayer:updateViews(  )
	if not self.tData then
		return
	end
	
	--攻方信息
	local bIsAtkWin = self.tData:getIsAtkWin()
	self:setFighterVO(self.tData:getAtk(), self.pLayPlayerLeft, self.pTxtNameLeft, self.pTxtTroopsLeft, self.pTxtLoseTroopsLeft, self.pImgFlagLeft, bIsAtkWin)
	
	--防方信息
	self:setFighterVO(self.tData:getDef(), self.pLayPlayerRight, self.pTxtNameRight, self.pTxtTroopsRight, self.pTxtLoseTroopsRight, self.pImgFlagRight, not bIsAtkWin)
end

function ItemEpwReportPlayer:setFighterVO( tFighterVO, pLayPlayer, pTxtName, pTxtTroops, pTxtLoseTroops, pImgFlag, bIsWin)
	if not tFighterVO then
		return
	end

	--头像框
	local ActorVo = require("app.layer.playerinfo.ActorVo")
	local tActorVo = nil
	local nNpcId = tFighterVO:getNpcId()
	if nNpcId then
		tActorVo = groupIdParsetActorVo(nNpcId)
	else
		tActorVo = ActorVo.new()
		tActorVo:initData(tFighterVO:getHeadIcon(), tFighterVO:getHeadBorder(), nil)
	end
	local pHeadIcon = getIconGoodsByType(pLayPlayer, TypeIconHero.NORMAL,type_icongoods_show.header, tActorVo, TypeIconHeroSize.M)			
	local sImg = WorldFunc.getCountryFlagImg(tFighterVO:getCountry())
	pImgFlag:setCurrentImage(sImg)

	--名字+等级
	pTxtName:setString(tFighterVO:getName() .. getLvString(tFighterVO:getLv()))
	--
	pTxtTroops:setString(string.format("<font color='#%s'>%s</font>%s", _cc.pwhite, getConvertedStr(3, 10124),tFighterVO:getOriginTroops()))
	
	pTxtLoseTroops:setString(string.format("<font color='#%s'>%s</font>-%s", _cc.pwhite, getConvertedStr(3, 10124), tFighterVO:getLoseTroops()))

	-- if bIsWin then
	-- 	pHeadIcon:setIconToGray(false)
	-- else
	-- 	pHeadIcon:setIconToGray(true)
	-- end
end

--tData: Replay
function ItemEpwReportPlayer:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemEpwReportPlayer


