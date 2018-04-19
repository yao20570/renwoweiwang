--
-- Author: tanqian
-- Date: 2017-09-21 11:33:41
--世界玩法说明对话框
local Line = require("app.layer.world.Line")
local DlgCommon = require("app.common.dialog.DlgCommon")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local AttackHelp = require("app.layer.worldhelp.AttackHelp")
local CityWarHelp = require("app.layer.worldhelp.CityWarHelp")
local CountryHelp = require("app.layer.worldhelp.CountryHelp")
local ResourceHelp = require("app.layer.worldhelp.ResourceHelp")
local ResourceHelp = require("app.layer.worldhelp.ResourceHelp")
local DefenseHelp = require("app.layer.worldhelp.DefenseHelp")
local DlgWorldHelp = class("DlgWorldHelp", function()
	return DlgCommon.new(e_dlg_index.dlgworldhelp)
end)
function DlgWorldHelp:ctor(  )
	self:myInit()
	parseView("dlg_worldhelp", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldHelp:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldHelp",handler(self, self.onDlgWorldHelpDestroy))
end

function DlgWorldHelp:myInit(  )
	self.tLines = {}
	self.nCurIndex = 0
end

function DlgWorldHelp:setupViews(  )
	
	self:setTitle(getConvertedStr(8, 10025))
	--头部标题层
	self.pTopTitle = self:findViewByName("txt_top")
	local sTitle = getTipsByIndex(20023)
	self.pTopTitle:setString(sTitle)
	self.pLayTabHost = self:findViewByName("lay_tab")
	--切换卡层
	self.tTitles = {
		getConvertedStr(8, 10020),
		getConvertedStr(8, 10021),
		getConvertedStr(8, 10022),
		getConvertedStr(8, 10023),
		getConvertedStr(8, 10024),
	}
	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onTabClicked))
	self.pTabItems = self.pTComTabHost:getTabItems()
	for i=1,#self.pTabItems do
		self.pTabItems[i].nIndex = i
	end
	self.pLayTabHost:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()

	--获取content
	-- self.pWorldHelpLayer = WorldHelpLayer.new()
	-- self.pTComTabHost:setContentLayer(self.pWorldHelpLayer)

	--中间内容层
	self.pLayContent = self:findViewByName("middle")

	--底部描述层
	-- self.pLbTips = {}
	-- self.pImgTips = {}
	self.pLbTips = self:findViewByName("lb_tips_1")
	-- for i=1,3 do
	-- 	self.pLbTips[i] = self:findViewByName("lb_tips_"..i)
	-- 	self.pImgTips[i] = self:findViewByName("img_tips_"..i)
	-- end

	
	--默认选中第一项
	self.pTComTabHost:setDefaultIndex(1)
	self.nCurIndex = 1
end
--控件刷新
function DlgWorldHelp:updateViews()
	
end
--设置底部不同切换卡的文字描述
function DlgWorldHelp:setBottomDesc(_nIndex)
	_nIndex = _nIndex or 1 
	local sIndex = 20017+ _nIndex

	local str = getTipsByIndex(sIndex)
	
	self.pLbTips:setString(getTextColorByConfigure(str))
	-- local tStr = luaSplit(str,"\\n")
	
	-- for i=1,#self.pLbTips do
	-- 	if tStr[i] then
	-- 		self.pLbTips[i]:setVisible(true)
	-- 		self.pLbTips[i]:setString(getTextColorByConfigure(tStr[i]))
	-- 		local pOther = self.pLbTips[i - 1]
	-- 		if pOther then
	-- 			-- pOther:updateTexture()
				
	-- 			local nPosY = pOther:getPositionY() - pOther:getContentSize().height - 15
	-- 			if pOther:getContentSize().height >= 40 then
	-- 				nPosY = pOther:getPositionY() - pOther:getContentSize().height  - 10
	-- 				if  i == 2 then
	-- 					nPosY = pOther:getPositionY() - pOther:getContentSize().height + 5
	-- 				end
	-- 			end
				
	-- 			self.pLbTips[i]:setPositionY(nPosY)

	-- 		end
			
	-- 	else
	-- 		-- self.pImgTips[i]:setVisible(false)
	-- 		self.pLbTips[i]:setVisible(false)
	-- 	end
	-- end
end
function DlgWorldHelp:changeMiddleView( _nIndex )
	if self.pLayHelp1 then
		self.pLayHelp1:removeFromParent()
		self.pLayHelp1 = nil 
	end
	if self.pLayHelp2 then
		self.pLayHelp2:removeFromParent()
		self.pLayHelp2 = nil 
	end
	if self.pLayHelp3 then
		self.pLayHelp3:removeFromParent()
		self.pLayHelp3 = nil 
	end

	if self.pLayHelp4 then
		self.pLayHelp4:removeFromParent()
		self.pLayHelp4 = nil 
	end

	if self.pLayHelp5 then
		self.pLayHelp5:removeFromParent()
		self.pLayHelp5 = nil 
	end


	
	if _nIndex == 1 then
		self.pLayHelp1 = AttackHelp.new(self)		
		self.pLayContent:addView(self.pLayHelp1)
	elseif _nIndex == 2 then
		self.pLayHelp2 = CityWarHelp.new(self)
		self.pLayContent:addView(self.pLayHelp2)
	elseif _nIndex == 3 then
		self.pLayHelp3 = CountryHelp.new(self)
		self.pLayContent:addView(self.pLayHelp3)
	elseif _nIndex == 4  then
		self.pLayHelp4 = DefenseHelp.new(self)
		self.pLayContent:addView(self.pLayHelp4)
	elseif _nIndex == 5  then
		self.pLayHelp5 = ResourceHelp.new(self)
		self.pLayContent:addView(self.pLayHelp5)
	end
end
--下标选择回调事件
--nIndex --1是幸运，2是王者
function DlgWorldHelp:onTabClicked( nIndex )
	if nIndex and  self.nCurIndex == nIndex then
		return 
	end
	self.nCurIndex = nIndex
	
	self:setBottomDesc(nIndex)
	self:changeMiddleView(nIndex)
end

function DlgWorldHelp:onResume(  )
	
	self:updateViews()
end

function DlgWorldHelp:onPause(  )
	
end

-- 析构方法
function DlgWorldHelp:onDlgWorldHelpDestroy(  )
	

end




--检路创建
function DlgWorldHelp:createLine( pLay,nLength,nType )
	--创建线
	local sLineImg = nil
	if nType == 1 then
		sLineImg = "#v1_img_xjlxlv.png"
	elseif nType == 2 then
		sLineImg = "#v1_img_xjlxhong.png"
	elseif nType == 3 then
		sLineImg = "#v1_img_xjlxhuang.png"
	else
		sLineImg = "#v1_img_xjlxlv.png"
	end
	--创建裁剪区域
	local pLayLine = cc.ClippingNode:create() 
	local nX, nY, nW, nH = 0,0, nLength, 18
	local tPoint = {
		{nX, nY}, 
		{nX + nW, nY}, 
		{nX + nW, nY + nH}, 
		{nX, nY + nH},
	}
	local tColor = {
		fillColor = cc.c4f(255, 0, 0, 255),
	    borderWidth  = 1,
	    borderColor  = cc.c4f(255, 0, 0, 255)
	} 
	stencil =  display.newPolygon(tPoint,tColor)
	pLayLine:setStencil(stencil)
	pLay:addView(pLayLine)

	nLength = math.ceil(nLength/LINE_LENGTH) * LINE_LENGTH

	--批处理
	local pBatchNode = display.newTiledBatchNode(sLineImg, "ui/p1_commonse3.png", cc.size(nLength,18), -LINE_MARGIN)
	pBatchNode:setAnchorPoint(cc.p(0,0))
	if pLayLine.addView then
		pLayLine:addView(pBatchNode)
	else
		pLayLine:addChild(pBatchNode)
	end
	pLayLine.pBatchNode = pBatchNode
	

	return pLayLine

end


function DlgWorldHelp:drawLine( pLay,startPos,endPos,nType )
	if endPos and startPos   then
		--显示线
		
		local tPos = {} 
		local fLength = cc.pGetDistance(startPos, endPos)
		local pLine = self:createLine(pLay,fLength,nType)
		

		local nAngle = getAngle(startPos.x, startPos.y, endPos.x, endPos.y)
		pLine:setRotation(nAngle)
		local nOffsetRadian = (nAngle + 90) * math.pi / 180;
		local nX, nY = startPos.x + 9 * math.cos(nOffsetRadian), startPos.y - 9 * math.sin(nOffsetRadian)
		pLine:setPosition(nX, nY)
		for i=1,LINE_NUM do
			
			local fX, fY = (i - 1) * LINE_SIDE, 0
			table.insert(tPos, cc.p(fX, fY))
		end

		 return tPos,pLine
	end
end


function DlgWorldHelp:createHero( _parent,_sName,_zOrder,_tPos )
    -- 加载纹理
    -- addTextureToCache(MapArmyImags[_sName])
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(1, 1)
	local pArm = MArmatureUtils:createMArmature(
			EffectWorldDatas[_sName],
			pLay,
			10,
			cc.p(0,0),
			function ( _pArm )
				
			end, Scene_arm_type.world)


	if pArm then
		pArm:play(-1)
	end
	
	pLay:setPosition(_tPos)
	_parent:addView(pLay,_zOrder)
	return pLay,pArm
end




return DlgWorldHelp