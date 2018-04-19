-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-16 17:28:51 星期六
-- Description: 对战双方头顶上的血条信息层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconHero = require("app.common.iconview.IconHero")

local FightSecBloodLayer = class("FightSecBloodLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function FightSecBloodLayer:ctor( _nDir )
	-- body
	self:myInit()
	self.nDir = _nDir
	parseView("layout_fight_unit_hero", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function FightSecBloodLayer:myInit(  )
	-- body
	self.nDir 				= 		1 		--方向
	self.tHeroInfo 			= 		nil 	--武将数据
	self.nMatrix 			= 		1 		--第几条队列
	self.nAllTrp 			= 		0 		--总血量
	self.nCurTrp 			= 		0 		--当前血量
	self.nHeroPos 			= 		1 		--第几个武将
end

--解析布局回调事件
function FightSecBloodLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FightSecBloodLayer",handler(self, self.onFightSecBloodLayerDestroy))
end

--初始化控件
function FightSecBloodLayer:setupViews( )
	-- body
	self.pBarBlood 			= 			self:findViewByName("bar_blood")
	self.pLbHName 			= 			self:findViewByName("lb_name")
	self.pImgType 			= 			self:findViewByName("img_t")
	self.pLayHIcon 			= 			self:findViewByName("lay_icon")
	self.pLaySkill 			= 			self:findViewByName("la_skill")
	self.pImgSkillName 		= 			self:findViewByName("img_skill_name")

	--设置锚点
	self.pLaySkill:setAnchorPoint(cc.p(0.5, 0.5))
	self.pLaySkill:ignoreAnchorPointForPosition(true)
	self.pLaySkill:setOpacity(0)

	--设置血条样式
	if self.nDir == 1 then --下方
		self.pBarBlood:setBarImage("ui/bar/v1_bar_blue_9.png")
		self.pLaySkill:setBackgroundImage("#sg_skill_mc_dt_01.png")
	elseif self.nDir == 2 then --上方
		self.pBarBlood:setBarImage("ui/bar/v1_bar_yellow_14.png")
		self.pLaySkill:setBackgroundImage("#sg_skill_mc_dt_02.png")
	end
end

function FightSecBloodLayer:setName(_sName)
	if _sName then
		self.pLbHName:setString(_sName)
	end
end

function FightSecBloodLayer:setIconImg(_icon)
	if _icon and self.pIconHero then
		self.pIconHero:setIconImg(_icon)
	end
end

-- 修改控件内容或者是刷新控件数据
function FightSecBloodLayer:updateViews(  )
	-- body
	if self.tHeroInfo and self.nMatrix then
		--设置武将名字 + 第几队
		if self.pLbHName then
			if self._bIsTLBoss or self.nMatrix == 0 then
				self.pLbHName:setString(self.tHeroInfo.sName)
			else
				self.pLbHName:setString(self.tHeroInfo.sName .. " " .. string.format(getConvertedStr(1,10275),"" .. self.nMatrix))
			end
		end
		--设置兵种
		if self.pImgType and self.tHeroInfo then
			if self._bIsTLBoss or self.nMatrix == 0 then
				self.pImgType:setVisible(false)
			else
				self.pImgType:setVisible(true)
				self.pImgType:setCurrentImage(getSoldierTypeImg(self.tHeroInfo.nKind))
			end
		end
		--设置头像
		if self.pLayHIcon then
			if self.pIconHero == nil then
				self.pIconHero = IconHero.new(TypeIconHero.NORMAL)
				self.pLayHIcon:addView(self.pIconHero)
				self.pIconHero:setScale(0.3)
			end
			self.pIconHero:setCurData(self.tHeroInfo)
		end
		--设置当前血量
		self:setbloodMsg()
	end
end

-- 析构方法
function FightSecBloodLayer:onFightSecBloodLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function FightSecBloodLayer:regMsgs( )
	-- body
end

-- 注销消息
function FightSecBloodLayer:unregMsgs(  )
	-- body
end


--暂停方法
function FightSecBloodLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightSecBloodLayer:onResume( )
	-- body
	self:regMsgs()
end

--设置当前数据
--_tHeroInfo：武将数据
--_nMatrix：武将内第几个部队
--_trp：该队伍总血量
--_nHeroPos：武将位置
--_bIsTLBoss: 是否限时Boss
function FightSecBloodLayer:setCurData( _tHeroInfo, _nMatrix, _trp, _nHeroPos, _bIsTLBoss)
	-- body
	self._bIsTLBoss = _bIsTLBoss
	if _tHeroInfo and _nMatrix and _trp and _nHeroPos then
		self.tHeroInfo = _tHeroInfo
		self.nMatrix = _nMatrix
		self.nAllTrp = _trp 
		self.nCurTrp = _trp 
		self.nHeroPos = _nHeroPos

		self:updateViews()
	end
end

--设置血量显示
function FightSecBloodLayer:setbloodMsg()
	-- body
	if self.tHeroInfo then --存在血量层
		--设置血量进度
		self.pBarBlood:setPercent(self.nCurTrp / self.nAllTrp * 100)
	end
end

--更新血量
--_nDropBlood：当前扣除的血量
function FightSecBloodLayer:updateBlood( _nDropBlood )
	-- body
	if _nDropBlood then
		self.nCurTrp = self.nCurTrp - _nDropBlood
		self:setbloodMsg()
	end
end

--获得武将位置
function FightSecBloodLayer:getHeroPos(  )
	-- body
	return self.nHeroPos
end

--展示报招动画
-- _nType：技能类型
function FightSecBloodLayer:callSkillNameAction( _nType )
	-- body
	_nType = _nType or 1
	if _nType == 1 then --横扫千军
		self.pImgSkillName:setCurrentImage("#sg_skill_mc_hsqj_01.png")
	elseif _nType == 2  then --金戈铁马
		self.pImgSkillName:setCurrentImage("#sg_skill_mc_jgtm_01.png")
	elseif _nType == 3  then --万箭齐发
		self.pImgSkillName:setCurrentImage("#sg_skill_mc_wjqf_01.png")
	end

	--初始化位置 缩放值 透明度
	self.pLaySkill:setPosition(0, 50)
	self.pLaySkill:setScale(0.43)
	self.pLaySkill:setOpacity(255)
	self.pLaySkill:setVisible(true)


	--第一阶段
	local ac1 = cc.ScaleTo:create(0.28, 1)
	--第二阶段
	local ac2 = cc.MoveBy:create(0.11, cc.p(0, 3))
	--第三阶段
	local ac3_1 = cc.MoveBy:create(0.44, cc.p(0, 23))
	local ac3_2 = cc.FadeOut:create(0.44)
	local ac3 = cc.Spawn:create(ac3_1,ac3_2)
	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		self.pLaySkill:setVisible(false)
	end)

	--执行动画
	local acs = cc.Sequence:create(ac1, ac2, ac3, actionEnd)
	self.pLaySkill:runAction(acs)

end

return FightSecBloodLayer