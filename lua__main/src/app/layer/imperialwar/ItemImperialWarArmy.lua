----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 14:50:00
-- Description: 战场内部武将 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemImperialWarArmy = class("ItemImperialWarArmy", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemImperialWarArmy:ctor(  )
	--解析文件
	parseView("item_imperial_war_army", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemImperialWarArmy:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemImperialWarArmy", handler(self, self.onItemImperialWarArmyDestroy))
end

-- 析构方法
function ItemImperialWarArmy:onItemImperialWarArmyDestroy(  )
    self:onPause()
end

function ItemImperialWarArmy:regMsgs(  )
end

function ItemImperialWarArmy:unregMsgs(  )
end

function ItemImperialWarArmy:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemImperialWarArmy:onPause(  )
	self:unregMsgs()
end

function ItemImperialWarArmy:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtTroops = self:findViewByName("txt_troops")
	self.pImgFlag = self:findViewByName("img_flag")
end

function ItemImperialWarArmy:updateViews(  )
	if not self.tData then
		return
	end
	--头像框
	local tActorVo = nil
	local nNpcId = self.tData:getNpcId()
	if nNpcId then
		tActorVo = npcIdParsetActorVo(nNpcId)
	else
		local ActorVo = require("app.layer.playerinfo.ActorVo")
		tActorVo = ActorVo.new()
		tActorVo:initData(self.tData:getHeadIcon(), self.tData:getHeadBorder(), nil)
	end
	if not self.pHeadIcon then
		self.pHeadIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, tActorVo, TypeIconHeroSize.M)			
	else
		self.pHeadIcon:setCurData(tActorVo)
	end
	local sImg = WorldFunc.getCountryFlagImg(self.tData:getCountry())
	self.pImgFlag:setCurrentImage(sImg)
	-- self.pHeadIcon:addCountryFlag(self.tData:getCountry())

	--名加+等级
	self.pTxtName:setString(self.tData:getName() .. getLvString(self.tData:getLv()))

	--兵力
	self.pTxtTroops:setString(getConvertedStr(3, 10183) ..getSpaceStr(1).. self.tData:getTroops())	
end

--tData: ArmyVO
function ItemImperialWarArmy:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemImperialWarArmy


