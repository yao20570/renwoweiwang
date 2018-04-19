-- Author: maheng
-- Date: 2017-12-29 14:14:05
-- 城墙武将
local MCommonView = require("app.common.MCommonView")
local ItemWallHero = require("app.layer.wall.ItemWallHero")
local DragChangeListView = require("app.layer.world.DragChangeListView")

local LayWallHeros = class("LayWallHeros", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LayWallHeros:ctor(_nTeamType)
	-- body
	self:myInit()

	self.nTeamType = _nTeamType or 1
	parseView("lay_wall_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("LayWallHeros",handler(self, self.onDestroy))
	
end

--初始化参数
function LayWallHeros:myInit()
	self.bIsFoundItem 		= false 		-- 是否找到了战斗武将
	self.tHeroItem = {}
	self.tWallArmy  =  {} --守城武将队列	
	self.tItemDrop = {} --item 
	self.tItemPos = {} --位置
end

--解析布局回调事件
function LayWallHeros:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function LayWallHeros:setupViews( )
	self.pImgTitle 	= 	self:findViewByName("img_title")
	if self.nTeamType == e_hero_team_type.normal then
		self.pImgTitle:setCurrentImage("#V2_fonts_zhuliwujiang.png")
	elseif self.nTeamType == e_hero_team_type.walldef then
		self.pImgTitle:setCurrentImage("#v2_fonts_chengfangwujiang2.png")
	end	
	self.pLayHeros 	= 	self:findViewByName("ly_heros")

	local pSize = self.pLayHeros:getContentSize()
	local pDragChangeListView = DragChangeListView.new(pSize, 1)
	pDragChangeListView:setPosition(0, 0)
	pDragChangeListView:setChangeSuccessHandler(handler(self, self.onItemChange))
	self.pDragChangeListView = pDragChangeListView
	self.pLayHeros:addView(pDragChangeListView)

	-- self:creatNewScrollayer()
	-- self:creatMovePart()
end



--创建一个新的上阵队列滑动层
-- function LayWallHeros:creatNewScrollayer()

--     self.pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(10, 0,self.pLayHeros:getWidth(),self.pLayHeros:getHeight()),
--         touchOnContent = false,
--         -- scrollbarImgV="ui/bg_map/v3_bg_background_cjjs.jpg",
--         direction=MUI.MScrollLayer.DIRECTION_VERTICAL,
--         bothSize=cc.size(self.pLayHeros:getWidth(), self.pLayHeros:getHeight())})

--     --设置用于拖拽交换
--     self.pScrollLayer:setUseForDrag(true)
--     self.pScrollLayer:setNeedScrollAction(false)
--     self.pLayHeros:addView(self.pScrollLayer)


--     self.pScrollLayer:setBounceable(false)
--     self.pScrollLayer:onScroll(handler(self,self.onTouch)) 
-- end

--创建移动层
-- function LayWallHeros:creatMovePart()
--     --新建一个内容层
-- 	self.pItemsView = MUI.MLayer.new()
-- 	-- self.pItemsView:setBackgroundImage("#v3_bg1.png")
-- 	self.pItemsView:setLayoutSize(self.pLayHeros:getWidth(), self.pLayHeros:getHeight())
-- 	self.pScrollLayer:addView(self.pItemsView,2)
-- 	self.pItemsView:setPosition(0,0)
-- 	self.pItemsView:setAnchorPoint(cc.p(0,0))

--     -- 初始化坐标
--     self:initPos()

-- 	--初始化在线的部队item
-- 	for i=1,4 do
-- 		self.tItemDrop[i] = ItemWallHero.new(i,self, self.nTeamType)
-- 		self.tItemDrop[i]:setPosition(self.tItemPos[i])
-- 		self.pItemsView:addView(self.tItemDrop[i],11)
-- 	end
-- end

--移动触摸事件
-- function LayWallHeros:onTouch(event)

-- 	if "began" == event.name then

-- 			for k,pItem in pairs(self.tItemDrop) do
-- 				if (pItem) then
-- 					if (pItem:isPointInItem(event.x,  event.y) and not self.bIsFoundItem) then
-- 						if pItem:getViewType() == en_army_state.online then --只有当前类型有武将才可以移动
-- 							pItem:getViewType()
-- 							pItem:setScale(0.99)
-- 							pItem:setOpacity(150)
-- 							self.bIsFoundItem = true 
-- 							-- self.pScrollLayer:setIsCanScroll(false)
-- 							self.pFoundItem = pItem
-- 							self.pCurDropIndex = pItem.nPos

-- 							-- 保留偏移的位置
-- 							pItem.fPointX =  event.x - self.tItemPos[self.pCurDropIndex].x
-- 							--pItem.fPointY =  event.y - self.tItemPos[self.pCurDropIndex].y
-- 							pItem.fPointY =  0 - self.tItemPos[self.pCurDropIndex].y
-- 							pItem:setSelected(true)
-- 						end
-- 					else
-- 						pItem:setScale(1.0)
-- 						pItem:setOpacity(255)
-- 						pItem:setSelected(false)
-- 					end
-- 				end
-- 			end
-- 		return true
-- 	elseif "clicked" == event.name then
-- 		self:changeItem()
-- 	elseif "moved" == event.name then
-- 			if(self.bIsFoundItem) then
-- 			-- self.pFoundItem:setPosition(event.x - self.pFoundItem.fPointX, 
-- 			-- 	event.y - self.pFoundItem.fPointY)
-- 			self.pFoundItem:setPosition(event.x - self.pFoundItem.fPointX, 
-- 							0 - self.pFoundItem.fPointY)			

-- 			-- 判断是否可以进行交换item
-- 			for i, pItem in pairs(self.tItemDrop) do
-- 				if(pItem.nPos ~= self.pCurDropIndex) then
-- 					-- 寻找是否移动到下一个目标
-- 					local bIs = pItem:isCanChange(self.pFoundItem)
-- 					if(bIs) then
-- 						--展示当前可以交换数据
-- 						pItem:showCanChange(true)
-- 					else
-- 						pItem:showCanChange(false)
-- 					end
-- 				end
-- 			end
-- 		end

-- 	else
--         -- 交换item
-- 		self:changeItem()
-- 	end
-- end

-- 重置被选择item的数据
-- function LayWallHeros:resetFoundItem(  )
-- 	if (not self.pFoundItem) then
-- 		return 
-- 	end

-- 	self.pFoundItem:setScale(1.0)
-- 	self.pFoundItem:setOpacity(255)
-- 	self.pFoundItem:setSelected(true)
-- 	self.pFoundItem = nil 
-- 	self.bIsFoundItem = false
-- 	-- self.pScrollLayer:setIsCanScroll(true)
-- end

-- 交换item
-- function LayWallHeros:changeItem(  )
-- 	if (not self.bIsFoundItem) then
-- 		return 
-- 	end

-- 	local bFound = false
-- 	-- 判断是否存在可交换的item
-- 	for i, p in pairs(self.tItemDrop) do
-- 		if(p.nPos ~= self.pCurDropIndex) then
-- 			-- 寻找是否移动到下一个目标
-- 			local bIs = p:isCanChange(self.pFoundItem)
-- 			if(bIs) then
-- 				-- 交换item的位置
-- 				local pItem = self.tItemDrop[p.nPos]
-- 				self.tItemDrop[p.nPos]= self.pFoundItem
-- 				self.tItemDrop[self.pFoundItem.nPos]= pItem

-- 				--交换临时表数据
-- 				self:changeTempSelTable(p.nPos, self.pFoundItem.nPos)
-- 				self.pFoundItem:changeToIndex(p.nPos, true)
-- 				self.pFoundItem:showChangedArm()
-- 				p:changeToIndex(self.pFoundItem.nOldIndex, true)
-- 				bFound = true
-- 				break
-- 			end
-- 		end
-- 	end

-- 	-- 如果没有找到，直接回到原位
-- 	if(not bFound) then
-- 		self.pFoundItem:changeToIndex(self.pFoundItem.nPos, true)
-- 	end

-- 	-- 重置被选择item的数据
-- 	self:resetFoundItem()
-- end

-- 交换数据
-- function LayWallHeros:changeTempSelTable( _pos1, _pos2)
-- 	-- 交换数据
-- 	if (not self.tWallArmy or not self.tWallArmy[_pos1] 
-- 		or not self.tWallArmy[_pos2]) then
-- 		self:refreshWallArmy()
-- 		return
-- 	end

-- 	--更改位置
-- 	if self.nTeamType == e_hero_team_type.normal then
-- 		local nPos = self.tWallArmy[_pos1].nP  + 0
-- 		self.tWallArmy[_pos1].nP = self.tWallArmy[_pos2].nP
-- 		self.tWallArmy[_pos2].nP = nPos
-- 	elseif self.nTeamType == e_hero_team_type.walldef then
-- 		local nPos = self.tWallArmy[_pos1].nDp  + 0
-- 		self.tWallArmy[_pos1].nDp = self.tWallArmy[_pos2].nDp
-- 		self.tWallArmy[_pos2].nDp = nPos	
-- 	end	
-- 	--更改数据
-- 	local tArmy = copyTab(self.tWallArmy[_pos1]) 
-- 	self.tWallArmy[_pos1] = copyTab(self.tWallArmy[_pos2])
-- 	self.tWallArmy[_pos2] = tArmy


-- 	self:refreshWallArmy()
-- end

-- 根据位置下标获取坐标
-- function LayWallHeros:getItemPosition( _nIndex )
-- 	return  self.tItemPos[_nIndex] or cc.p(0, 0)
-- end

--刷新城墙上阵部队的信息
-- function LayWallHeros:refreshWallArmy()
-- 	--刷新我自己的部队的消息
-- 	for k,v in pairs(self.tItemDrop) do
-- 		if self.tWallArmy[k] then
-- 			v:setCurData(self.tWallArmy[k])
-- 		else
-- 			v:setCurData(en_army_state.free)
-- 		end
-- 	end
-- end

--初始化坐标
-- function LayWallHeros:initPos()
-- 	if not self.tItemPos then
-- 		self.tItemPos = {}
-- 	end

-- 	--初始化位置
-- 	for i=1,4 do
-- 		self.tItemPos[i] = cc.p(150*(i-1),0 )
-- 	end
-- end
--刷新数据
function LayWallHeros:refreshData(  )
	-- body
	self.pData = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
	self.tWallArmy = {}
	if self.nTeamType == e_hero_team_type.normal then
		local tHeros = copyTab(Player:getHeroInfo():getOnlineHeroList()) 
		for i=1,4 do
			if tHeros[i] then
				self.tWallArmy[i] = tHeros[i]
			else
				if i> Player:getHeroInfo().nOnlineNums then
					self.tWallArmy[i] = TypeIconHero.LOCK
				else
					self.tWallArmy[i] = TypeIconHero.ADD
				end				
			end
		end		
	elseif self.nTeamType == e_hero_team_type.walldef then
		local tHeros = copyTab(Player:getHeroInfo():getDefenseHeroList())
		local nUnLockIndex = Player:getHeroInfo():getDefenseQueueNums()
		for i=1,4 do
			if tHeros[i] then
				self.tWallArmy[i] = tHeros[i]
			else
				if i > nUnLockIndex then
					self.tWallArmy[i] =  TypeIconHero.LOCK
				else
					self.tWallArmy[i] =  TypeIconHero.ADD
				end				
			end
		end					
	end	
end
-- 修改控件内容或者是刷新控件数据
function LayWallHeros:updateViews(  )	
	self:refreshData() --刷新数据
	local tItems = self.pDragChangeListView:getAllItemList()
	for newIndex = 1, 4 do
		local pData = self.tWallArmy[newIndex]
		local pItem = tItems[newIndex]
		if(not self.tHeroItem[newIndex]) then
			self.tHeroItem[newIndex] =  ItemWallHero.new(newIndex, self, self.nTeamType)	
			local nOffx, nOffy = self.tHeroItem[newIndex]:getWidth()/2, self.tHeroItem[newIndex]:getHeight()/2
			self.pDragChangeListView:addItem(self.tHeroItem[newIndex],cc.p(150*(newIndex-1) + nOffx, nOffy))			
			if not pItem then
				pItem = self.tHeroItem[newIndex]
			end
		end
		pItem:setCurData(pData)	
					
		if type(pData) == "table" then
			self.pDragChangeListView:includeItem(pItem)
		elseif pData == TypeIconHero.LOCK or pData == TypeIconHero.ADD then
			self.pDragChangeListView:excludeItem(pItem)
		end
    end
	--城防武将刷新解锁提示
	self:refreshLockTip()
end

function LayWallHeros:onItemChange( ... )
	-- body
	local tItems = self.pDragChangeListView:getItemList()
	local tEdit = {}
	for k, v in pairs(tItems) do
		local pData = v:getData()
		table.insert(tEdit, pData.nId)
	end	
	local sHeros = table.concat(tEdit, ";")
	local sProtocol = nil
	if self.nTeamType == e_hero_team_type.normal then
		sProtocol = "editOnLineHeros"		
	elseif self.nTeamType == e_hero_team_type.walldef then
		sProtocol = "editDefHeros"
	end	
	SocketManager:sendMsg(sProtocol, {sHeros},function (msg)
	end)		
end

--城防武将刷新解锁提示
function LayWallHeros:refreshLockTip()
	-- body
	if self.nTeamType == e_hero_team_type.walldef then
		local bLocked = true
		for k, v in pairs(self.tWallArmy) do
			if type(v) == "table" or v ~= 4 then
				bLocked = false
				break
			end
		end
		if bLocked then
			if not self.pLbDefLockTip then
				local MImgLabel = require("app.common.button.MImgLabel")
				self.pLbDefLockTip = MImgLabel.new({text = getConvertedStr(7, 10279), size = 20, parent = self})
				self.pLbDefLockTip:setImg("#v2_img_lock_tjp.png", 1, "left")
				self.pLbDefLockTip:followPos("center", self:getWidth()/2, 30, 5)
				setTextCCColor(self.pLbDefLockTip, _cc.red)
			end
			self.pLbDefLockTip:setVisible(true)
		else
			if self.pLbDefLockTip then
				self.pLbDefLockTip:setVisible(false)
			end
		end
	end
end

--析构方法
function LayWallHeros:onDestroy(  )
	-- body

end


--对守卫城墙武将进行排列
-- function LayWallHeros:sortWallAtkArmy()

-- 	if not self.pData  then
-- 		return
-- 	end

-- 	if not  self.pData.tSq then
-- 		return
-- 	end


-- 	local tSq = self.pData.tSq or {}
-- 	if self:checkHeroSq(copyTab(tSq)) == false then
-- 		tSq = {1,2,3,4}
-- 	end		
-- 	if #tSq < 4 then
-- 		for i = 1, 4 do
-- 			if not tSq[i] then
-- 				tSq[i] = i
-- 			end
-- 		end
-- 	end
-- 	for i, nq in pairs(tSq) do
-- 		for k, v in pairs(self.tWallArmy) do
-- 			if type(v) == "table" then
-- 				if v.nP == tonumber(nq) then
-- 					v.nSort = i
-- 				end
-- 			end
-- 		end
-- 	end                                                             
-- 	--	根据记录的排序,重新排行位置
-- 	table.sort(self.tWallArmy,function (a,b)
-- 		return a.nSort < b.nSort
-- 	end)	

-- 	--再进行多一次赋值
-- 	for k,v in pairs(self.tWallArmy) do	
-- 		if type(v) == "table" then
-- 			if tSq[k] then
-- 				v.nSort = tSq[k]
-- 			end
-- 		end
-- 	end
-- end
-- function LayWallHeros:checkHeroSq( tSq )
-- 	-- body
-- 	local tCheck = tSq
-- 	table.sort( tCheck, function ( a, b )
-- 		-- body
-- 		return a < b
-- 	end )
	
-- 	for i = 1, #tCheck do
-- 		if tCheck[i] > #tCheck then
-- 			return false
-- 		end
-- 		if i < #tCheck and tCheck[i] == tCheck[i + 1] then
-- 			return false
-- 		end
-- 	end
-- 	return true
-- end

-- function LayWallHeros:saveHeroLocation( )
-- 	-- body
-- 	local nType = 1
-- 	if self.nTeamType == e_hero_team_type.normal then		
-- 		nType = 1
-- 	elseif self.nTeamType == e_hero_team_type.walldef then
-- 		nType = 3		
-- 	end	
-- 	if self.pData.tSq then
-- 		local adasd = {}			
-- 		for k,v in pairs(self.tWallArmy) do			
-- 			if (type(v) == "table") and v.nSort then
-- 				table.insert(adasd, v.nSort)
-- 			end
-- 		end		
-- 		str = table.concat(adasd, ",")
-- 		--dump(str, nType, 100)
-- 		SocketManager:sendMsg("wallOperation", {nType,str},function (msg)
-- 		end)
-- 	end
-- end

-- function LayWallHeros:sortWallDefArmy(  )
-- 	-- body
-- if not self.pData  then
-- 		return
-- 	end

-- 	if not  self.pData.tDq then
-- 		return
-- 	end
-- 	--dump(self.pData.tDq, "self.pData.tDq", 100)

-- 	local tDq = self.pData.tDq or {}
-- 	if self:checkHeroSq(copyTab(tDq)) == false then
-- 		tDq = {1,2,3,4}
-- 	end		
-- 	if #tDq < 4 then
-- 		for i = 1, 4 do
-- 			if not tDq[i] then
-- 				tDq[i] = i
-- 			end
-- 		end
-- 	end
-- 	for i, nq in pairs(tDq) do
-- 		for k, v in pairs(self.tWallArmy) do
-- 			if type(v) == "table" then
-- 				if v.nDp == tonumber(nq) then
-- 					v.nSort = i
-- 				end
-- 			end
-- 		end
-- 	end                                                             
-- 	--	根据记录的排序,重新排行位置
-- 	table.sort(self.tWallArmy,function (a,b)
-- 		return a.nSort < b.nSort
-- 	end)	

-- 	--再进行多一次赋值
-- 	for k,v in pairs(self.tWallArmy) do	
-- 		if type(v) == "table" then
-- 			if tDq[k] then
-- 				v.nSort = tDq[k]
-- 			end
-- 		end
-- 	end	
-- end
return LayWallHeros