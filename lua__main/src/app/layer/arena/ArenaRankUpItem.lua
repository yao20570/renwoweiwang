-- Author: maheng
-- Date: 2018-03-12 21:15:17
-- Description: 竞技场排名特效item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ArenaRankUpItem = class("ArenaRankUpItem", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- _nMoveTime: 移动时间
function ArenaRankUpItem:ctor( _nMoveTime )
	-- body

	self:myInit()

	self.nMoveTime = _nMoveTime or self.nMoveTime
	parseView("item_arena_rank_up", handler(self, self.onParseViewCallback))

end

function ArenaRankUpItem:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	self:setupViews()
end
--初始化成员变量
function ArenaRankUpItem:myInit()
	self.pData = nil -- 玩家数据	
	self.nChangeNum = 0 -- 变化的排名		
	self.nOriginal = 0 -- 原始的排名

	self.nMoveTime = 0 -- 移动时间

	self.pTxtRank = nil
end

--初始化控件
function ArenaRankUpItem:setupViews()

	self.pMainView = self:findViewByName("layout_main") -- main层

	self.pHeadLayer = self:findViewByName("layout_fk") -- 头像层
	self.pImgBg = self:findViewByName("img_bg") -- 背景图
	self.pImgBgLight = self:findViewByName("img_bg_light") -- 背景图（加亮）
	self.pImgHead = self:findViewByName("img_head") -- 头像
	self.pImgOrn = self:findViewByName("img_orn") -- 挂饰
	self.pTxtName = self:findViewByName("txt_name") -- 玩家名字

	self.pRankLayer = self:findViewByName("layout_rank") -- 排名层
	self.pImgArrow = self:findViewByName("img_arrow") -- 箭头

	self.pImgTitle = self:findViewByName("img_title") -- 标题
	self.pImgHeadLight = MUI.MImage.new("#rwww_jjc_tx_bl_001.png")
	self.pImgHeadLight:setPosition(self.pImgHead:getPositionX(), self.pImgHead:getPositionY())
	self.pImgHeadLight:setVisible(false)
	self.pHeadLayer:addView(self.pImgHeadLight, 5)
	self.pImgOrnLight = MUI.MImage.new("ui/daitu.png")
	self.pImgOrnLight:setPosition(self.pImgHead:getPositionX(), self.pImgHead:getPositionY())
	self.pImgOrnLight:setVisible(false)
	self.pHeadLayer:addView(self.pImgOrnLight, 11)

	self.pImgBgLight:setVisible(false)
	self.pRankLayer:setVisible(false)
	self.pImgTitle:setVisible(false)

	self.pTxtRank = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_paiming1.png", pngw=33, pngh=38, scm=48})
	self.pTxtRank:setPosition(83, 10)	
	self.pTxtRank:setAnchorPoint(cc.p(0.5, 0))
	self.pRankLayer:addView(self.pTxtRank)	

	-- self.pTxtChange = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_paiming2.png", pngw=29, pngh=30, scm=48})
	-- self.pTxtChange:setPosition(83, 10)
	-- self.pTxtChange:setAnchorPoint(cc.p(0.5, 0))
	-- self.pRankLayer:addView(self.pTxtChange)	
end

-- 修改控件内容或者是刷新控件数据
function ArenaRankUpItem:updateViews()
	if (not self.pData) then
		return 
	end

	-- 刷新玩家数据
	self:refreshPlayerInfo()
	-- 刷新基本ui
	self:refreshBaseUI()
end

-- 刷新玩家数据
function ArenaRankUpItem:refreshPlayerInfo(  )
	-- 根据头像id获取头像数据
	local sIconPath = getPlayerIconStr(self.pData.icon)
	if (sIconPath) then
		self.pImgHead:setCurrentImage(sIconPath)
		-- self.pImgHeadLight:setCurrentImage(sIconPath)		
	end
	-- 根据挂饰id获取挂饰数据
	local sBoxPath = getPlayerIconBg(self.pData.box)
	if (sBoxPath) then
		self.pImgOrn:setVisible(true)
		self.pImgOrn:setCurrentImage(sBoxPath)
		self.pImgOrnLight:setCurrentImage(sBoxPath)
	end
	self.pTxtName:setString(self.pData.name or "", false)
end

-- 刷新基本ui
function ArenaRankUpItem:refreshBaseUI(  )	
	self.pTxtChange = nil
	if (self.nChangeNum > 0) then -- 排名上升
		self.pImgArrow:setCurrentImage("#v1_img_shengjilvjiantou2.png")
		self.pTxtChange = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_paiming3.png", pngw=29, pngh=30, scm=48})
		self.pTxtChange:setPosition(83, 10)
		self.pTxtChange:setAnchorPoint(cc.p(0.5, 0))
		self.pRankLayer:addView(self.pTxtChange)	
		-- self.pTxtChange:__resetOptions(false, {text="0", png="ui/atlas/v2_img_paiming3.png", pngw=29, pngh=30, scm=48})
		-- 加亮图
		self.pImgBgLight:setVisible(false)
		self.pImgHeadLight:setVisible(false)
		self.pImgOrnLight:setVisible(false)
		self.pImgBgLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgHeadLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)--头像	
		self.pImgOrnLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)--头像框	
		self.pImgArrow:setFlippedY(false)
		-- 刷新排名初始ui
		self:refreshRankUI()
		-- 重置排名层的y轴位置
		self.pRankLayer:setPositionY(self.pImgTitle:getPositionY() + self.pImgTitle:getHeight()/2 + 5)

		self.pHeadLayer:setAnchorPoint(cc.p(0.5, 0.5))
	else -- 排名下降		
		self.pImgArrow:setCurrentImage("#v1_img_shengjilvjianto.png")
		self.pTxtChange = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_paiming2.png", pngw=29, pngh=30, scm=48})
		self.pTxtChange:setPosition(83, 10)
		self.pTxtChange:setAnchorPoint(cc.p(0.5, 0))
		self.pRankLayer:addView(self.pTxtChange)			
		-- self.pTxtChange:__resetOptions(false, {text="0", png="ui/atlas/v2_img_paiming2.png", pngw=29, pngh=30, scm=48})
		self.pImgBgLight:setVisible(false)
		self.pImgHeadLight:setVisible(false)
		self.pImgOrnLight:setVisible(false)
		self.pImgArrow:setFlippedY(true)
		-- 显示标题
		self.pImgTitle:setVisible(false)

		-- 刷新排名初始ui
		self:refreshRankUI()
		-- 重置排名层的y轴位置
		self.pRankLayer:setPositionY(self.pHeadLayer:getPositionY()
				 + self.pHeadLayer:getHeight() + 0)

		self.pHeadLayer:setAnchorPoint(cc.p(-0.1, 1.1))
	end
end

-- 初始化排名展示
function ArenaRankUpItem:refreshRankUI(  )	
	self.pTxtRank:setString(self.nOriginal, false)	
	self.pTxtChange:setString(self.nChangeNum, false)
	local nWidth = self.pTxtRank:getWidth() + self.pTxtChange:getWidth() + self.pImgArrow:getWidth() + 40
	self.pRankLayer:setContentSize(cc.size(nWidth, self.pRankLayer:getHeight()))
	self.pRankLayer:setPositionX((self.pMainView:getWidth() - self.pRankLayer:getWidth()) / 2)

	self.pTxtRank:setPositionX(self.pTxtRank:getWidth()/2 + 15)
	self.pTxtChange:setPositionX(self.pTxtRank:getPositionX() + self.pTxtRank:getWidth()/2 + 30)
	self.pImgArrow:setPositionX(self.pTxtChange:getPositionX() + self.pTxtChange:getWidth()/2 + 10)
end

-------------------------------------------
-- 设置数据
-- _pData: 玩家数据
-- _nChangeNum：变化的排名
-- _nOriginal：原始的排名
function ArenaRankUpItem:setData( _pData, _nChangeNum, _nOriginal )
	self.pData = _pData -- 玩家数据
	self.nChangeNum = _nChangeNum or self.nChangeNum -- 变化的排名		
	self.nOriginal = _nOriginal or self.nOriginal -- 原始的排名
	self:updateViews()
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
-- 播放排名上升的动画
function ArenaRankUpItem:doUpArm( _nCallback1, _nCallback2 )
	local tActions = {}
	table.insert(tActions, cc.ScaleTo:create(self.nMoveTime, 1.2)) -- 放大
	table.insert(tActions, cc.CallFunc:create(function (  ) -- 移动到指定位置后的回调
		if (_nCallback1) then
			_nCallback1()
		end
	end))
	table.insert(tActions, cc.ScaleTo:create(0.15, 1.3))
	table.insert(tActions, cc.ScaleTo:create(0.1, 0.98))
	table.insert(tActions, cc.CallFunc:create(function (  ) -- 播放加亮图
		self.pImgBgLight:setVisible(true)		
		self.pImgBgLight:runAction(cc.Sequence:create(
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function (  )
				self.pImgBgLight:setVisible(false)				
			end)))
		self.pImgHeadLight:setVisible(true)
		self.pImgHeadLight:runAction(cc.Sequence:create(
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function (  )
				self.pImgHeadLight:setVisible(false)
			end)))		
		self.pImgOrnLight:setVisible(true)
		self.pImgOrnLight:runAction(cc.Sequence:create(
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function (  )
				self.pImgOrnLight:setVisible(false)
			end)))						
	end))
	table.insert(tActions, cc.ScaleTo:create(0.07, 1.01))
	table.insert(tActions, cc.ScaleTo:create(0.05, 1.0))
	table.insert(tActions, cc.CallFunc:create(function (  ) -- 播放结束的回调
		if (_nCallback2) then
			_nCallback2()
		end
	end))

	self.pHeadLayer:runAction(cc.Sequence:create(tActions))
end
-- 播放排名下降的动画
function ArenaRankUpItem:doDownArm(  )
	local nTime = self.nMoveTime * 0.5
	local tActions = {}
	table.insert(tActions, cc.ScaleTo:create(nTime, 0.85)) -- 缩小
	table.insert(tActions, cc.ScaleTo:create(self.nMoveTime - nTime, 1.0)) -- 放大
	self.pHeadLayer:runAction(cc.Sequence:create(tActions))
end

-- 播放排名下降的动画2
-- _nCallback：播放结束回调
function ArenaRankUpItem:doDownArmPart2( _nCallback )
	local tActions = {}
	table.insert(tActions, cc.MoveBy:create(0.1, cc.p(0, -10)))
	table.insert(tActions, cc.RotateBy:create(0.3, 15))
	table.insert(tActions, cc.RotateBy:create(0.4, -4))
	table.insert(tActions, cc.RotateBy:create(0.3, 2))
	table.insert(tActions, cc.RotateBy:create(0.3, -1))
	table.insert(tActions, cc.CallFunc:create(function (  )
		if (_nCallback) then
			_nCallback()
		end
	end))
	self.pHeadLayer:runAction(cc.Sequence:create(tActions))
end

-- 播放排名变化特效
function ArenaRankUpItem:doRankChangeArm(  )
	self.pRankLayer:setVisible(true)
	if (self.nChangeNum > 0) then -- 排名上升
		self.pImgTitle:setVisible(true)
	end
	
	self:onChangeNum()
end

-- 数字变化
function ArenaRankUpItem:onChangeNum(  )
	-- 数字变化次数
	local nChangeNum = -self.nChangeNum
	local nPerTimes = 13
	if (nPerTimes > math.abs(nChangeNum)) then
    	nPerTimes = math.abs(nChangeNum)
    end
    local nTimeDel = 0.04
    local nShowTime = 0.8
	local nPerNum = math.ceil(math.abs(nChangeNum) / nPerTimes)
    local nTimeDel = nShowTime / nPerTimes
    local nTimeDel = 0.04
    local nCurNUm = self.nOriginal
    local nFlag = nChangeNum / math.abs(nChangeNum)
    for i=1, nPerTimes do
    	local pSeqAct = cc.Sequence:create(
            cc.DelayTime:create(nTimeDel * i),
            cc.CallFunc:create(function (  )
            	nCurNUm = nCurNUm + nPerNum * nFlag
	    		if ((nFlag > 0 and nCurNUm > self.nOriginal + nChangeNum)
	    			or (nFlag < 0 and nCurNUm < self.nOriginal + nChangeNum)) then
	    			nCurNUm = self.nOriginal + nChangeNum
	    		end
	    		if (nCurNUm >= 2047483648) then
	    			-- 当数值大于int的最大值时的特殊处理
	    			self.pTxtRank:setString(nCurNUm.."*", false) 
	    		else
	    			self.pTxtRank:setString(nCurNUm, false)
	    		end
			end))
    	self:runAction(pSeqAct)
	end
	-- local nRankNumScheduler = nil
	-- local nRankNumIndexEnd = 0
	-- local nRankNumIndexEnd = 0
	-- local sPrev = tostring(self.nOriginal)
	-- local sCurr = tostring(self.nOriginal - self.nChangeNum)
	-- local nPrevStrLen = string.len(sPrev)
	-- local nCurrStrLen = string.len(sCurr)
	-- if nPrevStrLen == nCurrStrLen then
	-- 	--记录不同的数字进行滚动
	-- 	--找出不同的下标
	-- 	for i=1,nCurrStrLen do
	-- 		local sSubStr1 = string.sub(sPrev, i, i)
	-- 		local sSubStr2 = string.sub(sCurr, i, i)
	-- 		if sSubStr1 ~= sSubStr2 then
	-- 			nRankNumIndex = i
	-- 			break
	-- 		end
	-- 	end
	-- else
	-- 	--不同的位数，全部滚动，
	-- 	nRankNumIndex = 1
	-- end
	-- nRankNumIndexEnd = nCurrStrLen

	-- --容错
	-- if nRankNumIndexEnd <= 0 then
	-- 	return
	-- end	
	-- local fCurrT = 0
	-- local fChangeT = 0.04
	-- local fWei = 1/nRankNumIndexEnd
	-- nRankNumScheduler = MUI.scheduler.scheduleGlobal(function (  )
	-- 	--一段时间就减少一个随机
	-- 	if fCurrT >= fWei then
	-- 		fCurrT = 0
	-- 		nRankNumIndex = nRankNumIndex + 1
	-- 	end
	-- 	local sStr = ""
	-- 	--数字
	-- 	for i=1,nCurrStrLen do
	-- 		local sSubStr = string.sub(sCurr, i, i)
	-- 		if i >= nRankNumIndex and i <= nRankNumIndexEnd then
	-- 			sSubStr = math.random(0,9)
	-- 		end
	-- 		sStr = sStr .. sSubStr
	-- 	end
	-- 	if not tolua.isnull(self.pTxtRank) then
	-- 		self.pTxtRank:setString(sStr, false)
	-- 	end

	-- 	--跳出
	-- 	if nRankNumIndex > nRankNumIndexEnd then
	-- 		--显示偏差数字移动
	-- 		-- moveOffsetRankNum()
	-- 		--停止倒计时
	--     	if nRankNumScheduler then
	--     		MUI.scheduler.unscheduleGlobal(nRankNumScheduler)
	--     		nRankNumScheduler = nil
	--     	end
	-- 	end

	-- 	--累积时间
	-- 	fCurrT = fCurrT + fChangeT
 --    end,fChangeT)	
end

return ArenaRankUpItem
