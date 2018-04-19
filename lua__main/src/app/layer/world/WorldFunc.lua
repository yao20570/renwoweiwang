if WorldFunc then return end

WorldFunc = {}

--
e_grid_clicked = {
	effect = 0, --点击显示特效
	click = 1, --点击展开
}
--线路
--行军路线每条线段长度
LINE_LENGTH = 18
--行军路线每条线段宽度
LINE_WIDTH = 18 --(必须为2的整数幂)
--每条虚线间隔数量
LINE_NUM = 16
--箭头与箭头间除图片的间隔偏移
LINE_MARGIN = 6
--每条虚线间
LINE_SIDE = (LINE_LENGTH + LINE_MARGIN)/LINE_NUM

--const 值
--世界格子行列数
WORLD_GRID = 500
--区域格子行列数
BLOCK_GRID = 100

--视图点单位大小
UNIT_WIDTH 		= 260--240--190--238*0.8
UNIT_HEIGHT 	= 130--120--105--119*0.8
UNIT_HYPOTENUSE = math.sqrt(math.pow(UNIT_WIDTH, 2) + math.pow(UNIT_HEIGHT, 2))
--print("UNIT_HYPOTENUSE======",UNIT_HYPOTENUSE/2)

--区域地图的大小
BLOCK_BG_WIDTH = BLOCK_GRID * UNIT_WIDTH


--世界地图的大小
WORLD_BG_WIDTH 	= WORLD_GRID * UNIT_WIDTH
WORLD_BG_HEIGHT = WORLD_GRID * UNIT_HEIGHT

--草皮大小
IMAGE_MAP_WIDTH 		= 784--700
IMAGE_MAP_HEIGHT  		= 784--700

--边缘草皮的大小
WORLD_EDGE_WIDTH = 1020
WORLD_EDGE_HEIGHT = 510
WORLD_EDGE_HYPOTENUSE = math.sqrt(math.pow(WORLD_EDGE_WIDTH, 2) + math.pow(WORLD_EDGE_HEIGHT, 2))

--视图点坐标转成世界坐标
--nDotX, nDotY 视图点坐标
-- p.x = originP.x + tileW /2 × M + （-tileW/2） × N = originP.x + (M – N) × tileW/2；
-- p.y = originP.y + tileH/2 × M + tileH/2 × N = originP.y + (M + N) × tileH/2;
function WorldFunc.getMapPosByDotPos( nDotX, nDotY )
	--判断是否越界
	if nDotX >= 1 and nDotX <= WORLD_GRID and nDotY >= 1 and nDotY <= WORLD_GRID then
		--菱形上方的视图点
		local nOriginDotX,nOriginDotY = 1,WORLD_GRID
		--求出视图点离上方的视图点距离偏移量
		local N = math.abs(nDotX - nOriginDotX)
		local M = math.abs(nDotY - nOriginDotY)
		--求偏移量的坐标值
		local fX = (N - M) * UNIT_WIDTH/2
		local fY = (N + M) * UNIT_HEIGHT/2
		--偏移实际坐标
		fX = WORLD_BG_WIDTH/2 + fX
		fY = WORLD_BG_HEIGHT - fY - UNIT_HEIGHT/2
		return fX,fY
	end
	return nil
end

--世界坐标转成视图点坐标
--fPosX, fPosY ：世界坐标
function WorldFunc.getDotPosByMapPos( fPosX, fPosY )
	--判断是否越界
	if pointInLingxingEx(WORLD_BG_WIDTH, WORLD_BG_HEIGHT, fPosX, fPosY) then
		--原点
		local fOriginX = 0
		local fOriginY = WORLD_BG_HEIGHT/2
		--转换到原点的向量
		local fX2 = fPosX - fOriginX
		local fY2 = fPosY - fOriginY

		nDotX = math.ceil(fX2/UNIT_WIDTH - fY2/UNIT_HEIGHT)
		nDotY = math.ceil(fX2/UNIT_WIDTH + fY2/UNIT_HEIGHT)

		return nDotX,nDotY
	end
	return nil
end

-- --很蠢的验证方法
-- local tDotParseMap = nil
-- function WorldFunc.initMapPosDotPosDict(  )
-- 	if not tDotParseMap then
-- 		tDotParseMap = {}
-- 		local nOriginX = 0 + math.ceil(UNIT_WIDTH/2)
-- 		local nOriginY = WORLD_BG_HEIGHT/2
-- 		for i=1,WORLD_GRID do
-- 			if i == 1 then
-- 				tDotParseMap[i.."_"..1] = {nOriginX, nOriginY}
-- 			else
-- 				local nPrevPoint = tDotParseMap[tostring(i - 1).."_"..1]
-- 				if nPrevPoint then
-- 					local nX2 = nPrevPoint[1] + UNIT_WIDTH/2
-- 					local nY2 = nPrevPoint[2] - UNIT_HEIGHT/2
-- 					if tDotParseMap[i.."_"..1] then
-- 						print("error1")
-- 					end
-- 					tDotParseMap[i.."_"..1] = {nX2, nY2}
					
-- 				end
-- 			end	
-- 			for j=1,WORLD_GRID do
-- 				if j > 1 then
-- 					local nPrevPoint = tDotParseMap[i.."_"..tostring(j-1)]
-- 					if nPrevPoint then
-- 						local nX2 = nPrevPoint[1] + UNIT_WIDTH/2
-- 						local nY2 = nPrevPoint[2] + UNIT_HEIGHT/2
-- 						if tDotParseMap[i.."_"..j] then
-- 							print("error")
-- 						end
-- 						tDotParseMap[i.."_"..j] = {nX2, nY2}
-- 					end
-- 				end
-- 			end
-- 		end
-- 		print("WorldFunc.initMapPosDotPosDict=",table.nums(tDotParseMap))
-- 	end
-- 	return tDotParseMap
-- end

-- --视图点坐标转成世界坐标
-- --nDotX, nDotY 视图点坐标
-- function WorldFunc.getMapPosByDotPos( nDotX, nDotY )
-- 	WorldFunc.initMapPosDotPosDict()
-- 	--判断是否越界
-- 	if nDotX >= 1 and nDotX <= WORLD_GRID and nDotY >= 1 and nDotY <= WORLD_GRID then
-- 		local tPos = tDotParseMap[nDotX .."_" ..nDotY]
-- 		if tPos then
-- 			return tPos[1], tPos[2]
-- 		end
-- 	end
-- 	return nil
-- end


--根据位置求区域id
--nDotX, nDotY:视图点坐标
--返回视图id
function WorldFunc.getBlockId(  nDotX, nDotY )
	local tMapData = getWorldMapData()
	for k,v in pairs(tMapData) do
		if v.xstart <= nDotX and nDotX <= v.xover and
			v.ystart <= nDotY and nDotY <= v.yover then
			return k
		end
	end
	return nil
end

--根据位置求区域id
--fX, fY:世界坐标
--返回视图id
function WorldFunc.getBlockIdByMapPos(  fX, fY )
	local nDotX,nDotY = WorldFunc.getDotPosByMapPos(fX, fY)
	if not nDotX then
		return nil
	end
	local tMapData = getWorldMapData()
	for k,v in pairs(tMapData) do
		if v.xstart <= nDotX and nDotX <= v.xover and
			v.ystart <= nDotY and nDotY <= v.yover then
			return k
		end
	end
	return nil
end

--根据位置求区域数据
--nDotX, nDotY:视图点坐标
--return {pLeftDot = {x,y}, pRightDot = {x,y}, nBlockId = }:最左格子坐标，最右格子坐标,blockId
function WorldFunc.getBlockRangeData( nDotX, nDotY )
	--遍历已开放区域
	local tMapData = getWorldMapData()
	for k,v in pairs(tMapData) do
		if v.xstart <= nDotX and nDotX <= v.xover and
			v.ystart <= nDotY and nDotY <= v.yover then
			return {pLeftDot = cc.p(v.xstart, v.ystart), pRightDot = cc.p(v.xover, v.yover), nBlockId = k}
		end
	end
	--求未开区域 
	for i=1, WORLD_GRID, BLOCK_GRID do
		local nStartX = i
		local nEndX = (i - 1) + BLOCK_GRID
		for j=1, WORLD_GRID, BLOCK_GRID do
			local nStartY = j
			local nEndY = (j - 1) + BLOCK_GRID
			--
			if nStartX <= nDotX and nDotX <= nEndX and 
				nStartY <= nDotY and nDotY <= nEndY then
				return {pLeftDot = cc.p(nStartX, nStartY), pRightDot = cc.p(nEndX, nEndY)}
			end
		end
	end
	return nil
end

--是否跨区域
function WorldFunc.getIsCrossBlock(nX, nY)
	--显示我的坐标
	local nMyX, nMyY = Player:getWorldData():getMyCityDotPos()
	local nMyBlockId = WorldFunc.getBlockId(nMyX, nMyY)
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	if nMyBlockId ~= nBlockId then
		return true
	end
	return false
end

--算行军时间
--nStartDotX, nStartDotY, nEndDotX, nEndDotY 视图点起点和终点坐标
--nRatio:系统加成
function WorldFunc.getArmyMoveTime( nStartDotX, nStartDotY, nEndDotX, nEndDotY, nRatio)
	nRatio = nRatio or 1
	local nOffsetX = math.abs(nStartDotX - nEndDotX)
	local nOffsetY = math.abs(nStartDotY - nEndDotY)
	-- 格子距离 * 8 *（1 - 0.05 * 提升百分比数值）
	local nRet = (nOffsetX + nOffsetY) * 8 * (1 - Player:getBuffData():getBuffPercentAdds(e_buff_key.army_speed_tnoly_add)) *
		(1 - Player:getBuffData():getBuffPercentAdds(e_buff_key.army_speed_item_add))
	--时间加乘
	nRet = nRet * nRatio
	nRet = math.ceil(nRet) --向上取整
		
	return nRet
end

function WorldFunc.getArmyDistance( nStartDotX, nStartDotY, nEndDotX, nEndDotY )
	-- body	
	local nOffsetX = math.abs(nStartDotX - nEndDotX)
	local nOffsetY = math.abs(nStartDotY - nEndDotY)	
	local nRet = (nOffsetX + nOffsetY)		
	return nRet	
end

--获取武王伐纣速度加成系数
function WorldFunc.getBossSpeedAdd( nBossLv )
	--Boss行军时间比例
	if nBossLv then
		local tBossConf = getAwakeBossData(nBossLv, Player:getWuWangDiff())
		if tBossConf then
			return tBossConf.marchratio
		end
	end
	return 1
end

--行军耗费粮食数
--nTroops: 出征兵力
--nMoveTime: 行军时间
function WorldFunc.getCostFood( nTroops, nMoveTime)
	nTroops = nTroops or 0
	nMoveTime = nMoveTime or 0
	if nTroops <= 0 then
		return 0
	end
	local nFoodCost = math.ceil(nTroops/10) + 5 * nMoveTime
	--出征消耗粮草降低比例
	local nLessPer = Player:getBuffData():getBuffPercentAdds(e_buff_key.battle_food_cost_plus)
	nFoodCost = nFoodCost * (1 - nLessPer)
	return nFoodCost
end

--获取我的行军时间
--nEndDotX, nEndDotY : 视图点终点坐标
--nRatio:系统加成
function WorldFunc.getMyArmyMoveTime( nEndDotX, nEndDotY, nRatio)
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	local nRet = WorldFunc.getArmyMoveTime(nX, nY, nEndDotX, nEndDotY, nRatio)
	return nRet
end

--获取我的武将位置
function WorldFunc.getMyHeroPosByTask( tTask )
	if tTask then
		if tTask.nState == e_type_task_state.go or tTask.nState == e_type_task_state.back then
			local nStartX, nStartY = Player:getWorldData():getMyCityDotPos()
			if tTask:getIsBotAnGo() then
				nStartX = tTask:getBoX()
				nStartY = tTask:getBoY()
			end
			local fStartX, fStartY = WorldFunc.getMapPosByDotPos(nStartX, nStartY)

			local nEndX, nEndY = tTask.nTargetX, tTask.nTargetY
			local fEndX, fEndY = WorldFunc.getMapPosByDotPos(nEndX, nEndY)

			local fMoveTime = tTask:getCdMax()
			local pFStartP = cc.p(fStartX, fStartY)
			local pFEndP = cc.p(fEndX, fEndY)

			--对调位置
			if tTask.nState == e_type_task_state.back then
				local pTempP = pFStartP
				pFStartP = pFEndP
				pFEndP = pTempP
			end
			--角度
			local nAngle = getAngle(pFStartP.x, pFStartP.y, pFEndP.x, pFEndP.y)
			local nRadian = nAngle * math.pi / 180;
			local fLength = cc.pGetDistance(pFStartP, pFEndP)
			--计算位置时间
			local nMoveCd = tTask:getCd()
			local fMoved = math.max(fMoveTime - nMoveCd,0)/fMoveTime * fLength
			local fHeroX = pFStartP.x + fMoved * math.cos(nRadian)
			local fHeroY = pFStartP.y - fMoved * math.sin(nRadian)
			return fHeroX, fHeroY
		else
			--目的地位置
			return WorldFunc.getMapPosByDotPos(tTask.nTargetX, tTask.nTargetY)
		end
	end
	--主城位置
	local nStartX, nStartY = Player:getWorldData():getMyCityDotPos()
	return WorldFunc.getMapPosByDotPos(nStartX, nStartY)
end

--获取系统国家旗帜
function WorldFunc.getCountryFlagImg( nCountry )
	if nCountry == e_type_country.qunxiong then--玩家所在国家的国旗刷新
		return "#v1_img_qun.png"
	elseif nCountry == e_type_country.shuguo then
		return "#v1_img_han.png"
	elseif nCountry == e_type_country.weiguo then
		return "#v1_img_qing.png"
	elseif nCountry == e_type_country.wuguo then
		return "#v1_img_chu.png"
	end
	return "#v1_img_qun.png"
end

--获取地图背景
function WorldFunc.getCountryBgImg( nCountry )
	if nCountry == e_type_country.qunxiong then--玩家所在国家的国旗刷新
		return "#v1_img_graylump.png"
	elseif nCountry == e_type_country.shuguo then
		return "#v1_img_redlump.png"
	elseif nCountry == e_type_country.weiguo then
		return "#v1_img_bluelump.png"
	elseif nCountry == e_type_country.wuguo then
		return "#v1_img_greenlump.png"
	end
	return "#v1_img_graylump.png"
end

--获取视图点背景
function WorldFunc.getWorldCityDotBgImg( nCountry )
	if nCountry == e_type_country.qunxiong then--玩家所在国家的国旗刷新
		return "#v1_line_sj_gray.png"
	elseif nCountry == e_type_country.shuguo then
		return "#v1_line_sj_red.png"
	elseif nCountry == e_type_country.weiguo then
		return "#v1_line_sj_blue.png"
	elseif nCountry == e_type_country.wuguo then
		return "#v1_line_sj_green.png"
	end
	return "#v1_line_sj_gray.png"
end

--获取视图点背景层(背景由四张图组成)
function WorldFunc.getWorldCityDotBgImgLayer( sImgPath )
    local pBgLayer = MUI.MLayer.new()
    pBgLayer:setAnchorPoint(0.5, 0.5)
    pBgLayer:setContentSize(0, 0)

    local pImgBgLT = MUI.MImage.new(sImgPath)
    pImgBgLT:setAnchorPoint(0, 1)
    pImgBgLT:setScaleX(-1)
    pImgBgLT:setScaleY(-1)
	pBgLayer:addView(pImgBgLT)

    local pImgBgRT = MUI.MImage.new(sImgPath)
    pImgBgRT:setAnchorPoint(0, 1)
    pImgBgRT:setScaleY(-1)
	pBgLayer:addView(pImgBgRT)

    local pImgBgLB = MUI.MImage.new(sImgPath)
    pImgBgLB:setAnchorPoint(0, 1)
    pImgBgLB:setScaleX(-1)
	pBgLayer:addView(pImgBgLB)

    local pImgBgRB = MUI.MImage.new(sImgPath)
    pImgBgRB:setAnchorPoint(0, 1)
	pBgLayer:addView(pImgBgRB)

    local pImgBgs = {pImgBgLT, pImgBgRT, pImgBgLB, pImgBgRB}      
    pBgLayer.changeBgImg = function(obj,sPath)
        for k, v in pairs(pImgBgs) do	        
            v:setCurrentImage(sPath)
        end
    end

    return pBgLayer
end

--设置国家旗帜
function WorldFunc.setImgCountryFlag(pImg, nCountry)
	if not pImg then
		return
	end
	pImg:setCurrentImage(WorldFunc.getCountryFlagImg(nCountry))
end


--视图点相关icon标签
local nWorldIconTag = "name201705121831"
local nWorldIconTagNew = 2017090715554

--容器设置野军图标
--pContainer ：容器
--nRebelId:乱军id
--bIsFixScale:是否适至容器大小
--bIsWorld 是否是世界
function WorldFunc.getWildArmyIconOfContainer( pContainer, nRebelId, bIsFixScale, bIsWorld,_nType)
	if not pContainer then
		return
	end
	local nType = _nType or e_type_builddot.wildArmy
	local tWorldEnemyData = nil
	if nType == e_type_builddot.wildArmy then

		tWorldEnemyData = getWorldEnemyData(nRebelId)
	elseif nType == e_type_builddot.ghostdom then
		tWorldEnemyData = getWorldGhostdomData(nRebelId)
	end

	if tWorldEnemyData then
		--乱军图片
		local sImgPath = tWorldEnemyData.sIcon
		local pImg = nil
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pContainer:addView(pImg)
				pImg:setName(nWorldIconTag)
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
		end
		if bIsFixScale then
			-- WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end

--容器设置魔兵图标
--pContainer ：容器
--nRebelId:乱军id
--bIsFixScale:是否适至容器大小
--bIsWorld 是否是世界
function WorldFunc.getMoBingIconOfContainer( pContainer, nRebelId, bIsFixScale, bIsWorld)
	if not pContainer then
		return
	end
	local tMoBingData = getAwakeArmyData(nRebelId)
	if tMoBingData then
		--乱军图片
		local sImgPath = tMoBingData.sIcon
		local pImg = nil
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pContainer:addView(pImg)
				pImg:setName(nWorldIconTag)
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
		end
		if bIsFixScale then
			-- WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end

--容器设置野军动画
--pContainer ：容器
--nRebelId:乱军id
function WorldFunc.getWildArmyArmOfContainer( pContainer, nRebelId, nX, nY)
	if not pContainer then
		return
	end
	local WildArmyArm = require("app.layer.world.WildArmyArm")
	local tWorldEnemyData = getWorldEnemyData(nRebelId)
	if tWorldEnemyData then
		local nTag = 201708101504
		local pWildArmyArm = pContainer:getChildByTag(nTag)
		local nGif = tWorldEnemyData.gif
		if pWildArmyArm then
			pWildArmyArm:setData(nGif)
		else
			pWildArmyArm = WildArmyArm.new(nGif)
			pContainer:addView(pWildArmyArm)
			pWildArmyArm:setTag(nTag)
			centerInView(pContainer, pWildArmyArm)
		end
		return pWildArmyArm
	end
	return nil
end

--获取乱军动画
function WorldFunc.getWildArmyArmData( nArmyGif )
	if nArmyGif == 1 then
		tArmData = EffectWorldDatas["wildArmyInfantry"]
	elseif nArmyGif == 2 then
		tArmData = EffectWorldDatas["wildArmyArcher"]
	elseif nArmyGif == 3 then
		tArmData = EffectWorldDatas["wildArmyCavalry"]
	elseif nArmyGif == 4 then
		tArmData = EffectWorldDatas["wildArmy3x3"]
		-- tArmData = {
		-- 	EffectWorldDatas["wildArmy3x3_1"],
		-- 	EffectWorldDatas["wildArmy3x3_2"],
		-- 	EffectWorldDatas["wildArmy3x3_3"],
		-- 	EffectWorldDatas["wildArmy3x3_4"],
		-- 	EffectWorldDatas["wildArmy3x3_5"],
		-- 	EffectWorldDatas["wildArmy3x3_6"],
		-- 	EffectWorldDatas["wildArmy3x3_7"],
		-- 	EffectWorldDatas["wildArmy3x3_8"],
		-- 	EffectWorldDatas["wildArmy3x3_9"],
		-- }
	end
	return tArmData
end

--容器设置资源图标
--pContainer ：容器
--nMineId:乱军id
--bIsFixScale:是否适至容器大小
--bIsWorld 是否是世界
function WorldFunc.getMineIconOfContainer( pContainer, nMineId, bIsFixScale, bIsWorld)
	if not pContainer then
		return
	end
	local tWorldMineData = getWorldMineData(nMineId)
	if tWorldMineData then
		local sImgPath = tWorldMineData.sIcon
		local pImg = nil
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pContainer:addView(pImg)
				pImg:setName(nWorldIconTag)
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
			
		end
		if bIsFixScale then
			-- WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end

--容器设置城池图标
--pContainer ：容器
--nLv: 城池等级
--bIsFixScale:是否适至容器大小
--bIsWorld 是否是世界
function WorldFunc.getCityIconOfContainer( pContainer, nCountry, nLv ,bIsFixScale, bIsWorld)
	if not pContainer or not nCountry or not nLv then
		return
	end
	local sImgPath = getPlayerCityIcon(nLv, nCountry)
	if sImgPath then
		local pImg = nil
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)	
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
			
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pImg:setName(nWorldIconTag)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
		end
		if bIsFixScale then
			WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end

--容器设置系统城池图标
--pContainer ：容器
--cityId: 城池id
--nCountry: 城池国家
--bIsFixScale:是否适至容器大小
--bIsWorld 是否是世界
function WorldFunc.getSysCityIconOfContainer( pContainer, cityId, nCountry ,bIsFixScale, bIsWorld)
	if not pContainer then
		return
	end
	local tCityData = getWorldCityDataById(tonumber(cityId))
	if tCityData then
		if nCountry == nil then
			nCountry = e_type_country.qunxiong
		end
		local pImg = nil
		local sImgPath = tCityData.tCityicon[nCountry]
		if not sImgPath then
			return
		end
		--世界要平面处理
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				--居中
				centerInView(pContainer, pImg)
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pImg:setName(nWorldIconTag)
				pContainer:addView(pImg)
				--居中
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
		end
		
		--适配容器大小
		if bIsFixScale then
			WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end

--容器设置Boss图标
--pContainer ：容器
--nLv:Boss等级
--bIsFixScale:是否适至容器大小
--bIsWorld 是否是世界
function WorldFunc.getBossIconOfContainer( pContainer, nLv, bIsFixScale, bIsWorld)
	if not pContainer or not nLv then
		return
	end
	local tBossData = getAwakeBossData(nLv, Player:getWuWangDiff())
	if tBossData then
		--乱军图片
		local sImgPath = tBossData.sIcon
		local pImg = nil
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pContainer:addView(pImg)
				pImg:setName(nWorldIconTag)
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
		end
		if bIsFixScale then
			-- WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end

function WorldFunc.getGhostIconOfContainer( pContainer, nId, bIsFixScale, bIsWorld)
	if not pContainer or not nId then
		return
	end
	local tNpcData ,tNpcDetailData  = getGhostBossById(nId)
	if tNpcDetailData then
		--乱军图片
		local sImgPath = "#"..tNpcDetailData.icon..".png"
		local pImg = nil
		if bIsWorld then
			pImg = pContainer:getChildByTag(nWorldIconTagNew)
			if not pImg then
				pImg = createCCBillBorad(sImgPath)
				pImg:setTag(nWorldIconTagNew)
				pContainer:addView(pImg)
				centerInView(pContainer, pImg)
			else
				pImg:setSpriteFrame(getSpriteFrameByName(sImgPath))
			end
		else
			pImg = pContainer:findViewByName(nWorldIconTag)
			if not pImg then
				pImg = MUI.MImage.new(sImgPath)
				pContainer:addView(pImg)
				pImg:setName(nWorldIconTag)
				centerInView(pContainer, pImg)
			else
				pImg:setCurrentImage(sImgPath)
			end
		end
		if bIsFixScale then
			-- WorldFunc.fixScaleToContent(pContainer, pImg)
		end
		return pImg
	end
	return nil
end


--容器设置限时Boss图标
--pContainer ：容器
--bIsFixScale:是否适至容器大小
function WorldFunc.getTLBossIconOfContainer( pContainer, bIsFixScale)
	if not pContainer then
		return
	end
	--乱军图片
	local sImgPath = "#v1_img_boss2.png"
	local pImg = pContainer:findViewByName(nWorldIconTag)
	if not pImg then
		pImg = MUI.MImage.new(sImgPath)
		pContainer:addView(pImg)
		pImg:setName(nWorldIconTag)
		centerInView(pContainer, pImg)
	else
		pImg:setCurrentImage(sImgPath)
	end
	if bIsFixScale then
		-- WorldFunc.fixScaleToContent(pContainer, pImg)
	end
	return pImg
end

--容器设置纣王图标
--pContainer ：容器
--bIsFixScale:是否适至容器大小
function WorldFunc.getZhouwangIconOfContainer( pContainer, bIsFixScale)
	if not pContainer then
		return
	end
	--乱军图片	
	local sImgPath = "#v1_img_boss.png"
	local pKingZhou = WorldFunc.getKingZhouConfData()
	if pKingZhou then
		sImgPath = pKingZhou.sRoleImg					
	end			
	local pImg = pContainer:findViewByName(nWorldIconTag)
	if not pImg then
		pImg = MUI.MImage.new(sImgPath)
		pContainer:addView(pImg)
		pImg:setName(nWorldIconTag)
		centerInView(pContainer, pImg)
	else
		pImg:setCurrentImage(sImgPath)
	end
	if bIsFixScale then
		-- WorldFunc.fixScaleToContent(pContainer, pImg)
	end
	return pImg
end

--获取纣王配置信息
function WorldFunc.getKingZhouConfData()
	local nMonsterID = getKingZhouInitData("npc")
	local tGroup = getNpcGropById(nMonsterID)
	if tGroup and tGroup[1] then
		tGroup[1].sRoleImg = "#v1_img_boss.png"
		return tGroup[1]
	end
	return nil
end

--设置远近视角相机类型
function WorldFunc.setCameraMaskForView( _pView, bIsNow )
	-- body
	--是否开启远近视角
	if b_open_far_and_near_view_forworld then
		_pView:setCameraMask(MUI.CAMERA_FLAG.USER1,true)
		-- if bIsNow then
		-- 	_pView:setCameraMask(MUI.CAMERA_FLAG.USER1,true)
		-- else
		-- 	doDelayForSomething(_pView,function (  )
		-- 		-- body
		-- 		_pView:setCameraMask(MUI.CAMERA_FLAG.USER1,true)
		-- 	end,0.1)
		-- end
	end
	
end

--设置高于远近视角相机类型
function WorldFunc.setHighCameraMaskForView( _pView )
	-- body
	--是否开启远近视角
	if b_open_far_and_near_view_forworld then
			-- body
		_pView:setCameraMask(MUI.CAMERA_FLAG.USER2,true)
	end
	
end

--适应大小
function WorldFunc.fixScaleToContent(pContainer, pTarget)
	if not pContainer or not pTarget then
		return
	end
	local pSize = pContainer:getContentSize()
	local pSize2 = pTarget:getContentSize()
	local nLen = math.max(pSize2.width, pSize2.height)
	if nLen == pSize2.width then
		pTarget:setScale(pSize.width/nLen)
	else
		pTarget:setScale(pSize.height/nLen)
	end
end

--坐标点转到指定区域坐标
--区域视图大小
-- fX:在世界视图x坐标
-- fY:在世界视图y坐标
-- bIsFixedPos 是否先修正位置（用于地图背景)
--返回在指定区域中的坐标
function WorldFunc.parseWorldToBlock( pSize, fX, fY, bIsFixedPos)
	--越界
	local nDotX, nDotY = WorldFunc.getDotPosByMapPos(fX, fY)
	if not nDotX then
		myprint("parseWorldToBlock 越界")
		return nil
	end
	if bIsFixedPos then
		--位置修正
		fX, fY = WorldFunc.getMapPosByDotPos(nDotX, nDotY)
	end
	--区域范围数据
	local tRangeData = WorldFunc.getBlockRangeData(nDotX, nDotY)
	if not tRangeData then
		myprint("tBlockAreaData 出错")
		return nil
	end

	--世界视图中的x,y坐标
	local fWorldX,fWorldY = WorldFunc.getMapPosByDotPos(tRangeData.pLeftDot.x, tRangeData.pLeftDot.y)
	if not fWorldX then
		myprint("WorldFunc.getMapPosByDotPos 出错",tRangeData.pLeftDot.x, tRangeData.pLeftDot.y)
		return nil
	end

	--大地图和小地图的缩小比率
	local fWidthRate = pSize.width/(BLOCK_GRID * UNIT_WIDTH)
	local fHeightRate = pSize.height/(BLOCK_GRID * UNIT_HEIGHT)

	--取得是中心点所以要修正
	fWorldX = fWorldX - UNIT_WIDTH/2
	fWorldY = fWorldY - UNIT_HEIGHT/2

	--世界视图坐标间的向量值
	local fOffsetX = fX - fWorldX
	local fOffsetY = fY - fWorldY

	--乘以缩放比例
	fOffsetX = fOffsetX * fWidthRate
	fOffsetY = fOffsetY * fHeightRate

	--加上区域视图最左边坐标的Y值
	local fBlockX = fOffsetX
	local fBlockY = fOffsetY + pSize.height/2
	return fBlockX, fBlockY
end


--区域坐标点转到指定区域坐标
--区域id,
--区域视图大小
-- fX:在区域x坐标
-- fY:在区域y坐标
--返回在世界中的坐标
function WorldFunc.parseBlockToWorld( nBlockId, pSize, fX, fY)
	--空的不开放
	local tBlockData = getWorldMapDataById(nBlockId)
	if not tBlockData then
		return nil
	end

	--判断是否越界
	if pointInLingxingEx(pSize.width, pSize.height, fX, fY) then

		--相对于最左边的点的距离
		local nOffsetX = fX - 0
		local nOffsetY = fY - pSize.height/2

		--相对于最左边的点的距离的百分比
		local fPercentX = nOffsetX/pSize.width
		local fPercentY = nOffsetY/pSize.height

		--大地图格子左边的点
		local fWorldX, fWorldY = WorldFunc.getMapPosByDotPos(tBlockData.xstart, tBlockData.ystart)
		--取得是中心点所以要修正
		fWorldX = fWorldX - UNIT_WIDTH/2
		fWorldY = fWorldY - UNIT_HEIGHT/2

		--加上相对偏移量
		fWorldX = fWorldX + (BLOCK_GRID * UNIT_WIDTH) * fPercentX
		fWorldY = fWorldY + (BLOCK_GRID * UNIT_HEIGHT) * fPercentY

		return fWorldX, fWorldY
	end
	return nil
end

--获取世界像素点位置(主要是多个格子城池能获取中心点)
function WorldFunc.getMapPosByDotPosEx( nDotX, nDotY )
	local fX, fY = WorldFunc.getMapPosByDotPos( nDotX, nDotY )
	if not fX then
		return
	end
	local tSysCityData = getWorldCityDataByPos(nDotX, nDotY)
	if tSysCityData then
		fX = tSysCityData.tMapPos.x
		fY = tSysCityData.tMapPos.y
	end
	return fX, fY
end

--任务状态是否显示线
function WorldFunc.getIsShowLine( nState )
	if nState == e_type_task_state.go or nState == e_type_task_state.back or nState == e_type_task_state.waitbattle then
		return true
	end
	return false
end

--任务状态是否显示线
function WorldFunc.getIsShowLineTask( tTaskMsg )
	local nState = tTaskMsg.nState
	if nState == e_type_task_state.waitbattle then
		return true
	end
	if nState == e_type_task_state.go or nState == e_type_task_state.back then
		return tTaskMsg:getCd() > 0
	end
	return false
end

--创建进击特效
function WorldFunc.getViewDotAtkEffect( pView, fX, fY, nZorder, fScale)
	local pArmActions = {}
	for i=1,3 do
		local tArmData = nil
		if fScale then
			tArmData = clone(EffectWorldDatas["gridAtk"..i])
			tArmData.fScale = fScale
		else
			tArmData = EffectWorldDatas["gridAtk"..i]
		end
		local pArmAction = MArmatureUtils:createMArmature(
			tArmData, 
			pView, 
			nZorder, 
			cc.p(fX-2, fY),
		    function (  )
			end, Scene_arm_type.world)
		pArmAction:play(-1)
		table.insert(pArmActions, pArmAction)
	end
	return pArmActions
end

function WorldFunc.setViewDotAtkEffectScale( pArms, scale )
	for i=1,#pArms do
		local tData = clone(EffectWorldDatas["gridAtk"..i])
		---
		tData.fScale = scale
		pArms[i]:setData(tData)
	end
end

--系统城池影子图片缩放比例
function WorldFunc.setSysCityShadowImgScale( pImg, nKind)
	if not pImg or not nKind then
		return
	end
	if nKind == e_kind_city.zhongxing then
		pImg:setScale(1)
	elseif nKind == e_kind_city.ducheng then
		pImg:setScale(0.8)
	elseif nKind == e_kind_city.mingcheng then
		pImg:setScale(0.6)
	else
		pImg:setScale(0.8)
	end
end

--玩家城池点图片缩放比例
function WorldFunc.setPlayerDotImgScale( pImg, nPalaceLv)
	if not pImg or not nPalaceLv then
		return
	end
	local tData = getBuildUpLimitsFromDB(e_build_ids.palace, nPalaceLv)
	if tData then
		pImg:setScale(tData.iconrate)
	end
end

--补充城防
function WorldFunc.fillSysCityTroops( nCityId )
	local citydata = getWorldCityDataById(nCityId)
	if not citydata then
		return
	end
	local temp = luaSplit(citydata.recovercost, ";") 
	local isenough = true
	local resstr = ""
	for k, v in pairs(temp) do
		local tt = luaSplit(v, ":")
		local id = tonumber(tt[1]) 
		local cnt = tonumber(tt[2])
		local res = getGoodsByTidFromDB(id)
		if getMyGoodsCnt(id) < cnt then
			isenough = false
		end 
		if k == 1 then
			resstr = resstr..formatCountToStr(cnt)..res.sName
		else
			resstr = resstr..","..formatCountToStr(cnt)..res.sName
		end
	end
	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
    	local DlgAlert = require("app.common.dialog.DlgAlert")
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))

    local tStr = {
    	{color=_cc.pwhite,text=getConvertedStr(6, 10101)},
	    {color=_cc.yellow,text=resstr},
	    {color=_cc.pwhite,text=getConvertedStr(6, 10419)},
	}
	local MRichLabel = require("app.common.richview.MRichLabel")
	local pRichLabel = MRichLabel.new({str = tStr, fontSize = 20, rowWidth = 380})
    pDlg:addContentView(pRichLabel)
    pDlg:setRightHandler(function (  )
    	if isenough == true then
	        SocketManager:sendMsg("reqSupplyCity", {nCityId}, function ( __msg )
	        	if  __msg.head.state == SocketErrorType.success then 
					if __msg.head.type == MsgType.reqSupplyCity.id then
						TOAST(getTipsByIndex(10071))				
					end
				else
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
	        end)	
	        pDlg:closeDlg(false)
    	else
    		TOAST("资源不足")
    	end
    end)
    pDlg:showDlg(bNew)	
end

--预计资源收获
--nHeroTid:武将id
--nMineId:资源点id
function WorldFunc.getCollectPreview( nHeroTid, nMineId)
	local tHeroData = getHeroDataById(nHeroTid)
	if not tHeroData then
		return 0
	end

	local tMine = getWorldMineData(nMineId)
	if not tMine then
		return 0
	end

	local tCollectTime = getWorldInitData("collectTime")
	local nTime = tCollectTime[tHeroData.nQuality] or 0
	local fPercentAdd = 0
	local nOutput = tMine.output
	if nOutput == e_type_resdata.coin then--银币 
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(105)
	elseif nOutput == e_type_resdata.wood then--银币 
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(106)
	elseif nOutput == e_type_resdata.food then--粮草 
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(107)
	elseif nOutput == e_type_resdata.iron then--镔铁
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(108)
	end
	return math.ceil(tMine.crop * (1 + fPercentAdd) * nTime/3600)
end

--预计资源收获
--nMineId:资源点id
--nCanTime：可以采取的时间
function WorldFunc.getCollectPreviewBase( nMineId, nCanTime )
	local tMine = getWorldMineData(nMineId)
	if not tMine then
		return 0
	end

	return tMine.crop * nCanTime
end

--获取额外收获
--nMineId:资源点id
--nGetBase:基础收获
function WorldFunc.getCollectPreviewEx( nMineId, nGetBase)
	local tMine = getWorldMineData(nMineId)
	if not tMine then
		return 0
	end

	local fPercentAdd = 0
	local nOutput = tMine.output
	if nOutput == e_type_resdata.coin then--银币 
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(105)
	elseif nOutput == e_type_resdata.wood then--银币 
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(106)
	elseif nOutput == e_type_resdata.food then--粮草 
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(107)
	elseif nOutput == e_type_resdata.iron then--镔铁
		fPercentAdd = Player:getBuffData():getBuffPercentAdds(108)
	end

	 --显示活动额外增收(金矿除外)
    if tMine.type ~= e_type_mines.gold then
    	local tAct=Player:getActById(e_id_activity.doublecollect)
		if tAct and tAct:isOpen() then
			fPercentAdd = fPercentAdd + tAct.nX
		end		
    end

    return nGetBase * fPercentAdd
end


--世界开保护打别人，或出征国战提示
--回调
function WorldFunc.checkIsAttackCityInProtect( nHandler )
	if Player:getWorldData():getProtectCD() > 0 then
		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.citywarprotectconfirm, --dlg类型
	    	nCallBackFunc = nHandler,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
		return true
	end
	return false
end

--系统城池周围
local tSySCityAroundPos = nil
function WorldFunc.initSysCityAroundPos(  )
	if not tSySCityAroundPos then
		tSySCityAroundPos = {}
		--点击系统城池周围一圈不可操作
		local tCityDatas = getWorldCityData()
		for k,tCityData in pairs(tCityDatas) do
			local tCoordinate = tCityData.tCoordinate
			if tCoordinate then
				local nLeftX = nil
				local nLeftY = nil
				local nRightX = nil 
				local nRightY = nil
				if tCityData.kind == e_kind_city.firetown then --烽火台特殊处理，还没有想好怎么跟触碰连接起来，以后优化znftodo
					nLeftX = tCoordinate.x
					nLeftY =  tCoordinate.y
					nRightX = tCoordinate.x2
					nRightY = tCoordinate.y2
				else
					if tCoordinate.x and tCoordinate.y and tCoordinate.x2 and tCoordinate.y2 then
						nLeftX = tCoordinate.x - 1
						nLeftY =  tCoordinate.y - 1
						nRightX = tCoordinate.x2 + 1
						nRightY = tCoordinate.y2 + 1
					elseif tCoordinate.x and tCoordinate.y then
						nLeftX = tCoordinate.x - 1
						nLeftY =  tCoordinate.y - 1
						nRightX = tCoordinate.x + 1
						nRightY = tCoordinate.y + 1
					end
				end
				--系统城池一圈不可以操作
				if nLeftX and nLeftY and nRightX and nRightY then
					for nDotX=nLeftX, nRightX do
						for nDotY=nLeftY, nRightY do
							local sDotKey = string.format("%s_%s", nDotX, nDotY)
						 	tSySCityAroundPos[sDotKey] = tCityData.id
						end
					end
				end
			end
		end
	end
end

--是否点击了系统城池周围
function WorldFunc.checkIsSySCityAround( nX, nY)
	WorldFunc.initSysCityAroundPos()
	local sDotKey = string.format("%s_%s", nX, nY)
	if tSySCityAroundPos[sDotKey] then
		return true
	end
	return false
end

--点击了系统城池周围返回SysCity id
function WorldFunc.getSysCityIdInAround( nX, nY)
	WorldFunc.initSysCityAroundPos()
	local sDotKey = string.format("%s_%s", nX, nY)
	return tSySCityAroundPos[sDotKey]
end

--获取Boss旗子图片(小地图显示)
function WorldFunc.getWorldBossFlagFile( nLv )
	if nLv == 3 then
		return "#v2_img_emobiaozhi2.png"
	else
		return "#v2_img_emobiaozhi.png"
	end
end

--设置Boss旗子
function WorldFunc.setWorldBossFlag( pImgFlag, nLv )
	if not pImgFlag then
		return
	end
	local sImg = WorldFunc.getWorldBossFlagFile(nLv)
	pImgFlag:setCurrentImage(sImg)
end

--设置Boss地图点
function WorldFunc.setWorldBossBBFlag( pBillborad, nLv )
	if not pBillborad then
		return
	end

	if nLv == 3 then
		pBillborad:setSpriteFrame(getSpriteFrameByName("#v2_img_dengjidi03.png"))
	else
		pBillborad:setSpriteFrame(getSpriteFrameByName("#v2_img_dengjidi02.png"))
	end
end

--获取TLBoss旗子图片(小地图显示)
function WorldFunc.getWorldTLBossFlagFile(  )
	return "#v2_img_emobiaozhi2.png"
end

--根据文本宽度更新名字图片纹理
function WorldFunc.updateBbNameBgByStrWidth( pBbNameBg, nWidth )
	if not pBbNameBg then
		return
	end
	if not nWidth then
		return
	end

	--更新等级背景大小
	if nWidth <= 46 then
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg1a.png"))
	elseif nWidth <= 64 then
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg1.png"))
	elseif nWidth <= 82 then
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg2.png"))
	elseif nWidth <= 100 then
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg3.png"))
	elseif nWidth <= 118 then
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg4.png"))
	elseif nWidth <= 136 then
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg5.png"))
	else 
		pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg6g.png"))

	end
end

--是否在未解锁的区域，是就弹出相关提示
function WorldFunc.checkIsInLockBlock( nDotX, nDotY )
	--容错
	if not nDotX or not nDotY then
		TOAST(getConvertedStr(3, 10435))
		return false
	end

	--可视状态
	if Player:getWorldData():getBlockIsCanSeeByPos(nDotX, nDotY) then
		return false
	end


	local tStr = {
		{color=_cc.white,text=getConvertedStr(3, 10400)},
	}
	local nBlockId = WorldFunc.getBlockId(nDotX, nDotY)
	if nBlockId then
		local tLastMapData = nil
		local tMapData = getWorldMapDataById(nBlockId)
		if tMapData then
			if tMapData.type == e_type_block.jun or tMapData.type == e_type_block.kind then
				local nBlockId2 = Player:getWorldData():getMyCityBlockId()
				tLastMapData = getWorldMapDataById(nBlockId2)
				--如果前往的郡和自己的郡是同属一个州的，就要攻打本国的开启郡的中心城
				if tMapData.type == e_type_block.jun and tLastMapData.subordinate == tMapData.subordinate then
					--tLastMapData这里就是自己的区域值，所以不用处理 
				else
					--如果前往的是别的郡，就要攻打本国的开启阿房宫的州的中心城
					while tLastMapData do
						if tLastMapData.type == e_type_block.zhou then
							break
						end
						tLastMapData = getWorldMapDataById(tLastMapData.subordinate)
					end
				end
			else
				--如果前往的是别的州，就要攻打本国的开启郡的中心城
				local nBlockId2 = Player:getWorldData():getMyCityBlockId()
				tLastMapData = getWorldMapDataById(nBlockId2)
			end
		end
		if tLastMapData then
			local tCityData = getWorldCityDataById(tLastMapData.maincity)
		    if tCityData then
		  --  		tStr = {
			 --    	{color=_cc.white,text=getConvertedStr(3, 10515)},
				--     {color=_cc.yellow,text=tCityData.name},
				--     {color=_cc.white,text=getConvertedStr(3, 10516)},
				-- }
				local tObject = {}
				tObject.nType = e_dlg_index.dlgareanotopen --dlg类型
				tObject.tCityData = tCityData --数据
				sendMsg(ghd_show_dlg_by_type,tObject)
			end
		end
	else
		tStr = {
			{color=_cc.white, text = getTipsByIndex(20042)}
		}
		--二次确认框
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10514))
	    pDlg:setContent(tStr)
	    pDlg:setRightHandler(function (  )
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)
	    pDlg:setOnlyConfirm(getConvertedStr(3,10381))
	end

	return true
end

--判断是否需要弹出空白区域提示
function WorldFunc.getIsShowInNullBlock( nDotX, nDotY )
	local bIsShow = true
	local tBlockDataDict = getWorldMapData()
	for k,tBlockData in pairs(tBlockDataDict) do
		-- print("nDotX, nDotY=",nDotX, nDotY,tBlockData.xstart - 4, tBlockData.xover + 4,tBlockData.xstart - 4 <= nDotX and tBlockData.xover + 4 <= nDotX, tBlockData.ystart - 4, tBlockData.yover + 4,tBlockData.ystart - 4 <= nDotY and tBlockData.yover + 4 <= nDotY )
		if tBlockData.xstart - 4 <= nDotX and nDotX <= tBlockData.xover + 4 and 
			tBlockData.ystart - 4 <= nDotY and nDotY <= tBlockData.yover + 4 then
			bIsShow = false
			break
		end 
	end
	return bIsShow
end


-- --获取城池防护罩动画7层
-- function WorldFunc.setCityProtectArms( pLayBack, pLayFront)
-- 	if not pLayBack or not pLayFront then
-- 		return
-- 	end

-- 	--添加纹理
-- 	addTextureToCache("tx/other/sg_ccbh_xlz_dbgy")

-- 	--位置
-- 	--local pPos = cc.p(pLayArm:getContentSize().width/2, pLayArm:getContentSize().height/2)
-- 	local pPos = cc.p(0, 0)

-- 	-- 第一层：（左上角光墙序列帧）  透明度改为：50%
-- 	local tProtectArm1 = 
-- 	{
-- 		nFrame = 15, -- 总帧数
-- 		pos = {-100, 73}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale = 1,-- 初始的缩放值
--         fScaleX = -1.36, 
--         fScaleY = 1.36, 
-- 		nBlend = 1, -- 需要加亮
-- 	   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 		tActions = {
-- 			 {
-- 				nType = 1, -- 序列帧播放
-- 				sImgName = "sg_ccbh_xlz_dbgy_",
-- 				nSFrame = 1, -- 开始帧下标
-- 				nEFrame = 15, -- 结束帧下标
-- 				tValues = nil, -- 参数列表
-- 			},
-- 		},
-- 	}
-- 	--创建精灵
-- 	local pProtectArm1 = MArmatureUtils:createMArmature(tProtectArm1, 
-- 	pLayBack, 
-- 	0, 
-- 	pPos,
--     function (  )
-- 	end, Scene_arm_type.world)
-- 	--设置透明度
-- 	pProtectArm1:setOpacity(255*0.5)
-- 	WorldFunc.setCameraMaskForView(pProtectArm1) 
-- 	local function createArm1()
-- 		pProtectArm1:play(-1)
-- 	end


-- 	-- 第二层：（右上角光墙序列帧）透明度改为：50%
-- 	local tProtectArm2 =
-- 	{
-- 		nFrame = 15, -- 总帧数
-- 		pos = {98, 71}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale = 1.36,-- 初始的缩放值 
-- 		nBlend = 1, -- 需要加亮
-- 	   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 		tActions = {
-- 			 {
-- 				nType = 1, -- 序列帧播放
-- 				sImgName = "sg_ccbh_xlz_dbgy_",
-- 				nSFrame = 1, -- 开始帧下标
-- 				nEFrame = 15, -- 结束帧下标
-- 				tValues = nil, -- 参数列表
-- 			},
-- 		},
-- 	}
-- 	--创建精灵
-- 	local pProtectArm2 = MArmatureUtils:createMArmature(tProtectArm2, 
-- 	pLayBack, 
-- 	0, 
-- 	pPos,
--     function (  )
-- 	end, Scene_arm_type.world)
-- 	--设置透明度
-- 	pProtectArm2:setOpacity(255*0.5)
-- 	WorldFunc.setCameraMaskForView(pProtectArm2) 
-- 	local function createArm2()
-- 		pProtectArm2:play(-1)
-- 	end

-- 	--第三层（这里需要摆放时间城池）

-- 	--第四层：（上层光墙加暗）
-- 	local tProtectArm4 =
-- 	{
-- 		nFrame = 15, -- 总帧数
-- 		pos = {0, -41}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale = 1.5,-- 初始的缩放值
-- 		nBlend = 0, -- 需要加亮
-- 	  	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 		tActions = {
-- 			{
-- 				nType = 2, -- 透明度
-- 				sImgName = "sg_ccbh_xlz_dbgy01_0002",
-- 				nSFrame = 1,
-- 				nEFrame = 15,
-- 				tValues = {-- 参数列表
-- 					{255, 255}, -- 开始, 结束透明度值
-- 				}, 
-- 			},
-- 		},
-- 	}
-- 	--创建精灵
-- 	local pProtectArm4 = MArmatureUtils:createMArmature(tProtectArm4, 
-- 	pLayFront, 
-- 	0, 
-- 	pPos,
--     function (  )
-- 	end, Scene_arm_type.world)
-- 	pProtectArm4:play(-1)
-- 	WorldFunc.setCameraMaskForView(pProtectArm4) 


-- 	--第五层：（右下角光墙序列帧）
-- 	local tProtectArm5 = 
-- 	{
-- 		nFrame = 15, -- 总帧数
-- 		pos = {97, -26}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale = 1,-- 初始的缩放值 
-- 	        fScaleX = -1.36, 
-- 	        fScaleY = 1.36, 
-- 		nBlend = 1, -- 需要加亮
-- 	   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 		tActions = {
-- 			 {
-- 				nType = 1, -- 序列帧播放
-- 				sImgName = "sg_ccbh_xlz_dbgy_",
-- 				nSFrame = 1, -- 开始帧下标
-- 				nEFrame = 15, -- 结束帧下标
-- 				tValues = nil, -- 参数列表
-- 			},
-- 		},
-- 	}
-- 	--创建精灵
-- 	local pProtectArm5 = MArmatureUtils:createMArmature(tProtectArm5, 
-- 	pLayFront, 
-- 	0, 
-- 	pPos,
--     function (  )
-- 	end, Scene_arm_type.world)
-- 	WorldFunc.setCameraMaskForView(pProtectArm5) 
-- 	local function createArm5()
-- 		pProtectArm5:play(-1)
-- 	end

-- 	--第六层：（左下角光墙序列帧）
-- 	local tProtectArm6 = 
-- 	{
-- 		nFrame = 15, -- 总帧数
-- 		pos = {-99, -26}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale = 1.36, 
-- 		nBlend = 1, -- 需要加亮
-- 	   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 		tActions = {
-- 			 {
-- 				nType = 1, -- 序列帧播放
-- 				sImgName = "sg_ccbh_xlz_dbgy_",
-- 				nSFrame = 1, -- 开始帧下标
-- 				nEFrame = 15, -- 结束帧下标
-- 				tValues = nil, -- 参数列表
-- 			},
-- 		},
-- 	}
-- 	--创建精灵
-- 	local pProtectArm6 = MArmatureUtils:createMArmature(tProtectArm6, 
-- 	pLayFront, 
-- 	0, 
-- 	pPos,
--     function (  )
-- 	end, Scene_arm_type.world)
-- 	WorldFunc.setCameraMaskForView(pProtectArm6) 
-- 	local function createArm6()
-- 		pProtectArm6:play(-1)
-- 	end


-- 	--第七层：（墙体边缘光环2）
-- 	local tProtectArm7 = 
-- 	{
-- 		nFrame = 30, -- 总帧数
-- 		pos = {-2, -74}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale = 1.5,-- 初始的缩放值
-- 		nBlend = 1, -- 需要加亮
-- 	  	nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
-- 		tActions = {
-- 			{
-- 				nType = 2, -- 透明度
-- 				sImgName = "sg_ccbh_xlz_dbgy01_0001",
-- 				nSFrame = 1,
-- 				nEFrame = 15,
-- 				tValues = {-- 参数列表
-- 					{255, 200}, -- 开始, 结束透明度值
-- 				}, 
-- 			},
-- 			{
-- 				nType = 2, -- 透明度
-- 				sImgName = "sg_ccbh_xlz_dbgy01_0001",
-- 				nSFrame = 15,
-- 				nEFrame = 30,
-- 				tValues = {-- 参数列表
-- 					{200, 255}, -- 开始, 结束透明度值
-- 				}, 
-- 			},
-- 		},
-- 	}
-- 	--创建精灵
-- 	local pProtectArm7 = MArmatureUtils:createMArmature(tProtectArm7, 
-- 	pLayFront, 
-- 	0, 
-- 	pPos,
--     function (  )
-- 	end, Scene_arm_type.world)
-- 	pProtectArm7:play(-1)
-- 	WorldFunc.setCameraMaskForView(pProtectArm7) 

-- 	--错开分侦播放--（其中 一层、二层、五层、六层、为序列帧层，  序列帧层需要错开时间播放，分别错开为1 3 5 7帧开始播放,
-- 	gRefreshViewsAsync(pLayBack, 7, function ( _bEnd, _index )
-- 		if _index == 1 then
-- 			createArm1()
-- 		elseif _index == 3 then
-- 			createArm2()
-- 		elseif _index == 5 then
-- 			createArm5()
-- 		elseif _index == 7 then
-- 			createArm6()
-- 		end
-- 	end)

-- 	return {pProtectArm1, pProtectArm2, pProtectArm4, pProtectArm5, pProtectArm6, pProtectArm7}
-- end


--获取城池防护罩动画4层
function WorldFunc.setCityProtectArms( pLayBack, pLayFront)
	if not pLayBack or not pLayFront then
		return
	end

	--位置
	local pPos = cc.p(0, 0)

	-- 第一层  光圈底加暗
	local tProtectArm1 = 
	{
		nFrame = 64, -- 总帧数
		pos = {0, 32}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.5,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	  	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "sg_sjdt_bhz_s33_021",
				nSFrame = 1,
				nEFrame = 64,
				tValues = {-- 参数列表
					{255, 255}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	--创建精灵
	local pProtectArm1 = MArmatureUtils:createMArmature(tProtectArm1, 
	pLayFront, 
	0, 
	pPos,
    function (  )
	-- end, Scene_arm_type.world, cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	end, Scene_arm_type.world) --不使用BillBoard_Mode，关掉闪屏，可能造成摄像机压
	--设置透明度
	WorldFunc.setCameraMaskForView(pProtectArm1) 
	pProtectArm1:play(1)

	-- 第二层：（右上角光墙序列帧）透明度改为：50%
	local tProtectArm2 =
	{
		nFrame = 8, -- 总帧数
		pos = {0, 32}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.25,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "sg_sjdt_bhz_s3_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 8, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	--创建精灵
	local pProtectArm2 = MArmatureUtils:createMArmature(tProtectArm2, 
	pLayFront, 
	0, 
	cc.p(pPos.x, pPos.y - 1), --billboard --pPos,
    function (  )
	end, Scene_arm_type.world, cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	WorldFunc.setCameraMaskForView(pProtectArm2) 
	pProtectArm2:play(-1)
		
	--第三层：粒子“lizi_ccbh_xldlz_002” 摆放位置：  坐标(x=0,y=74)      缩放值1.25   
	local pParitcle1 =  createParitcle("tx/other/lizi_ccbh_xldlz_002.plist")
	pParitcle1:setPosition(0, 74)
	pParitcle1:setScale(1.25)
	pLayFront:addView(pParitcle1)

	--第四层： 光波扩散  “sg_sjdt_bhz_s33_022”  每隔1.6秒出现一次。
	-- 时间        缩放值（%）      透明度（255）      位移（Y）
	-- 0秒           40                 46               192
	-- 0.92秒        104                255              164
	-- 1.25秒        120                200              142
	-- 2.67秒        147                0                12
	local function createCircleLight( )
		if tolua.isnull(pLayFront) then
			return
		end

		if not pLayFront:isVisible() then
			return
		end

		local pCircleLight = MUI.MImage.new("#sg_sjdt_bhz_s33_022.png")
		WorldFunc.setCameraMaskForView(pCircleLight)
		pLayFront:addView(pCircleLight)

		pCircleLight:setPosition(0,12)
		pCircleLight:setOpacity(0)

		--兼容一开始显示(地图压)
		-- local pAct0 = cc.DelayTime:create(0.5)

		--正式动画
		local nOffsetTime = 1.5
		local pAct1 = cc.Spawn:create({
		    			cc.ScaleTo:create(0 * nOffsetTime, 0.4),
		    			cc.FadeTo:create(0 * nOffsetTime, 0.46*255),
		    			cc.MoveTo:create(0 * nOffsetTime, cc.p(0,192)),
		    		})
		local pAct2 = cc.Spawn:create({
		    			cc.ScaleTo:create(0.92 * nOffsetTime, 1.04),
		    			cc.FadeTo:create(0.92 * nOffsetTime, 255),
		    			cc.MoveTo:create(0.92 * nOffsetTime, cc.p(0,164)),
		    		})
		local nPrevTime = 0.92 * nOffsetTime
		local pAct3 = cc.Spawn:create({
		    			cc.ScaleTo:create(1.25 * nOffsetTime - nPrevTime, 1.2),
		    			cc.FadeTo:create(1.25 * nOffsetTime - nPrevTime, 200),
		    			cc.MoveTo:create(1.25 * nOffsetTime - nPrevTime, cc.p(0,142)),
		    		})
		local nPrevTime = 1.25 * nOffsetTime
		local pAct4 = cc.Spawn:create({
		    			cc.ScaleTo:create(2.67 * nOffsetTime - nPrevTime, 1.47),
		    			cc.FadeTo:create(2.67 * nOffsetTime - nPrevTime, 0),
		    			cc.MoveTo:create(2.67 * nOffsetTime - nPrevTime, cc.p(0,12)),
		    		})
		pCircleLight:runAction(cc.RepeatForever:create(cc.Sequence:create({pAct1, pAct2, pAct3, pAct4})))
		-- pCircleLight:runAction(cc.RepeatForever:create(cc.Sequence:create({pAct0, pAct1, pAct2, pAct3, pAct4})))
	end

	createCircleLight()
	pLayFront:runAction(cc.Sequence:create({
		cc.DelayTime:create(2),
		cc.CallFunc:create(createCircleLight),
		cc.DelayTime:create(2),
		cc.CallFunc:create(createCircleLight),
		}))

	return {pProtectArm1, pProtectArm2}, nArmSchedule
end

--系统城池是否可申请城主
function WorldFunc.getIsSCityCanExclamation( nSystemCityId )
	local bIsCan = false
	local tCityData = getWorldCityDataById(nSystemCityId)
	if tCityData then
		--都城没有城征收
		if tCityData.kind == e_kind_city.ducheng or tCityData.kind == e_kind_city.zhongxing then
			--
		else
			local tViewDotMsg = Player:getWorldData():getSysCityDot(nSystemCityId)
			if tViewDotMsg then
				--显示申请城主
				if not tViewDotMsg:getIsSysCityHasOwner() and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
					bIsCan = true
				end
			end
		end
	end
	return bIsCan
end