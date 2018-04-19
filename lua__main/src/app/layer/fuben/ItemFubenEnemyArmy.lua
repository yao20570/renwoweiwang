-- Author: liangzhaowei
-- Date: 2017-04-28 10:23:49
-- 敌人部队信息

local MCommonView = require("app.common.MCommonView")
local ItemFubenEnemyArmy = class("ItemFubenEnemyArmy", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index
function ItemFubenEnemyArmy:ctor(_index,_tData,_armyType)
	-- body
	self:myInit()

	self.nIndex = _index or self.nIndex

	self.tData =  _tData  -- 敌人数据
	self.nArmyType = _armyType -- 部队类型

	parseView("item_fuben_army_enemy", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemFubenEnemyArmy",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenEnemyArmy:myInit()
	-- body
	self.nIndex = 1

	self.tData = {} -- 敌人数据


end

--解析布局回调事件
function ItemFubenEnemyArmy:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemFubenEnemyArmy:setupViews( )
	--ly
	self.pLyMain = self:findViewByName("ly_main")
	self.pLyIcon = self:findViewByName("ly_icon")

	--lb
	self.pLbName = self:findViewByName("lb_name") --武将名字
	self.pLbDetail = self:findViewByName("lb_detail") --详情
	self.pLbLv = self:findViewByName("lb_lv") --等级
	self.pLbNum = self:findViewByName("lb_num") --兵力

	setTextCCColor(self.pLbName,_cc.blue)
	setTextCCColor(self.pLbDetail,_cc.blue)
	
	--img
	self.pImgHeroType = self:findViewByName("img_hero_type") --兵种

	--icon
	if self.tData then
		self.pIcon = getIconHeroByType(self.pLyIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.M)
	end	

	--兵力名字
	self.pLbDetail:setString(getConvertedStr(5, 10027))

	--已阵亡文字
	self.pLbDead = MUI.MLabel.new({text = getConvertedStr(7, 10382), size = 25})
	self.pLyMain:addView(self.pLbDead, 10)
	setTextCCColor(self.pLbDead, _cc.red)
	self.pLbDead:setPosition(self.pLbDetail:getPosition())
	self.pLbDead:setVisible(false)

end

-- 修改控件内容或者是刷新控件数据
function ItemFubenEnemyArmy:updateViews(  )

	--敌人名称
	if self.tData.sName then
		self.pLbName:setString(self.tData.sName,false)
	end

	--等级
	if self.tData.nLevel then
		self.pLbLv:setString("Lv."..self.tData.nLevel)
		self.pLbLv:setPositionX(self.pLbName:getPositionX() + self.pLbName:getWidth() + 15)
	end

	--兵力
	if self.nArmyType == en_army_type.killherofight then --过关斩将类型
		--血量
		if self.tData.nBlood then
			self.pLbNum:setString(tostring(self.tData.nBlood))
			if self.tData.nBlood > 0 then
				self.pIcon:setIconBgToGray(false)
				self.pLbDead:setVisible(false)
				self.pImgHeroType:setVisible(true)
				self.pLbDetail:setVisible(true)
				self.pLbNum:setVisible(true)
			else
				self.pIcon:setIconBgToGray(true)
				self.pLbDead:setVisible(true)
				self.pImgHeroType:setVisible(false)
				self.pLbDetail:setVisible(false)
				self.pLbNum:setVisible(false)
			end
		end
	else
		if self.tData.nTroops then
			self.pLbNum:setString(tostring(self.tData.nTroops))
		end
	end

		--显示兵种
	self.pImgHeroType:setCurrentImage(getSoldierTypeImg(self.tData.nKind))


end

--析构方法
function ItemFubenEnemyArmy:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemFubenEnemyArmy:setCurData(_data)
	if not _data then
		return
	end

	self.pData = _data or {}


	if self.pData.sName then
		self.pLbTitle:setString(self.pData.sName)
	end

	-- self.pData.nS = 2
	if self.pData.nS and self.pData.nS > 0 then
		self.pLyAcross:setVisible(true)
		for k,v in pairs(self.tImgStart) do
			if k > self.pData.nS then
				v:setCurrentImage("#v1_img_starb.png")
			else
				v:setCurrentImage("#v1_img_stara.png")
			end
		end

	else
		self.pLyAcross:setVisible(false)
	end

	--攻打进度
	if self.pData.nX and self.pData.nY then
		self.pLbSectionPlan:setString(getConvertedStr(5, 10014)..self.pData.nX.."/"..self.pData.nY)
	end






end


return ItemFubenEnemyArmy