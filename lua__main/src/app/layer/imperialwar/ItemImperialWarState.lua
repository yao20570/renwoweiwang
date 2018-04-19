----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 14:50:00
-- Description: 战况内部 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemImperialWarState = class("ItemImperialWarState", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemImperialWarState:ctor(  )
	--解析文件
	parseView("item_imperial_war_state", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemImperialWarState:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemImperialWarState", handler(self, self.onItemImperialWarStateDestroy))
end

-- 析构方法
function ItemImperialWarState:onItemImperialWarStateDestroy(  )
    self:onPause()
end

function ItemImperialWarState:regMsgs(  )
end

function ItemImperialWarState:unregMsgs(  )
end

function ItemImperialWarState:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemImperialWarState:onPause(  )
	self:unregMsgs()
end

function ItemImperialWarState:setupViews(  )
	--左边
	self.pLayPlayerLeft = self:findViewByName("lay_player_left")
	self.pTxtNameLeft = self:findViewByName("txt_name_left")
	self.pTxtTroopsLeft = self:findViewByName("txt_troops_left")
	self.pTxtKillLeft = self:findViewByName("txt_kill_left")
	self.pTxtScoreLeft = self:findViewByName("txt_score_left")
	self.pImgWinLeft = self:findViewByName("img_win_left")
	self.pImgFlagLeft = self:findViewByName("img_flag_left")


	--右边
	self.pLayPlayerRight = self:findViewByName("lay_player_right")
	self.pTxtNameRight = self:findViewByName("txt_name_right")
	self.pTxtTroopsRight = self:findViewByName("txt_troops_right")
	self.pTxtKillRight = self:findViewByName("txt_kill_right")
	self.pTxtScoreRight = self:findViewByName("txt_score_right")
	self.pImgWinRight = self:findViewByName("img_win_right")
	self.pImgFlagRight = self:findViewByName("img_flag_right")
	--

	self.pImgPlay = self:findViewByName("img_play")
	self.pLayLight = self:findViewByName("lay_light")
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function ( _pView )
		if not self.tData then
			return
		end
		local tObject = {
		    nType = e_dlg_index.imperwarreport, --dlg类型
		    tReplay = self.tData ,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end)
end

function ItemImperialWarState:updateViews(  )
	if not self.tData then
		return
	end
	
	--攻方信息
	local bIsAtkWin = self.tData:getIsAtkWin()
	self:setFighterVO(self.tData:getAtk(), self.pLayPlayerLeft, self.pTxtNameLeft, self.pTxtTroopsLeft, self.pTxtKillLeft, self.pTxtScoreLeft, self.pImgWinLeft, self.pImgFlagLeft, bIsAtkWin)
	
	--防方信息
	self:setFighterVO(self.tData:getDef(), self.pLayPlayerRight, self.pTxtNameRight, self.pTxtTroopsRight, self.pTxtKillRight, self.pTxtScoreRight, self.pImgWinRight, self.pImgFlagRight, not bIsAtkWin)

	--是我自己就显示
	local bIsMeJoin = false
	local tAtk = self.tData:getAtk()
	if tAtk then
		if tAtk:getIsMe() then
			bIsMeJoin = true
		end
	end
	local tDef = self.tData:getDef()
	if tDef then
		if tDef:getIsMe() then
			bIsMeJoin = true
		end
	end
	self.pLayLight:setVisible(bIsMeJoin)
end

function ItemImperialWarState:setFighterVO( tFighterVO, pLayPlayer, pTxtName, pTxtTroops, pTxtKill, pTxtScore, pImgWin, pImgFlag, bIsWin)
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
	pTxtName:setString(tFighterVO:getName())
	setTextCCColor(pTxtName, _cc.blue)
	--
	pTxtTroops:setString(string.format("<font color='#%s'>%s</font><font color='#%s'>-%s</font>/%s", _cc.pwhite, getConvertedStr(3, 10124), _cc.red, getResourcesStr(tFighterVO:getLoseTroops()), getResourcesStr(tFighterVO:getOriginTroops())))

	pTxtKill:setString(string.format("<font color='#%s'>%s</font><font color='#%s'>%s</font>", _cc.pwhite, getConvertedStr(3, 10226), _cc.blue, getResourcesStr(tFighterVO:getKilled())))

	pTxtScore:setString(string.format("<font color='#%s'>%s</font><font color='#%s'>+%s</font>", _cc.pwhite, getConvertedStr(3, 10494), _cc.green, getResourcesStr(tFighterVO:getMerit())))

	local sImg = nil
	if bIsWin then
		sImg = "#v2_img_shengli_jzhc.png"
		pHeadIcon:setIconToGray(false)
	else
		sImg = "#v2_imgIshibai_jzhc.png"
		pHeadIcon:setIconToGray(true)
	end
	pImgWin:setCurrentImage(sImg)
end

--tData: Replay
function ItemImperialWarState:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemImperialWarState


