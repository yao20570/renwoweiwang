----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-12 17:00:22
-- Description: 得到物品显示
-----------------------------------------------------
local e_resui_belong = {
	home 		= 1,
	world 		= 2,
	collect  	= 3,
}

--显示获取所有物品
--tItemList:List<Pair<Integer,Long>>	获得物品 (--Pair = {k=,v=})
--nTargetType: 1:飞往主城上方，2:飞往世界上方
function showGetAllItems( tItemList, nTargetType)
	-- tItemList = {
	-- 	{k = 12, v = 999},
	-- 	--
	-- 	{k = 2, v = 999},
	-- 	{k = 5, v = 999},
	-- 	{k = 4, v = 999},
	-- 	{k = 3, v = 999},
	-- 	-- --
	-- 	{k = 100083, v = 99},
	-- 	{k = 100083, v = 99},
	-- 	{k = 100083, v = 99},
	-- 	{k = 100083, v = 99},
	-- 	{k = 100083, v = 99},
	-- 	{k = 100083, v = 99},
		
	-- 	{k = 1, v = 999},
	-- 	{k = 6, v = 999},
	-- 	{k = 7, v = 999},
	-- 	{k = 8, v = 999},
	-- 	{k = 9, v = 999},
	-- 	{k = 10, v = 999},
	-- 	{k = 11, v = 999},
	-- 	{k = 13, v = 999},
	-- }
	if not tItemList then
		return
	end
--一下获得物品的表现保留代码，策划总是改来改去的
---------------------------------------------------------------------------------------
	-- nTargetType = nTargetType or e_resui_belong.home
	-- local tResList = {}
	-- local tOtherResList = {}
	-- local tItemList2 = {}
	-- local tBuffList = {}
	-- local nExp = nil
	-- for i=1,#tItemList do
	-- 	local tItem = tItemList[i]
	-- 	local nItemId = tItem.k
	-- 	local nItemNum = tItem.v
	-- 	if nItemId == e_type_resdata.food or
	-- 		nItemId == e_type_resdata.wood or
	-- 		nItemId == e_type_resdata.iron or
	-- 		nItemId == e_type_resdata.coin then
	-- 		table.insert(tResList, tItem)
	-- 	elseif nItemId == e_type_resdata.exp then
	-- 		nExp = nItemNum
	-- 	elseif nItemId >= 30001 and nItemId <= 39999 then --获得Buff
	-- 		table.insert(tBuffList, tItem)
	-- 	else
	-- 		if(nItemId >= 1 and nItemId <= 199) then -- 资源
	-- 			table.insert(tOtherResList, tItem)
	-- 		else
	-- 			table.insert(tItemList2, tItem)
	-- 		end
	-- 	end
	-- end

	-- -- 优先播放经验获得动画， 再播放 资源获得动画，最后播放道具，装备，资源包等动画。
	-- local fDelay = 0
	-- -- 1、经验值。
	-- if nExp then
	-- 	showGetExp(nExp)
	-- 	fDelay = fDelay + 1
	-- end
	-- -- 2、资源。
	-- if #tResList > 0 then
	-- 	showGetRes(tResList, fDelay, nTargetType)
	-- 	fDelay = fDelay + 1
	-- end

	-- -- 3、道具，装备，资源包等。  
	-- if #tItemList2 > 0 then
	-- 	showGetItems(tItemList2, fDelay, nTargetType)
	-- 	fDelay = fDelay + 1
	-- end

	-- -- 4、其他资源
	-- if #tOtherResList > 0 then
	-- 	showGetOtherRes(tOtherResList, fDelay)
	-- end
	-- -- 5 buff生效
	-- if #tBuffList > 0 then
	-- 	showGetBuffs(tBuffList)
	-- end

--------------------------------------------------------------------------
	--之前的其他表现全部不要了，换成下面这种

	local tResList = {}
	local tOtherResList = {}
	local tItemList2 = {}
	local tBuffList = {}
	local tExp = {}
	for i=1,#tItemList do
		local tItem = tItemList[i]
		local nItemId = tItem.k
		local nItemNum = tItem.v
		if nItemId == e_type_resdata.food or
			nItemId == e_type_resdata.wood or
			nItemId == e_type_resdata.iron or
			nItemId == e_type_resdata.coin then
			table.insert(tResList, tItem)
		elseif nItemId == e_type_resdata.exp then
			table.insert(tExp, tItem)
		elseif nItemId >= 30001 and nItemId <= 39999 then --获得Buff
			table.insert(tBuffList, tItem)
		else
			if(nItemId >= 1 and nItemId <= 199) then -- 资源
				table.insert(tOtherResList, tItem)
			else
				table.insert(tItemList2, tItem)
			end
		end
	end

	--排序
	local tAllItems = {}
	addTrueOrderLists(tAllItems,tExp)
	addTrueOrderLists(tAllItems,tResList)
	addTrueOrderLists(tAllItems,tOtherResList)
	addTrueOrderLists(tAllItems,tItemList2)
	-- addTrueOrderLists(tAllItems,tBuffList) --独立出来做表现
	-- 6 目前只有这种表现
	showRealyItemGet(tAllItems)

	--buff特殊展示
	if #tBuffList > 0 then
		showGetBuffs(tBuffList)
	end
end

--子表插入到父表中
function addTrueOrderLists( _tAllLists, _tSubLists )
	-- body
	if not _tAllLists or not _tSubLists then return end
	if #_tSubLists > 0 then
		for k, v in pairs (_tSubLists) do
			table.insert(_tAllLists, v)
		end
		
	end
end


--经验值获得动画 
--nExp:经验值
function showGetExp( nExp )
	local pRootLayer = RootLayerHelper:getCurRootLayer()
	if not pRootLayer then
		return
	end
	local tGood = getGoodsByTidFromDB(e_type_resdata.exp)
	if not tGood then
		return
	end

    local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if pParView then
    	local nX = display.width/2
    	local nY = display.height/2
    	local nBeginX, nBeginY = nX, nY
    	--层
    	local pLayer = MUI.MLayer.new()
    	pLayer:setPosition(nBeginX, nBeginY)
    	pParView:addView(pLayer)
    	--经验图片
    	local pImgExp = MUI.MImage.new(tGood.sIcon)
    	local pImgWidth = pImgExp:getContentSize().width
    	pImgExp:setScale(0.9)
    	pImgWidth = pImgWidth * 0.9
    	pImgExp:setPosition(-pImgWidth/2, 0)
    	pLayer:addView(pImgExp)
    	--经验文字
    	local pTxtExp = MUI.MLabel.new({text = "+"..tostring(nExp), size = 20})
    	pTxtExp:setPosition(pImgWidth/2, 0)
    	pLayer:addView(pTxtExp)

    	local fOffsetDelay = 0
		--隐藏文字方法
    	local function hideTxtExp(  )
    		if not tolua.isnull(pTxtExp) then
    			pTxtExp:setVisible(false)
    		end
    		if not tolua.isnull(pImgExp) then
    			pImgExp:runAction(cc.FadeOut:create(0.3 + fOffsetDelay))
    		end
    	end
    	--显示粒子
    	local function showParitcle(  )
    		if not tolua.isnull(pLayer) then
    			local pParitcle =  createParitcle("tx/other/lizi_huodejy_sa_02.plist")
    			local nX, nY = pImgExp:getPosition()
    			pParitcle:setPosition(nX, nY)
    			pLayer:addView(pParitcle)
    			local pCurrPoint = pLayer:convertToNodeSpace(cc.p(0,display.height))
    			local pSeqAct = cc.Sequence:create({
    				cc.MoveBy:create(0.2, cc.p(0, 15)),
    				cc.MoveTo:create(0.6, pCurrPoint)})
    			pParitcle:runAction(pSeqAct)
	    	end
    	end
    	--删除层
    	local function removeLayer( )
    		if not tolua.isnull(pLayer) then
    			pLayer:removeSelf()
    		end
    	end
    	
    	--执行方法，注意层消失，粒子，图片也会消息
    	local pSeqAct = cc.Sequence:create({
    		cc.DelayTime:create(0.5 + fOffsetDelay),
    		cc.CallFunc:create(hideTxtExp),
    		cc.DelayTime:create(0.2 + fOffsetDelay),
    		cc.CallFunc:create(showParitcle),
    		cc.DelayTime:create(1.5 + fOffsetDelay),
    		cc.CallFunc:create(removeLayer)}
    	)
    	pLayer:runAction(pSeqAct)
    end
end

--设类型
--设置资源目标位置
local tResUis = {}
--nTargetType：主城还是世界 弹窗
--稻草， 木头， 生铁  ，银币
--pFoodUi, pWoodUi, pIronUi, pCoinUi
function setShowGetItemResUis( nTargetType, pCoinUi, pWoodUi, pFoodUi, pIronUi)
	tResUis[nTargetType] = {}
	tResUis[nTargetType][e_type_resdata.food] = pFoodUi
	tResUis[nTargetType][e_type_resdata.wood] = pWoodUi
	tResUis[nTargetType][e_type_resdata.iron] = pIronUi
	tResUis[nTargetType][e_type_resdata.coin] = pCoinUi
end

function getShowGetItemResUis( nTargetType, nResType )
	-- body
	if not tResUis[nTargetType] then
		return nil
	end
	local pUi = tResUis[nTargetType][nResType]
	return pUi
end

--资源获得动画
--按稻草， 木头， 生铁  ，银币。  从做到右固定位置排列，然后垂直向上移动。 
--tItemList 资源列表
--fDelay :延时
--nTargetType: 1:飞往主城上方，2:飞往世界上方
function showGetRes( tItemList, fDelay, nTargetType)
	if not tResUis[nTargetType] then
		return
	end
	if not tResUis[e_resui_belong.home] then --出现的位置始置像主城一样
		return
	end
	local pRootLayer = RootLayerHelper:getCurRootLayer()
	if not pRootLayer then
		return
	end
	
    local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if pParView then
		--资源顺序表
		local tResSeq = {
			e_type_resdata.coin,
			e_type_resdata.wood,
			e_type_resdata.food,
			e_type_resdata.iron,
			
		}
		--数据字典
		local tItemDict = {}
		for i=1,#tItemList do
    		tItemDict[tItemList[i].k] = tItemList[i].v
    	end
		--图片组
    	local pItems = {}
		for i=1,#tResSeq do
			local nItemId = tResSeq[i]
			local nItemNum = tItemDict[nItemId]
			if nItemNum then
				local tGood = getGoodsByTidFromDB(nItemId)
				if tGood then
					--资源图片
		    		local pImgRes = MUI.MImage.new(tGood.sIcon)

		    		--资源文字
			    	local pTxtRes = MUI.MLabel.new({text = "+"..tostring(nItemNum), size = 20})
			    	setTextCCColor(pTxtRes, getColorByQuality(tGood.nQuality))

			    	--层
			    	local nLayerIconWidth = pImgRes:getContentSize().width
			    	local nLayerIconHeight = pImgRes:getContentSize().height + pTxtRes:getContentSize().height
			    	local pLayerIcon = MUI.MLayer.new()
			    	pLayerIcon:setContentSize(cc.size(nLayerIconWidth, nLayerIconHeight))
			    	pLayerIcon:setAnchorPoint(0.5, 0.5)

			    	--加入文字
			    	pTxtRes:setPosition(nLayerIconWidth/2, -pTxtRes:getContentSize().height/2)
			    	pLayerIcon:addView(pTxtRes,2)

			    	--加入图片
			    	pImgRes:setPosition(nLayerIconWidth/2, pTxtRes:getContentSize().height)
			    	pLayerIcon:addView(pImgRes)

			    	--做记录
			    	pLayerIcon._nItemId = nItemId
			    	
			    	table.insert(pItems, pLayerIcon)
			    end
			end
		end
		if #pItems == 0 then
			return
		end

		--层
    	local pLayer = MUI.MLayer.new()
    	pLayer:setAnchorPoint(0.5, 0.5)
    	pLayer:setContentSize(display.width, display.height)
    	pLayer:setPosition(display.width/2, display.height/2)
    	pParView:addView(pLayer)

    	--加入图片到层
		for i=1,#pItems do
			local pLayerIcon = pItems[i]
			local pUi = tResUis[e_resui_belong.home][pLayerIcon._nItemId]
			if pUi then
				local pUiPoint = pUi:getResText():getAnchorPointInPoints()
				pWorldPoint = pUi:getResText():convertToWorldSpace(pUiPoint)
				local pCurrPoint = pLayer:convertToNodeSpace(pWorldPoint)
				pLayerIcon:setPosition(pCurrPoint.x, display.height/2)
				pLayer:addView(pLayerIcon)
			end
		end

    	--删除层
    	local function removeLayer( )
    		if not tolua.isnull(pLayer) then
    			pLayer:removeSelf()
    		end
    	end

    	--移动到指定目标
    	local fMoveToTargetDt = 1.18
		local function iconMoveToTarget(  )
			if not tolua.isnull(pLayer) then
				for i=1,#pItems do
					local pLayerIcon = pItems[i]
					local nItemId = pLayerIcon._nItemId

					--世界坐标
					local pUi = tResUis[nTargetType][nItemId]
					if pUi then
						local pUiPoint = pUi:getResText():getAnchorPointInPoints()
						local pWorldPoint = pUi:getResText():convertToWorldSpace(pUiPoint)

						-- 时间       缩放值          位移
						-- 0秒          30%        （X=0，Y=0）
						-- 0.21秒       87%        （X=0, Y=0） 
						-- 0.42秒       74%        （X=0，Y=0）
						-- 0.59秒       80%        （X=0, Y=0）
						-- 0.76秒       110%       （X=0，Y=-22）
						-- 1.18秒       50%        （X=未知，Y=未知）
						--转换所在层坐标
						pLayerIcon:setScale(0.3)
						local pCurrPoint = pLayer:convertToNodeSpace(pWorldPoint)
						local pSeqAct = cc.Sequence:create({
							cc.ScaleTo:create(0.21, 0.87),
				    		cc.ScaleTo:create(0.21, 0.74),
				    		cc.ScaleTo:create(0.17, 0.8),
				    		cc.Spawn:create({
				    			cc.ScaleTo:create(0.17, 1.1),
				    			cc.MoveBy:create(0.17, cc.p(0,-22)),
				    		}),
							cc.Spawn:create({
				    			cc.ScaleTo:create(fMoveToTargetDt - 0.76, 0.5),
				    			cc.MoveTo:create(fMoveToTargetDt - 0.76, pCurrPoint),
				    		}),
				    		cc.CallFunc:create(function (  )
				    				pUi:playGetItem()
				    			end),
				    		cc.Hide:create(),
				    	})
						pLayerIcon:runAction(pSeqAct)
					end
				end
			end
		end

		fDelay = fDelay or 0
		pLayer:setVisible(false)
    	--执行方法
    	local pSeqAct = cc.Sequence:create({
    		cc.DelayTime:create(fDelay),
    		cc.Show:create(),
    		cc.CallFunc:create(iconMoveToTarget),
    		cc.DelayTime:create(fMoveToTargetDt+0.1),
    		cc.CallFunc:create(removeLayer)
    	})
    	pLayer:runAction(pSeqAct)
    end
end


--图标的动画
--无论一次性获得几个道具都以三个为一排。往下排 。
--所有道具图标合成一个整体，然后进行缩放与位移。  
--tItemList:获得物品 List<Pair<Integer,Long>>	
--fDelay：延时
--nTargetType:1:飞往主城上方，2:飞往世界上方
function showGetItems( tItemList, fDelay, nTargetType)
	if #tItemList == 0 then
		return
	end

	local pRootLayer = RootLayerHelper:getCurRootLayer()
	if not pRootLayer then
		return
	end

    local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if pParView then

    	--图片组
    	local pItems = {}
    	for i=1,#tItemList do
    		local nItemId = tItemList[i].k
    		local nItemNum = tItemList[i].v
    		local tGood = getGoodsByTidFromDB(nItemId)
			if tGood then
				--底条背景
    			local pImgBottom = MUI.MImage.new("#sg_ztbhddt_001.png")
    			pImgBottom:setAnchorPoint(0, 0)
    			pImgBottom:setPosition(0, 0)
    			local nBottomH = pImgBottom:getContentSize().height
    			local nBottomW = pImgBottom:getContentSize().width
    			--名字
    			local pTxtName = MUI.MLabel.new({text = tGood.sName, size = 20})
    			pTxtName:setPosition(nBottomW/2, nBottomH/2)
    			setTextCCColor(pTxtName, _sColor) 

    			--图片资源
    			local pImgRes = MUI.MImage.new(tGood.sIcon)
    			local pIconSize = pImgRes:getContentSize()
    			local nLayerWidth = math.max(pIconSize.width, pImgBottom:getContentSize().width)
    			local nLayerHeight = pIconSize.height + nBottomH
    			pImgRes:setPosition(nLayerWidth/2, nBottomH + pIconSize.height/2)
    			--数量
    			local pTxtNum = MUI.MLabel.new({text = tostring(getResourcesStr(nItemNum)), size = 20})
    			pTxtNum:setAnchorPoint(1, 0)
    			pTxtNum:setPosition(pImgRes:getContentSize().width, pImgBottom:getContentSize().height)

    			--层
    			local pLayer = MUI.MLayer.new()
    			pLayer:addView(pImgBottom)
    			pLayer:addView(pImgRes)
    			pLayer:addView(pTxtNum)
    			pLayer:addView(pTxtName)
    			pLayer:setContentSize(nLayerWidth, nLayerHeight)
				table.insert(pItems, pLayer)
			end
    	end
    	if #pItems == 0 then
    		return
    	end
    	
    	local nIconCol = 3
    	local nOffsetX = 10
    	local nOffsetY = 10
    	local nIconWidht = pItems[1]:getContentSize().width + 10
    	local nIconHeight = pItems[1]:getContentSize().height + 10
    	local nLayerWidth = math.min(#pItems, nIconCol) * nIconWidht
    	local nLayerHeight = math.ceil(#pItems/nIconCol) * nIconHeight
 		
    	--层
    	local pLayer = MUI.MLayer.new()
    	pLayer:setContentSize(cc.size(nLayerWidth, nLayerHeight))
    	local nX = display.width/2
    	local nY = display.height/2
    	pLayer:setPosition(nX, nY)
    	pLayer:setAnchorPoint(0.5, 0.5)
    	pParView:addView(pLayer)

    	--加入图片到层
    	local nBeginX,nBeginY = 0, nLayerHeight 
		for i=1,#pItems do
			local pIcon = pItems[i]
			local nCol = ((i-1) % nIconCol)
			local nRow = math.ceil(i/nIconCol)
			local fX = nBeginX + nCol * nIconWidht
			local fY = nBeginY - nRow * nIconHeight
			pIcon:setPosition(fX, fY)
			pLayer:addView(pIcon)
		end

    	--删除层
    	local function removeLayer( )
    		if not tolua.isnull(pLayer) then
    			pLayer:removeSelf()
    		end
    	end

		-- 时间       缩放值          位移
		-- 0秒         61%        （X=0，Y=0）
		-- 0.21秒      83%        （X=0, Y=0）
		-- 0.6秒       83%        （X=0, Y=0）
		-- 0.80秒      93%        （X=-30，Y=82）
		-- 0.93秒      108%　　　 （X=49, Y=-119）
		-- 1.18秒      32%        （X=255，Y=-543）
		local fOffsetScale = 1
		local fOffsetDelay = 0
		pLayer:setScale(0.61)
		pLayer:setVisible(false)
		fDelay = fDelay or 0
		local nCX = display.width/2
		local nCY = display.height/2
    	--执行方法
    	local pSeqAct = cc.Sequence:create({
    		cc.DelayTime:create(fDelay),
    		cc.Show:create(),
    		cc.ScaleTo:create(0.21 + fOffsetDelay, 0.83 * fOffsetScale),
    		cc.DelayTime:create(0.6 - 0.21 + fOffsetDelay),
    		cc.Spawn:create({
    			cc.ScaleTo:create(0.8 - 0.6 + fOffsetDelay, 0.93 * fOffsetScale),
    			-- cc.MoveBy:create(0.8 - 0.6, cc.p(30,82)),
    			cc.MoveTo:create(0.8 - 0.6 + fOffsetDelay, cc.p(nCX - 30,nCY + 82)),
    		}),
    		cc.Spawn:create({
    			cc.ScaleTo:create(0.93 - 0.8 + fOffsetDelay, 1.08 * fOffsetScale),
    			-- cc.MoveBy:create(0.93 - 0.8, cc.p(49,-119)),
    			cc.MoveTo:create(0.93 - 0.8 + fOffsetDelay, cc.p(nCX + 49, nCY -119)),
    		}),
    		cc.Spawn:create({
    			cc.ScaleTo:create(1.18 - 0.93 + fOffsetDelay, 0.32 * fOffsetScale),
    			-- cc.MoveBy:create(1.18 - 0.93, cc.p(248,-543)),
    			cc.MoveTo:create(1.18 - 0.93 + fOffsetDelay, cc.p(nCX + 255, nCY -543)),
    		}),
    		cc.CallFunc:create(removeLayer)
    	})
    	pLayer:runAction(pSeqAct)
    end
end


--图标的动画
--无论一次性获得几个道具都以三个为一排。往下排 。
--所有道具图标合成一个整体，然后进行缩放与位移。  
--tItemList:获得物品 List<Pair<Integer,Long>>	
--fDelay：延时
function showGetOtherRes( tItemList, fDelay)
	if #tItemList == 0 then
		return
	end
	local pRootLayer = RootLayerHelper:getCurRootLayer()
	if not pRootLayer then
		return
	end

	fDelay = fDelay or 0

	local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if pParView then
    	local fSubDelay = 0.3
		local nCX = display.width/2
		local nCY = display.height/2

		local function createLayer( nIndex, pPos, _fDelay)
			if nIndex > #tItemList then
				return
			end
			local nItemId = tItemList[nIndex].k
	    	local nItemNum = tItemList[nIndex].v
			
			--资源
			local tGood = getGoodsByTidFromDB(nItemId)
			if not tGood then
				return
			end
			local pImgRes = MUI.MImage.new(tGood.sIcon)
			pImgRes:setScale(0.5)
			local nBeginX = 50
			local nIconWidth = pImgRes:getContentSize().width * 0.5
			local nIconHeight = pImgRes:getContentSize().height * 0.5
			pImgRes:setPosition(nBeginX + nIconWidth/2, nIconHeight/2)

			--资源文字
	    	local pTxtRes = MUI.MLabel.new({text = tGood.sName .. "+"..tostring(getResourcesStr(nItemNum)), size = 20})
	    	pTxtRes:setAnchorPoint(0, 0.5)
	    	setTextCCColor(pTxtRes, getColorByQuality(tGood.nQuality))
	    	local nX = nIconWidth
	    	local nY = nIconHeight/2
	    	pTxtRes:setPosition(nBeginX + nX, nY)

			--层
			local pLayer = MUI.MLayer.new()
			pLayer:setAnchorPoint(0.5, 0.5)
    		pLayer:setContentSize(cc.size(226, 44))
    		pLayer:setBackgroundImage("#sg_ztbhddt_002.png",{scale9 = true,capInsets=cc.rect(226/2,44/2, 1, 1)})
    		pLayer:addView(pImgRes)
    		pLayer:addView(pTxtRes)

    		--延迟
    		--位置
    		-- print("_fDelay=,pPos=",_fDelay,pPos.x, pPos.y)
    		-- if pPos.x <= display.width/2 then
    		-- 	print("left")
    		-- else
    		-- 	print("right")
    		-- end
    		pLayer:setPosition(pPos)
    		pLayer:setVisible(false)
    		pParView:addView(pLayer)

    		--删除层
	    	local function removeLayer( )
	    		if not tolua.isnull(pLayer) then
	    			pLayer:removeSelf()
	    		end
	    		-- createLayer(nIndex+1, pPos)
	    	end
    		-- 时间                   位移                   透明度
			-- 0秒                 （X=0,Y=0）                100%
			-- 0.33秒              （X=0,Y=28.5）             100%
			-- 0.67秒              （X=0,Y=50）               100%
			-- 1.04秒              （X=0,Y=69）               100%		
			-- 1.21秒              （X=0,Y=73）                0%
    		local pSeqAct = cc.Sequence:create({
    			cc.DelayTime:create(_fDelay),
    			cc.Show:create(),
    			cc.MoveTo:create(0.33 - 0, cc.p(pPos.x, pPos.y + 28.5)),
    			cc.MoveTo:create(0.67 - 0.33, cc.p(pPos.x, pPos.y + 50)),
    			cc.MoveTo:create(1.04 - 0.67, cc.p(pPos.x, pPos.y + 69)),
    			cc.Spawn:create({
	    			cc.FadeOut:create(1.21 - 1.04),
	    			cc.MoveTo:create(1.21 - 1.04, cc.p(pPos.x, pPos.y + 73)),
	    		}),
	    		cc.CallFunc:create(removeLayer)
	    	})
	    	pLayer:runAction(pSeqAct)
		end

		--第一个
		local nCX = display.width/2
		local fDelay2 = 0
		local pPrevPos = nil
		for i=1,#tItemList do
			--delay时间
    		fDelay2 = fDelay + fSubDelay * (i - 1)
    		--位置
    		local pPos = nil
    		if pPrevPos then
    			pPos = pPrevPos
    			if i%2 == 0 then --正
    				pPos.x = nCX + math.random(0, 150)
    			else
    				--负
    				pPos.x = nCX + math.random(-150, 0)
    			end
    			--需要Y-15至-20。
    			pPos.y = pPos.y + math.random(-20, -15)
    		else
    			--负
    			pPos = cc.p(nCX + math.random(-150, 0), display.height/2)
    		end
    		pPrevPos = pPos
    		--播放特效
			createLayer(i, pPos, fDelay2)	
		end
		
	end
end
--显示获得buff
function showGetBuffs( tBuffList)
	-- body
	if #tBuffList <= 0 then
		return
	end
	for i = 1, #tBuffList do
		local Buff = getGoodsByTidFromDB(tBuffList[i].k)
		if Buff then
			TOAST(Buff.sDesc..getConvertedStr(6, 10486))
		end
	end
end


-------------
--征收资源动画
--pOriginUi:起点Ui
--nResId:征收资源id
--nResFlyNum:向上飞的资源数量
function showLevyRes( pOriginUi, nResId, nResFlyNum, nDelayHandler, _parentLay )
	--容错
	if not tResUis[e_resui_belong.collect] then
		return
	end
	if not pOriginUi then
		return
	end
	if not nResId then
		return
	end
	if not nResFlyNum or nResFlyNum == 0 then
		return
	end
	--播放动画字段
	local sArmKey = nil
	if nResId == e_type_resdata.coin then
		sArmKey = "levyCoin"
	elseif nResId == e_type_resdata.wood then
		sArmKey = "levyWood"
	elseif nResId == e_type_resdata.food then
		sArmKey = "levyFood"
	elseif nResId == e_type_resdata.iron then
		sArmKey = "levyIron"
	end
	if not sArmKey then
		return
	end

	
    local pParView = nil
    if _parentLay then
    	pParView = _parentLay
    else
    	local pRootLayer = RootLayerHelper:getCurRootLayer()
		if not pRootLayer then
			return
		end
    	pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    end
    if pParView then
		--获取目标位置
		local pUi = tResUis[e_resui_belong.collect][nResId]
		if not pUi then
			return
		end
		local pUiPoint = pUi:getResImg():getAnchorPointInPoints()
		local pWorldPoint = pUi:getResImg():convertToWorldSpace(pUiPoint)
		local pEndPoint = pParView:convertToNodeSpace(pWorldPoint)

		--进行遍历
		local fDelay = 0
		for i=1,nResFlyNum do
			--移动层
			local pLayRes = MUI.MLayer.new()
			pParView:addView(pLayRes)	

		    --代码动作
		    --产生并设置位置
		    local function showAndMove(  )
		    	if tolua.isnull(pLayRes) then
		    		return
		    	end
		    	if tolua.isnull(pOriginUi) then
		    		return
		    	end

                --加载图片
                addTextureToCache("tx/world/sg_by_zysj")

		    	--播放动画
				require("app.common.getitem.GetItemEffectDatas")
				local tArmData = GetItemEffectDatas[sArmKey]
			    local pArm =  createMArmature(pLayRes,tArmData,function (pArmate)
			    	--循环播放不处理，等移到目的地才删除
			    end,cc.p(0,0))
			    if pArm then
			        pArm:play(-1)
			    end

				local tArmNumData = GetItemEffectDatas["levyNum"]
			    local pNumArm =  createMArmature(pOriginUi:getParent(),tArmNumData,function (pArmate)
			    	--循环播放不处理，等移到目的地才删除
			    end,cc.p(pOriginUi:getPositionX(), pOriginUi:getPositionY()), 110)
			    if pNumArm then
			        pNumArm:play(1)
			    end

		    	--设置起始位置
				local pOrginUiPoint = pOriginUi:getAnchorPointInPoints()
				local pWorldPoint = pOriginUi:convertToWorldSpace(pOrginUiPoint);
				local pCurrPoint = pParView:convertToNodeSpace(pWorldPoint)
				local pAnchorPoint = pOriginUi:getAnchorPoint()
				if pAnchorPoint.x == 0 then
					pCurrPoint.x = pCurrPoint.x + pOriginUi:getContentSize().width/2
				end
				if pAnchorPoint.y == 0 then
					pCurrPoint.y = pCurrPoint.y + pOriginUi:getContentSize().height/2
				end

				--最大距离
				local fDistance = cc.pGetDistance(pCurrPoint, pEndPoint)
				local fMoveT = fDistance/display.height * 1.8					
				--删除层
		    	local function removeLayer( )
		    		if not tolua.isnull(pArm) then
		    			pArm:removeSelf()
		    		end
		    		if not tolua.isnull(pLayRes) then
		    			pLayRes:removeSelf()
		    		end
					local pUi = tResUis[e_resui_belong.collect][nResId]
		    		if not tolua.isnull(pUi) then
		    			pUi:playGetItem()
		    		end
		    		if not tolua.isnull(pNumArm) then
		    			pNumArm:removeSelf()
		    		end
		    		if i == 3 then
		    			if nDelayHandler then
		    				nDelayHandler()
		    			end
		    		end
		    	end
		    	--第二次动作
		    	-- local nStartX = pCurrPoint.x - 25
		    	-- local nStartY = pCurrPoint.y - 25

		    	local nStartX = pCurrPoint.x
		    	local nStartY = pCurrPoint.y

		    	--两点间的角度
		    	--每一次的偏移值
		    	local nAngle = getAngle(nStartX, nStartY, pEndPoint.x, pEndPoint.y)
		    	if i > 0 then
		    		if i%2 == 0 then
			    		nAngle = nAngle - math.min(i * 15, 20)
			    	else
			    		nAngle = nAngle + math.min(i * 15, 20)
			    	end
			    end
		    	local nRadian = nAngle * math.pi / 180;
		    	local nOffset = 130
		    	local nX = nStartX + nOffset * math.cos(nRadian)
		    	local nY = nStartY - nOffset * math.sin(nRadian)
		    	local pMidPos = cc.p(nX, nY)
		  
		    	local pSeqAct = cc.Sequence:create({
		    			--曲线
						-- cc.EaseInOut:create(cc.BezierTo:create(fMoveT,{cc.p(nStartX, nStartY),pMidPos,pEndPoint}), 1),
						-- cc.EaseOut:create(cc.BezierTo:create(fMoveT,{cc.p(nStartX, nStartY),pMidPos,pEndPoint}),2.5),

						cc.EaseOut:create(cc.BezierTo:create(fMoveT,{cc.p(nStartX, nStartY),pMidPos,pEndPoint}),2.5),
						-- cc.CallFunc:create(removeLayer),
					})

		    	local function func2()
		    		if not tolua.isnull(pLayRes) then
			    		local pSeqAct3 = cc.Sequence:create({
				    		cc.MoveTo:create(fMoveT * 0.2 , pEndPoint),
				    		cc.CallFunc:create(removeLayer),
				    	})
				    	pLayRes:stopAllActions()
			    		pLayRes:runAction(pSeqAct3)
			    	end
		    	end

		    	local pSeqAct2 = cc.Sequence:create({
		    			cc.DelayTime:create(fMoveT * 0.9),
		    			cc.CallFunc:create(func2),
		    		})
		    	--一段时间停止并减慢速度
				pLayRes:setVisible(true)
				pLayRes:setPosition(nStartX, nStartY)
				pLayRes:runAction(pSeqAct)
				pLayRes:runAction(pSeqAct2)
				
		    end
		    pLayRes:setVisible(false)

	    	local pSeqAct = cc.Sequence:create({
	    		cc.DelayTime:create(fDelay),
	    		cc.CallFunc:create(showAndMove),
	    	})
	    	pLayRes:runAction(pSeqAct)
			--延迟时间		    
			-- fDelay = fDelay + 0.15			
			fDelay = fDelay + 0.12
		end
	end
end

local nMaxShowCount = 10 -- 同时展示的最多个数
local tAllShowItems = {} -- 循环展示的个数
local nCurShowIndex = 0 -- 当前显示的下标


--执行初始化布局操作
function doInitShowGetItems(  )
	-- body
	for i = 1, 10 do
		--层
		local pLayer = MUI.MLayer.new()
		pLayer:setAnchorPoint(0.5, 0.5)
		pLayer:setContentSize(cc.size(249, 45))
		pLayer:setBackgroundImage("#sg_hdwp_pzdk.png",{scale9 = true,capInsets=cc.rect(248/2,44/2, 1, 1)})
		pLayer:addView(pTxtRes,100)

		--图片
		local pImgRes = MUI.MImage.new("ui/daitu.png")
		pImgRes:setScale(0.5)
    	pImgRes:setName("_img_get_item")
		pLayer:addView(pImgRes)

		--文字
    	local pTxtRes = MUI.MLabel.new({text = "" .. " +".. "", size = 20})
    	pTxtRes:setAnchorPoint(0, 0.5)
    	pTxtRes:setName("_text_get_item")
		pLayer:addView(pTxtRes)

		pLayer:retain()
		table.insert(tAllShowItems, pLayer)
	end
end

-- --初始化操作
-- doInitShowGetItems()

--所有物品获得的特效
function showRealyItemGet( tItemList, fDelay)
	if #tItemList == 0 then
		return
	end
	local pRootLayer = RootLayerHelper:getCurRootLayer()
	if not pRootLayer then
		return
	end

	fDelay = fDelay or 0

	local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if pParView then
    	local fSubDelay = 0.2

		local function createLayer( nIndex, pPos, _fDelay)

			if nIndex > #tItemList then
				return
			end
			local nItemId = tItemList[nIndex].k
	    	local nItemNum = tItemList[nIndex].v
			
			--资源
			local tGood = getGoodsByTidFromDB(nItemId)
			if not tGood then
				return
			end

			nCurShowIndex = nCurShowIndex + 1
			-- 判断不超过总个数
			if(nCurShowIndex > #tAllShowItems) then
			    nCurShowIndex = 1
			end

			local pLayer = tAllShowItems[nCurShowIndex]
			if(pLayer) then
			    -- 从父节点移除，停止所有动画
			    pLayer:removeSelf()
			    pLayer:stopAllActions()
			    pLayer:setOpacity(255)
			end
			pLayer:setPosition(pPos)
			pLayer:setVisible(false)
			pParView:addView(pLayer)

			--图片
			local pImgRes = pLayer:findViewByName("_img_get_item")
			local nBeginX = 20
			pImgRes:setCurrentImage(tGood.sIcon)
			local nIconWidth = pImgRes:getContentSize().width * 0.5
			local nIconHeight = pImgRes:getContentSize().height * 0.5
			pImgRes:setPosition(nBeginX + nIconWidth/2, nIconHeight/2)

			--名字
			local sGoodsName = tGood.sName or ""
	    	local pTxtRes = pLayer:findViewByName("_text_get_item")
	    	pTxtRes:setString(sGoodsName .. " +"..tostring(getResourcesStr(nItemNum)))
	    	setTextCCColor(pTxtRes, getColorByQuality(tGood.nQuality))
	    	local nX = nIconWidth
	    	local nY = nIconHeight/2
	    	pTxtRes:setPosition(nBeginX + nX, nY)

    		--播放特效
    		local function showLightTx(  )
    			-- --播放音效
	    		Sounds.playEffect(Sounds.Effect.get)
    			-- body
    			--计算位置
    			local nX = pLayer:getPositionX() - (pLayer:getWidth() / 2 - pImgRes:getPositionX())
    			local nY = pLayer:getPositionY() 
    			local tPos = cc.p(nX,nY)

    			for i = 1, 2 do
    				--图标上的特效
    				local pArm = MArmatureUtils:createMArmature(
    					tNormalCusArmDatas["12_" .. i], 
    					pParView, 
    					10, 
    					tPos,
    				    function ( _pArm )
    				    	_pArm:removeSelf()
    				    	_pArm = nil
    				    end,
    				    Scene_arm_type.normal)
    				if pArm then
    					pArm:play(1)
    				end
    			end
    			
    		end

    		--删除层
	    	local function removeLayer( )
	    		if not tolua.isnull(pLayer) then
	    			pLayer:removeSelf()
	    		end
	    	end
    		-- 时间                   位移                透明度
			-- 0                 （X=0,Y=0）               100%
			-- 0.5秒             （X=0，Y=76）             100%
			-- 1.25秒            （X=0，Y=130）            0%
			local fMoveTime = 0.45
			local fFadeTime = 1.1
    		local pSeqAct = cc.Sequence:create({
    			cc.DelayTime:create(_fDelay),
    			cc.Show:create(),
    			cc.CallFunc:create(showLightTx),
    			cc.MoveTo:create(fMoveTime - 0, cc.p(pPos.x, pPos.y + 76)),
    			cc.Spawn:create({
	    			cc.FadeOut:create(fFadeTime - fMoveTime),
	    			cc.MoveTo:create(fFadeTime - fMoveTime, cc.p(pPos.x, pPos.y + 130)),
	    		}),
	    		cc.CallFunc:create(removeLayer)
	    	})
	    	pLayer:runAction(pSeqAct)
		end

		--第一个
		local nCX = display.width/2
		local fDelay2 = 0
		local pPrevPos = nil

		if #tItemList == 1 then --只有一个 位置在中间
			local pPos = cc.p(display.width/2,display.height/2)
    		--播放特效
			createLayer(1, pPos, 0)
		else
			for i=1,#tItemList do
				--delay时间
	    		fDelay2 = fDelay + fSubDelay * (i - 1)
	    		--位置
	    		local pPos = nil
	    		if pPrevPos then
	    			pPos = pPrevPos
	    			if i%2 == 0 then --正
	    				pPos.x = nCX + math.random(50, 150)
	    			else
	    				--负
	    				pPos.x = nCX + math.random(-150, -50)
	    			end
	    			--需要Y-15至-20。
	    			pPos.y = pPos.y - math.random(21, 25)
	    		else
	    			--负
	    			pPos = cc.p(nCX + math.random(-150, -50), display.height/2)
	    		end
	    		pPrevPos = pPos
	    		--播放特效
				createLayer(i, pPos, fDelay2)	
			end
		end
		
		
	end
end