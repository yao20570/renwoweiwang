local WorldHelpFunc = {}

--检路创建
function WorldHelpFunc.createLine( pLay,nLength,nType )
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


function WorldHelpFunc.drawLine( pLay,startPos,endPos,nType )
	if endPos and startPos   then
		--显示线
		
		local tPos = {} 
		local fLength = cc.pGetDistance(startPos, endPos)
		local pLine = WorldHelpFunc.createLine(pLay,fLength,nType)
		

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


function WorldHelpFunc.createHero( _parent,_sName,_zOrder,_tPos )
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(1, 1)
	local pArm = MArmatureUtils:createMArmature(
			EffectWorldDatas[_sName],
			pLay,
			10,
			cc.p(0,0),
			function ( _pArm )
				
			end, Scene_arm_type.normal)


	if pArm then
		pArm:play(-1)
	end
	
	pLay:setPosition(_tPos)
	_parent:addView(pLay,_zOrder)
	return pLay,pArm
end

return WorldHelpFunc