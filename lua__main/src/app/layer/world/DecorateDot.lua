----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-03-31 10:18:23
-- Description: 地图上的装饰点(树，山)
-----------------------------------------------------
local DecorateDot = class("DecorateDot")
function DecorateDot:ctor( pWroldLayer )
	self.pWroldLayer = pWroldLayer
end

-- function DecorateDot:setDotKey(sDotKey)
-- 	self.sDotKey = sDotKey
-- end

-- function DecorateDot:getDotKey()
-- 	return self.sDotKey
-- end

-- function DecorateDot:getZsType(  )
-- 	return self.nZsType
-- end

-- function DecorateDot:setZsType( nZsType )
-- 	self.nZsType = nZsType
-- 	if self.pZsImg then
-- 		local sImg = sImgs[nZsType]
-- 		if sImg then
-- 			self.pZsImg:setCurrentImage(sImg)
-- 			self.pZsImg:setVisible(true)
-- 		else
-- 			self.pZsImg:setVisible(false)
-- 		end
-- 	end
-- end

function DecorateDot:setDecorateData( tDecorateData )
	self.tDecorateData = tDecorateData
	if self.pZsImg then
		local sImg = tDecorateData.sImg
		if sImg then
			self.pZsImg:setCurrentImage(sImg)
			self.pZsImg:setVisible(true)
		else
			self.pZsImg:setVisible(false)
		end
	end
end

function DecorateDot:getDecorateData( )
	return self.tDecorateData
end

function DecorateDot:setZsImg( pZsImg )
	self.pZsImg = pZsImg
end

function DecorateDot:setVisible( bIsVisible )
	if self.pZsImg then
		self.pZsImg:setVisible(bIsVisible)
	end
end

function DecorateDot:getViewRect()
	if self.pZsImg then
		return self.pZsImg:getBoundingBox()
	end
	return cc.rect(0,0,0,0)
end

--要先设置图片才调用这个方法，切记！！！
function DecorateDot:setPosition( pPos )
	if self.pZsImg then
		self.pZsImg:setPosition( pPos )
	end

	-- 测试打印
    -- if not self.pLabel then
    -- 	local pLabel = MUI.MLabel.new({
    --     text=self.sDotKey,
    --     size=18,
    --     anchorpoint=cc.p(0.5, 0.5),
    --     color = cc.c3b(255, 0, 0), -- 使用纯红色
    --     dimensions = cc.size(0, 0),
    --     })
    --     WorldLayerObj:getScrollNode():addChild(pLabel,9999,9999)
    --     pLabel:setPosition(pPos)
    --     self.pLabel = pLabel
    -- else
    -- 	self.pLabel:setPosition(pPos)
    -- 	self.pLabel:setString(self.sDotKey)
    -- end
end

return DecorateDot
