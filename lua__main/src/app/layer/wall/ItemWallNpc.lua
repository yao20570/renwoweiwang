-- Author: liangzhaowei
-- Date: 2017-05-15 15:59:22
-- 守城npc武将
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemWallNpcState = require("app.layer.wall.ItemWallNpcState")
local DlgOperateWallDefCost = require("app.layer.wall.DlgOperateWallDefCost")
local ItemWallNpc = class("ItemWallNpc", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWallNpc:ctor()
	-- body
	self:myInit()


	parseView("item_wall_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemWallNpc",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemWallNpc:myInit()
	self.tCurData  			= 	nil 						-- 当前数据
	self.pItemNpcState      =   nil                         -- npc状态
	self.nType              =   1                           -- 类型

end

--解析布局回调事件
function ItemWallNpc:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	
	self.pLyIcon = self:findViewByName("ly_hero")
	self.pLyBar = self:findViewByName("ly_bar")
	self.pLyBar:setVisible(true)


	self.pBarLv = 	nil
	self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_1.png",barWidth = 106, barHeight = 14})
	self.pLyBar:addView(self.pBarLv,100)
	centerInView(self.pLyBar,self.pBarLv)


	self.pLbLv = self:findViewByName("lb_lv")
	setTextCCColor(self.pLbLv, _cc.blue)
	self.nLvPosY = self.pLbLv:getPositionY()

	--img
	self.pSelImg = self:findViewByName("img_sel")
	self.pSelImg:setVisible(false)
	-- self.pLbLv:setVisible(false)


	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemWallNpc:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemWallNpc:updateViews(  )
	self:stopAllActions()
end

--析构方法
function ItemWallNpc:onDestroy(  )
	-- body
end




--设置数据 _data _nType  1为可触发操作功能 2为只显示信息
function ItemWallNpc:setCurData(_tData,_nType)
	if not _tData then
		return
	end

	if not _nType then
		self.nType = 1
	else
		self.nType = _nType
	end

	-- dump(self.pData,"_tData",2)

	if type(self.pData) == "table" and type(_tData) == "table"  then --znftodo 容错，突然出现的一个错误，类型是number,不知道怎么重现。。。
			-- dump(_tData.nLevel,"tadaa")
			-- dump(self.pData.nLevel,"self.pData.nLevel")
		if self.pData and self.pData.nLevel and _tData.nLevel and self.pIcon then

			if _tData.nLevel > self.pData.nLevel then
				playUpDefenseArm(self.pIcon)
			end
		end
	end

	self.pData = _tData or {}

	if type(self.pData) == "table" then
		self.pLyBar:setVisible(true)
		if self.pData then
			if not self.pIcon then
				self.pIcon = getIconHeroByType(self.pLyIcon, TypeIconHero.NORMAL, self.pData, TypeIconHeroSize.L)
				self.pIcon:setIconClickedCallBack(handler(self, self.onViewClick))
			else
				self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
				self.pIcon:setCurData(self.pData)
			end



			if not self.pItemNpcState then
				self.pItemNpcState = ItemWallNpcState.new()
				self.pIcon:addView(self.pItemNpcState,10)
			end
			self.pItemNpcState:setCurData(self.pData)

			self.pBarLv:setPercent(self.pData.nTp/self.pData.nTroops *100)

			local nPercent = self.pData.nTp/self.pData.nTroops
			if nPercent <= 0.1 then
				self.pBarLv:setBarImage("ui/bar/v1_bar_red1.png")
			elseif nPercent >= 1 then
				self.pBarLv:setBarImage("ui/bar/v1_bar_blue_3.png")
			else
				self.pBarLv:setBarImage("ui/bar/v1_bar_yellow_8.png")
			end

			setTextCCColor(self.pLbLv, _cc.blue)
			self.pLbLv:setString(self.pData.sName.."Lv."..self.pData.nLevel)
			self.pLbLv:setPositionY(self.nLvPosY)
		end
	else
		local pGate = Player:getBuildData():getBuildById(e_build_ids.gate) --城门数据

		self.pLyBar:setVisible(false)
		if not self.pIcon then
			self.pIcon = getIconHeroByType(self.pLyIcon,self.pData, nil, TypeIconHeroSize.L)
			self.pIcon:setIconClickedCallBack(handler(self, self.onViewClick))
		end


		self.pIcon:setIconHeroType(self.pData)	
		--加号提示是否展示可招募状态
		if not pGate:showRecruitTip() then
			self.pIcon:stopAddImgAction()
		end

		if self.pData == TypeIconHero.LOCK then
			--当前等级城防容量个数
			if pGate and pGate.nLv then
				local nNums = getWallBaseDataByLv(pGate.nLv).num
				local sTip = ""
				local nLv = getWallLvByNum(nNums + 1)
				if nLv then
					sTip = nLv..getConvertedStr(5, 10257)
				end
				self.pLbLv:setString(sTip)--开锁提示
				setTextCCColor(self.pLbLv, _cc.red)
				self.pLbLv:setPositionY(self.nLvPosY + 22)
			end
		else
			self.pLbLv:setString("")
		end
		if self.pItemNpcState then
			self.pItemNpcState:removeFromParent(true)
			self.pItemNpcState = nil
		end
	end

	-- self.pIcon.bWallNpc = 12

	
end

--点击回调
function ItemWallNpc:onViewClick(pView)


	

	if self.nType ~=2 then
		if type(self.pData) == "table" then

			--显示是否补充兵
			if self.pData.nTp < self.pData.nTroops then
				local pDlg, bNew = getDlgByType(operatewalldefcost)
			    if not pDlg then
			    	pDlg = DlgOperateWallDefCost.new()
			    end
			    pDlg:setCurdata(2,tonumber(getWallInitParam("healCost")),self.pData)
			    pDlg:showDlg(bNew)
		    else
				if self.pData.nCt > 0 then --升级

					local pDlg, bNew = getDlgByType(operatewalldefcost)
				    if not pDlg then
				    	pDlg = DlgOperateWallDefCost.new()
				    end
				    pDlg:setCurdata(1,tonumber(getWallInitParam("trainCost")),self.pData)
				    pDlg:showDlg(bNew)
				end
			end
		else
			if self.pData == TypeIconHero.ADD then
		 		sendMsg(ghd_recruit_wall_wall) --通知招募城墙守卫
			end
		end
	end

end

return ItemWallNpc