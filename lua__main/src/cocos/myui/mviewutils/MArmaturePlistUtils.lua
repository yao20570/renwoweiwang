--region 动画异步加载工具类
--Author : wenzongyao
--Date   : 2018/3/29
--此文件由[BabeLua]插件自动生成

--这个工具是MArmature异步加载纹理使用

e_plist_state ={
    no = 1,         --没加载
    loading = 2,    --加载中
    exit = 3        --已加载
}

e_img_type = {
    png = 1,
    pvr = 2,
    jpg = 3
}

local tPlistInfo = {}   -- 记录plist加载信息的列表

MArmaturePlistUtils = {}

-- 预加载plist
-- _sPlist： 不带后缀的名称 例如 ""tx/other/sg_zjm_blsqt_sfx"
-- _nType：  1:png   2:pvr   3:jpg
function MArmaturePlistUtils.preloadPlist(_sPlist, _nType)            
    local tPlistInfo = getPlistInfo(_sPlist)
    asyncLoadPlist(_sPlist, _nType)
end

-- 引用图片
-- _sPlist： 不带后缀的名称 例如 ""tx/other/sg_zjm_blsqt_sfx"
-- _nType：  1:png   2:pvr   3:jpg
function MArmaturePlistUtils.retainPlist(_sPlist, _nType)
            
    local tPlistInfo = getPlistInfo(_sPlist)
    tPlistInfo.retain = tPlistInfo.retain + 1 

    asyncLoadPlist(_sPlist, _nType)
end

-- 释放图片引用
-- _sPlist: 不带后缀的名称 例如 ""tx/other/sg_zjm_blsqt_sfx"
function MArmaturePlistUtils.releasePlist(_sPlist)
    if addTextureToCache == nil then
        assert(false, "addTextureToCache is nil")
        return 
    end
        
    local tPlistInfo = getPlistInfo(_sPlist)
    tPlistInfo.retain = tPlistInfo.retain - 1 
    assert(tPlistInfo.retain>=0, _sPlist .. "~~~~~~~~~引用数有问题~~~~~~~")

end

-- 清理没用到的异步加载的textrue, spriteFrame
function MArmaturePlistUtils.cleanKeep()
    for k, v in pairs(tPlistInfo) do
        if v.retain <= 0 then
            setIsKeep(k, false)
            v.state = e_plist_state.no
        end
    end
end

-- 获取plist的引用信息
-- _sPlist: 不带后缀的路径和名称 例如 ""tx/other/sg_zjm_blsqt_sfx"
function getPlistInfo(_sPlist)
    if tPlistInfo[_sPlist] == nil then
        tPlistInfo[_sPlist] = {
            sPlist = _sPlist,           --plist的路径和名称
            state = e_plist_state.no,   --纹理状态
            retain = 0                  --被多少个动画引用
        }
    end
    return tPlistInfo[_sPlist]
end

-- 引用图片
-- _sPlist： 不带后缀的名称 例如 ""tx/other/sg_zjm_blsqt_sfx"
-- _nType：  1:png   2:pvr   3:jpg
function asyncLoadPlist(_sPlist, _nType)
    if addTextureToCache == nil then
        assert(false, "addTextureToCache is nil")
        return 
    end
        
    local tPlistInfo = getPlistInfo(_sPlist)
    if tPlistInfo.state == e_plist_state.no then   
        tPlistInfo.state = e_plist_state.loading       
        addTextureToCache(_sPlist, _nType, 0, function() 
            --失败没有回调
            myprint("加载纹理-图集(异步)", "===========>:成功",  _sPlist, _nType)
            setIsKeep(_sPlist, true)
            tPlistInfo.state = e_plist_state.exit
            
        end)   
    end
end

-- 设置图片持久化
-- _sPlist: 不带后缀的名称 例如 ""tx/other/sg_zjm_blsqt_sfx"
-- _bIs: 是否持久化
function setIsKeep(_sPlist, _bIs)
    if ccs.SpriteFrameCacheHelper == nil then
        return
    end
    if(_bIs) then
        ccs.SpriteFrameCacheHelper:getInstance():retainSpriteFrames(_sPlist .. ".plist")
    else
        ccs.SpriteFrameCacheHelper:getInstance():releaseSpriteFrames(_sPlist .. ".plist")
    end
end

--endregion
