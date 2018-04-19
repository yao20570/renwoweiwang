-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 19:43:51 星期四
-- Description: 分页管理器，使用这个类必须实现createTab函数 
-----------------------------------------------------


local TabManager = class("TabManager")


-- _target：实现了createTab函数的类对象
-- _pContentView：需要挂载内容展示的父节点
-- _tTabItems：（table）标签页的复选框列表
-- _tKeys：（table）标签页的标识
-- _nHandler：切换需要的回调函数(可选)
-- 			  _nHandler(_sKey, _nType) : 说明如下
-- 					_sKey:当前界面的key值；
-- 					_nType：-1：切换的是当前界面   0：该展示层已经存在的  1：该展示层是新添加进来的
function TabManager:ctor( _target, _pContentView, _tTabItems, _tKeys, _nHandler )
	-- body
	self:myInit()
	if not _target or not _pContentView or not _tTabItems or not _tKeys then
		print("参数不能为nil")
		return 
	end
	self.pTarget = _target 
	self.pContentView = _pContentView
	self.nHandlerCallBack = _nHandler
	self.tKeys = _tKeys
	--初始化相关数据
	self:initDatas(_tTabItems, _tKeys)
	--控件初始化
	self:setupViews()
end

--初始化成员变量
function TabManager:myInit(  )
	-- body
	--定义参数
	self.pTarget 			= 			nil  		
	self.pContentView 		= 			nil  		
	self.tTabItems 			= 			nil  		
	self.tKeys 				= 			nil  		
	self.nHandlerCallBack 	= 			nil  	

	self.tTabItemsAndKeys 	= 			{} 				--（table）切换页签和key的对应关系
	self.tContentLayers 	= 			{} 				--（table）展示内容集合
	self.sCurKey 			= 			"" 				--（string）当前展示层的key值
	self.nZOrder 			= 			10 				--（int）当前展示层的优先级
	self.bRunningAnim 		= 			false 			--（boolean）是否正在展示动画
	self.nActionType 		= 			1 				--（int）是否释放前一个标签(1,push,2,replace) 可选

	self.sImgBgSelected 	= 			nil 			--选中背景
	self.sImgBg 			= 			nil				--背景

end

--初始化相关数据
function TabManager:initDatas( tTabItems, tKeys )
	-- body
	if(tTabItems and tKeys and #tTabItems == #tKeys ) then
		-- 把数据加到对应的列表中
		for i,v in pairs(tTabItems) do
			v.sKey = tKeys[i]
			table.insert(self.tTabItemsAndKeys, v)
		end
        self.tTabItems = tTabItems
	end
end

--初始化相关控件
function TabManager:setupViews(  )
	-- body
	--处理页签点击事件
	for k, v in pairs (self.tTabItemsAndKeys) do
		if v then
			v:onMViewClicked(handler(self, self.onItemTabClicked))
		end
	end

end

function TabManager:setImgBag( sImgBg, sImgBgSelected )
	-- body
	self.sImgBgSelected 	= 			sImgBg 						--选中背景
	self.sImgBg 			= 			sImgBgSelected				--背景	
end

-- 刷新界面
function TabManager:updateViews(  )
	-- body
	--设置是否选中状态
	for k, v in pairs (self.tTabItemsAndKeys) do
		if self.sCurKey == v.sKey then
			v:setChecked(true, self.sImgBgSelected)
		else
			v:setChecked(false, self.sImgBg)
		end
	end
end

--页签点击回调事件
function TabManager:onItemTabClicked( pView )
	-- body
	if pView.sKey and #pView.sKey > 0 then
		--切换展示层
		self:changeContentLayer(pView.sKey, self.nActionType)
	end
end

-- 切换标签页
-- _key 标签(这里涉及到删除等操作,尽量不要用数字作为key值)
-- _type 是否释放前一个标签(1,push,2,replace) 可选
function TabManager:changeContentLayer( _key, _type )

    if self:isRunningAnim() then --如果在执行动画直接返回
        return
    end

    if self.sCurKey == _key then --选择的是当前展示的层
    	--刷新界面
    	self:updateViews()
    	if self.nHandlerCallBack ~= nil then
    	    self.nHandlerCallBack(_key, -1)
    	end
    	return
    end

    if self.pContentView then
		local isNew = false --是否为新的展示层
		if not self.tContentLayers[_key] then
			if self.pTarget.createTab then
				local layer = self.pTarget:createTab( _key )
				self.tContentLayers[_key] = layer
	            -- 如果有进场动画，不能在同一帧加载，所以要先retain
	            layer:retain()
				isNew = true
			else
				print("当前界面需要实现createTab方法")			
			end
			
		end
		if _type == 1 then
			self:pushLayer(_key,isNew)
		else
			self:replaceLayer(_key,isNew)
		end
    end
end

-- 将标签页盖上去
function TabManager:pushLayer( _key, _isNew )
	--获得当前展示的层
	local layer = self.tContentLayers[self.sCurKey]
	if(layer)then    --当前存在界面
        if layer.onExitAction ~= nil then  --有出场动画
            self:setRunnginAnim(true)
            layer:onExitAction(function()
                self:setRunnginAnim(false)
		        layer:setVisible(false)
                self:handleNewLayer(_key, _isNew, true)
            end)
        else
		    layer:setVisible(false)
            self:handleNewLayer(_key, _isNew, true)
        end
    else 			--当前不存在界面
        self:handleNewLayer(_key, _isNew, true)
    end
end

--添加一个新的界面
--_isPush：是否是叠加上来的
function TabManager:handleNewLayer(_key, _isNew, _isPush)
	--记录当前展示层的key
	self.sCurKey = _key
	local layer = self.tContentLayers[self.sCurKey]
	if _isNew then
        if _isPush then
		    self.nZOrder = self.nZOrder + 1
        end
		layer:setZOrder(self.nZOrder)
		self.pContentView:addView(layer)
	else
		layer:setVisible(true)
	end

    if layer.onEnterAction ~= nil then --有进场动画
        self:setRunnginAnim(true)
        layer:onEnterAction(function()
            self:setRunnginAnim(false)
            self:updateViews()
        end)
    else
        self:updateViews()
    end

	self:updateViews()

	if self.nHandlerCallBack ~= nil then
		if(_isNew) then
			self.nHandlerCallBack(_key, 1)
		else
			self.nHandlerCallBack(_key, 0)
		end
	end
end

-- 将标签页替换进去
function TabManager:replaceLayer( _key, _isNew )
	local layer = self.tContentLayers[self.sCurKey]
	if layer then
        if layer.onExitAction ~= nil then
            self:setRunnginAnim(true)
            layer:onExitAction(function()
                self:setRunnginAnim(false)
                self:handleReplaceLayer(layer)
                self:handleNewLayer(_key, _isNew, false)
            end)
        else
            self:handleReplaceLayer(layer)
            self:handleNewLayer(_key, _isNew, false)
        end
	else
        self:handleNewLayer(_key, _isNew, false)
    end
end

-- 替换掉之前的layer
function TabManager:handleReplaceLayer(_layer)
    if _layer then
        -- 新建时已retain, 故这里取消
        -- _layer:retain()
        _layer:removeSelf()
        _layer:release() 
        self.tContentLayers[self.sCurKey] = nil
    end
end

-- 清除所有子界面
function TabManager:releaseAll( )
	if self.tContentLayers then
		for k,v in pairs(self.tContentLayers) do
	        v:release() 
		end
	end
end

--跳到第几分页
--_nIndex：分页下标从1开始
function TabManager:gotoTabByIndex( _nIndex )
	-- body
	local nIndex = _nIndex or 1
	if nIndex > table.nums(self.tKeys) then
		nIndex = 1
	end
	self:changeContentLayer(self.tKeys[nIndex], self.nActionType)
end

--设置是否在运行切换动画
function TabManager:setRunnginAnim(running)
    self.bRunningAnim = running
end

--获取是否在运行切换动画
function TabManager:isRunningAnim()
    return self.bRunningAnim
end

--设置加载类型
--_nType：1：表示push，2：表示replace
function TabManager:setActionType( _nType )
	-- body
	self.nActionType = _nType
end

--获得加载类型
function TabManager:getActionType(  )
	-- body
	return self.nActionType
end

-- 获取当前显示的标签页
function TabManager:getCurLayer( )
	return self.tContentLayers[self.sCurKey]
end

-- 获取当前展示层的key
function TabManager:getCurIndex()
	return self.sCurKey or ""
end

--获取标签页
function TabManager:getLayer( _key )
    return self.tContentLayers[_key]
end

return TabManager