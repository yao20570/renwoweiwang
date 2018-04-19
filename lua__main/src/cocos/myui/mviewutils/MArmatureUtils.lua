--
-- Author: Jiangruichao
-- Date: 2016-03-28 16:45:21
-- 自定义特效管理类
----------------------------------------------------
local MArmature = require("cocos.myui.MArmature")

local SCENE_TAG = "scene_" -- key值的记录
local SCENE_DEFAULT_TYPE = 1 -- 默认的类型
tMArmatureList = {}

local nSceneType = nil
MArmatureUtils = {}
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--------------------------------- 自定义特效管理 -----------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- 刷新自定义特效列表中的特效
function MArmatureUtils:updateMArmature(_sceneType)

    _sceneType = _sceneType or SCENE_DEFAULT_TYPE
    local tT = tMArmatureList[_sceneType]
    nSceneType = _sceneType
    if (tT) then
        -- 将不存在的特效添加到移除队列中
        local tNeedRemoveList = nil
        for k, pArm in pairs(tT) do
            -- 特效存在，并且在可视范围内
            if pArm.updateFrame then                
                if _sceneType == 3 then 
                    -- Scene_arm_type.world，为了性能，所以直接等于3了
                    -- 地图是3d视角，用isInsideScreen会让在边边的动画不动
                        pArm:updateFrame()
                    else
                        if _sceneType == 5 then
                            pArm:updateFrame()
                        elseif pArm:isInsideScreen() and pArm:isRunning() then
                            -- isInsideScreen不一定准确，当某个祖先比它小并在它范围之内，或在屏幕内时祖先被隐藏了，就肯定是true
                            -- 需要判断isRunning是因为有可能在缓存池中
                            pArm:updateFrame()
                        else
                            -- print("生效了")
                        end
                    end
            else
                -- 特效已清除，添加到移除队列中
                tNeedRemoveList = tNeedRemoveList or { }
                table.insert(tNeedRemoveList, pArm)
            end
        end

        if tNeedRemoveList ~= nil then
            for k, pDisArm in pairs(tNeedRemoveList) do
                if (pDisArm) then
                    self:removeMArmature(pDisArm, _sceneType)
                end
            end
        end
    end

end


-- 创建自定义的Action动画
-- _tArmData(table): 特效数据 
-- _pView(MView): 动画的父控件
-- _nZorder(int): 显示的层级
-- _tPos(ccp): 显示的坐标
-- _callback(function): 播放结束回调
function MArmatureUtils:createMArmature( _tArmData, _pView, _nZorder, _tPos, _callback, _sceneType, _mode )
    if (not _tArmData) then
        return 
    end    
    _sceneType = _sceneType or SCENE_DEFAULT_TYPE
    -- 创建特效
    local pArm = MArmature.new(_tArmData, _pView, _nZorder, _tPos, _callback, _mode)
    -- 添加到特效管理列表中
    self:addMArmature(pArm, _sceneType)
    return pArm
end

-- 添加一个自定义的特效到管理列表中
-- _pArm(MArmature): 自定义的帧特效
function MArmatureUtils:addMArmature(_pArm, _sceneType)
    if (not _pArm) then
        return
    end
    _sceneType = _sceneType or SCENE_DEFAULT_TYPE
    tMArmatureList[_sceneType] = tMArmatureList[_sceneType] or { }
    tMArmatureList[_sceneType][_pArm] = _pArm

end

-- 移除一个自定义的特效
-- _pArm（MArmature）：自定义的帧特效
function MArmatureUtils:removeMArmature(_pArm, _sceneType)
    if (not _pArm or not tMArmatureList) then
        return
    end
    _sceneType = _sceneType or SCENE_DEFAULT_TYPE
    local pArm = tMArmatureList[_sceneType][_pArm]
    tMArmatureList[_sceneType][_pArm] = nil
    if tolua.isnull(pArm) == false then        
        _pArm:removeSelf()
    end
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
--------------------------------- 自定义特效刷新 -----------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

-- 刷新图片序列帧动作  
-- tValues = nil
local function updateCstArmImgSeqAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        
        local framData = _pArm.tFramData  

        -- 替换当前的帧图片
        local imageName = nil 
        if (framData.nCurFrame < 10) then
            imageName = _pAction.sImgName .. "0" .. framData.nCurFrame
        else
            imageName = _pAction.sImgName .. "" .. framData.nCurFrame
        end
        _pArm:setFrameByImg(imageName, _pAction.sImgFormat)
    end
end
-- 刷新渐隐效果 
-- tValues = {{255, 0}}，透明度从255到0的变化
local function updateCstArmOpacityAct( _pArm, _pAction )
    

    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end
    if (not _pAction.tValues or #_pAction.tValues < 1) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的透明度
    local nSValue = _pAction.tValues[1][1] or 0
    local nEValue = _pAction.tValues[1][2] or 0
    local fCurValue = nSValue 
         + (nEValue - nSValue) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setOpacity(fCurValue) -- 设置透明度值
end
-- 刷新缩放效果 
-- tValues = {{1, 0.5}}，缩放值从1到0.5的变化
local function updateCstArmScaleAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end

    if (not _pAction.tValues or #_pAction.tValues < 1) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的缩放值
    local nSValue = _pAction.tValues[1][1] or 0
    local nEValue = _pAction.tValues[1][2] or 0
    local fCurValue = nSValue 
         + (nEValue - nSValue) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setScaleC(fCurValue * framData.fScale) -- 设置缩放值
end
-- 刷新移动效果
-- tValues = {{0, 0}, {20, 20}}，从坐标(0, 0)移动到(20, 20)
local function updateCstArmMoveAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end

    if (not _pAction.tValues or #_pAction.tValues < 2) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的移动距离
    local fOriX = _pAction.tValues[1][1] or 0
    local fOriY = _pAction.tValues[1][2] or 0
    local fToX = _pAction.tValues[2][1] or 0
    local fToY = _pAction.tValues[2][2] or 0
    local fMovX = fOriX
         + (fToX - fOriX) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    local fMovY = fOriY 
         + (fToY - fOriY) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum

    _pArm:setPositionC(framData.tPos.x + fMovX, framData.tPos.y + fMovY) -- 设置最新坐标
end
-- 刷新缩放 + 透明度效果
-- tValues = {{1, 0.5}, {255, 0}}, 
-- 缩放值从1到0.5的变化，同时执行透明度从255到0的变化
local function updateCstArmScaleAndOpacityAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end

    if (not _pAction.tValues or #_pAction.tValues < 2) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的缩放值
    local nSValue1 = _pAction.tValues[1][1] or 0
    local nEValue1 = _pAction.tValues[1][2] or 0
    local fCurValue1 = nSValue1 
         + (nEValue1 - nSValue1) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setScaleC(fCurValue1 * framData.fScale) -- 设置缩放值

    -- 计算当前的透明度值
    local nSValue2 = _pAction.tValues[2][1] or 0
    local nEValue2 = _pAction.tValues[2][2] or 0
    local fCurValue2 = nSValue2 
         + (nEValue2 - nSValue2) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setOpacity(fCurValue2) -- 设置透明度值
end
-- 刷新旋转效果
-- tValues = {{0, 180}}, 旋转角度从0到180度的变化
local function updateCstArmRotateAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end

    if (not _pAction.tValues or #_pAction.tValues < 1) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的旋转角度
    local nSValue = _pAction.tValues[1][1] or 0
    local nEValue = _pAction.tValues[1][2] or 0
    local fCurValue = nSValue 
         + (nEValue - nSValue) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setRotationC(fCurValue) -- 设置最新旋转角度
end
-- 刷新旋转 + 透明度效果
-- tValues = {{0, 180}, {255, 0}}
-- 旋转角度从0到180度的变化，同时执行透明度从255到0的变化
local function updateCstArmRotateAndOpacityAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end

    if (not _pAction.tValues or #_pAction.tValues < 2) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的旋转角度
    local nSValue1 = _pAction.tValues[1][1] or 0
    local nEValue1 = _pAction.tValues[1][2] or 0
    local fCurValue1 = nSValue1 
         + (nEValue1 - nSValue1) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setRotationC(fCurValue1) -- 设置最新旋转角度

    -- 计算当前的透明度值
    local nSValue2 = _pAction.tValues[2][1] or 0
    local nEValue2 = _pAction.tValues[2][2] or 0
    local fCurValue2 = nSValue2 
         + (nEValue2 - nSValue2) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setOpacity(fCurValue2) -- 设置透明度值
end
-- 刷新移动+透明度效果
-- tValues = {{0, 0}, {20, 20}, {255, 0}}
-- 从坐标(0, 0)移动到(20, 20)，同时执行透明度从255到0的变化
local function updateCstArmMoveAndOpacityAct( _pArm, _pAction )
    if (_pAction.sImgName) then
        -- 替换当前的图片
        _pArm:setFrameByImg(_pAction.sImgName, _pAction.sImgFormat)
    end
    local nFrameNum = _pAction.nEFrame - _pAction.nSFrame
    if (nFrameNum == 0) then
        return 
    end

    if (not _pAction.tValues or #_pAction.tValues < 2) then
        return 
    end
    
    local framData = _pArm.tFramData 

    -- 计算当前的移动距离
    local fOriX = _pAction.tValues[1][1] or 0
    local fOriY = _pAction.tValues[1][2] or 0
    local fToX = _pAction.tValues[2][1] or 0
    local fToY = _pAction.tValues[2][2] or 0
    local fMovX = fOriX
         + (fToX - fOriX) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    local fMovY = fOriY 
         + (fToY - fOriY) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setPositionC(framData.tPos.x + fMovX, framData.tPos.y + fMovY) -- 设置最新坐标

    -- 计算当前的透明度值
    local nSValue = _pAction.tValues[3][1] or 0
    local nEValue = _pAction.tValues[3][2] or 0
    local fCurValue = nSValue 
         + (nEValue - nSValue) * (framData.nCurFrame - _pAction.nSFrame) / nFrameNum
    _pArm:setOpacity(fCurValue) -- 设置透明度值
end


------------------------------------------------------------------------------
--------------------------------- 自定义特效定义 -----------------------------
------------------------------------------------------------------------------
local e_cust_armature_t = {
    do_nothing = 0, -- 不做任何动作 tValues = nil
    img_seq = 1, -- 图片序列帧播放 tValues = nil
    opacity = 2, -- 透明度 tValues = {{255, 0}}，透明度从255到0的变化
    scale = 3, -- 缩放 tValues = {{1, 0.5}}，缩放值从1到0.5的变化
    move = 4, -- 移动 tValues = {{0, 0}, {20, 20}}，从坐标(0, 0)移动到(20, 20)
    scale_opacity = 5, -- 缩放+透明度 tValues = {{1, 0.5}, {255, 0}}, 
                       -- 缩放值从1到0.5的变化，同时执行透明度从255到0的变化
    rotate = 6, -- 旋转 tValues = {{0, 180}}, 旋转角度从0到180度的变化
    rotate_opacity = 7, -- 旋转+透明度 tValues = {{0, 180}, {255, 0}}
                        -- 旋转角度从0到180度的变化，同时执行透明度从255到0的变化
    move_opacity = 8, -- 移动+透明度 tValues = {{0, 0}, {20, 20}, {255, 0}}
                      -- 从坐标(0, 0)移动到(20, 20)，同时执行透明度从255到0的变化
}

-- 执行动作
-- _pArm（MArmature）：自定义的帧特效
-- _pAction（CCAction）：动画行为
function MArmatureUtils:doCstArmAdtions( _pArm, _pAction )
    if (not _pArm or not _pAction) then
        return
    end

    if (_pAction.nType == e_cust_armature_t.do_nothing) then -- 不做任何动作
    elseif (_pAction.nType == e_cust_armature_t.img_seq) then -- 图片序列帧播放
        updateCstArmImgSeqAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.opacity) then -- 透明度变化效果
        updateCstArmOpacityAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.scale) then -- 缩放效果
        updateCstArmScaleAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.move) then -- 移动
        updateCstArmMoveAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.scale_opacity) then -- 缩放 + 透明度
        updateCstArmScaleAndOpacityAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.rotate) then -- 旋转
        updateCstArmRotateAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.rotate_opacity) then -- 旋转+透明度
        updateCstArmRotateAndOpacityAct(_pArm, _pAction)
    elseif (_pAction.nType == e_cust_armature_t.move_opacity) then -- 移动+透明度
        updateCstArmMoveAndOpacityAct(_pArm, _pAction)
    end
end

--获取当前SceneType
function MArmatureUtils:getSceneType(  )
    return nSceneType
end