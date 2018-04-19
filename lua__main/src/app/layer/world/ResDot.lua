----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-03-31 10:18:23
-- Description: 地图上的资源点
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local nLvBgZorder = 4
local nNameZorder = 5
local nShowYAdd = 6

local ResDot = class("ResDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

--pWorldLayer：世界层
--pImgDot 视图点图片（减少drawcall）
function ResDot:ctor( pWorldLayer, pImgDot)
	self.pWorldLayer = pWorldLayer
	self.pImgDot = pImgDot
	self.pImgDot:setScale(0.7)
	WorldFunc.setCameraMaskForView(self.pImgDot)

	self:onParseViewCallback()
end

--解析界面回调
function ResDot:onParseViewCallback(  )
	self:setContentSize(cc.size(UNIT_WIDTH, UNIT_HEIGHT))
	self:setupViews()

	--注册析构方法
    self:setDestroyHandler("ResDot",handler(self, self.onResDotDestroy))
end

function ResDot:onResDotDestroy(  )
	self:onPause()
end

function ResDot:onResume(  )
end

function ResDot:onPause(  )
end

function ResDot:setupViews(  )
	--创建名字背景
	self.pLayName = MUI.MLayer.new()
	self:addChild(self.pLayName, nNameZorder)
	self.pLayName:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - 5)

	--创建名字
	self.pTxtName = MUI.MLabel.new({text = "1", size = 22})
	self.pTxtName:setVisible(false) --隐藏起来 只拿来获取texture
	setTextCCColor(self.pTxtName, _cc.lwhite)

	self:addChild(self.pTxtName)

	--创建等级
	self.pTxtLv = MUI.MLabel.new({text = "1", size = 22})
	self.pTxtLv:setVisible(false) --隐藏起来 只拿来获取texture
	setTextCCColor(self.pTxtLv, _cc.lwhite)

	self:addChild(self.pTxtLv)


	--创建一个名字背景框
	self.pBbNameBg = createCCBillBorad("ui/daitu.png")
	self.pLayName:addChild(self.pBbNameBg)
	self.pLayName:setVisible(false)

	--创建一个等级背景框
	self.pBbLvBg = createCCBillBorad("#v1_img_dengjidi3c.png")
	self.pBbLvBg:setPosition3D(cc.vec3(self:getContentSize().width/2, 17, 0))
	self:addChild(self.pBbLvBg, nLvBgZorder)

	--随便设置一个设置 只为了获取texture
	self.pTxtName:setString("1")
	self.pTxtName:updateContent()
	--随便设置一个设置 只为了获取texture
	self.pTxtLv:setString("1")
	self.pTxtLv:updateContent()
	--获取所有的子节点
	local tChildrens = self.pTxtName:getChildren()
	local tChildrens2 = self.pTxtLv:getChildren()
	
	if(tChildrens[1]) then
	    local texture = tChildrens[1]:getTexture()
	    --名字
	    self.pBbName = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbName:setPosition3D(cc.vec3(0, -1, 1))
	    self.pLayName:addChild(self.pBbName)
	end
	if(tChildrens2[1]) then
	    local texture = tChildrens2[1]:getTexture()
	    --等级
	    self.pBbLv = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbLv:setPosition3D(cc.vec3(18, 18, 1))
	    self.pBbLvBg:addChild(self.pBbLv,20)
	end

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--设置服务器数据
--tData:服务器发过来的数据
function ResDot:setData( tData )
	self.tData = tData
	self:updateViews()
end

--获取数据
function ResDot:getData(  )
	return self.tData
end

function ResDot:getDotKey()
	if not self.tData then
		return
	end
	return self.tData.sDotKey
end

--更新
function ResDot:updateViews(  )
	if not self.tData then
		return
	end

	--防止重复刷新
	if self.nMineId ~= self.tData.nMineID then
		self.nMineId = self.tData.nMineID
		local tWorldMineData = getWorldMineData(self.nMineId)
		if tWorldMineData then
			--名字显示
			-- self.pTxtName:setString(tWorldMineData.name)
			--等级
			if self.nLevel ~= tWorldMineData.level then --防止重复刷新
				self.nLevel = tWorldMineData.level

				self.pTxtLv:setString(tWorldMineData.level, false)
				--强制渲染一下
				self.pTxtLv:updateContent()
				local tChildrens = self.pTxtLv:getChildren()
				if(tChildrens[1]) then
				    local pTexture = tChildrens[1]:getTexture()
				    self.pBbLv:setTexture(pTexture)
				    --重新设置一下大小
				    self.pBbLv:setTextureRect(cc.rect(0,0,self.pTxtLv:getContentSize().width,self.pTxtLv:getContentSize().height))
				end
			end
			
			--图片
			-- local pImg = WorldFunc.getMineIconOfContainer(self, self.nMineId, nil)
			-- if pImg then
			-- 	pImg:setScale(0.7)
			-- 	if not self.bIsSetedPos then
			-- 		self.bIsSetedPos = true
			-- 		pImg:setPositionY(pImg:getPositionY() + nShowYAdd)
			-- 	end
			-- 	--加入倾斜视角
			-- 	if not pImg.bIsAddCarema then
			-- 		pImg.bIsAddCarema = true
			-- 		WorldFunc.setCameraMaskForView(pImg)
			-- 	end
			-- end
			local sImgPath = tWorldMineData.sIcon
			if sImgPath then
				self.pImgDot:setCurrentImage(sImgPath)
			end
		end
	end

	--防止重复刷新
	local sOwnerName = self.tData.sOccupyerName
	local nOwnerCountry = self.tData.nOccupyerCountry
	if self.sOwnerNamePrev ~= sOwnerName or self.nOwnerCountryPrev ~= nOwnerCountry then
		self.sOwnerNamePrev = sOwnerName
		self.nOwnerCountryPrev = nOwnerCountry
		if sOwnerName == nil or sOwnerName == "" then
			self.pLayName:setVisible(false)
		else
			local tStr = {
				{color = getColorByCountry(nOwnerCountry), text = getCountryShortName(nOwnerCountry, true)},
				{color = _cc.pwhite, text = tostring(sOwnerName)}
				-- {color = _cc.pwhite, text = tostring("字字字字字字")}
			}
			
			--设置内容
			self.pTxtName:setString(tStr, false)

			--强制渲染一下
			self.pTxtName:updateContent()
			local tChildrens = self.pTxtName:getChildren()
			if(tChildrens[1]) then
			    local pTexture = tChildrens[1]:getTexture()
			    self.pBbName:setTexture(pTexture)
			    --重新设置一下大小
			    self.pBbName:setTextureRect(cc.rect(0,0,self.pTxtName:getContentSize().width,self.pTxtName:getContentSize().height))
			end

			--更新等级背景大小
			WorldFunc.updateBbNameBgByStrWidth(self.pBbNameBg, self.pTxtName:getWidth())
			self.pLayName:setVisible(true)
		end
	end


	--防止重复刷新
	if self.nX ~= self.tData.nX or self.nY ~= self.tData.nY then
		self.nX = self.tData.nX
		self.nY = self.tData.nY
		--更新坐标
		local fX, fY = self.pWorldLayer:getMapPosByDotPos(self.tData.nX,self.tData.nY)
		self:setPosition(fX, fY)

		self.pImgDot:setPosition(fX, fY + nShowYAdd)
	end
end

--显示或隐藏扩展
function ResDot:setVisibleEx( bIsShow )
	if bIsShow == false then
		--清空数据
		self:delViewDotMsg()
	end
	self:setVisible(bIsShow)
	self.pImgDot:setVisible(bIsShow)
end

function ResDot:delViewDotMsg( )
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
end

return ResDot
