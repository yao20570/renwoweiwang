----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-11-15 19:50:16 
-- Description: 控件缓存池
-- 缓存池中的控件，都会存在  m_sPoolTypeName 字段，用来存放类型标识
-----------------------------------------------------

-- 缓存池基本控件类型
MPoolObjectType = {}
MPoolObjectType.LABEL = "MLabel" -- 缓存类型为Label
MPoolObjectType.LAYER = "MLayer" -- 缓存类型为MLayer
MPoolObjectType.FILLLAYER = "MFillLayer" -- 缓存类型为MFillLayer
MPoolObjectType.IMAGE = "MImage" -- 缓存类型为MImage
MPoolObjectType.IMAGENINE = "MImagenine" -- 缓存类型为MImage 点9


MViewPool = myclass("MViewPool")

-- 获取单列类
function MViewPool:getInstance(  )
    if(not self.m_instance) then
        self.m_instance = MViewPool.new()
    end
    return self.m_instance
end

function MViewPool:ctor( )    
    -- 缓存对象列表
    self.m_tViews = { }
    
    -- 创建对象的函数
    self.m_tObjInfos = {}
end

-- 注册缓存类型信息
-- _objType(MPoolObjectType) : 对象类型
-- _maxCount(int) : 创建对象的数量上限
-- _createFun(function) : 创建对象的回调函数
function MViewPool:regObjInfo(_objType, _maxCount, _objClass, _createParams)    
    self.m_tObjInfos[_objType] = {
        objType = _objType,
        maxCount = _maxCount,
        objClass = _objClass,
        params = _createParams or {}
    }

    self.m_tViews[_objType] = {}
end


-- 在空闲时间调用此函数补充对象池对象
function MViewPool:autoPushByFreeTime()        
    for k, v in pairs(self.m_tObjInfos) do
        local tObjInfo = v
        if #(self.m_tViews[k]) < tObjInfo.maxCount then
            local pView = self:createCacheObj(tObjInfo.objType)
            pView.m_sPoolTypeName = k
            self:push(pView, false)
        end
    end   
end

function MViewPool:createCacheObj(_objType)
    local tObjInfo = self.m_tObjInfos[_objType]
    local pView = tObjInfo.objClass.new(unpack(tObjInfo.params))
    return pView
end

-- 将一个新的控件，压入到缓存池中
-- _pView(MView): 需要缓存的控件
function MViewPool:push( _pView, _isNeedRemove)   
    -- 获取对象类型对应的缓存列表
    local tList = self.m_tViews[_pView.m_sPoolTypeName]
    if tList == nil then
        print(debug.traceback("添加对象到缓存池失败，没注册缓存类型信息", 2))
        return
    end

    table.insert(tList, _pView)
    _pView:retain()
    -- 从父节点身上移除
    if _isNeedRemove == nil then
        _isNeedRemove = true
    end
    if _isNeedRemove == true then
        _pView:removeFromParent(true)
    end

    -- 添加对象池引用标记
    --_pView.m_bInObjPool = false

end

-- 从缓存池里面取出某种类型的控件
-- _sType(string): 需要取出的控件类型
-- return(MView): 没有返回nil, 有返回一个aotorelease的控件
function MViewPool:pop(_sType)
    -- 获取对象类型对应的缓存列表
    local tList = self.m_tViews[_sType]
    if tList == nil then
        print(debug.traceback("获取缓存对象失败，没注册缓存类型信息", 2))
        return
    end

    -- 从对象池中移除
    local pView = table.remove(tList, #tList)
    if (pView) then
        pView:autorelease()
        -- 移除对象池引用标记
        --pView.m_bInObjPool = false
    end

    

    return pView
end

-------------------------------------------------------------------------------------------
-- 以下是全局方法，提供给业务层的人使用
-------------------------------------------------------------------------------------------
G__PoolViews = {} -- 临时缓存的数据
-- 从缓存池中获取一个控件的横向列表
-- _name(string)：需要获取的控件名称
function popViewFromPool( _name )
    local views = G__PoolViews[_name]
    if(views) then
        
        -- 如果读取的缓存池已经为空了
        if(#views == 0) then
            print("缓存池中的控件不够使用，请扩充缓存池存放上限", _name)
            return 
        end
        
        -- 从对象池中移除
        local pView = table.remove(views, #views)
        if pView then
            --print("popViewFromPool===>", #views)
            pView:autorelease()
            -- 移除对象池引用标记
            --pView.m_bInObjPool = false
        end

        -- 恢复透明度
        pView:setOpacity(255)        

        return pView
    else
        print("业务层缓存池中没有该类型的控件缓存", _name, "请联系老王进行处理")
    end
end
-- 把控件返回缓存池中
-- _view（MView）：当前需要释放回缓存池中的控件
-- _name (string) ：用户控件类型
-- _isNeedRemove (bool) ： 是否需要重父节点移除, 默认(nil) == true 
function pushViewToPool( _view, _name , _isNeedRemove)

    if _view.setDestory2ObjPoolFlag == nil then
        myprint("The node in the object pool failure, it's not MView")
        return 
    end

    if(not _view or tolua.isnull(_view) or (not _view.__poolTmpName and not _name)) then
        myprint("The node in the object pool failure, it is null or has no name")
        return
    end

    -- 设置客户控件名称
    _view.__poolTmpName = _view.__poolTmpName or _name

    -- 获取对象存放列表
    G__PoolViews[_view.__poolTmpName] = G__PoolViews[_view.__poolTmpName] or {}
    local views = G__PoolViews[_view.__poolTmpName]
    if(views) then
        
        -- 添加析构入对象池事件
        _view:setDestory2ObjPoolFlag()

        -- 从父节点身上移除
        if _isNeedRemove == nil then
            _isNeedRemove = true
        end
        if _isNeedRemove == true then
            _view:removeFromParent(true, true)
        else
            -- 添加一次引用        
            _view:retain()

            -- 添加到对象池中
            table.insert(views, _view)

            --print("pushViewToPool===>", #views)
        end
    else
        print("业务层缓存池中没有该类型的控件缓存", _name, "请联系老王进行处理")
    end
end