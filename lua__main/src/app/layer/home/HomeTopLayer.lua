-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-10 15:40:48 星期一
-- Description: 主界面顶部层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemHomeRes = require("app.layer.home.ItemHomeRes")
local MBtnExText = require("app.common.button.MBtnExText")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local nNumJumpZorder = 99

local HomeTopLayer = class("HomeTopLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function HomeTopLayer:ctor(  )
	-- body
	self:myInit()
	parseView("layout_home_top", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HomeTopLayer:myInit(  )
	-- body
end

--解析布局回调事件
function HomeTopLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeTopLayer",handler(self, self.onHomeTopLayerDestroy))
end

--初始化控件
function HomeTopLayer:setupViews( )
	-- body

	--资源层
	self.pLayTop 				= 		self:findViewByName("lay_res")
	self.pLayTop:setViewTouched(true)
	self.pLayTop:setIsPressedNeedScale(false)
	self.pLayTop:onMViewClicked(handler(self, self.onResClicked))
	--平均宽度
	local nW = self.pLayTop:getWidth() / 4
	--铜币
	self.pItemCoin 				= 		ItemHomeRes.new(1)
	self.pLayTop:addView(self.pItemCoin)
	self.pItemCoin:setPosition(0,5)
	--木头
	self.pItemWood 				= 		ItemHomeRes.new(2)
	self.pLayTop:addView(self.pItemWood)
	self.pItemWood:setPosition(nW,5)
	--粮食
	self.pItemFood 				= 		ItemHomeRes.new(3)
	self.pLayTop:addView(self.pItemFood)
	self.pItemFood:setPosition(nW * 2,5)
	--铁
	self.pItemIron 				= 		ItemHomeRes.new(4)
	self.pLayTop:addView(self.pItemIron)
	self.pItemIron:setPosition(nW * 3,5)
	

	--设置获得物品资源ui
	setShowGetItemResUis(1, self.pItemCoin, self.pItemWood, self.pItemFood, self.pItemIron)

	--vip
	self.pLayVip 				= 		self:findViewByName("lay_vip")
	self.pLayVip:setViewTouched(true)
	self.pLayVip:setIsPressedNeedScale(false)
	self.pLayVip:onMViewClicked(handler(self, self.onVIPClicked))
	self.pLbVip 				= 		self:findViewByName("lb_vip")

	--战力
	self.pLayZl 				= 		self:findViewByName("lay_zl")
	self.pLayZl:setViewTouched(true)
	self.pLayZl:setIsPressedNeedScale(false)
	self.pLayZl:onMViewClicked(handler(self, self.onZLClicked))
	self.pLbZl 					= 		self:findViewByName("lb_zl")
	setTextCCColor(self.pLbZl,_cc.white)
	self.pLayZjmZl 				= 		self:findViewByName("lay_zjm_zl")

	--充值
	self.pLayCz 				= 		self:findViewByName("lay_cz")
	self.pLayCz:setViewTouched(true)
	self.pLayCz:setIsPressedNeedScale(false)
	self.pLayCz:onMViewClicked(handler(self, self.onCZClicked))
	self.pLbCz 					= 		self:findViewByName("lb_cz_v")
	setTextCCColor(self.pLbCz,_cc.white)

	--兵种数量
	self.pLbBB 					= 		self:findViewByName("lb_bb")
	self.pLbGB 					= 		self:findViewByName("lb_gb")
	self.pLbQB 					= 		self:findViewByName("lb_qb")
	setTextCCColor(self.pLbBB,_cc.dblue)
	setTextCCColor(self.pLbGB,_cc.dblue)
	setTextCCColor(self.pLbQB,_cc.dblue)

	--等级
	self.pLbLv 					= 		self:findViewByName("lb_lv") 

	--体力
	self.pImgTl 				= 		self:findViewByName("img_tl")
	self.pLayTl 				= 		self:findViewByName("lay_tili")
	self.pLbTl                  =       self:findViewByName("lb_tl")
	local tBtnTableE = {}
	-- tBtnTableE.parent = self.pLayTl
	-- tBtnTableE.awayH = -30
	--文本
	tBtnTableE.tLabel = {
	 	{0,getC3B(_cc.green)},
	 	{"/",getC3B(_cc.pwhite)},
	 	{0,getC3B(_cc.dblue)}
	}
	tBtnTableE.fontSize = 18
	self.pExTextEnergy = createGroupText(tBtnTableE)
	self.pLayTl:addView(self.pExTextEnergy, 10)
	self.pExTextEnergy:setPosition(self.pLbTl:getPositionX(), self.pLbTl:getPositionY()-12)
	self.pLayTl:setViewTouched(true)
	self.pLayTl:setIsPressedNeedScale(false)
	self.pLayTl:onMViewClicked(handler(self, self.onTLClicked))

	--经验
	self.pLayJy 				= 		self:findViewByName("lay_jy")	
	self.pBarJy      			= 		MCommonProgressBar.new({bar = "v2_bar_green_zjm.png",barWidth = 74, barHeight = 10})
	self.pLayJy:addView(self.pBarJy,100)
	centerInView(self.pLayJy,self.pBarJy)

	--主公信息
	self.pLayZg 				= 		self:findViewByName("lay_toux")
	self.pLayZg:setViewTouched(true)
	self.pLayZg:setIsPressedNeedScale(false)
	self.pLayZg:onMViewClicked(handler(self, self.onZGClicked))

	--国旗
	self.pImgC 					= 		self:findViewByName("img_c")
	self.pImgC:setVisible(false) --znftodo 隐藏

	--主公头像
	self.pLayIcon 				=		self:findViewByName("lay_icon")
end

-- 修改控件内容或者是刷新控件数据
function HomeTopLayer:updateViews(  )
	-- body
	--资源
	self.pItemFood:updateValue()
	self.pItemWood:updateValue()
	self.pItemIron:updateValue()
	self.pItemCoin:updateValue()

	--VIP
	self.pLbVip:setString(Player:getPlayerInfo().nVip)
	--战力
	self.pLbZl:setString(getConvertedStr(1,10279) .. Player:getPlayerInfo().nScore)
	self.pLayZjmZl:setContentSize(cc.size(self.pLbZl:getPositionX() + self.pLbZl:getWidth(),self.pLayZjmZl:getHeight()))
	self.pLayZjmZl:setPositionX((self.pLayZl:getWidth() - self.pLayZjmZl:getWidth()) / 2)
	--充值
	local nHasMoney = Player:getPlayerInfo().nMoney
	self.pLbCz:setString(nHasMoney)
	--兵种数量
	self.pLbBB:setString(getResourcesStr(Player:getPlayerInfo().nInfantry))
	self.pLbGB:setString(getResourcesStr(Player:getPlayerInfo().nArcher))
	self.pLbQB:setString(getResourcesStr(Player:getPlayerInfo().nSowar))

	--显示玩家兵种跳字特效
	-- if self.nPrevInfantry then
	-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nInfantry - self.nPrevInfantry)
	-- 	if pLayArm then
	-- 		local fX, fY = self.pLbBB:getPosition()
	-- 		local pSize = self.pLbBB:getContentSize()
	-- 		self.pLbBB:getParent():addView(pLayArm, nNumJumpZorder)
	-- 		pLayArm:setPosition(fX + pSize.width/2, fY)
	-- 	end
	-- end
	-- self.nPrevInfantry = Player:getPlayerInfo().nInfantry
	-- --显示玩家兵种跳字特效
	-- if self.nPrevArcher then
	-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nArcher - self.nPrevArcher)
	-- 	if pLayArm then
	-- 		local fX, fY = self.pLbGB:getPosition()
	-- 		local pSize = self.pLbGB:getContentSize()
	-- 		self.pLbGB:getParent():addView(pLayArm, nNumJumpZorder)
	-- 		pLayArm:setPosition(fX + pSize.width/2, fY)
	-- 	end
	-- end
	-- self.nPrevArcher = Player:getPlayerInfo().nArcher
	-- --显示玩家兵种跳字特效
	-- if self.nPrevSowar then
	-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nSowar - self.nPrevSowar)
	-- 	if pLayArm then
	-- 		local fX, fY = self.pLbQB:getPosition()
	-- 		local pSize = self.pLbQB:getContentSize()
	-- 		self.pLbQB:getParent():addView(pLayArm, nNumJumpZorder)
	-- 		pLayArm:setPosition(fX + pSize.width/2, fY)
	-- 	end
	-- end
	-- self.nPrevSowar = Player:getPlayerInfo().nSowar

	--体力
	self:setPlayerEnergy()
	--等级经验
	--计算等级进度
	local tLvUp = getAvatarLvUpByLevel(Player:getPlayerInfo().nLv)
	local nPercentLv = math.floor(Player:getPlayerInfo().nExp / tLvUp.exp * 100)
	self.pBarJy:setPercent(nPercentLv)
	--国家
	-- self.pImgC:setCurrentImage(WorldFunc.getCountryFlagImg(Player:getPlayerInfo().nInfluence))
	--头像(临时处理，等有了头像系统，这里需要修改)
	local data = Player:getPlayerInfo():getActorVo()
	local pActorVo2 	 = 			ActorVo.new()
  	pActorVo2:initData(data.sI, nil, nil)
	-- data.nGtype = e_type_goods.type_head --头像
	-- data.nQuality = 100
	-- data.sIcon = Player:getPlayerInfo().sTx
	-- data.nLv = Player:getPlayerInfo().nLv
	local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.header, pActorVo2, 0.7)
	pIconHero:setIconIsCanTouched(false)

	--等级
	self.pLbLv:setString(Player:getPlayerInfo().nLv)

end

-- 析构方法
function HomeTopLayer:onHomeTopLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function HomeTopLayer:regMsgs( )
	-- body
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.setPlayerEnergy))
end

-- 注销消息
function HomeTopLayer:unregMsgs(  )
	-- body
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 销毁玩家能量刷新消息
	unregMsg(self, ghd_refresh_energy_msg)
end


--暂停方法
function HomeTopLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function HomeTopLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置玩家能量
function HomeTopLayer:setPlayerEnergy(  )
	--获得体力上限值
	local nEnergyMax = tonumber(getGlobleParam("initEnergy") or 100)
	self.pExTextEnergy:setLabelCnCr(1,Player:getPlayerInfo().nEnergy)
	self.pExTextEnergy:setLabelCnCr(3,nEnergyMax)
	-- self.pExTextEnergy:setPositionX(self.pImgTl:getPositionX() + 23)

	-- --显示玩家能量跳字特效
	-- if self.nPrevEnergy then
	-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nEnergy - self.nPrevEnergy)
	-- 	if pLayArm then
	-- 		local fX, fY = self.pLayTl:getPosition()
	-- 		local pSize = self.pLayTl:getContentSize()
	-- 		self.pLayTl:getParent():addView(pLayArm, nNumJumpZorder)
	-- 		pLayArm:setPosition(fX + pSize.width/2, fY + pSize.height/2)
	-- 	end
	-- end
	-- self.nPrevEnergy = Player:getPlayerInfo().nEnergy
end

--资源点击事件(跳转到仓库)
function HomeTopLayer:onResClicked( pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.warehouse --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--Vip点击事件
function HomeTopLayer:onVIPClicked( pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgvipprivileges --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

--战力点击事件
function HomeTopLayer:onZLClicked( pView )
	-- body
	if not b_open_ios_shenpi then
		local tObject = {}
		tObject.nType = e_dlg_index.fcpromote --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)	
	end
end

--充值点击事件
function HomeTopLayer:onCZClicked( pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)   
	-- gDumpTextureInfo()
-- gDumpLuaInfo()

	-- showReconnectDlg(e_disnet_type.cli, true)
end

--主公信息点击事件
function HomeTopLayer:onZGClicked( pView )
	-- body
	--角色
	local tObject = {}
	tObject.nType = e_dlg_index.playerinfo --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--体力点击事件
function HomeTopLayer:onTLClicked()
	-- body
	
	openDlgBuyEnergy()
end

return HomeTopLayer