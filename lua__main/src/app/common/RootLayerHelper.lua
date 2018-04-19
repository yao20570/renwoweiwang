-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 16:17:49 星期四
-- Description: RootLayer的管理类,用于场景或者层之间的管理
-----------------------------------------------------

RootLayerHelper = class("RootLayerHelper")

RootLayerHelper.pAllRootLayers = {} -- 用于保存所有的layer
RootLayerHelper.pRootLayers = {} -- 用于保存回调用的表
RootLayerHelper.pCurScene = nil -- 当前的场景
RootLayerHelper.pCurRootLayer = nil -- 当前显示在最顶层的RootLayer

local WIDTH = display.width
local HEIGHT = display.height

function RootLayerHelper:ctor(  )
	-- body
	self:myInit()
end

--初始化成员变量
function RootLayerHelper:myInit(  )
	-- body
	RootLayerHelper.pCurScene = nil
	RootLayerHelper.pCurRootLayer = nil
end

-- 设置当前场景
-- pCurScene（CCScene）：
function RootLayerHelper:setCurScene( pCurScene )
	-- body
	RootLayerHelper.pCurScene = pCurScene
end

-- 获取当前场景
-- return(CCScene): 返回当前场景
function RootLayerHelper:getCurScene( )
	-- body
	return RootLayerHelper.pCurScene
end

-- 获取当前显示的layer
-- return（MRootLayer）： 返回当前显示的layer
function RootLayerHelper:getCurRootLayer()
	-- body
	return RootLayerHelper.pCurRootLayer
end

-- 设置当前显示的layer
-- pRootLayer: 当前显示的layer
function RootLayerHelper:setCurRootLayer( pRootLayer )
	-- body
	RootLayerHelper.pCurRootLayer = pRootLayer
	RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers+1] = pRootLayer
	pRootLayer:setPositionY((display.height - HEIGHT)/2)
end

-- 将一个新的Rootlayer显示在场景的顶层
-- pRootLayer（MRootLayer）： 一个新的SRootLayer
-- bDelay：是否延迟
-- handler：界面切换完成回调
function RootLayerHelper:pushRootLayer( pRootLayer,bDelay, enterHandler )
	-- body
	if(RootLayerHelper.pCurScene and pRootLayer) then
		local zOrder = 0
		-- 获取当前layer的层次
		if(RootLayerHelper.pCurRootLayer) then
			zOrder = RootLayerHelper.pCurRootLayer:getLocalZOrder()
		end

		-- 把新的layer放到scene的最上面
		RootLayerHelper.pCurScene:addChild(pRootLayer)
		pRootLayer:setPositionY((display.height - HEIGHT)/2)

		if bDelay and pRootLayer.setShowFightLayerCallBack then
			showUnableTouchDlg()
			pRootLayer:setShowFightLayerCallBack(function (  )
				-- body
				hideUnableTouchDlg(false)
				-- 将层次提高 1
				pRootLayer:setLocalZOrder(zOrder + 1)
				-- 隐藏起来，不然点击事件会有问题
				if RootLayerHelper.pCurRootLayer then
					RootLayerHelper.pCurRootLayer:setVisible(false)
				end
				-- 修改当前layer
				RootLayerHelper.pCurRootLayer = pRootLayer
				-- 增加一个到数组中
				RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers+1] = pRootLayer
				if enterHandler then
					enterHandler()
				end
			end)
		else
			-- 将层次提高 1
			pRootLayer:setLocalZOrder(zOrder + 1)
			-- 隐藏起来，不然点击事件会有问题
			RootLayerHelper.pCurRootLayer:setVisible(false)
			-- 修改当前layer
			RootLayerHelper.pCurRootLayer = pRootLayer
			-- 增加一个到数组中
			RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers+1] = pRootLayer
		end
		
	else
		if(RootLayerHelper.pCurScene) then
			myprint("新的rootlayer为空")
		else
			myprint("场景为空")
		end
	end
end

-- 替换当前的layer，并且关闭旧的layer
-- pRootLayer（SRootLayer）： 新的layer
function RootLayerHelper:replaceRootLayer( pRootLayer,bDelay )
	-- body
	if(RootLayerHelper.pCurScene and pRootLayer) then
		local zOrder = 0
		-- 获取当前layer的层次
		if(RootLayerHelper.pCurRootLayer) then
			zOrder = RootLayerHelper.pCurRootLayer:getLocalZOrder()
		end
		-- 将层次提高 1
		if bDelay then
			pRootLayer:setLocalZOrder(zOrder - 1)
		else
			pRootLayer:setLocalZOrder(zOrder + 1)
		end
		
		-- 把新的layer放到scene的最上面
		RootLayerHelper.pCurScene:addChild(pRootLayer)
		pRootLayer:setPositionY((display.height - HEIGHT)/2)
		pRootLayer:setPositionX((display.width - WIDTH)/2)

		if bDelay and pRootLayer.setShowHomeLayerCallBack then --需要延迟
			pRootLayer:setVisible(false)
			pRootLayer:setShowHomeLayerCallBack(function (  )
				pRootLayer:setVisible(true)
				-- body
				-- 清除旧的layer
				self:finishRootLayer(RootLayerHelper.pCurRootLayer)
				-- 隐藏上一个
		        if (RootLayerHelper.pCurRootLayer ~= nil) then
		        	RootLayerHelper.pCurRootLayer:setVisible(false)
		        end
				-- 设置新的layer
				RootLayerHelper.pCurRootLayer = pRootLayer
				-- 增加一个到数组中
				RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers+1] = pRootLayer
				if pRootLayer.doFirstEnterHome then
					pRootLayer:doFirstEnterHome()
				end
			end)
		else
			-- 清除旧的layer
			self:finishRootLayer(RootLayerHelper.pCurRootLayer)
			-- 隐藏上一个
	        if (RootLayerHelper.pCurRootLayer ~= nil) then
	        	RootLayerHelper.pCurRootLayer:setVisible(false)
	        end
			-- 设置新的layer
			RootLayerHelper.pCurRootLayer = pRootLayer
			-- 增加一个到数组中
			RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers+1] = pRootLayer
		end
	else
		myprint("场景为空或者新的rootlayer为空")
	end
end

-- 结束一个layer
-- pRootLayer（SRootLayer）： 要清除掉的layer
-- 如果有销毁前的回调，还要回调一下
function RootLayerHelper:finishRootLayer( pRootLayer )
	-- body
	if(pRootLayer == nil) then
		myprint("pRootLayer == nil")
		return
	end
	-- 判断是否存在回调句柄
	local pTargetLayer = RootLayerHelper.pRootLayers[pRootLayer]
	if(pTargetLayer ~= nil) then
		-- 关闭layer前回调数据,(int, CCObject)
  		pTargetLayer:onRootLayerResult(pRootLayer:getRequestCode(), 
  			pRootLayer:getResultData())
  		RootLayerHelper.pRootLayers[pRootLayer] = nil
	end
	if(RootLayerHelper.pCurRootLayer) then
		-- 将当前layer从父节点中删除，并且清除所有的数据
		pRootLayer:removeSelf()
	end
	-- 始终删除最顶部那一个
	table.remove(RootLayerHelper.pAllRootLayers, #RootLayerHelper.pAllRootLayers)
	if(#RootLayerHelper.pAllRootLayers > 0) then
		RootLayerHelper.pCurRootLayer = RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers]
		if(RootLayerHelper.pCurRootLayer) then
			RootLayerHelper.pCurRootLayer:setVisible(true)
		end
	else
        RootLayerHelper.pCurRootLayer = nil
    end
end

-- 将一个新的Rootlayer显示在场景的顶层
-- pRootLayer(SRootLayer): 当前要显示的layer
-- pTargetLayer(CCObject): 回调事的layer
-- 备注：调用该方法，则pTargetLayer必须实现onRootLayerResult(int, CCObject)方法
function RootLayerHelper:pushRootLayerForResult( pRootLayer, pTargetLayer )
	-- body
	if(RootLayerHelper.pCurScene and pRootLayer and pTargetLayer) then
		RootLayerHelper.pRootLayers[pRootLayer] = pTargetLayer
	end
	if(RootLayerHelper.pCurScene and pRootLayer) then
		local zOrder = 0
		-- 获取当前layer的层次
		if(RootLayerHelper.pCurRootLayer) then
			zOrder = RootLayerHelper.pCurRootLayer:getLocalZOrder()
		end
		-- 将层次提高 1
		pRootLayer:setLocalZOrder(zOrder + 1)
		-- 把新的layer放到scene的最上面
		RootLayerHelper.pCurScene:addChild(pRootLayer)
		-- 隐藏起来，不然点击事件会有问题
		RootLayerHelper.pCurRootLayer:setVisible(false)
		-- 修改当前layer
		RootLayerHelper.pCurRootLayer = pRootLayer
		-- 增加一个到数组中
		RootLayerHelper.pAllRootLayers[#RootLayerHelper.pAllRootLayers+1] = pRootLayer
		pRootLayer:setPositionY((display.height - HEIGHT)/2)
	else
		if(RootLayerHelper.pCurScene) then
			myprint("新的rootlayer为空")
		else
			myprint("场景为空")
		end
	end
end

-- 关闭当前layer
function RootLayerHelper:finishCurRootLayer( )
	-- body
	self:finishRootLayer(RootLayerHelper.pCurRootLayer)

end

--实现单例
function RootLayerHelper:Instance()  
    if self.instance == nil then  
        self.instance = self.new()  
    end  
    return self.instance  
end

return RootLayerHelper