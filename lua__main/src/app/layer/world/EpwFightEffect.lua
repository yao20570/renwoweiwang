--皇城战特效层
local MCommonView = require("app.common.MCommonView")

local EpwFightEffect = class("EpwFightEffect", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function EpwFightEffect:ctor(  )
	self:setLayoutSize(1, 1)
	self:setAnchorPoint(0.5, 0.5)

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EpwFightEffect", handler(self, self.onEpwFightEffectDestroy))
end

-- 析构方法
function EpwFightEffect:onEpwFightEffectDestroy(  )
    self:onPause()
end

function EpwFightEffect:regMsgs(  )
end

function EpwFightEffect:unregMsgs(  )
end

function EpwFightEffect:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function EpwFightEffect:onPause(  )
	self:unregMsgs()
end

function EpwFightEffect:setData( nCityId )
	if self.nSystemCityId == nCityId then
		return
	end
	self.nSystemCityId = nCityId
	self:updateViews()
end

function EpwFightEffect:updateViews( )
	if not self.nSystemCityId then
		return
	end
	--步骤1、动画需要用到 燃烧效果对应的损坏图片“v1_img_hong03_sh”覆盖在建筑上。
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	if tCityData then 
		local nCityKind = tCityData.kind   
		local sImg = "#v1_img_hong01_sh.png"
		local nImgScale = 1
		if nCityKind == e_kind_city.zhongxing then 
			sImg = "#v1_img_hong03_sh.png"
			nImgScale = 1
			self:setScale(2)
		elseif nCityKind == e_kind_city.firetown then
			sImg = "#v1_img_hong04_sh.png"
			nImgScale = 0.5
			self:setScale(1)
		end
		if self.pImgBroke then
			self.pImgBroke:setCurrentImage(sImg)
		else
			self.pImgBroke = MUI.MImage.new(sImg)
			self:addView(self.pImgBroke)
			WorldFunc.setCameraMaskForView(self.pImgBroke)
		end
		self.pImgBroke:setScale(nImgScale)
	end
	--步骤2、爆炸效果需要在5个指定的位置上， 随机时间在随机的位置上出现随机的缩放值序列帧 。
	-- 位置信息（粒子需要在这几个坐标随机出现，不连续重复的位置）：
	self:playBlast()

	--步骤3:石头
	-- 位置信息（动画需要在这几个坐标随机出现，不连续重复的位置）：
	self:playStone()

	-- 步骤4：箭
	-- 位置信息（动画需要在这几个坐标随机出现，不连续重复的位置）：
	self:playArrow()
end

--播放爆炸
function EpwFightEffect:playBlast( )
	--爆炸方法
	local function _playBlast(  )
		local tPosList = {
			{-81,9},
			{-28,-11},
			{32,-34},
			{1,43},
			{81,9},
		}
		--随机不上次
		local nCount = #tPosList
		local nIndex = math.random(1,nCount)
		if self.nBlastIndex == nIndex then
			if nIndex + 1 > nCount then
				nIndex = 1
			else
				nIndex = nIndex + 1
			end
		end
		self.nBlastIndex = nIndex
		local tPos = tPosList[nIndex]
		if not tPos then
			return
		end
		
		local nRanScale = math.random(80, 100)/100 -- 随机出现的缩放值区间为：（80% —— 110%）
		if tPos and nRanScale then
			local pNewBlast = MUI.MLayer.new()
			self:addView(pNewBlast)
			pNewBlast:setLayoutSize(1, 1)
			pNewBlast:setAnchorPoint(0.5, 0.5)
			pNewBlast:setPosition(tPos[1], tPos[2])
			pNewBlast:setScale(nRanScale)

			--序列帧资源：
			local tArmData1  = 
			{
				-- sPlist = "tx/other/rwww_gc_bzxg",
				-- nImgType = 1,
				nFrame = 13, -- 总帧数
				pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
				fScale = 1,-- 初始的缩放值
				nBlend = 0, -- 需要加亮
			   	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
				tActions = {
					 {
						nType = 1, -- 序列帧播放
						sImgName = "rwww_gc_bzxg_",
						nSFrame = 1, -- 开始帧下标
						nEFrame = 13, -- 结束帧下标
						tValues = nil, -- 参数列表
					},
				},
			}
			local pBlastArm = MArmatureUtils:createMArmature(
				tArmData1, 
				pNewBlast, 
				0, 
				cc.p(0, 0),
			    function ( _pArm )
			    	_pArm:removeSelf()
			    	pNewBlast:removeFromParent()
			    end, Scene_arm_type.forver)
			if pBlastArm then
				pBlastArm:play(1)
			end
			WorldFunc.setCameraMaskForView(pNewBlast)
			
			--播放下一个爆炸
			self.bIsBlasting = false
			self:playBlast()
		end
	end


	--播放爆炸
	if self.bIsBlasting then
		return
	end
	self.bIsBlasting = true
	local nNextTime = math.random(2, 6)/10 -- 连续出现的时间随机值区间为：（0.2秒 —— 0.6秒）
	local pSeqAct = cc.Sequence:create({
			cc.DelayTime:create(nNextTime),
			cc.CallFunc:create(_playBlast),
		})
	self:runAction(pSeqAct)
end

--播放石头
function EpwFightEffect:playStone(  )
	--石头方法
	local function _playStone(  )
		local tParamList = {
			{tPos = {-86, -33}, tScale = {80, 100}, bFlippedX = false},
			{tPos = {-137, -24}, tScale = {80, 100}, bFlippedX = false},
			{tPos = {-150, 10}, tScale = {80, 100}, bFlippedX = false},
			{tPos = {86, -33},  tScale = {80, 100}, bFlippedX = true},
			{tPos = {137,-24},  tScale = {80, 100}, bFlippedX = true},
			{tPos = {150,10},  tScale = {80, 100}, bFlippedX = true},
		}

		--随机不上次
		local nCount = #tParamList
		local nIndex = math.random(1,nCount)
		if self.nStoneIndex == nIndex then
			if nIndex + 1 > nCount then
				nIndex = 1
			else
				nIndex = nIndex + 1
			end
		end
		self.nStoneIndex = nIndex

		local tParam = tParamList[nIndex]
		if not tParam then
			return
		end
		local tPos = tParam.tPos
		local nRanScale = 1
		local tScale = tParam.tScale
		if tScale then
			nRanScale = math.random(tScale[1], tScale[2])/100 -- 随机出现的缩放值区间为：（80% —— 110%）
		end
		local bFlippedX = tParam.bFlippedX
		if tPos and nRanScale then
			local pNewStone = MUI.MLayer.new()
			self:addView(pNewStone)
			pNewStone:setLayoutSize(1, 1)
			pNewStone:setAnchorPoint(0.5, 0.5)
			pNewStone:setPosition(tPos[1], tPos[2])
			pNewStone:setScale(nRanScale)

			--序列帧资源：
			local tArmData1  = 
			{
				-- sPlist = "tx/other/rwww_gc_stgj",
				-- nImgType = 1,
				nFrame = 13, -- 总帧数
				pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
				fScale = 1,-- 初始的缩放值
				nBlend = 0, -- 需要加亮
			   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
				tActions = {
					 {
						nType = 1, -- 序列帧播放
						sImgName = "rwww_gc_stgj_",
						nSFrame = 1, -- 开始帧下标
						nEFrame = 20, -- 结束帧下标
						tValues = nil, -- 参数列表
					},
				},
			}
			local pStonerm = MArmatureUtils:createMArmature(
				tArmData1, 
				pNewStone, 
				0, 
				cc.p(0, 0),
			    function ( _pArm )
			    	_pArm:removeSelf()
			    	pNewStone:removeFromParent()
			    end, Scene_arm_type.forver)
			if pStonerm then
				pStonerm:setFlippedX(bFlippedX)
				pStonerm:play(1)
			end
			WorldFunc.setCameraMaskForView(pNewStone)

			--播放下一个爆炸
			self.bIsStoneing = false
			self:playStone()
		end
	end

	--播放爆炸
	if self.bIsStoneing then
		return
	end
	self.bIsStoneing = true
	local nNextTime = math.random(4, 6)/10 -- 连续出现的时间随机值区间为：（0.4秒 —— 0.6秒）
	local pSeqAct = cc.Sequence:create({
			cc.DelayTime:create(nNextTime),
			cc.CallFunc:create(_playStone),
		})
	self:runAction(pSeqAct)
end

--播放箭头
function EpwFightEffect:playArrow(  )
	--箭头方法
	local function _playArrow(  )
		local tParamList = {
			{tPos = {-72, -82}, tScale = {80, 100},  bFlippedX = false, nAngle = -14},
			{tPos = {-140, -48}, tScale = {80, 100}, bFlippedX = false, nAngle = 0},
			{tPos = {-126, -2}, tScale = {80, 100},  bFlippedX = false, nAngle = 16},
			{tPos = {-103, 20},  tScale = {80, 100}, bFlippedX = false, nAngle = 21},
			{tPos = {-149,31},  tScale = {80, 100}, bFlippedX = false, nAngle = 23},

			{tPos = {65, -41}, tScale = {80, 100},  bFlippedX = true, nAngle = 10},
			{tPos = {140, -48}, tScale = {80, 100}, bFlippedX = true, nAngle = 0},
			{tPos = {126, -2}, tScale = {80, 100},  bFlippedX = true, nAngle = -16},
			{tPos = {103, 20},  tScale = {80, 100}, bFlippedX = true, nAngle = -21},
			{tPos = {149,31},  tScale = {80, 100}, bFlippedX = true, nAngle = -23},
		}
		--随机不上次
		local nCount = #tParamList
		local nIndex = math.random(1,nCount)
		if self.nArrowIndex == nIndex then
			if nIndex + 1 > nCount then
				nIndex = 1
			else
				nIndex = nIndex + 1
			end
		end
		self.nArrowIndex = nIndex

		local tParam = tParamList[nIndex]
		if not tParam then
			return
		end
		local tPos = tParam.tPos
		local nAngle = tParam.nAngle
		local nRanScale = 1
		local tScale = tParam.tScale
		if tScale then
			nRanScale = math.random(tScale[1], tScale[2])/100 -- 随机出现的缩放值区间为：（80% —— 110%）
		end
		local bFlippedX = tParam.bFlippedX
		if tPos and nRanScale and nAngle then
			local pNewArrow = MUI.MLayer.new()
			self:addView(pNewArrow)
			pNewArrow:setLayoutSize(1, 1)
			pNewArrow:setAnchorPoint(0.5, 0.5)
			pNewArrow:setPosition(tPos[1], tPos[2])
			pNewArrow:setScale(nRanScale)
			pNewArrow:setRotation(nAngle)

			--序列帧资源：
			local tArmData1  = 
			{
				-- sPlist = "tx/other/rwww_gc_gifs",
				-- nImgType = 1,
				nFrame = 13, -- 总帧数
				pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
				fScale = 1,-- 初始的缩放值
				nBlend = 1, -- 需要加亮
			   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
				tActions = {
					 {
						nType = 1, -- 序列帧播放
						sImgName = "rwww_gc_gjfs_",
						nSFrame = 1, -- 开始帧下标
						nEFrame = 17, -- 结束帧下标
						tValues = nil, -- 参数列表
					},
				},
			}
			local pArrowrm = MArmatureUtils:createMArmature(
				tArmData1, 
				pNewArrow, 
				0, 
				cc.p(0, 0),
			    function ( _pArm )
			    	_pArm:removeSelf()
			    	pNewArrow:removeFromParent()
			    end, Scene_arm_type.forver)
			if pArrowrm then
				pArrowrm:setFlippedX(bFlippedX)
				pArrowrm:play(1)
			end
			WorldFunc.setCameraMaskForView(pNewArrow)
			
			--播放下一个箭头
			self.bIsArrowing = false
			self:playArrow()
		end
	end

	--播放箭头
	if self.bIsArrowing then
		return
	end
	self.bIsArrowing = true
	local nNextTime = math.random(20, 35)/100 -- 连续出现的时间随机值区间为：（0.2秒 —— 0.35秒）
	local pSeqAct = cc.Sequence:create({
			cc.DelayTime:create(nNextTime),
			cc.CallFunc:create(_playArrow),
		})
	self:runAction(pSeqAct)
end

return EpwFightEffect
