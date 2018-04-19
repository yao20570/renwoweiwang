----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-01-12 18:12:52 
-- Description: 游戏的工具类
-----------------------------------------------------
import(".GameConfig")
import(".msg.MsgUtils")
import(".LocalGameState")
import(".AccountCenter")
import(".net.SocketManager")
import(".Sounds")
import(".PolygonTouch")
import(".ActionUtils")
import(".NormalCusArmDatas")
import(".RechargeUtil")

import("..worldlan.ColorUtils")
import("..module.ModuleUtils")
import("..worldlan.LanManager")
import("..common.RootLayerHelper")
import("..common.dialog.DlgUtils")
import("..common.dialog.UIAction")
import("..common.toast.UIToast")
import("..common.button.BtnUtils")
import("..common.richview.RichLabelUtils")
import("..common.iconview.IconUtils")
import("..common.heroview.HeroViewUtils")
import("..common.listview.ListViewUtil")
import("..common.getitem.GetItemUtils")
import("..common.rednums.RedNumsUtils")
import("..common.banner.MBannerUtils")



import("..data.dbmrg.ResManager")
import(".MathUtils")
import("..module.ModuleUtils")
import("..module.PoolUtils")
import(".ShowSequence")

require("cocos.myui.mviewutils.MArmaturePlistUtils")

local FightLayer = require("app.layer.fight.FightLayer")
local FightSecLayer = require("app.layer.fightsec.FightSecLayer")

local DlgFubenResult = require("app.layer.fuben.DlgFubenResult")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ScoreBox = require("app.layer.country.data.ScoreBox")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemMailSendTimeShare = require("app.layer.mail.ItemMailSendTimeShare")
local ItemActBtn = require("app.layer.activitymodel.ItemActBtn")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")
local TaskDialogLayer = require("app.layer.task.TaskDialogLayer")
local ArenaFightRepotRes = require("app.layer.arena.data.ArenaFightRepotRes")
local ExpediteReportRes = require("app.layer.passkillhero.data.ExpediteReportRes")

--记录上次点击界面的系统时间(点击任务提示需要)
N_LAST_CLICK_TIME = nil

--总览层是否可见
B_OVERVIEW_LAYER = nil

--建筑引导
BuildGuide = nil

ContactServiceControl = {
    1071,
    1072,
    1073,
    1074,
    1075,
    1076,
    1077   
}

-- 解析布局lua文件
-- _sLuaName：lua文件名字（必传，例如：layout_fight）
-- _pViewHandler：生成view后的回到方法（必传，return view）
function parseView( _sLuaName, _pViewHandler )
	-- body
--	if not _sLuaName or #_sLuaName == 0 then
--		print("_sLuaName is nil")
--		return
--	end
--	if not _pViewHandler then
--		print("_pViewHandler is nil")
--		return
--	end
	MViewReader:getInstance():createNewGroup("app.jsontolua." .. _sLuaName, _pViewHandler)
		
end

-- 执行表的普通复制
-- st(table)：源表
-- -- return(table): 复制后得到的表
-- function copyTab( st )
--     local tab = {}
--     -- print(":type=" .. type(st))
--     for k, v in pairs(st or {}) do
--     print(":type11=" .. type(v))

--         if type(v) ~= "table" then
--             tab[k] = v
--         else
--             tab[k] = copyTab(v)
--         end
--     end
--     return tab
-- end

--深度拷贝  
function copyTab(object)      
    local lookup_table = {}  
    local function _copy(object)  
        if type(object) ~= "table" then  
            return object  
        elseif lookup_table[object] then  
            return lookup_table[object]  
        end         
        local new_table = {}  
        lookup_table[object] = new_table  
        for index, value in pairs(object) do  
            new_table[_copy(index)] = _copy(value)  
        end   
        return setmetatable(new_table, getmetatable(object))      
    end       
    return _copy(object)  
end 

-- 检测替换成最终的layer
-- 每一层帅选，拿到没有启用定时回调的控件
function checkRealLayer( pView )
    for i=1, 5, 1 do
        if(i == 2 and Player:getUIHomeLayer() ) then
            pView = Player:getUIHomeLayer()
        elseif(i == 3 and Player:getUIHomeLayer().pHomeTop) then
            pView = Player:getUIHomeLayer().pHomeTop
        elseif(i == 4 and Player:getUIHomeLayer().pHomeBottom) then
            pView = Player:getUIHomeLayer().pHomeBottom
        elseif(i == 5 and Player:getUIHomeLayer().pHomeCenter) then
            pView =Player:getUIHomeLayer().pHomeCenter
        end
        if(pView.nRefrCallbadkdd == nil) then
            break
        end
    end
    return pView
end

-- 只执行一次刷新
-- nCount：需要回调多少帧
function scheduleOnceCallback( pView, nBackHandler, nCount)
    if(nCount == 0) then
        nBackHandler()
        return
    end
    if(pView) then
    	pView = checkRealLayer(pView)
        pView.nCallbackCount = 0
        pView.nRefrCallbadkdd = MUI.scheduler.scheduleUpdateGlobal(function (  )
            if(pView.nCallbackCount ~= nil) then
                pView.nCallbackCount = pView.nCallbackCount + 1
                if(pView.nCallbackCount >= nCount) then
                    if pView ~= nil and pView.nRefrCallbadkdd ~= nil then
                        nBackHandler()
                        MUI.scheduler.unscheduleGlobal(pView.nRefrCallbadkdd)
                        pView.nRefrCallbadkdd = nil
                        nBackHandler = nil
                    end
                end
            else
                if pView ~= nil and pView.nRefrCallbadkdd ~= nil then
                    MUI.scheduler.unscheduleGlobal(pView.nRefrCallbadkdd)
                    pView.nRefrCallbadkdd = nil
                    nBackHandler = nil
                end
            end
        end)
    end
end

--判断颜色是否相同Color4B
function isEqualC4B( _aColor4B, _bColor4B )
    -- body
    if not _aColor4B or not _bColor4B then
        return false
    else
        if _aColor4B.r == _bColor4B.r and _aColor4B.g == _bColor4B.g 
            and _aColor4B.b == _bColor4B.b and _aColor4B.a == _bColor4B.a  then
            return true
        else
            return false
        end
    end
end

--判断颜色是否相同Color3B
function isEqualC3B( _aColor3B, _bColor3B )
    -- body
    if not _aColor3B or not _bColor3B then
        return false
    else
        if _aColor3B.r == _bColor3B.r and _aColor3B.g == _bColor3B.g 
            and _aColor3B.b == _bColor3B.b  then
            return true
        else
            return false
        end
    end
end

-- sStr: 目前只能是六个十六位进制的字符，比如"f7d729"
-- 返回值：对应的颜色
function getC3B( sStr )
    local str = tostring(sStr)
    local color = {}
    local j = 1
    for i=1, 6, 2 do
        color[j] = tonumber("0x" .. string.sub(str, i, i+1))
        j = j + 1
    end
    if color[1] and color[2] and color[3] then
        return cc.c3b(color[1], color[2], color[3])
    else
        return cc.c3b(255, 255, 255)
    end
end

-- sStr: 目前只能是8个十六位进制的字符，比如"fff7d729"
-- 返回值：对应的颜色
function getC4B( sStr )
    local str = tostring(sStr)
    local color = {}
    local j = 1
    for i=1, 8, 2 do
        color[j] = tonumber("0x" .. string.sub(str, i, i+1))
        j = j + 1
    end
    return cc.c4b(color[1], color[2], color[3], color[4])
end

-- 延迟加载数据
-- pParentView（CCNode）：执行延迟的父类
-- nFunc（function）: 延迟之后回调的函数
-- fDelayTime（float）：延迟的时间，默认的
function doDelayForSomething( pParentView, nFunc, fDelayTime )
    if(pParentView and nFunc) then
        fDelayTime = fDelayTime or 0.17
        pParentView:runAction(cc.Sequence:create(
            cc.DelayTime:create(fDelayTime),
            cc.CallFunc:create(nFunc)))
    end
end


-- 分割字符串（快速的分割方式）
-- str(string)：原来的字符串
-- split_char(string)：分割的字符样式（不能是正则表达式）
function luaSplit( str, split_char )
    return string.split(str, split_char)
end

-- 多项分割
-- 例子：
-- local testStr = "1,85025:3000|2,85025:2700|3,85025:2400|4,85025:2100|5,85025:1800|6,85025:1500|7,85025:1200|8,85025:1000"
-- local tRes = luaSplitMuilt(testStr,"|",",",":")
function luaSplitMuilt( _str,...)
    local function _luaSplitMuilt(str,index,charList)
        local charListNum = #charList
        if index > charListNum then
            return
        elseif index == #charList  then
            local dataList = string.split(str, charList[index])
            if #dataList == 1 then
                return str
            else
                return dataList
            end
        elseif index < #charList then
            local strList = string.split(str, charList[index])
            local t = {}
            for i=1,#strList do
                local subT = _luaSplitMuilt(strList[i],index+1,charList)
                if subT then
                    table.insert(t,subT)
                end
            end
            --只有一个元素的时候直接返回元素
            if #t == 1 then
                return t[1]
            end
            return t
        end
    end
    return _luaSplitMuilt(_str,1,{...})
end

-- 多项分割
-- 例子：
-- local testStr = "1,85025:3000|2,85025:2700|3,85025:2400|4,85025:2100|5,85025:1800|6,85025:1500|7,85025:1200|8,85025:1000"
-- local tRes = luaSplitMuilt2(testStr,"|",",",":")
function luaSplitMuilt2( _str,...)
    local function _luaSplitMuilt(str,index,charList)
        local charListNum = #charList
        if index > charListNum then
            return
        elseif index == #charList  then
            local dataList = string.split(str, charList[index])
            return dataList
        elseif index < #charList then
            local strList = string.split(str, charList[index])
            local t = {}
            for i=1,#strList do
                local subT = _luaSplitMuilt(strList[i],index+1,charList)
                if subT then
                    table.insert(t,subT)
                end
            end
            return t
        end
    end
    return _luaSplitMuilt(_str,1,{...})
end

--根据首字节获取UTF8需要的字节数
function getUTF8CharLength(ch)
    local utf8_look_for_table = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1,
    }
    return utf8_look_for_table[ch]
end

--根据UTF8流获取字符串长度
--string.getUTF8Length("一二三四五六七") 返回7
function string.getUTF8Length(str)
    local len = 0
    local ptr = 1
    repeat
        local char = string.byte(str, ptr)
        local char_len = getUTF8CharLength(char)
        len = len + 1
        ptr = ptr + char_len
    until(ptr>#str)
    return len
end

--截取UTF8字符串
--string.subUTF8String("一二三四五六七",1,3) 返回一二三
function string.subUTF8String(str, begin, length)
    begin = begin or 1
    length = length or -1 --length为-1时代表不限制长度
    local ret = ""
    local len = 0
    local ptr = 1
    repeat
        local char = string.byte(str, ptr)
        local char_len = getUTF8CharLength(char)
        len = len + 1

        if len>=begin and (length==-1 or len<begin+length) then
            for i=0,char_len-1 do
                ret = ret .. string.char( string.byte(str, ptr + i) )
            end
        end

        ptr = ptr + char_len
    until(ptr>#str)
    return ret
end

-- 将table序列化为字符串
function sz_Table2String(_t)  
    local szRet = "{"  
    function doT2S(_i, _v)  
        if "number" == type(_i) then  
            szRet = szRet .. "[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. sz_Table2String(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. '["' .. _i .. '"] = '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. sz_Table2String(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        end  
    end  
    table.foreach(_t, doT2S)  
    szRet = szRet .. "}"  
    return szRet  
end


-- 是否从后台切换回来后已经准备好工作了
function isForegroundReady( )
    -- 如果从后台回来还不到1秒钟，不执行刷新行为
    if(n_last_foreground_time) then
        local fEnterBackDisTime = getSystemTime() - n_last_foreground_time
        if(fEnterBackDisTime <= 1.01) then
            return false
        end
    end
    return true
end

--[[  ccs.Armature   play(name.-1,-1) :名字，两个动画之间的切换帧数量，播放次数：-1循环播放
创建动画，如果动画资源没有找到，使用替代的动画，并且返回最终的动画名字 
@param _srcPath(string) 资源的路径(例如 "tx/task/")
@param _srcName(string) json资源的名字（不包括后缀名)
@param _count(int)  json需要的plist资源数量  可选(当需要多plist时,必须填写)
@param _strName(string) plist资源的名字 (如果plist与json资源不同名才填写) 可选
@param _isNeedRemove(bool)  是否需要加入清除列表  可选
@param _leftCount(int) 需要保留的次数   可选
@param _tPlist(table) 引用到其他多个不同名字的plist纹理文件，除去默认的纹理
]]

v_vUnusedAnima = {}
v_fightAnima = {}

function createAnimationBackName( _srcPath, _srcName, _count, _strName, _isNeedRemove, _leftCount, _tPlist)
    local finalName = _srcName

    if v_fightAnima[finalName] then
        -- 如果纹理已经被清除了，强制补充纹理的加载
        -- 补齐路径
        if _srcPath and #_srcPath > 0 then
            if not string.find(_srcPath, "/", #_srcPath - 1) then
                local tempStr = _srcPath.."/"
                _srcPath = tempStr;
            end
        end
        --筛选最终名字
        local sNa = _srcName
        if _strName and #_strName > 0 then
            sNa = _strName
        end
        local _str = _srcPath..sNa
        -- 判断是否存在
        if(v_vUnusedAnima[_str]) then
            local pTempPng = _srcPath..sNa.."0.png"
            local pTempPlist = _srcPath..sNa.."0.plist"
            local pTempJson = _srcPath..sNa..".ExportJson"
            local tPngs = v_vUnusedAnima[_str].tPngs
            if(tPngs and table.nums(tPngs) > 0) then
                for i, v in pairs(tPngs) do
                    local pTempPng = v
                    local pTempPlist = string.gsub(pTempPng, ".png", ".plist")
                    local pTex = cc.Director:getInstance():getTextureCache()
                        :getTextureForKey(pTempPng)
                    if(pTex == nil) then
                        -- 将已经被清除掉的纹理补回来
                        cc.SpriteFrameCache:getInstance()
                            :addSpriteFramesWithFile(pTempPlist, pTempPng)
                    end
                end
            end
        end
        return finalName
    end

    if _isNeedRemove == nil then
        _isNeedRemove = true
    end
    _leftCount = _leftCount or 1
    _count = _count or 1
    if _srcPath == nil or string.len(_srcPath) <= 0 then
        _srcPath = "tx/home/"
    end
    if _srcName == nil or string.len(_srcName) <= 0 then
        _srcName = "tx_uiputx003"
    end


    if _srcName and #_srcName > 0 then
        --如果最后面没有"/"，就加上
        if _srcPath and #_srcPath > 0 then
            if not string.find(_srcPath, "/", #_srcPath - 1) then
                local tempStr = _srcPath.."/"
                _srcPath = tempStr;
            end
        end
        local _animJSON = _srcPath.._srcName..".ExportJson"
        -- 判断Plist名是否和Json名一致
        if _strName and #_strName > 0 then
            _srcName = _strName
        end
        local _animPNG = _srcPath.._srcName.."0.png"
        local _animPLIST = _srcPath.._srcName.."0.plist"
        if _isNeedRemove then
            -- 记录需要删除的动画数据
            local _str = _srcPath.._srcName
            if v_vUnusedAnima[_str] then
                v_vUnusedAnima[_str].value = v_vUnusedAnima[_str].value+1
                -- return finalName
            else
                v_vUnusedAnima[_str] = {}
                v_vUnusedAnima[_str].value = _leftCount
                v_vUnusedAnima[_str].file = _animJSON
                v_vUnusedAnima[_str].tPngs = v_vUnusedAnima[_str].tPngs or {}
                v_vUnusedAnima[_str].tPngs[#v_vUnusedAnima[_str].tPngs+1] = _animPNG
            end
            -- 当动画所需的plist大于一个时,需要在这里加入纹理并记录
            if _count > 1 then
                for i=1, _count-1 do
                    local countPng = _srcPath.._srcName..i..".png"
                    local countPlist = _srcPath.._srcName..i..".plist"
                    v_vUnusedAnima[_str].tPngs[#v_vUnusedAnima[_str].tPngs+1] = countPng
                    ccs.ArmatureDataManager:getInstance():addSpriteFrameFromFile(countPlist,countPng,_animJSON)
                end
            end
            -- 加入纹理表 _tPlist 并记录下来 
            if _tPlist and table.nums(_tPlist) > 0 then
                for k, v in pairs (_tPlist) do
                    local countPng = _srcPath..v..".png"
                    local countPlist = _srcPath..v..".plist"
                    v_vUnusedAnima[_str].tPngs[#v_vUnusedAnima[_str].tPngs+1] = countPng
                    ccs.ArmatureDataManager:getInstance():addSpriteFrameFromFile(countPlist,countPng,_animJSON)
                end
            end
        end

        local PngPath = cc.FileUtils:getInstance():fullPathForFilename(_animPNG)
        local PlistPath = cc.FileUtils:getInstance():fullPathForFilename(_animPLIST)
        local JsonPath = cc.FileUtils:getInstance():fullPathForFilename(_animJSON)
        if isFileExistCfg(PngPath) and isFileExistCfg(PlistPath) and isFileExistCfg(JsonPath) then
            v_fightAnima[finalName] = {}
            v_fightAnima[finalName].file = _animJSON
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(_animPNG,_animPLIST,_animJSON)
        else
            -- 执行默认的特效
        end
    end
    return finalName
end

-- 循环显示特效
-- pView(SView): 控件
-- sArmPath（string）：特效路径
-- sArmName（string）：特效名字
-- nTag（int）：tag值，便于查找
-- nZorder（int）: 要显示的zorder值
-- sActionName(string) : 特效中的需要播放的动作名字, 可选
function showRepeatForeverAnimation( pView , sArmPath, sArmName, nTag, nZorder, sActionName )
    sActionName = sActionName or "Animation1"
    nTag = nTag or 199999
    nZorder = nZorder or 100
    -- 判断是否已经存在这个特效，有的话清除掉先
    clearRepeatForeverAnimation(pView, nTag)
    --加载特效文件
    local name = createAnimationBackName(sArmPath,sArmName)
    local armature = ccs.Armature:create(name)
    armature:setTag(nTag)
    armature:setZOrder(nZorder)
    pView:addChild(armature)
    centerInView(pView,armature)
    armature:getAnimation():play(sActionName, -1, -1)
    return armature
end

-- 清除循环特效
-- pView（SView）：控件
-- nTag （int）：tag值
function clearRepeatForeverAnimation( pView, nTag )
    -- body
    nTag = nTag or 199999
    if(pView) then
        local pChildView = pView:getChildByTag(nTag)
        if(pChildView) then -- 清除自己
            pChildView:removeSelf()
        end
    end
end

-- 替换骨骼
-- _pArm（ccs.Armature）：特效
-- _sBoneName（string）：需要替换的骨骼名字
-- sImgName（string）：需要替换的图片名称
-- _bIsBlend（bool）：是否需要混合模式
function changeBoneWithImage( _pArm, _sBoneName, sImgName, _bIsBlend )
    if (not _pArm or not _sBoneName or not sImgName) then
        return 
    end
    local pImgUpg0 = display.newSprite(sImgName)
    if (_bIsBlend == true) then
        pImgUpg0:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    end
    if pImgUpg0 then
        local pBone0 = _pArm:getBone(_sBoneName)
        if (pBone0) then
            pBone0:addDisplay(pImgUpg0, 0)
        end
    end
end

-- 使用名字更换骨骼的展示
-- pArmature（CCArmature）：特效
-- sBoneName（string）：骨骼名字
-- sPngName （string）：最终要展示的图片名字
-- bIsBlend（bool）：是否需要混合模式
function changeBoneWithPngName( pArmature, sBoneName, sPngName, bIsBlend )
    -- body
    -- 自定义一个图片
    local pImg = MUI.MImage.new(sPngName)
    if (bIsBlend == true) then
        pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    end
    -- 更换展示的node
    changeBoneWithNode(pArmature, sBoneName, pImg)
    return pImg
end

-- 使用名字更换骨骼的展示
-- pArmature（CCArmature）：特效
-- sBoneName（string）：骨骼名字
-- sPngName （string）：最终要展示的图片名字
-- bIsBlend（bool）：是否需要混合模式
function changeBoneWithPngAndScale( pArmature, sBoneName, sPngName, bIsBlend, tAnchorPoint )
    -- body
    tAnchorPoint = tAnchorPoint or cc.p(0.5,0.5)
    local pLay = MUI.MLayer.new()
    local pImg = MUI.MImage.new(sPngName)
    pLay:setLayoutSize(1,1)
    pLay:addView(pImg)
    pImg:setPosition((0.5 - tAnchorPoint.x) * pImg:getWidth(),(0.5 - tAnchorPoint.y) * pImg:getHeight())
    if bIsBlend == true then
        pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    end
    changeBoneWithNode(pArmature,sBoneName,pLay)
end
-- 使用名字更换骨骼的展示
-- pArmature（CCArmature）：特效
-- sBoneName（string）：骨骼名字
-- pNode （CCNode）：最终要展示的布局
function changeBoneWithNodeAndScale( pArmature, sBoneName, pNode, tAnchorPoint )
    -- body
    tAnchorPoint = tAnchorPoint or cc.p(0.5,0.5)
    local pLay = MUI.MLayer.new()    
    pLay:setLayoutSize(1,1)
    pLay:addView(pNode)
    pNode:setPosition((0.5 - tAnchorPoint.x) * pNode:getWidth(),(0.5 - tAnchorPoint.y) * pNode:getHeight())
    changeBoneWithNode(pArmature,sBoneName,pLay)    
end

-- 更换骨骼
-- pArmature（CCArmature）：特效
-- sBoneName（string）：骨骼名字
-- pNode （CCNode）：最终要展示的布局
function changeBoneWithNode( pArmature, sBoneName, pNode )
    -- body
    local pBone = pArmature:getBone(sBoneName)
    -- 替换骨骼的显示内容
    if(pBone) then
        pBone:addDisplay(pNode, 0)
        -- pBone:setIgnoreMovementBoneData(true)
        -- pBone:changeDisplayWithIndex(0, true)
    end
end


-- 创建一个新的粒子特效
-- sPlistName（string）：粒子特效的名称
function createParitcle( sPlistName )
    local pPartical = cc.ParticleSystemQuad:create(sPlistName)
    local pBatch = cc.ParticleBatchNode:createWithTexture(pPartical:getTexture())
    pPartical:setPositionType(MUI.kCCPositionTypeRelative)
    return pPartical
end

--[[-- 
清空动画缓存
]]
function clearUnusedAnima()
    
    if table.nums(v_vUnusedAnima) > 0 then
        local removeTable = {}
        for k,v in pairs(v_vUnusedAnima) do
            -- v.value = 0 --强制释放
            if v.value <= 0 then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v.file)
                removeTable[#removeTable + 1] = k
            end
        end
        for k,v in pairs(removeTable) do
            v_vUnusedAnima[v] = nil
        end
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end
    if v_fightAnima and table.nums(v_fightAnima) > 0 then
        for k, v in pairs(v_fightAnima) do
            v_fightAnima[k] = nil
        end
    end
end

-- 清除界面中未使用到的纹理缓存
function removeUnusedTextures()
    MArmaturePlistUtils.cleanKeep()
    display.removeUnusedSpriteFrames()
end

--把plist纹理添加到缓存中
--_sPathAndName：纹理名字  例如：tx/fight/p1_wj_s_002
--_nType：1：png 2：pvr 3：jpg
-- _bKeep(bool): 是否常驻内存
-- _fAsyncHandler(function):异步加载回调
function addTextureToCache( _sPathAndName, _nType, _bKeep, _fAsyncHandler )
    -- body
    if not _sPathAndName then
        return
    end

    _nType = _nType or 1

    if b_show_load_texture_info ~= false then
        if _fAsyncHandler == nil then
            myprint("加载纹理-图集(即时)","===========>:", _sPathAndName, _nType)
        else
            myprint("加载纹理-图集(异步)","===========>:开始", _sPathAndName, _nType)
        end
    end

    if _nType == 1 then --png
        if b_open_texture_cutquality then --是否需要降低品质
            if(gIsFileIn8888FormatList(_sPathAndName  .. ".png")) then
                -- 使用16位的纹理
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            else
                 -- 使用16位的纹理
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
            end
        end
        --纹理添加到缓存中
        display.addSpriteFrames(_sPathAndName .. ".plist", _sPathAndName .. ".png", _fAsyncHandler)
        --恢复回来
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)

    elseif _nType == 2 then --pvr
        --纹理添加到缓存中
        display.addSpriteFrames(_sPathAndName .. ".plist", _sPathAndName .. ".pvr.ccz", _fAsyncHandler)

    elseif _nType == 3 then --jpg
        if b_open_texture_cutquality then --是否需要降低品质
            if(gIsFileIn8888FormatList(_sPathAndName  .. ".jpg")) then
                -- 使用16位的纹理
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            else
                 -- 使用16位的纹理
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
            end
        end
        --纹理添加到缓存中
        display.addSpriteFrames(_sPathAndName .. ".plist", _sPathAndName .. ".jpg", _fAsyncHandler)
        --恢复回来
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)

    end
    -- 判断是否常驻内存，如果需要常驻内存的话，添加到helper管理器中
    if _fAsyncHandler == nil then
        if(_bKeep and ccs.SpriteFrameCacheHelper) then
            ccs.SpriteFrameCacheHelper:getInstance():retainSpriteFrames(_sPathAndName .. ".plist")
        end
    end
end


--从缓存中把纹理释放掉
--_sPathAndName：纹理名字  例如：tx/fight/p1_wj_s_002
--_nType：1：png 2：pvr 3：jpg
function removeTextureFromCache( _sPathAndName, _nType )
    -- body
    if(not ccs.SpriteFrameCacheHelper) then
        return
    end

    ccs.SpriteFrameCacheHelper:getInstance():releaseSpriteFrames(_sPathAndName .. ".plist")

    _nType = _nType or 1
    if _nType == 1 then
        display.removeSpriteFramesWithFile(_sPathAndName .. ".plist", _sPathAndName .. ".png")
    elseif _nType == 2 then
        display.removeSpriteFramesWithFile(_sPathAndName .. ".plist", _sPathAndName .. ".pvr.ccz")
    elseif _nType == 3 then
        display.removeSpriteFramesWithFile(_sPathAndName .. ".plist", _sPathAndName .. ".jpg")
    end
end

--特殊需要预加载纹理
tNeedLoadFirstTexture = {}

-- 特效
tNeedLoadFirstTexture["tx/other/sg_zjm_blsqt_sfx.plist"]= "tx/other/sg_zjm_blsqt_sfx.plist"
tNeedLoadFirstTexture["tx/other/sg_zjm_blsqt_xfs.plist"]= "tx/other/sg_zjm_blsqt_xfs.plist"
tNeedLoadFirstTexture["tx/other/sg_zjm_ddh_sfx.plist"]  = "tx/other/sg_zjm_ddh_sfx.plist"
tNeedLoadFirstTexture["tx/other/sg_zjm_ddh_xfs.plist"]  = "tx/other/sg_zjm_ddh_xfs.plist"
tNeedLoadFirstTexture["tx/other/p1_tx_zjmpb.plist"]     = "tx/other/p1_tx_zjmpb.plist"
tNeedLoadFirstTexture["tx/other/p1_tx_zjmpb2.plist"]    = "tx/other/p1_tx_zjmpb2.plist"
tNeedLoadFirstTexture["tx/other/p1_tx_slt.plist"]       = "tx/other/p1_tx_slt.plist"
tNeedLoadFirstTexture["tx/other/sg_jztx_zjm_kjy.plist"] = "tx/other/sg_jztx_zjm_kjy.plist"  
tNeedLoadFirstTexture["tx/other/sg_xlb_sx_sw.plist"]    = "tx/other/sg_xlb_sx_sw.plist"  
tNeedLoadFirstTexture["tx/other/sg_xlb_xs_sw.plist"]    = "tx/other/sg_xlb_xs_sw.plist"  
tNeedLoadFirstTexture["tx/other/sg_smby_taoyue.plist"]  = "tx/other/sg_smby_taoyue.plist"  
tNeedLoadFirstTexture["tx/other/sg_smhy_taoyue.plist"]  = "tx/other/sg_smhy_taoyue.plist"  
tNeedLoadFirstTexture["tx/other/sg_hyyd_sz1.plist"]     = "tx/other/sg_hyyd_sz1.plist"  --白色游鱼
tNeedLoadFirstTexture["tx/other/sg_zjm_bbgjdj.plist"]   = "tx/other/sg_zjm_bbgjdj.plist"  
tNeedLoadFirstTexture["tx/other/gb_x_dj_a.plist"]       = "tx/other/gb_x_dj_a.plist"  
tNeedLoadFirstTexture["tx/other/gb_x_dj_b.plist"]       = "tx/other/gb_x_dj_b.plist"  
tNeedLoadFirstTexture["tx/other/gb_x_gj_a.plist"]       = "tx/other/gb_x_gj_a.plist"  
tNeedLoadFirstTexture["tx/other/gb_x_gj_b.plist"]       = "tx/other/gb_x_gj_b.plist"  
tNeedLoadFirstTexture["tx/other/sg_xlb_qbx_x.plist"]    = "tx/other/sg_xlb_qbx_x.plist"  
tNeedLoadFirstTexture["tx/other/sg_zjm_yun_x_l.plist"]  = "tx/other/sg_zjm_yun_x_l.plist"  
--tNeedLoadFirstTexture["tx/other/sg_gj_ts.plist"]        = "tx/other/sg_gj_ts.plist"  
--tNeedLoadFirstTexture["tx/other/sg_sjdt_zdtx_sa.plist"] = "tx/other/sg_sjdt_zdtx_sa.plist"
tNeedLoadFirstTexture["tx/other/sg_sjdt_bhz.plist"]     = "tx/other/sg_sjdt_bhz.plist"
--tNeedLoadFirstTexture["tx/other/sg_sjdt_sjboss.plist"]  = "tx/other/sg_sjdt_sjboss.plist"
tNeedLoadFirstTexture["tx/other/sg_sjdt_xbhz_x.plist"]  = "tx/other/sg_sjdt_xbhz_x.plist"
tNeedLoadFirstTexture["tx/other/sg_xldb_a.plist"]       = "tx/other/sg_xldb_a.plist"
--tNeedLoadFirstTexture["tx/other/sg_jmtx_zdlts_gx.plist"] = "tx/other/sg_jmtx_zdlts_gx.plist"
--tNeedLoadFirstTexture["tx/other/sg_txk_dh_vip12.plist"] = "tx/other/sg_txk_dh_vip12.plist"
tNeedLoadFirstTexture["tx/other/sg_hytx_xk_a_01.plist"] = "tx/other/sg_hytx_xk_a_01.plist"
tNeedLoadFirstTexture["tx/other/rwww_boss_jdt.plist"] = "tx/other/rwww_boss_jdt.plist"          --有图片被UI使用了(准备改为异步加载)
--tNeedLoadFirstTexture["tx/other/rwww_nslx_gjgx.plist"] = "tx/other/rwww_nslx_gjgx.plist"      --有图片被UI使用了(写在dlg里，不是持久，准备改为异步加载)
--tNeedLoadFirstTexture["tx/other/rwww_qmlb_w.plist"] = "tx/other/rwww_qmlb_w.plist"            --有图片被UI使用了(写在dlg里，不是持久，准备改为异步加载)
--tNeedLoadFirstTexture["tx/other/rwww_sjbs_ddg_bk.plist"] = "tx/other/rwww_sjbs_ddg_bk.plist" 
--tNeedLoadFirstTexture["tx/other/rwww_sjbs_xdg_bk.plist"] = "tx/other/rwww_sjbs_xdg_bk.plist"
tNeedLoadFirstTexture["tx/other/rwww_sjbs_enter.plist"] = "tx/other/rwww_sjbs_enter.plist"      --有图片被UI使用了(准备改为异步加载)
tNeedLoadFirstTexture["tx/other/rwww_sjbs_dlxg_dl_seq.plist"] = "tx/other/rwww_sjbs_dlxg_dl_seq.plist"
--tNeedLoadFirstTexture["tx/other/sg_tx_jmtx_smjsj.plist"] = "tx/other/sg_tx_jmtx_smjsj.plist"
--tNeedLoadFirstTexture["tx/other/sg_wjjj_jdt.plist"] = "tx/other/sg_wjjj_jdt.plist"
--tNeedLoadFirstTexture["tx/other/sg_jssj_zjm_2s3.plist"] = "tx/other/sg_jssj_zjm_2s3.plist"
--tNeedLoadFirstTexture["tx/other/sg_jssj_zjm_2x3.plist"] = "tx/other/sg_jssj_zjm_2x3.plist"

-- world
--tNeedLoadFirstTexture["tx/world/p1_tx_gqr.plist"]       = "tx/world/p1_tx_gqr.plist"
tNeedLoadFirstTexture["tx/world/p1_tx_world.plist"]     = "tx/world/p1_tx_world.plist"
tNeedLoadFirstTexture["tx/world/p1_tx_zjmsc.plist"]     = "tx/world/p1_tx_zjmsc.plist"
tNeedLoadFirstTexture["tx/world/qb_zjm_by.plist"]       = "tx/world/qb_zjm_by.plist"
--tNeedLoadFirstTexture["tx/world/sg_jmtx_hdwpdh.plist"]  = "tx/world/sg_jmtx_hdwpdh.plist"
--tNeedLoadFirstTexture["tx/world/sg_zdsl_js_sl.plist"]  = "tx/world/sg_zdsl_js_sl.plist"
--tNeedLoadFirstTexture["tx/world/sg_sjdt_xzg_zstx.plist"]= "tx/world/sg_sjdt_xzg_zstx.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_gf_jzd.plist"]   = "tx/world/sg_zjm_gf_jzd.plist"    --有图片被UI使用了(准备改为异步加载)
tNeedLoadFirstTexture["tx/world/sg_zjm_jzdh_gby.plist"] = "tx/world/sg_zjm_jzdh_gby.plist"
--tNeedLoadFirstTexture["tx/world/sg_zjm_jzdh_jjf.plist"] = "tx/world/sg_zjm_jzdh_jjf.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_jzdh_nc.plist"]  = "tx/world/sg_zjm_jzdh_nc.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_jztx_hy.plist"]  = "tx/world/sg_zjm_jztx_hy.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_jztx_yw.plist"]  = "tx/world/sg_zjm_jztx_yw.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_kjy_h.plist"]    = "tx/world/sg_zjm_kjy_h.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_rwtih.plist"]    = "tx/world/sg_zjm_rwtih.plist"
tNeedLoadFirstTexture["tx/world/sg_zjm_rwtih_1.plist"]  = "tx/world/sg_zjm_rwtih_1.plist"
--tNeedLoadFirstTexture["tx/world/sg_zjm_tjp.plist"]      = "tx/world/sg_zjm_tjp.plist"
tNeedLoadFirstTexture["tx/world/rwww_jjc_qz.plist"]     = "tx/world/rwww_jjc_qz.plist"
--tNeedLoadFirstTexture["tx/world/rwww_hddj_fkxg.plist"]  = "tx/world/rwww_hddj_fkxg.plist"
--tNeedLoadFirstTexture["tx/world/sg_warline_hero.plist"] = "tx/world/sg_warline_hero.plist"
--tNeedLoadFirstTexture["tx/world/sg_mw_line_hero.plist"] = "tx/world/sg_mw_line_hero.plist"
tNeedLoadFirstTexture["tx/world/rwww_zw_dj_dh.plist"]     = "tx/world/rwww_zw_dj_dh.plist"
-- 战斗兵和武将
--tNeedLoadFirstTexture["tx/fight/p2_fight_bb_s.plist"]   = "tx/fight/p2_fight_bb_s.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_bb_x.plist"]   = "tx/fight/p2_fight_bb_x.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_gb_s.plist"]   = "tx/fight/p2_fight_gb_s.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_gb_x.plist"]   = "tx/fight/p2_fight_gb_x.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_qb_s.plist"]   = "tx/fight/p2_fight_qb_s.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_qb_x.plist"]   = "tx/fight/p2_fight_qb_x.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_wj_s.plist"]   = "tx/fight/p2_fight_wj_s.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_wj_x.plist"]   = "tx/fight/p2_fight_wj_x.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_hurt.plist"]   = "tx/fight/p2_fight_hurt.plist"
--tNeedLoadFirstTexture["tx/fight/p2_fight_boss_s.plist"]   = "tx/fight/p2_fight_boss_s.plist"

--先等4.8的合，才用最新的异步加载
tNeedLoadFirstTexture["tx/other/rwww_gc_bzxg.plist"]     = "tx/other/rwww_gc_bzxg.plist"
tNeedLoadFirstTexture["tx/other/rwww_gc_stgj.plist"]     = "tx/other/rwww_gc_stgj.plist"
tNeedLoadFirstTexture["tx/other/rwww_gc_gifs.plist"]     = "tx/other/rwww_gc_gifs.plist"
tNeedLoadFirstTexture["tx/other/rwww_efg_pzgx.plist"]     = "tx/other/rwww_efg_pzgx.plist" 
tNeedLoadFirstTexture["tx/other/rwww_efg_zztx.plist"]     = "tx/other/rwww_efg_zztx.plist" 



--保存不需要降低色阶的纹理
function saveFilterSepTexture(  )
    -- body
    gSaveFileFor8888Format("ui/p1_commmon1_sep.png")
    gSaveFileFor8888Format("ui/p1_commmon2_sep.png")
    gSaveFileFor8888Format("ui/p1_commmon3_sep.png")
    gSaveFileFor8888Format("ui/p1_commmon4_sep.png")
    gSaveFileFor8888Format("ui/p1_commmon5_sep.png")
    gSaveFileFor8888Format("ui/p1_commmon6_sep.png")
    
    gSaveFileFor8888Format("ui/p1_commonse1.png")
    gSaveFileFor8888Format("ui/p1_commonse4.png")

    gSaveFileFor8888Format("ui/p2_commmon1_sep.png")
    gSaveFileFor8888Format("ui/p2_commmon2_sep.png")
	gSaveFileFor8888Format("ui/p2_commmon3_sep.png")
    gSaveFileFor8888Format("ui/p2_common3_sep.png")

    gSaveFileFor8888Format("ui/p1_button1.png")
    gSaveFileFor8888Format("ui/p2_button1.png")

    gSaveFileFor8888Format("tx/other/p1_tx_weapon.png")
    gSaveFileFor8888Format("tx/other/p1_loading.png")
    gSaveFileFor8888Format("tx/other/p1_tx_jzjs.png")
    gSaveFileFor8888Format("tx/other/sg_xldb_yw_x.png")
    gSaveFileFor8888Format("tx/other/sg_sjdt_bhz.png")
    gSaveFileFor8888Format("tx/other/sg_xldb_a.png")
    gSaveFileFor8888Format("tx/other/rwww_ksdh_qsaq.png")
    gSaveFileFor8888Format("tx/other/rwww_sjbs_dlxg_dl_seq.png")

    gSaveFileFor8888Format("tx/world/sg_jdt_tjp_tptmd.png")
    gSaveFileFor8888Format("tx/world/p1_tx_world.png")
    gSaveFileFor8888Format("tx/world/sg_zjm_jzdh_jjf.png") 
    gSaveFileFor8888Format("tx/world/p1_fight_skill_sep.png")
    gSaveFileFor8888Format("tx/world/sg_zjm_rwtih_1.png")
    gSaveFileFor8888Format("tx/world/rwww_jjc_qz.png")
    gSaveFileFor8888Format("tx/world/sg_by_zysj.png")   
    
    gSaveFileFor8888Format("ui/language/cn/p1_font_sep.png")
    gSaveFileFor8888Format("ui/language/cn/p2_font_sep.png")
    
    --非plist
    gSaveFileFor8888Format("ui/sg_ckp_8gz_tx_06.png")
    gSaveFileFor8888Format("ui/sg_dc_tbiao_10ctx_001.png")
    gSaveFileFor8888Format("ui/sg_dc_tbiao_10ctx_002.png")
    gSaveFileFor8888Format("ui/sg_dzjs_zzsk_xk_008.png")
    gSaveFileFor8888Format("ui/v1_bg_mengban.png")
    gSaveFileFor8888Format("ui/v1_img_callfight_bg.png")
    gSaveFileFor8888Format("ui/v1_img_dtx_sj.png")
    gSaveFileFor8888Format("ui/v1_img_roleshade.png")
    gSaveFileFor8888Format("ui/v1_img_tishichangtiao.png")
    gSaveFileFor8888Format("ui/v1_img_u.png")
    gSaveFileFor8888Format("ui/bg_world/v1_img_quyutu1.png")
    gSaveFileFor8888Format("ui/v1_img_zhuanpan.png")
    gSaveFileFor8888Format("ui/sg_gzbg_bgg_01.png")
    gSaveFileFor8888Format("ui/v1_img_huodezhezhao.png")
    gSaveFileFor8888Format("ui/v1_bg_gxhdxsa_x_02.jpg")    
    gSaveFileFor8888Format("ui/bg_guide/v1_img_qinqinshihuang.png")  
    gSaveFileFor8888Format("ui/bg_guide/v1_img_hanliubang.png")  
    gSaveFileFor8888Format("ui/bg_guide/v1_img_chuxiangyu.png")
    gSaveFileFor8888Format("ui/v1_bg_fbd.jpg")   
    gSaveFileFor8888Format("ui/bg_base/v2_bg_tiejiangpu.jpg") 
    gSaveFileFor8888Format("ui/v2_bg_popup_a.png") 
    gSaveFileFor8888Format("ui/v2_bg_popup_b.png") 
    gSaveFileFor8888Format("ui/v2_bg_gjbj.jpg")
    gSaveFileFor8888Format("ui/v2_bg_nsdkz.jpg")
    gSaveFileFor8888Format("ui/v2_img_xunlongdi.jpg")
    gSaveFileFor8888Format("ui/v2_img_wushen_cf.png")
    gSaveFileFor8888Format("ui/v2_bg_kejizonglan.jpg")
    gSaveFileFor8888Format("ui/bg_hero/v2_img_caiwenji.png")
    gSaveFileFor8888Format("ui/bg_hero/v1_img_zhujue.png")
    gSaveFileFor8888Format("ui/bg_hero/v2_img_yangguifei.png")
    gSaveFileFor8888Format("ui/v2_bg_bj.jpg")
    gSaveFileFor8888Format("ui/v2_bg_bjdi.png")
    gSaveFileFor8888Format("ui/bg_hero/v1_img_role.png")
    gSaveFileFor8888Format("ui/v2_bg_shouci.jpg")
    gSaveFileFor8888Format("ui/v2_bg_xunfangmeiren.jpg")
    gSaveFileFor8888Format("ui/big_img/v2_bg_guojia_wuzi.png") 
    gSaveFileFor8888Format("ui/big_img/v2_img_shengzi.png") 
        
    --big_img_sep
    gSaveFileFor8888Format("ui/big_img_sep/rwww_ui_dc1_a_01.png")   
    gSaveFileFor8888Format("ui/big_img_sep/rwww_ui_dc1_a_02.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_bg_popup.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_dijunlaixi.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_jianbian.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_kabei.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_kapai1.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_kapai2.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_shenbingkuang.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_shuxingtu.png")    
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_yindaokuang.png")
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_yindaotankuang2.png")  
    gSaveFileFor8888Format("ui/big_img_sep/v2_bg_guoguanzhanjiang.jpg")
    gSaveFileFor8888Format("ui/big_img_sep/v2_bg_laba.png")
    gSaveFileFor8888Format("ui/big_img_sep/v2_img_duihuanshangdi.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_img_fuwuliebiao.png")    
    gSaveFileFor8888Format("ui/big_img_sep/v2_img_gaojiyubingshudi.png")   
    gSaveFileFor8888Format("ui/big_img_sep/v2_img_qizhi_boss.png")
    gSaveFileFor8888Format("ui/big_img_sep/v2_img_tequanlibaodi_chongzhi.png")
    gSaveFileFor8888Format("ui/big_img_sep/v2_img_zhangjiejianglidi_fb.png") 
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_kelashenyidu.png") 
    gSaveFileFor8888Format("ui/big_img_sep/v1_img_kelashenweidu.png")
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiabaozang.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiachengchi.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiajuewei.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiakeji.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiarenwu.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiarongyu.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiashangdian.jpg") 
    gSaveFileFor8888Format("ui/big_img_sep/v2_fonts_guojiahuzhu.jpg") 
     

    -- banner
    gSaveFileFor8888Format("ui/banner_ui/v2_img_qgqshuang.jpg") 
    gSaveFileFor8888Format("ui/banner_ui/v2_img_hglbang.jpg")        
    gSaveFileFor8888Format("ui/banner_ui/v2_img_cgxyu.jpg") 

end

-- 判断是否为低分辨率设备
-- return(bool): 返回是否为低分辨率设备
function getIsTargetLow(  )
    -- body
    --计算宽度适配后的高度为多少
    local nCurHeight = display.height * 640 / display.width
    if nCurHeight < 1130 then --适配后的高度小于960的都认为是ipad
        return true
    end
    return false
end

-- 判断是否为ipad
-- return(bool): 返回是否为低分辨率设备
function getIsTargetPad(  )
    -- body
    --计算宽度适配后的高度为多少
    local nCurHeight = display.height * 640 / display.width
    if nCurHeight < 955 then --适配后的高度小于950的都认为是ipad
        return true
    end
    return false
end

-- 根据平台调整适配情况
function addViewConsiderTarget( pParentView, pChildView, bScale)
    if bScale == nil then
        bScale = true
    end
    -- 如果是低分辨率设备的情况下
    local isLow  = getIsTargetLow()
    if(isLow and bScale ) then
        --计算缩放比例
        local fScale = pParentView:getHeight() / pChildView:getHeight()
        local pVg = MUI.MLayer.new()
        pVg:setContentSize(pParentView:getContentSize())
        pChildView:setScale(fScale)
        pVg:addView(pChildView)
        centerInView(pVg,pChildView)
        pParentView:addView(pVg)
    else
        pParentView:addView(pChildView)
    end
        -- pParentView:addView(pChildView)
end

--获得需要的缩放值
function getTargetScale(  )
    -- body
    local winSize = cc.Director:getInstance():getWinSize()
    --计算宽度适配后的高度为多少
    local nCurHeight = winSize.height * 640 / winSize.width
    local fScale = nCurHeight / 1138
    return fScale
end

-- 根据平台调整适配情况
-- pParentView：父层控件
-- pChildView：需要缩放的控件
-- nType：缩放后位置的摆放情况  1：左下角 
function addViewConsiderTargetForSep( pParentView, pChildView, nType)
    -- 如果是ipad的情况下
    nType = nType or 1
    local isLow = getIsTargetLow()
    if(isLow) then
        -- 从父控件中清除
        pChildView:removeSelf(false)
        if fScale == nil then
            fScale = getTargetScale()
        end
        local pVg = MUI.MLayer.new()
        pVg:setContentSize(pParentView:getContentSize())
        pChildView:setScale(fScale)
        pVg:addView(pChildView)
        pParentView:addView(pVg)
        if nType == 1 then --左下角
            pChildView:setPosition((pChildView:getWidth() * pChildView:getScale() - pVg:getWidth()) / 2,
                (pChildView:getHeight()*pChildView:getScale() - pVg:getHeight()) / 2)
        end
    end
end

--功能：情况列表数据
--注意：map数据没有清空
function clearTableArray(array)
    local number = #array
    for i=number, 1, -1 do
        array[i] = nil
    end
end

-- 保留小数点位数
-- num: 被剪切的数字
-- n: 小数点位数, 如果是小数,以1作为结尾(10, 1, 0.1, 0.01)
function cutOffNum( num, n )
    -- body
    if n > 0 then
        return math.floor(num / n) * n 
    elseif n == 0 then
        return num 
    end
    return num
end

-- 四舍五入
-- num: 被剪切的数字
-- n: 小数点位数, 如果是小数,以1作为结尾(10, 1, 0.1, 0.01)
function roundOff( num, n )
    -- body
    if n > 0 then
        return math.floor(num / n + 0.5) * n 
    elseif n == 0 then
        return num 
    end
    return num
end

-- 关闭fps
function closeFPS(  )
--    if(device.platform == "ios" or device.platform == "android") then
--        local sharedDirector = cc.Director:getInstance()
--        sharedDirector:setDisplayStats(false)
--        if(device.platform == "android") then
--            sharedDirector:setAnimationInterval(1/40)
--        end
--    end
    if (device.platform == "ios" or device.platform == "android") then
        local sharedDirector = cc.Director:getInstance()
        --测试包开启
        if N_PACK_MODE == 1000 or N_PACK_MODE == 1050 then
            sharedDirector:setDisplayStats(true)
        else
            sharedDirector:setDisplayStats(false)
        end
    end
    cc.Director:getInstance():setAnimationInterval(1/40)
end


-- 保存本地数据
-- sKey（string）：key值
-- sValue（string）：数据
local tLocalInfoCache = {} -- cc.UserDefault使用xml存储，当数据躲起来后查询很慢
function saveLocalInfo( sKey, sValue )    
    local pUserDefault = cc.UserDefault:getInstance()
    if pUserDefault then
        tLocalInfoCache[sKey] = sValue
        pUserDefault:setStringForKey(sKey, sValue)
        pUserDefault:flush()
    else
        print(getConvertedStr(3, 10543))
        TOAST(getConvertedStr(3, 10543))
    end
end

-- 保存多个本地数据
--tData:
--{
    -- sKey（string）：key值
    -- sValue（string）：数据
--}
function saveLocalInfoList( tData )    
    if not tData then
        return
    end
    if table.nums(tData) == 0 then
        return
    end
    local pUserDefault = cc.UserDefault:getInstance()
    if pUserDefault then
        for sKey,sValue in pairs(tData) do
            tLocalInfoCache[sKey] = sValue 
            pUserDefault:setStringForKey(sKey, sValue)
        end
        pUserDefault:flush()
    else
        print(getConvertedStr(3, 10543))
        TOAST(getConvertedStr(3, 10543))
    end
end

-- 获取本地数据
-- sKey（string）：key值
-- sDefaultValue（string）：默认数据
function getLocalInfo( sKey, sDefaultValue )
    if not sKey then
        return sDefaultValue
    end
    if not sDefaultValue then
        return sDefaultValue
    end
    local pUserDefault = cc.UserDefault:getInstance()
    if pUserDefault then
        local ret = tLocalInfoCache[sKey]
        if ret == nil then
            ret = pUserDefault:getStringForKey(sKey, sDefaultValue)
            tLocalInfoCache[sKey] = ret
        end
        return ret
    else
        print(getConvertedStr(3, 10543))
        TOAST(getConvertedStr(3, 10543))
    end
    return sDefaultValue
end

--获取设置状态 设置项1代表开启 否则代表关闭
function getSettingInfo( _sKey )
    -- body
    if not _sKey then
        return
    end
    if _sKey == gameSetting_eachButtonKey[2] or _sKey == gameSetting_eachButtonKey[3] then
        return getLocalInfo(_sKey, "1")
    else
        return getLocalInfo(_sKey..Player:getPlayerInfo().pid, "1")
    end
end
--保存游戏设置状态 设置项1代表开启 否则代表关闭
function setSettingInfo( _sKey, _nValue )
    -- body
    if not _sKey then
        return
    end
    if _sKey == gameSetting_eachButtonKey[2] or _sKey == gameSetting_eachButtonKey[3] then
        saveLocalInfo(_sKey, _nValue)
        if _sKey == gameSetting_eachButtonKey[2] then --背景音乐
            if _nValue == "1" then
                --发送消息开启背景音乐（世界或者基地）
                sendMsg(ghd_open_worldorbase_music_msg)
            else
                --暂停基地或者世界背景音乐
                Sounds.stopMusic(true)
            end
        end
    else
        saveLocalInfo(_sKey..Player:getPlayerInfo().pid, _nValue)
    end
end

-- 创建listView 
-- _parent listView 加入的父层
-- _direction 方向 默认竖向
-- _barImg 拖动进度指示条 
-- _name listView的名称
function createNewListView(_parent,_direction,_barImg,_name, _disTop, _disBottom,_disLeft, _disRight)
    local pView = nil
    local strBarImg = _barImg or "ui/daitu.png" 
    if _parent then
        local pView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, _parent:getWidth(), _parent:getHeight()),
            itemMargin = {left = _disLeft or 0,
            right = _disRight or 0,
            top = _disTop or 5 ,
            bottom = _disBottom or 5 },
            direction = _direction or MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
            scrollbarImgV = strBarImg
        }
        _parent:addView(pView)
        pView:setName(_name or "")
        pView:setBounceable(true) --是否回弹
        return pView
    end

    return pView
end

--获得对应资源物品道具列表
--_nResId：e_resdata_ids 资源id
function getAddResItemLists( _nResId )
    -- body
    if not _nResId then
        return
    end
    local pItemLists = {}
    local tT = {}
    if _nResId == e_resdata_ids.lc then --粮草
        tT = luaSplit(getDisplayParam("foodItem"),";")
    elseif _nResId == e_resdata_ids.yb then --铜币
        tT = luaSplit(getDisplayParam("coinItem"),";")
    elseif _nResId == e_resdata_ids.mc then --木材
        tT = luaSplit(getDisplayParam("woodItem"),";")
    elseif _nResId == e_resdata_ids.bt then --铁矿
        tT = luaSplit(getDisplayParam("ironItem"),";")
    end

    if table.nums(tT) > 0 then
        for k, v in pairs (tT) do
            --先从玩家身上查找
            local tItem = Player:getBagInfo():getItemDataById(tonumber(v))
            -- if not tItem then --如果没有，那么从配表中查找
            --     tItem = getBaseItemDataByID(tonumber(v))
            -- end
            if tItem then
                table.insert(pItemLists, tItem)
            end
        end
    end
    return pItemLists
end

--获得对应主城保护道具列表
function getProtectItemLists( )
    -- body
    local pItemLists = {}
    local tT = luaSplit(getDisplayParam("protectItem"),";")
    if table.nums(tT) > 0 then
        for k, v in pairs (tT) do
            --先从玩家身上查找
            local tItem = Player:getBagInfo():getItemDataById(tonumber(v))
            if not tItem then --如果没有，那么从配表中查找
                tItem = getBaseItemDataByID(tonumber(v))
            end
            if tItem then
                table.insert(pItemLists, tItem)
            end
        end
    end
    return pItemLists
end

--获得重建家园道具列表
function getRecreateItemLists( )
    -- body
    local pItemLists = {}
    local tT = luaSplit(getDisplayParam("recreateItem"),";")
    if table.nums(tT) > 0 then
        for k, v in pairs (tT) do
            --先从玩家身上查找
            local tItem = Player:getBagInfo():getItemDataById(tonumber(v))
            if not tItem then --如果没有，那么从配表中查找
                tItem = getBaseItemDataByID(tonumber(v))
            end
            if tItem then
                table.insert(pItemLists, tItem)
            end
        end
    end
    return pItemLists
end

--打印数据到日志
--像myprint那样使用，直接传数据
local bIsInitFileTxt = false
function myprintToFile( ... )
    local tT = {...}
    if #tT == 1 then
        tT = tT[1]
    end

    local file = nil
    if not bIsInitFileTxt then
        bIsInitFileTxt = true
        file = io.open("myprintToFile.txt","w")
    else
        file = io.open("myprintToFile.txt","a")
    end
    if type(tT) == "table" then
        for i=1,#tT do
            file:write(tT[i])
            if #tT == i then
                file:write("\n")
            end
        end 
    else
        file:write(tT)
        file:write("\n")
    end
    io.close(file)    
end

--将物品字符串转换成数组
function parseGoodStrToTable( sStr )
    local tRes = {}
    if string.find(sStr, ";") then
        local tData = luaSplitMuilt(sStr, ";", ":")
        for i=1,#tData do
            local tData2 = tData[i]
            if type(tData2) == "table" then
                local nId = tonumber(tData2[1])
                local nNum = tonumber(tData2[2])
                if nId and nNum then
                    table.insert(tRes, {nId = nId, nNum = nNum})
                end
            end
        end
    else
        local tData2 = luaSplit(sStr, ":")
        if type(tData2) == "table" then
            local nId = tonumber(tData2[1])
            local nNum = tonumber(tData2[2])
            if nId and nNum then
                table.insert(tRes, {nId = nId, nNum = nNum})
            end
        end
    end
    return tRes
end

--玩家是否满足需要的资源字符串
--sResStr：需求字符串 id:数量;id:数量;...
--bIsShowToast:不够时是否显示Toast
--倍率
--返回 不满足需求的id，没有返回nil
function checkIsResourceStrEnough( sResStr, bIsShowToast, nRate)
    nRate = nRate or 1
    local tRes = parseGoodStrToTable(sResStr)
    for i=1,#tRes do
        local nId = tRes[i].nId
        local nNum = tRes[i].nNum * nRate
        if not checkIsResourceEnough(nId, nNum, bIsShowToast) then
            return false
        end
    end
    return true 
end

--玩家是否满足需要的资源字符串
--nId: id
--nNum: 数量
--bIsShowToast:不够时是否显示Toast
function checkIsResourceEnough(nId, nNum ,bIsShowToast)
    if not getIsResourceEnough(nId, nNum) then
        if bIsShowToast then
            local tItem = getGoodsByTidFromDB(nId)
            if tItem then
                TOAST(string.format(getConvertedStr(3, 10096),tItem.sName))
            end

            goToBuyRes(nId)
        end
        return false
    end
    return true
end

--玩家是否满足需要的资源
--nId: id
--nNum: 数量
function getIsResourceEnough( nId, nNum)
    nNum = tonumber(nNum)
    return getMyGoodsCnt(nId) >= nNum
end

--获数当前道具(包括资源或其他)数量
function getMyGoodsCnt( nId )
    nId = tonumber(nId)
    local nCurrNum = 0
    if(nId >= 1 and nId <= 199) then -- 资源
        if nId == e_type_resdata.energy then --体力
            nCurrNum = Player:getPlayerInfo().nEnergy
        elseif nId == e_type_resdata.food then --粮草
            nCurrNum = Player:getPlayerInfo().nFood
        elseif nId == e_type_resdata.coin then --银币
            nCurrNum = Player:getPlayerInfo().nCoin
        elseif nId == e_type_resdata.wood then --木材
            nCurrNum = Player:getPlayerInfo().nWood
        elseif nId == e_type_resdata.iron then --镔铁
            nCurrNum = Player:getPlayerInfo().nIron
        elseif nId == e_type_resdata.infantry then --步兵
            nCurrNum = Player:getPlayerInfo().nInfantry
        elseif nId == e_type_resdata.sowar then --骑兵
            nCurrNum = Player:getPlayerInfo().nSowar
        elseif nId == e_type_resdata.archer then --弓兵
            nCurrNum = Player:getPlayerInfo().nArcher
        elseif nId == e_type_resdata.person then --人口
            nCurrNum = 0 --znftodo
        elseif nId == e_type_resdata.money then --元宝
            nCurrNum = Player:getPlayerInfo().nMoney
        elseif nId == e_type_resdata.prestige then --威望
            nCurrNum = Player:getPlayerInfo().nPrestige
        elseif nId == e_type_resdata.exp then --主公经验
            nCurrNum = Player:getPlayerInfo().nExp
        elseif nId == e_type_resdata.vipdot then --VIP点数
            nCurrNum = Player:getPlayerInfo().nVipExp
        elseif nId == e_type_resdata.medal then --VIP点数
            nCurrNum = Player:getPlayerInfo().nMedal
        elseif nId == e_type_resdata.killheroexp then --积分
            nCurrNum = Player:getPlayerInfo().nKillHeroExp       
        elseif nId == e_type_resdata.royalscore then --皇城战积分
            nCurrNum = Player:getPlayerInfo().nRoyalscore
        elseif nId == e_type_resdata.countrycoin then --国家商店货币
            nCurrNum = Player:getPlayerInfo().nCountryCoin        
        end
    elseif(nId >= 1001 and nId <= 1099) then -- 地图
    elseif(nId >= 2001 and nId <= 2999) then -- 装备
        return Player:getEquipData():getCntByEquipId(nId)
    elseif(nId >= 3001 and nId <= 3999) then --科技
    elseif(nId >= 10000 and nId <= 10999) then -- 建筑
    elseif (nId >= 11001 and nId <= 11999) then -- 城池
    elseif (nId >= 12001 and nId <= 12999) then -- 矿点
    elseif(nId >= 13001 and nId <= 13999) then -- 乱军
    elseif(nId >= 20001 and nId <= 29999) then -- 任务
    elseif(nId >= 30001 and nId <= 39999) then -- buff
    elseif(nId >= 50001 and nId <= 70000) then -- 掉落id
    elseif(nId >= 70001 and nId <= 80000) then -- 怪物组
    elseif(nId >= 80001 and nId <= 90000) then -- 怪物
    elseif(nId >= 100001 and nId <= 129999) then -- 物品
        local tItem = Player:getBagInfo():getItemDataById(nId)
        if tItem then
            nCurrNum = tItem:getCnt()
        end
    elseif(nId >= 200001 and nId <= 299999) then -- 英雄
    end
    return nCurrNum
end


--获取资源的单位产量
function getMyGoodsUnitTimeCnt( nId )
    -- body
    nId = tonumber(nId)
    local  nCurrNum = 0
    if nId >= 2 and nId <= 5 then --粮草,银币,木材,镔铁
        nCurrNum = Player:getResourceData():getResCntUnitTime(nId)
    end
    return nCurrNum
end

--获取多个消耗只消耗其中一个，优先玩家现有，其次是配表顺序, 没有的话就最后一个
--sStr:   100001:1|1:100
function getMulitCostResOnly( sStr )
    local tData = luaSplitMuilt(sStr, "|", ":")
    local nId1, nValue1 = nil ,nil
    for i=1,#tData do
        local nId,nValue = nil,nil
        if type(tData[i]) == "table" then
            nId = tonumber(tData[i][1])
            nValue = tonumber(tData[i][2])
            if nId and nValue then
                --当满足就返回
                if getIsResourceEnough(nId, nValue) then
                    return nId, nValue
                end
                --一直记录最后一个
                nId1 = nId
                nValue1 = nValue
            end
        end
    end
    return nId1, nValue1
end

--获取多个消耗只消耗其中一个是否正常消耗
function getMulitCostResTypeIsSpecial( _nId, sStr)
    local tData = luaSplitMuilt(sStr, "|", ":")
    local nId1, nValue1 = nil ,nil
    for i=1,#tData do
        local nId,nValue = nil,nil
        if type(tData[i]) == "table" then
            nId = tonumber(tData[i][1])
            if nId then
                if nId == _nId then
                    return i == 1 --1为特殊消耗，2为正常消耗
                end
            end
        end
    end
    return false
end

--获取消耗资源的图片
function getCostResImg( nId )
    local pGood = getGoodsByTidFromDB(nId)
    if pGood then
        return pGood:getSmallIcon()
    end
    return nil
end

--获取消耗资源的图片
function getCostResName( nId )
    local pGood = getGoodsByTidFromDB(nId)
    if pGood then
        return pGood.sName
    end
    return nil
end
--获取购买下一个工坊生产队列的黄金花费\
--根据时间获得金币数量
-- _fTime：时间
function getGoldByTime( _fTime )
    -- body
    _fTime = _fTime or 0
    local nCost = 0
    --获取一分钟消耗多少金币
    local nCostEveryM = getBuildParam("timeSpeed") or 2
    if _fTime > 0 then
        nCost = math.ceil(_fTime / 60) * nCostEveryM
    end
    return nCost
end
--打造加速花费
--根据时间获得打造装备花费的金币数量
-- _fTime：时间
function getGoodByMakeTime(_fTime)
    _fTime = _fTime or 0
    local nCost = 0
    --获取一分钟消耗多少金币
    local nCostEveryM = getBuildParam("makeTimeSpeed") or 2
    if _fTime > 0 then
        nCost = math.ceil(_fTime / 60) * nCostEveryM
    end
    return nCost
end

--获取购买下一个工坊生产队列的黄金花费
--参数 _num已经购买队列的次数
function getNextProductLineCost( _num )
    -- body
    local tcost = luaSplit(getAtelierParam("cost"),";")
    if table.nums(tcost) >= _num + 1 then
        return tcost[_num + 1]
    else
        print("无法继续购买生产队列！")
        return nil
    end
end

--解析服务端返回的奖励数据
-- tDatas(table): {{k=id, v=数量}}
-- bSorted(bool)：是否需求排序后再返回
function getRewardItemsFromSever( tDatas, bSorted )
    if(not tDatas or #tDatas <= 0) then
        return nil
    end
    local tResults = {}
    for i, v in pairs(tDatas) do
        local pData = getGoodsByTidFromDB(tonumber(v.k))
        if(pData) then
            pData.nCt = tonumber(v.v)
        end
        tResults[#tResults+1] = pData
    end
    if(bSorted) then
        table.sort(tResults, function ( a, b )
            return a.sTid < b.sTid
        end)
    end
    return tResults
end

--根据品质获取消耗图纸
function getAtelierCostItemsByQuality( _nQ )
    -- body
    local itemlist = {}
    if not _nQ then
        return itemlist
    end
    
    local tAtelierProduction = getAtelierProductionParam()
    --dump(tAtelierProduction, "tAtelierProduction=", 100)
    if tAtelierProduction[_nQ] then
        local tcost = luaSplit(tAtelierProduction[_nQ].itemcost, ";")
        if table.nums(tcost) > 0 then
            for k, v in pairs (tcost) do
                --先从玩家身上查找
                local tItem = Player:getBagInfo():getItemDataById(tonumber(v))
                -- if not tItem then --如果没有，那么从配表中查找
                --     tItem = getBaseItemDataByID(tonumber(v))
                -- end
                if tItem then
                    table.insert(itemlist, tItem)
                end
            end
        end           
    end
    return itemlist
end

--设置提示类信息的展示状态
-- _nState: 1：只做存储； 为其他时：播放效果
function setToastNCState( _nState )
    -- body
    _TOAST_NC_STATE_S = _nState
end

--获得提示类信息的展示状态
function getToastNCState(  )
    -- body
    return _TOAST_NC_STATE_S
end

--播放战斗表现
--_tReport：战报
--_nCallBack：战斗结束回调
--_bCanJumpFight:是否可以直接跳过战斗
--_nEndterHandler：界面切换完成回调
function showFight( _tReport, _nCallBack, _bCanJumpFight, _nEndterHandler)
    -- body
    if (not _tReport) then
        print("战报为nil")
        return 
    end
    if Player:getUIFightLayer() then
        print("当前在战斗中..")
        return
    end
    
    if b_use_sec_fightlayer then
        local pFightLayer = FightSecLayer.new(_tReport,_nCallBack, _bCanJumpFight)
        RootLayerHelper:pushRootLayer(pFightLayer,true,_nEndterHandler)
    else
        local pFightLayer = FightLayer.new(_tReport,_nCallBack, _bCanJumpFight)
        RootLayerHelper:pushRootLayer(pFightLayer,true,_nEndterHandler)        
    end            
    
end

--展示战斗结果
function showFightRst( _tData )
    -- body
    -- 打开战斗结果界面
    local pDlg, bNew = getDlgByType(e_dlg_index.fubenresult)
    if not pDlg then
        pDlg = DlgFubenResult.new(_tData)
    end
    pDlg:showDlg(bNew)
end

--获得预加载纹理的名字
function getPreAddTextureName( sDir, sLastName )
    -- body
    if(string.find(sDir, "language")) then -- 如果是
        return
    end

end

-- 获取指定目录下所有的文件名（根据后缀）
-- sDir（string）：指定目录
-- sLastName(string)：文件后缀名
function getAllFileByLastName( sDir, sLastName )
    local tDatas = {}
    if(device.platform == "android") then
        -- 获取upd目录下的数据
        local sStr = getAllFileNamesDevice(2, sDir, sLastName)
        if(sStr and string.len(sStr) > 0) then
            -- 解析所有的名字，类型@名字：类型0代表文件，类型1代表目录
            local tStr = string.split(sStr, ";")
            local tTmpStr = {}
            if(tStr) then
                for i, v in pairs(tStr) do
                    if(string.len(v) > 0) then
                        tTmpStr = string.split(v, "@")
                        if(tTmpStr and #tTmpStr == 2) then
                            local file = tTmpStr[2]
                            if(tTmpStr[1] == "0") then
                                if(not tDatas[file]) then
                                    tDatas[file] = sDir .. "/" .. file
                                end
                            end
                        end
                    end
                end
            end
        end
        -- 获取res目录的数据
        sStr = getAllFileNamesDevice(1, sDir, sLastName)
        if(sStr and string.len(sStr) > 0) then
            -- 解析所有的名字，类型@名字：类型0代表文件，类型1代表目录
            local tStr = string.split(sStr, ";")
            local tTmpStr = {} -- 临时数据
            if(tStr) then
                for i, v in pairs(tStr) do
                    if(string.len(v) > 0) then
                        tTmpStr = string.split(v, "@")
                        if(tTmpStr and #tTmpStr == 2) then
                            local file = tTmpStr[2]
                            if(tTmpStr[1] == "0") then
                                if(not tDatas[file]) then
                                    tDatas[file] = sDir .. "/" .. file
                                end
                            end
                        end
                    end
                end
            end
        end
        -- 增加压缩包中plist文件的读取
        local tFileData = getPlistDataForMobile(sDir)
        if(tFileData) then
            for file, v in pairs(tFileData) do
                if(not tDatas[file]) then
                    tDatas[file] = v
                end
            end
        end
        return tDatas
    elseif(device.platform == "ios") then -- Ios
        local bFound = true
        -- （upd）判断目录是否存在
        local sFinalPath, bFound = checkDirs(2, sDir)
        if(sFinalPath and string.len(sFinalPath) > 0 and bFound) then
            for file in lfs.dir(sFinalPath) do
                if(file and file ~= "." and file ~= "..") then
                    if(not tDatas[file] and string.find(file, sLastName)) then
                        tDatas[file] = sDir .. "/" .. file
                    end
                end
            end
        end
        -- （res）判断目录是否存在
        sFinalPath, bFound = checkDirs(1, sDir)
        if(sFinalPath and string.len(sFinalPath) > 0 and bFound) then
            for file in lfs.dir(sFinalPath) do
                if(file and file ~= "." and file ~= "..") then
                    if(not tDatas[file] and string.find(file, sLastName)) then
                        tDatas[file] = sDir .. "/" .. file
                    end
                end
            end
        end
        -- 增加压缩包中plist文件的读取
        local tFileData = getPlistDataForMobile(sDir)
        if(tFileData) then
            for file, v in pairs(tFileData) do
                if(not tDatas[file]) then
                    tDatas[file] = v
                end
            end
        end
        return tDatas
    else -- windows
        local writablePath = S_WRITABLE_PATH or cc.FileUtils:getInstance():getWritablePath()
        local sDirPath = writablePath .. "upd/"
        for file in lfs.dir(sDirPath .. sDir) do
            if(file and file ~= "." and file ~= "..") then
                if(not tDatas[file] and string.find(file, sLastName)) then
                    tDatas[file] = sDir .. "/" .. file
                end
            end
        end
        sDirPath = "res/"
        for file in lfs.dir(sDirPath .. sDir) do
            if(file and file ~= "." and file ~= "..") then
                if(not tDatas[file] and string.find(file, sLastName)) then
                    tDatas[file] = sDir .. "/" .. file
                end
            end
        end
        -- 为手机保存可读取的内容
        saveForMobile(sDir, tDatas)
    end
    return tDatas
end
-- 保存到目录下，提供给android和ios使用
-- _dir(string): 当前要检查的目录
-- _data(table): 当前从目录下读取出来的数据
function saveForMobile( _dir, _data )
    local tmpData = getPlistDataForMobile(_dir)
    if(tmpData) then
        local bSame = true
        for i, v in pairs(_data) do
            if(tmpData[i] == nil) then
                bSame = false
                break
            end
        end
        for i, v in pairs(tmpData) do
            if(_data[i] == nil) then
                bSame = false
                break
            end
        end
        if(bSame) then
            return
        end
    end
    local sStr = "local tDatas = {}\n"
    for k, v in pairs(_data) do
        local tmpStr = "tDatas[\"" .. k .. "\"] = \"" .. v .. "\""
        sStr = sStr .. tmpStr .. "\n"
    end
    sStr = sStr .. "return tDatas"
    local _path = cc.FileUtils:getInstance():fullPathForFilename("res/" .. _dir.."/plistfile.txt")
    writeContentToFile(_path, sStr)
end
-- 获取res目录下的plist列表给手机使用
-- _sdir(string): 需要获取的目录
-- return(table): 返回已经在win32下构建好的内容
function getPlistDataForMobile( _sdir )
    local tData = nil
    local bFound = isFileExistCfg(_sdir.."/plistfile.txt", 1)
    if(bFound) then
        local sStr = cc.FileUtils:getInstance():getDataFromFile("res/".._sdir.."/plistfile.txt")
        if(sStr and #sStr > 0) then
            tData = luaDoString(sStr)
        end
    end
    return tData
end

-- 获取所有的文件路径名称
-- nType（int）：1是assets/res目录下的，2是upd目录下的
-- sDir（string）：res下为相对路径，upd下是绝对路径
function getAllFileNamesDevice(nType, sDir, sFindName)
    if(device.platform == "android") then
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "getAllFileNames"
        if(nType == 1) then
            sDir = "res/" .. sDir
        else
            local writablePath = S_WRITABLE_PATH or cc.FileUtils:getInstance():getWritablePath()
            sDir = writablePath .. "upd/" .. sDir
        end
        local result, ret = luaj.callStaticMethod(className, methodName, 
            {nType, sDir, sFindName}, 
            "(ILjava/lang/String;Ljava/lang/String;)Ljava/lang/String;");
        if result then
            return ret or ""
        end
    end
    return ""
end

-- 创建目录
-- nType(int): 1是res，2是upd
-- return(string): 返回最终创建好的目录
function checkDirs( nType, sDir )
    if(device.platform ~= "ios") then
        print("只支持ios平台，其他平台不支持")
        return
    end
    local sApath = ""
    local sBpath = ""
    local bExist = true
    if(nType == 1) then -- res
        sBpath = getStringDataCfg("appResPath") .. "/res"
    else -- upd
        local writablePath = S_WRITABLE_PATH or cc.FileUtils:getInstance():getWritablePath()
        sBpath = writablePath .. "upd"
        -- 目录不存在，直接返回
        if(not isFileOrDirExist(sBpath)) then
            return sApath, false
        end
    end
    sApath = sBpath .. "/" .. sDir
    if(sApath and string.len(sApath) > 0) then
        if(not isFileOrDirExist(sApath)) then
            bExist = false
        end
    end
    return sApath, bExist
end

--文件或者文件夹是否存在
-- path(string)：文件或者文件夹的全路径
function isFileOrDirExist(path)
    return cc.FileUtils:getInstance():isFileExist(path)
end

-- 创建新目录
-- sPath（string）：绝对路径
function createNewDir( sPath )
    print("创建目录", sPath)
    lfs.mkdir(sPath)
end

--[[-- 
设置推送的免打扰时间
nStartTime  免打扰开始时间
nEndTime    免打扰结束时间
nState      免打扰开关
]]
function setAlterTime(nStartTime,nEndTime,nState)
    if device.platform == "android" then
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "setAlterTime"
        luaj.callStaticMethod(className, methodName, {tonumber(nStartTime),tonumber(nEndTime),tonumber(nState)}, "(III)V");
    end
end

--游戏设置状态
gameSetting_eachButtonKey = {
    [1] = "NoDisturb",              --免打扰设置
    [2] = "BgMusic",                --背景音乐
    [3] = "ButtonSound",            --按键音响
    [4] = "ShowChatArea",           --显示聊天地区
    [5] = "AutoIncreaseForces",     --自动补兵
    [6] = "GoldCostTip",     --自动补兵
    [20] = "PChatGoldTip",    --私聊花费
    --推送
    [7] = "Conscription",           --募兵完成
    [8] = "UnderAttack",            --遭到攻击推送
    [9] = "Investigated",           --遭到侦查推送
    [10] = "FillEnergy",             --体力值满推送
    [11] = "ForgeFinished",          --装备打造完成推送
    [12] = "Research",              --科技研发完成推送
    [13] = "UpBuild",               --建筑升级完成推送
    [14] = "AtelierProduce",        --作坊生产完成推送
    [15] = "FillWashPulp",          --培养次数恢复推送
    [16] = "FillBaptize",           --洗练次数恢复推送 
    [17] = "JeanBourget",           --珍宝阁冷却完成推送
    [18] = "ResourceCollection",    --资源采集完成推送
    -- [17] = "FillLevied",            --征收次数恢复推送
    [19] = "Garrison",              --城防军冷却完成推送    
    [21] = "TLBossCome",            --魔神来袭准备推送
    [22] = "ImperialWar",           --决战阿房宫通知 
}

--游戏推送类型
GamePushType = {
    CallPlay            =           1,      --提醒上线
    CallConscription    =           2,      --募兵完成
    CallAttack          =           3,      --遭到攻击推送
    CallInvestigated    =           4,      --遭到侦查推送
    CallEnergy          =           5,      --体力值满推送
    CallForge           =           6,      --装备打造完成推送
    CallResearch        =           7,      --科技研发完成推送
    CallUpBuild         =           8,      --建筑升级完成推送
    CallAtelierProduce  =           9,      --作坊生产完成推送
    CallWashPulp        =           10,     --培养次数恢复推送
    CallBaptize         =           11,     --洗练次数恢复推送 
    CallJeanBourget     =           12,     --珍宝阁冷却完成推送
    CallResCollection   =           13,     --资源采集完成推送
    CallLevied          =           14,     --征收次数恢复推送
    CallGarrison        =           15,      --城防军冷却完成推送   
    CallTLBossCome      =           16,     --魔神来袭准备推送
    CallTLBossFight     =          17,     --魔神来袭开战
    CallImperialCom     =          18, --决战阿房宫准备通知
    CallImperialFight   =          19, --决战阿房宫开战通知
}
--游戏设置界面分类
GameSetting_Type = {
    close           =       0,  --关闭状态    
    gamesetting     =       10,  --游戏设置
    helpcenter      =       11,  --帮助中心
    contactservice  =       12,  --联系客服
    giftrecharge    =       13,  --礼包兑换
    changeservers   =       14,  --切换服务器
    changeAccount   =       15,  --切换账号
    newnotice       =       16,  --最新公告
    guidcopy        =       17   --guid复制
}

--用于ios推送信息过滤
function filterPushAlarms(_params)
    if not _params then
        return
    end
    local startTimeStr = tonumber(getLocalInfo("No_Disturb_Start", "22"))
    local endTimeStr = tonumber(getLocalInfo("No_Disturb_End", "8"))
    local nState = tonumber(getSettingInfo("NoDisturb"))
    local timeNow = math.floor(socket.gettime())
    if nState == 0 then
        _params = _params
    elseif startTimeStr == endTimeStr then
        _params = _params
    else
        for i=#_params, 1, -1 do
            --同一天
            local tData = os.date("*t", timeNow + _params[i]["time"])
            local nHour = tData.hour
            local nMin  = tData.min
            if startTimeStr < endTimeStr then
                if startTimeStr <  nHour and endTimeStr > nHour then
                        table.remove(_params, i)
                end
                -- tData.hour
            --跨天
            elseif startTimeStr > endTimeStr then
                if startTimeStr < nHour or endTimeStr > nHour then
                    table.remove(_params, i)
                end
            end
        end
    end
    return _params
end

--总览
-- Overview_Item =  {
--     "1_1"           =
-- }
--开启推送
function startPushAlarms(  )
    -- body
    -- 检查是否登陆成功
    if Player:getPlayerInfo().pid == nil or  string.len(Player:getPlayerInfo().pid) <= 0 then
        return
    end

    --免打扰时间    
    local startTimeStr = getLocalInfo("No_Disturb_Start", "22")
    local endTimeStr = getLocalInfo("No_Disturb_End", "8")
    local nState = getSettingInfo("NoDisturb")
    setAlterTime(startTimeStr,endTimeStr,nState)  --设置安卓的时间

    -- 发送给android或ios的json参数
    local params = {}

        -- 获取系统今天零点的秒数
    local function getTodayZeroTime()
        local tab = os.date("*t")
        tab.sec = 0
        tab.min = 0
        tab.hour = 0
        local time = os.time(tab);
        return time
    end

    -- 创建闹钟数据
    -- nType 闹钟类型
    -- nTime 剩余时间
    -- sMsg 消息文本
    -- nInterval 重复类型(0, 不重复, 1, 每天重复, 2, 每周重复, 3, 每月重复)
    -- nId 消息id(id为0时默认为 不同消息)该字段做预留
    local function createAlarmData(nType, nTime, sMsg, nInterval, nId)
        local alarm = {}
        alarm.type = nType
        alarm.time = nTime
        alarm.msg = sMsg

        local tTaMsg = luaSplit( alarm.msg, "_")
        if tTaMsg == nil or table.nums(tTaMsg) < 2 then
            print("推送文本格式不对")
            return
        end
        alarm.interval = nInterval
        if device.platform == "ios" then
            alarm.id = ""..nId or "0"
        else
            alarm.id = nId or 0
        end
        return alarm
    end

    -- 当前时间
    local timeNow = math.floor(socket.gettime())

    -- 当天零点
    local timeZero = getTodayZeroTime()

    --提醒上线
    if (true) then
        -- 玩家离线超过一个自然日，如：1号下线后2号一整天都没玩，3号18点推送
        local timeCallPlay =  66*3600 - timeNow + timeZero      --单位：秒
        local tPushData = getPushTipsParam(GamePushType.CallPlay)
        if tPushData then
            local sInof = tPushData.system .. "_" .. tPushData.content
            local callPlay = createAlarmData(GamePushType.CallPlay, timeCallPlay, sInof, 1, 10000)
            table.insert(params, callPlay)
        end
    end


    --判断是否开启募兵完成推送
    if getSettingInfo(gameSetting_eachButtonKey[6]) == "1" then --开启募兵推送
        --获取兵营募兵的剩余时间
        --（这里不用一个for来做的原因是策划有可能建筑id配表会修改）
        --步兵营
        local pBuildCampA = Player:getBuildData():getBuildById(e_build_ids.infantry)
        if pBuildCampA then --存在
             local tRecruiting = pBuildCampA:getRecruitingQue()
             if tRecruiting then --正在招募中
                local timeCallPlay = tRecruiting:getRecruitLeftTime()
                if timeCallPlay > 0 then
                    local tPushData = getPushTipsParam(GamePushType.CallConscription)
                    if tPushData then
                        local sInof = tPushData.system .. "_" .. string.format(tPushData.content,pBuildCampA.sName)
                        local callPlay = createAlarmData(GamePushType.CallConscription + 1000, timeCallPlay, sInof, 0, 10001)
                        table.insert(params, callPlay)
                    end
                end
             end
        end
        --骑兵营
        local pBuildCampB = Player:getBuildData():getBuildById(e_build_ids.sowar)
        if pBuildCampB then --存在
             local tRecruiting = pBuildCampB:getRecruitingQue()
             if tRecruiting then --正在招募中
                local timeCallPlay = tRecruiting:getRecruitLeftTime()
                if timeCallPlay > 0 then
                    local tPushData = getPushTipsParam(GamePushType.CallConscription)
                    if tPushData then
                        local sInof = tPushData.system .. "_" .. string.format(tPushData.content,pBuildCampB.sName)
                        local callPlay = createAlarmData(GamePushType.CallConscription + 1001, timeCallPlay, sInof, 0, 10002)
                        table.insert(params, callPlay)
                    end
                end
             end
        end
        --弓兵营
        local pBuildCampC = Player:getBuildData():getBuildById(e_build_ids.archer)
        if pBuildCampC then --存在
             local tRecruiting = pBuildCampC:getRecruitingQue()
             if tRecruiting then --正在招募中
                local timeCallPlay = tRecruiting:getRecruitLeftTime()
                if timeCallPlay > 0 then
                    local tPushData = getPushTipsParam(GamePushType.CallConscription)
                    if tPushData then
                        local sInof = tPushData.system .. "_" .. string.format(tPushData.content,pBuildCampC.sName)
                        local callPlay = createAlarmData(GamePushType.CallConscription + 1002, timeCallPlay, sInof, 0, 10003)
                        table.insert(params, callPlay)
                    end
                end
             end
        end
    end

    --判断体力值满是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[9]) == "1" then
        --当前的能量值
        local nCurTl = Player:getPlayerInfo().nEnergy 
        --体力上限值
        local nMaxTl = tonumber(getGlobleParam("initEnergy"))
        if nCurTl < nMaxTl then
            local nValue = (nMaxTl - nCurTl - 1) * tonumber(getGlobleParam("refEnergyTime"))
            local timeCallPlay = Player:getPlayerInfo():getEnergyLeftTime() + nValue
            if timeCallPlay then
                local tPushData = getPushTipsParam(GamePushType.CallEnergy)
                if tPushData then
                    local sInof = tPushData.system .. "_" .. tPushData.content
                    local callPlay = createAlarmData(GamePushType.CallEnergy, timeCallPlay, sInof, 0, 10010)
                    table.insert(params, callPlay)
                end
            end
        end
    end

    --判断装备是否打造完成开启推送
    if getSettingInfo(gameSetting_eachButtonKey[10]) == "1" then
        --判断是否有正在打造的装备
        local tMakeVo = Player:getEquipData():getMakeVo()
        if tMakeVo then
            --打造cd
            local timeCallPlay = tMakeVo:getCd()
            if timeCallPlay > 0 then
                local tPushData = getPushTipsParam(GamePushType.CallForge)
                if tPushData then
                    local tEquipData = getBaseEquipDataByID(tMakeVo.nId)
                    local sInof = tPushData.system .. "_" .. string.format(tPushData.content, tEquipData.sName)
                    local callPlay = createAlarmData(GamePushType.CallForge, timeCallPlay, sInof, 0, 10011)
                    table.insert(params, callPlay)
                end
            end
        end
    end

    --判断是否开启科技研究完成推送
    if getSettingInfo(gameSetting_eachButtonKey[11]) == "1" then
        --判断是否有研究中的科技
        local tCurTonly = Player:getTnolyData():getUpingTnoly()
        if tCurTonly then
            local timeCallPlay = tCurTonly:getUpingFinalLeftTime()
            if timeCallPlay > 0 then --剩余时间大于0
                local tPushData = getPushTipsParam(GamePushType.CallResearch)
                if tPushData then
                    local sInof = tPushData.system .. "_" .. string.format(tPushData.content,tCurTonly.sName)
                    local callPlay = createAlarmData(GamePushType.CallResearch, timeCallPlay, sInof, 0, 10020)
                    table.insert(params, callPlay)
                end
            end
        end
    end

    --判断建筑升级是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[12]) == "1" then
        --判断是否有升级中，拆除中，创建中的队列
        local pIngBuilds = Player:getBuildData():getBuildUpdingLists()
        if pIngBuilds and table.nums(pIngBuilds) > 0 then
            local nIndex = 1
            for k, v in pairs (pIngBuilds) do
                local timeCallPlay = v:getBuildingFinalLeftTime()
                if timeCallPlay > 0 then
                    -- local sTm = ""
                    -- if v.nState == e_build_state.uping then
                    --     sTm = getConvertedStr(1, 10089)
                    -- elseif v.nState == e_build_state.removing then
                    --     sTm = getConvertedStr(1, 10110)
                    -- elseif v.nState == e_build_state.creating then
                    --     sTm = getConvertedStr(1, 10264)
                    -- end

                    --只针对升级处理
                    if v.nState == e_build_state.uping then
                        local tPushData = getPushTipsParam(GamePushType.CallUpBuild)
                        if tPushData then
                            local sInof = tPushData.system .. "_" .. string.format(tPushData.content,v.sName)
                            local callPlay = createAlarmData(GamePushType.CallUpBuild + nIndex + 2000, timeCallPlay, sInof, 0, 10021)
                            table.insert(params, callPlay)
                        end
                    end
                    nIndex = nIndex + 1
                end
            end
        end
    end

    --判断作坊生产完成是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[13]) == "1" then
        --判断是否有正在生产的队列
        local tBuildData = Player:getBuildData():getBuildById(e_build_ids.atelier)
        if tBuildData and tBuildData:isAtelierProducing() then
            for k, v in pairs(tBuildData.tProQueue) do
                local timeCallPlay = v:getProduceCD()
                if timeCallPlay > 0 then
                    local tPushData = getPushTipsParam(GamePushType.CallAtelierProduce)
                    if tPushData then
                        local sInof = tPushData.system .. "_" .. string.format(tPushData.content, v:getProduct().sName)
                        local callPlay = createAlarmData(GamePushType.CallAtelierProduce, timeCallPlay, sInof, 0, 10022)
                        table.insert(params, callPlay)
                    end
                end
            end
        end
    end

    --判断武将培养次数恢复是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[14]) == "1" then
        --当前的培养次数
        local nTrainTime = Player:getHeroInfo().tFe.f
        --次数上限值
        local nFreeMax = tonumber(getHeroInitData("trainFreeMax"))
        -- dump(nTrainTime,"nTrainTime=",100)
        if nTrainTime < nFreeMax then
            local nValue = (nFreeMax - nTrainTime - 1) * tonumber(getHeroInitData("trainFreeCD"))
            local timeCallPlay = Player:getHeroInfo():getTrainTime() + nValue
            if timeCallPlay then
                local tPushData = getPushTipsParam(GamePushType.CallWashPulp)
                if tPushData then
                    local sInof = tPushData.system .. "_" .. tPushData.content
                    local callPlay = createAlarmData(GamePushType.CallWashPulp, timeCallPlay, sInof, 0, 10023)
                    table.insert(params, callPlay)
                end
            end
        end
    end

    --判断洗炼次数恢复是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[15]) == "1" then
        --当前的培养次数
        local nTrainTime = Player:getEquipData():getFreeTrain()
        --次数上限值
        local nFreeMax = tonumber(getEquipInitParam("trainFreeMax"))
        if nTrainTime < nFreeMax then
            local nValue = (nFreeMax - nTrainTime - 1) * tonumber(getEquipInitParam("trainFreeCD"))
            local timeCallPlay = Player:getEquipData():getFreeTrainCd() + nValue
            if timeCallPlay then
                local tPushData = getPushTipsParam(GamePushType.CallBaptize)
                if tPushData then
                    local sInof = tPushData.system .. "_" .. tPushData.content
                    local callPlay = createAlarmData(GamePushType.CallBaptize, timeCallPlay, sInof, 0, 10024)
                    table.insert(params, callPlay)
                end
            end
        end
    end

    --判断珍宝阁冷却完成是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[16]) == "1" then
        --判断是否有翻牌CD
        local timeCallPlay = Player:getShopData():getFlipCardCd()
        if timeCallPlay and timeCallPlay > 0 then
            local tPushData = getPushTipsParam(GamePushType.CallJeanBourget)
            if tPushData then
                local sInof = tPushData.system .. "_" .. tPushData.content
                local callPlay = createAlarmData(GamePushType.CallJeanBourget, timeCallPlay, sInof, 0, 10025)
                table.insert(params, callPlay)
            end
        end
    end

    --判断资源采集完成是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[17]) == "1" then
        local tTaskMsgs = Player:getWorldData():getTaskMsgs()
        for sUuid, tTaskMsg in pairs(tTaskMsgs) do
            --如果是采集任务且正在采集
            if tTaskMsg.nType == 1 and tTaskMsg.nState == 2 then
                local timeCallPlay = tTaskMsg:getCd()
                if timeCallPlay > 0 then
                    local tPushData = getPushTipsParam(GamePushType.CallResCollection)
                    if tPushData then
                        local sInof = tPushData.system .. "_" .. string.format(tPushData.content, tTaskMsg.sTargetName)
                        local callPlay = createAlarmData(GamePushType.CallResCollection, timeCallPlay, sInof, 0, 10026)
                        table.insert(params, callPlay)
                    end
                end
            end
        end
    end

    --判断城防军冷却完成是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[18]) == "1" then
        local tBuildData = Player:getBuildData():getBuildById(e_build_ids.gate)
        if tBuildData then
            local timeCallPlay = tBuildData:getRecruitCd()
            if timeCallPlay > 0 then
                local tPushData = getPushTipsParam(GamePushType.CallGarrison)
                if tPushData then
                    local sInof = tPushData.system .. "_" .. tPushData.content
                    local callPlay = createAlarmData(GamePushType.CallGarrison, timeCallPlay, sInof, 0, 10027)
                    table.insert(params, callPlay)
                end
            end
        end
    end

    --魔神来袭是否开启推送
    if getSettingInfo(gameSetting_eachButtonKey[21]) == "1" then
        local nComeCd = Player:getTLBossData():getComeCd()
        if nComeCd > 0 then
            local tPushData = getPushTipsParam(GamePushType.CallTLBossCome)
            if tPushData then
                local sInof = tPushData.system .. "_" .. tPushData.content
                local callPlay = createAlarmData(GamePushType.CallTLBossCome, nComeCd, sInof, 0, 10028)
                table.insert(params, callPlay)
            end
        end

        local nFightCd = Player:getTLBossData():getFightCd()
        if nFightCd > 0 then
            local tPushData = getPushTipsParam(GamePushType.CallTLBossFight)
            if tPushData then
                local sInof = tPushData.system .. "_" .. tPushData.content
                local callPlay = createAlarmData(GamePushType.CallTLBossFight, nFightCd, sInof, 0, 10029)
                table.insert(params, callPlay)
            end
        end
    end
    --决战皇城通知
    if getSettingInfo(gameSetting_eachButtonKey[22]) == "1" then
        local pData = Player:getImperWarData()
        if not pData then
            return
        end
        local nOpenCd = pData:getOpenCd()        
        local nCofiT = tonumber(getEpangWarInitData("pushTimeSub")) or 0
        local nComCd = nOpenCd - nCofiT
        if nComCd > 0 then
            local tPushData = getPushTipsParam(GamePushType.CallImperialCom)             
            if tPushData then                
                local sInof = tPushData.system .. "_" .. tPushData.content
                local callPlay = createAlarmData(GamePushType.CallImperialCom, nComCd, sInof, 0, 10030)
                table.insert(params, callPlay)
            end            
        end
        if nOpenCd > 0 then
            local tPushData = getPushTipsParam(GamePushType.CallImperialFight) 
            if tPushData then                
                local sInof = tPushData.system .. "_" .. tPushData.content
                local callPlay = createAlarmData(GamePushType.CallImperialFight, nOpenCd, sInof, 0, 10031)
                table.insert(params, callPlay)
            end 
        end
    end

    if device.platform == "ios" then
        params =  filterPushAlarms(params)
    end

    if params and table.nums(params) > 0 then
        -- dump(params,"params数据=",100)
        local paramsStr = json.encode(params)
        if device.platform == "android" then
            local className = "com/andgame/mgr/GameBridge"
            local methodName = "startAllAlert"
            luaj.callStaticMethod(className, methodName, {paramsStr}, "(Ljava/lang/String;)V");
        elseif device.platform == "ios" then
            local msg = {}
            msg.params = paramsStr
            local luaoc = require("framework.luaoc")
            luaoc.callStaticMethod("PlatformSDK", "createAllNotification", msg)         
        end
    end


end

--关闭推送
function cancelPushAlarms(  )
    -- body
    if bIsGoingExitGame then
        return
    end

    -- 发送给android或ios的json参数
    local params = {}
    for k, v in pairs(GamePushType) do
        local push = {type = v}
        table.insert(params, push)
    end

    local paramsStr = json.encode(params)
    if device.platform == "android" then
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "cancelAllAlert"
        luaj.callStaticMethod(className, methodName, {paramsStr}, "(Ljava/lang/String;)V");
    elseif device.platform == "ios" then
        local msg = {}
        msg.params = paramsStr
        local luaoc = require("framework.luaoc")
        luaoc.callStaticMethod("PlatformSDK", "removeAllNotification", msg)     
    end
end

-- 获取本地ID与服务器ID的key值数据
-- 获取本地数据
-- sKey（string）：key值
-- sDefaultValue（string）：默认数据
-- function getOnlyIdLocalInfo( sKey, sDefaultValue )
--     local nOnlyId = Player.baseInfos.pid..AccountCenter.nowServer.id..sKey
--     if nOnlyId and sDefaultValue then
--         return CCUserDefault:sharedUserDefault():getStringForKey(nOnlyId, sDefaultValue)
--     else
--         return sDefaultValue
--     end
-- end

-- 展示退出对话框
function showExitDialog()
    local bDo=1
    if(AccountCenter.isNormalLogin) then
        bDo = 1
    else
        if device.platform == "android" then
            local className = "com/game/quickmgr/QuickMgr"
            local methodName = "doShowExitDialog"
            local result, ret = luaj.callStaticMethod(className, methodName, 
                {}, "()I")
            if(result) then
                if(ret == 0) then
                    bDo = 1
                else
                    bDo = 0
                end
            end
        end
    end
    if bDo~=0 then
        local pDlg = getDlgByType(e_dlg_index.exitalert)
        if(not pDlg) then
            pDlg = DlgAlert.new(e_dlg_index.exitalert)
            pDlg:setTitle(getConvertedStr(1, 10218))
            pDlg:setContent(getConvertedStr(1, 10219))
            pDlg:setIsNeedOutside(false)
            pDlg:setRightHandler(function ()
                    doExitGame()
                end)
            pDlg:showDlg()
            pDlg:setZOrder(10)
        else
            closeDlgByType(e_dlg_index.exitalert)
        end
    end
end

--退出游戏
local bIsGoingExitGame = false
function doExitGame()
    -- 执行一下android端的退出回调接口（可能需要执行清理行为）
    if device.platform == "android" then
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "onExitGame"
        luaj.callStaticMethod(className, methodName, {}, "()V");
    elseif device.platform == "ios" then
        return 
    end
    bIsGoingExitGame = true
    startPushAlarms()
    cc.Director:getInstance():endToLua()
end

--将列表分成最多为_num个的列表(!!!连续列表!!! k值为1,2,3...)
function separateTable(_table,_num)
    -- body
    local nNum = _num or 2
    local tList = {}
    if _table and type(_table) == "table" then
        local pRecmServer = _table
        if pRecmServer and table.nums(pRecmServer)>0 then
            local tData = {}
            for k,v in pairs(pRecmServer) do
                if k == table.nums(pRecmServer) then
                    table.insert(tData, v)
                    table.insert(tList, tData)
                else
                    if k%nNum == 0 then
                        table.insert(tData, v)
                        table.insert(tList, tData)
                        tData= {}
                    else
                        table.insert(tData, v)
                    end
                end
            end
        end

    end
    return tList
end

-- 判断token是否已经过期了，专门为从后台回来的帐号在其他地方登录做的处理
function getIsTokenOuttime(  )
    local bIsOut = false
    local fCurTime = getSystemTime()
    if(fCurTime and n_last_background_time and 
        fCurTime > n_last_background_time) then
        local fTempDis = fCurTime - n_last_background_time
        local nMaxTime = 60 * 60 * 1 -- 超过1个小时就认为已经失效
        if(fTempDis >= nMaxTime) then
            bIsOut = true
        end
    end
    return bIsOut
end

--获取系统国家旗帜
function getBigCountryFlagImg( nCountry )
    if nCountry == e_type_country.qunxiong then--玩家所在国家的国旗刷新
        return "#v1_img_flagqun.png"
    elseif nCountry == e_type_country.shuguo then
        return "#v2_img_hanz.png"
    elseif nCountry == e_type_country.weiguo then
        return "#v2_img_qingz.png"
    else
        return "#v2_img_chuz.png"
    end
end

--获取系统国家旗帜
function getBigCountryFlagImg2( nCountry )
    if nCountry == e_type_country.qunxiong then--玩家所在国家的国旗刷新
        return "#v1_img_zhenyingsuiji.png"
    elseif nCountry == e_type_country.shuguo then
        return "#v1_img_zhenyinghan.png"
    elseif nCountry == e_type_country.weiguo then
        return "#v1_img_zhenyingqin.png"
    else
        return "#v1_img_zhenyingchu.png"
    end
end

--获取系统国家旗帜
function getBigCountryFlagImg3( nCountry )
    if nCountry == e_type_country.qunxiong then--玩家所在国家的国旗刷新
        return "ui/daitu.png"
    elseif nCountry == e_type_country.shuguo then
        return "#v2_img_guojiahan.png"
    elseif nCountry == e_type_country.weiguo then
        return "#v2_img_guojiaqin.png"
    else
        return "#v2_img_guojiachu.png"
    end
end

--获取菱形势力图案
function getCountryDiamondImg( nCountry )
    if nCountry == e_type_country.qunxiong then
        return "#v2_img_qxsld.png"
    elseif nCountry == e_type_country.shuguo then
        return "#v2_img_dhsld.png"
    elseif nCountry == e_type_country.weiguo then
        return "#v2_img_dqsld.png"
    else
        return "#v2_img_xcsld.png"
    end
end

--获取阿房宫势力图案
function getCountryImperCityImg( nCountry )
    if nCountry == e_type_country.wuguo then
        return "#v2_img_afgxc.png" --绿
    elseif nCountry == e_type_country.shuguo then
        return "#v2_img_afghg.png" --红
    elseif nCountry == e_type_country.weiguo then
        return "#v2_img_afgqg.png" --蓝
    else
        return "#v2_img_afgqx.png"
    end
end

--获取雇用列表
function getEmployList(_nlimitLv, _ntype)
    -- body
    local DataOfficial = require("app.layer.palace.DataOfficial")
    local DataResearcher = require("app.layer.palace.DataResearcher")
    local DataSmith = require("app.layer.palace.DataSmith")
    local tmplist = {}
    if _nlimitLv and _ntype then
        if _ntype == 1 then--王宫文官表
            local tbuildpalace = getBuildPalaceData()
            table.sort(tbuildpalace, function (a, b)
                -- body
                if a.level == b.level then
                    return a.canchange < b.canchange
                else
                    return a.level > b.level
                end
            end) 
            local ncurlv = 1
            for i, v in pairs(tbuildpalace) do                
                if _nlimitLv >= v.palacelevel then
                    ncurlv = v.level                                       
                    break
                end
            end
            for i, v in pairs(tbuildpalace) do
                if (ncurlv == v.level) or (ncurlv + 1 == v.level) then
                    local pData = DataOfficial.new()
                    pData:refreshDataByDB(v)
                    table.insert(tmplist, pData)
                end
            end         
            table.sort( tmplist, function ( a, b )
                -- body
                if a.nLv == b.nLv then
                    return a.nCanChange < b.nCanChange
                else
                    return a.nLv < b.nLv
                end
            end )    
        elseif _ntype == 2 then--研究员
            local ResearcherDatas = getResearcherDatasFromDB()
            table.sort(ResearcherDatas, function (a, b)
                -- body
                if a.level == b.level then
                    return a.canchange < b.canchange
                else
                    return a.level > b.level
                end
            end)             
            local ncurlv = 1
            for i, v in pairs(ResearcherDatas) do
                if _nlimitLv >= v.institute then
                    ncurlv = v.level
                    break
                end
            end
            for i, v in pairs(ResearcherDatas) do
                if (ncurlv == v.level) or (ncurlv + 1 == v.level) then
                    local pData = DataResearcher.new()
                    pData:refreshDataByDB(v)
                    table.insert(tmplist, pData)
                end
            end
            table.sort( tmplist, function ( a, b )
                -- body
                if a.nLv == b.nLv then
                    return a.nCanChange < b.nCanChange
                else
                    return a.nLv < b.nLv
                end
            end )     
        elseif _ntype == 3 then--铁匠
            local buildBlackSmith = getBuildBlackSmith()  
            --dump(buildBlackSmith, "buildBlackSmith=", 100) 
            table.sort(buildBlackSmith, function (a, b)
                -- body
                return a.level > b.level
            end)         
            local ncurlv = 1
            for i, v in pairs(buildBlackSmith) do
                if _nlimitLv >= v.palacelevel then
                    ncurlv = v.level
                    break
                end
            end
            --print("ncurlv="..ncurlv)
            for i, v in pairs(buildBlackSmith) do
                if (ncurlv == v.level) or (ncurlv == v.level - 1) then            
                    local pData = DataSmith.new()
                    pData:refreshDataByDB(v)
                    table.insert(tmplist, pData)
                end        
            end
            table.sort( tmplist, function ( a, b )
                -- body
                return a.nLv < b.nLv
            end ) 
        end        
    end
    return tmplist
end

--获取官员数量
local tOfficialNum = nil
function getOfficialNum(_official)
    -- body
    local nCnt = 0
    if not _official then
        return nCnt
    end
    if not tOfficialNum then
        tOfficialNum = {}
        local svalue = getCountryParam("officialNums")         
        local ttmp = luaSplit(svalue, ";")           
        for i, v in pairs(ttmp) do
            local t = luaSplit(v, ":")            
            tOfficialNum[tonumber(t[1])] = tonumber(t[2])
        end
    end
    if tOfficialNum[_official] then
        nCnt = tOfficialNum[_official]
    end
    return nCnt
end

--根据区域iD获取区域名字
function getAreaName(_id  )
    -- body
    if not _id then
        return nil
    end
    local ttable = getWorldMapData()
    if ttable and ttable[_id] then
        return ttable[_id].name
    end
    return nil
end

--获取积分盒子基础数据
function getScoreBoxsBaseData(  )
    -- body
    local ttable = {}
    local t = luaSplit(getCountryParam("castleWarScoreTasks"), ";") 
    for k, v in pairs(t) do
        local tvalue = luaSplit(v, ":")
        local pScoreBox = ScoreBox.new()
        pScoreBox:refreshDataByDB({tonumber(tvalue[1]), tonumber(tvalue[2]), tonumber(tvalue[3])})
        local id = tonumber(tvalue[1])
        ttable[id] = pScoreBox
    end
    return ttable
end
--根据排行类型和排行序列获取奖票数量
function getRankVoteNum( _ranktype, idx )
    -- body
    if not _ranktype or not idx then
        return 0
    end
    local tvalue = nil
    if _ranktype == e_rank_type.cityfight then
        local tmp = luaSplit(getCountryParam("cityVote"), ";") 
        tvalue = luaSplit(tmp[idx], ":")
    elseif _ranktype == e_rank_type.countryfight then        
        local tmp = luaSplit(getCountryParam("countryVote"), ";") 
        tvalue = luaSplit(tmp[idx], ":")
    elseif _ranktype == e_rank_type.country_science then
        local tmp = luaSplit(getCountryParam("scienceVote"), ";") 
        tvalue = luaSplit(tmp[idx], ":")
    else
        return 0
    end
    if tvalue and tvalue[2] then
        return tonumber(tvalue[2])
    else
        return 0
    end 
end

--转换服务器
function changeServer(_pServer)
    local pSverver = _pServer
    if pSverver and pSverver.id then
        if pSverver.id ~= AccountCenter.nowServer.id then
            AccountCenter.nowServer = pSverver
            sendMsg(gud_refresh_login) --通知刷新界面
            closeDlgByType(e_dlg_index.serverlist, false)
            local pDlg, bNew = getDlgByType(e_dlg_index.dlgsettingmain)
            if not bNew then
                closeDlgByType(e_dlg_index.dlgsettingmain, false)
                AccountCenter.backToLoginScene(0)
            end
        else
            local pDlg, bNew = getDlgByType(e_dlg_index.dlgsettingmain)
            if not bNew then
                TOAST(getConvertedStr(5, 10191))--选择当前服务器提示
            else
                AccountCenter.nowServer = pSverver
                sendMsg(gud_refresh_login) --通知刷新界面
                closeDlgByType(e_dlg_index.serverlist, false)
                closeDlgByType(e_dlg_index.dlgsettingmain, false)
                AccountCenter.backToLoginScene(0)
            end
        end
    end
end

--创建活动时间 _pParent 父节点,_pos 位置, pActData活动数据
function createActTime(_pParent,pActData,_pos)
    local pLayer = nil
    local pPos = _pos or cc.p(0,0)
    if _pParent and pActData then
        local ItemActTime = require("app.layer.activitya.ItemActTime")
        pLayer = ItemActTime.new(pActData)
        pLayer:setPosition(pPos)
        _pParent:addView(pLayer,10)
    end

    return pLayer
end

--主界面菜单栏是否有一键征收快捷入口
function isShowItemHomeCollectFast( _nType, nIndex )
    -- body
    local bShow = false
    if Player:getUIHomeLayer() and Player:getUIHomeLayer().pHomeCenter then
        bShow = Player:getUIHomeLayer().pHomeCenter:isLRItemShowedByIndex(_nType, nIndex)
    end
    return bShow
end

--国家是否开启
function isCountryOpen()
    -- body
    local nopenlv = tonumber(getCountryParam("openLv"))         
    if Player:getPlayerInfo().nLv < nopenlv then
        return false        
    else
        return true
    end 
end

--是否已选择国家
function isSelectedCountry()
    return Player:getPlayerInfo().nCountrySelected == 1
end

-- --是否竞技场已经解锁
-- function isArenaUnLocked()
--     local tBuild = Player:getBuildData():getBuildById(e_build_ids.arena)
--     return tBuild ~= nil
-- end


--打开分享窗口
--[[_pParentView:  分享按钮或按钮层; 
    _nShareId:     分享的通告编号; 
    _param:        字符串{"", ""}; 
    _nId:          装备id或武将id或神兵id或邮件id, 不是的话不传
    _nType:        邮件类型]]

function openShare(_pParentView, _nShareId, _param, _nId, _nType)
    local DlgFlow = require("app.common.dialog.DlgFlow")
    local pDlg,bNew = getDlgByType(e_dlg_index.dlgshare)
    if(not pDlg) then
        pDlg = DlgFlow.new(e_dlg_index.dlgshare)
    end
    local DlgShare = require("app.layer.share.DlgShare")
    local pChildView = DlgShare.new(pDlg, _nShareId, _param, _nId ,_nType)
    pDlg:showChildView(_pParentView, pChildView)
    UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
end

--打开任务引导提醒框
function openGuideTip()
    -- body
    local DlgFlow = require("app.common.dialog.DlgFlow")
    local pDlg,bNew = getDlgByType(e_dlg_index.taskguidetip)
    if(not pDlg) then
        pDlg = DlgFlow.new(e_dlg_index.taskguidetip)
    end
    local TaskGuideTip = require("app.common.taskguidetip.TaskGuideTip")
    local pChildView = TaskGuideTip.new()
    pDlg:showChildView(_pParentView, pChildView)
    UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
    pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
end

--关闭任务引导
function closeGuideTip()
    -- body
    local pDlg,bNew = getDlgByType(e_dlg_index.taskguidetip)
    if pDlg then
        closeDlgByType( e_dlg_index.taskguidetip, false )
        local tObj = {}
        tObj.bIsShow = false
        sendMsg(ghd_refresh_home_bottom_msg, tObj)
    end
end

--打开icon信息
-- _pParentView:  分享按钮或按钮层
function openIconInfoDlg(_pParentView,_pData)

    if not _pParentView  then
        return
    end

    if not _pData then
        return
    end
    --默认对物品装备资源Icon进行相应
    if _pData.nGtype and ((_pData.nGtype == e_type_goods.type_item) or
        (_pData.nGtype == e_type_goods.type_equip) or 
        (_pData.nGtype == e_type_goods.type_tech) or 
        (_pData.nGtype == e_type_goods.type_resdata)) then
--        dump(_pData, "_pData", 100)
        local DlgFlow = require("app.common.dialog.DlgFlow")
        local pDlg,bNew = getDlgByType(e_dlg_index.showicontips)
        if(not pDlg) then
            pDlg = DlgFlow.new(e_dlg_index.showicontips)
        end
        local IconInfo = require("app.common.iconview.IconInfo")
        local pChildView = IconInfo.new()
        pChildView:setCurData(_pData)
        pDlg:showChildView(_pParentView, pChildView)
        UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew) 
    end  
end

--是否为英雄数据
function bJudgeHeroData(_data)
    local bData = false
    if (_data and _data.nKey) or (_data and _data.k) then
        if _data.nKey and (_data.nKey >= 200001 and _data.nKey <= 299999) then
            bData = true
        end
        if _data.k and (_data.k >= 200001 and _data.k <= 299999) then
            bData = true
        end
    end
    return bData
end

--是否为推荐信
function bJudgeRecommend(_data)
    local bData = false
    if (_data and _data.sTid) or (_data and _data.k) then
        if (_data.sTid == 100177) then
            bData = true
        end

        if (_data.k == 100177) then
            bData = true
        end
    end
    return bData
end
        
--根据活动类型获取排行类型
function getRankTypeByActType( nActType )
    -- body
    if not nActType then
        return nil
    end
    if nActType == e_id_activity.countryfight then
        return e_rank_type.ac_country_fight
    elseif nActType == e_id_activity.forgerank then
        return e_rank_type.ac_forge
    elseif nActType == e_id_activity.armyrank then
        return e_rank_type.ac_army
    elseif nActType == e_id_activity.foodstore then
        return e_rank_type.ac_foodstore
    elseif nActType == e_id_activity.succinctrank then
        return e_rank_type.ac_succinct
    elseif nActType == e_id_activity.ironstore then
        return e_rank_type.ironstore
    elseif nActType == e_id_activity.cityfight then        
        return e_rank_type.ac_cityfight
    elseif nActType == e_id_activity.luckystar then        
        return e_rank_type.ac_lucky_star
    elseif nActType == e_id_activity.nationpillars then        
        return e_rank_type.ac_nation_combat        
    else
        return nil
    end
end

--创建动作特效
--_parent 父节点,_armatureNe动画名称,_pos位置,_handler回调,_zorder层级
function createMArmature(_parent,_armatureNe,_handler,_pos,_zorder, _sceneType)
    if not _parent then
       return
    end

    if not _armatureNe then
       return
    end

    local pos = _pos or cc.p(_parent:getWidth()/2,_parent:getHeight()/2)
    local nZorder = _zorder or 1

    local pHandler = _handler

    local pArm = MArmatureUtils:createMArmature(
    _armatureNe, --动画名字
    _parent, --动画父节点
    nZorder, --动画层级
    pos, --动画位置
    function (pArme)
       if pHandler then
           pHandler(pArme)
        end 
    end, _sceneType or Scene_arm_type.normal)

    return pArm
end

--播放守军提升动画
function playUpDefenseArm(_parent, fScale, nZoder)
    -- body
    local pos = cc.p(_parent:getWidth()/2,_parent:getHeight()/2+15) 
    local pArm =  createMArmature(_parent,tNormalCusArmDatas["7"],function (pArmate)
        if pArmate then
            pArmate:removeSelf()
        end
    end,pos, nZoder)
    if fScale then
        pArm:setScale(fScale)
    end
    if pArm then
        pArm:play(1)
    end
end

--
--根据活动排行档次获取对应取字符串
function getClassifyName( _nCa )
    -- body
    local nCa = _nCa or 0
    if nCa == 1 then
        return {color = _ccq.red, text = getConvertedStr(6, 10457)}
    elseif nCa == 2 then
        return {color = _ccq.orange, text = getConvertedStr(6, 10458)}
    elseif nCa== 3 then
        return {color = _ccq.purple, text = getConvertedStr(6, 10459)}
    elseif nCa== 4 then
        return {color = _ccq.blue, text = getConvertedStr(6, 10460)}
    elseif nCa== 5 then
        return {color = _ccq.green, text = getConvertedStr(6, 10461)} 
    elseif nCa== 6 then
        return {color = _ccq.white, text = getConvertedStr(6, 10462)}
    elseif nCa== 7 then
        return {color = _ccq.white, text = getConvertedStr(6, 10463)}
    elseif nCa== 8 then
        return {color = _ccq.white, text = getConvertedStr(6, 10464)}
    else
        return {color = _ccq.white, text = getConvertedStr(6, 10452)}
    end
end

--是否可以在升级科技的时候同时研究科技
function getIsCanTnolyUpingWithTecnologying()
    -- body
    --是否购买了vip5特价礼包
    if Player:getPlayerInfo():getIsBoughtVipGift(5) then
        --是否雇佣了紫色研究员
        local researcherData = Player:getTnolyData():getResearcherBaseData()
        if researcherData and researcherData.nQuality == 4 then
            return true
        end
    end
    return false
end

--下一步操作是否超过体力上限
--_energy:下一步操作增加的体力
function getIsOverMaxEnergy(_energy)
    -- body
    if (Player:getPlayerInfo().nEnergy + _energy) > tonumber(getGlobleParam("maxEnergy")) then
        TOAST(getConvertedStr(7,10123))
        return true
    end
    return false
end

--播放点击音效
function playClickSoundEffect(  )
    -- body
    Sounds.playEffect(Sounds.Effect.click)
    --重置引导时间
    N_LAST_CLICK_TIME = getSystemTime()
end

--检测建筑是否开启，未开启则弹出相应提示
--bHideToast,是否屏蔽提示
function showBuildOpenTips(nBuildId, bHideToast)
    -- body
    local pBuild = Player:getBuildData():getBuildById(nBuildId)    
    if not pBuild then
        local builddata = getBuildDatasByTid(nBuildId)
        if builddata then
            if not bHideToast then
                TOAST(builddata.notopen)
            end   
        end
        return false
    else
        return true
    end
    -- local builddata = getBuildDatasByTid(nBuildId)
    -- if not builddata then 
    --     return false 
    -- end           
    -- local tOpen = luaSplit(builddata.open, ":")
    -- local ntype = tonumber(tOpen[1] or 0)
    -- local nlv = tonumber(tOpen[2] or 0)        
    -- if ntype == 1 then--玩家等级限制
    --     if Player:getPlayerInfo().nLv < nlv then
    --         TOAST(string.format(getConvertedStr(6, 10500), getLvString(nlv, false), builddata.name))
    --         return false
    --     end
    -- elseif ntype == 2 then--王宫等级限制
    --     local pBPalace = Player:getBuildData():getBuildById(e_build_ids.palace)
    --     if pBPalace and pBPalace.nLv < nlv then
    --         TOAST(string.format(getConvertedStr(6, 10499), getLvString(nlv, false), builddata.name))
    --         return false
    --     end
    -- end             
    -- return true
end

--判断是否达到系统等级开放限制
--nId open_system表 id字段
--bIsShowLog 是否提示, 默认是显示
--return 达到条件，返回TRUE，否则返回FALSE和飘字提示语
function getIsReachOpenCon( nId, bIsShowLog )

    -- if true then
    --    return true
    -- end

    if bIsShowLog == nil then
        bIsShowLog = true
    end

    if not nId then
        myprint("getIsReachOpenCon no nId")
        return true
    end

    local tOpenSystem = getOpenSystem(nId)
    -- dump(tOpenSystem, "tOpenSystem", 100)
    if not tOpenSystem then
        myprint("getIsReachOpenCon no tOpenSystem")
        return true
    end

    if not tOpenSystem.condition then
        myprint("getIsReachOpenCon no tOpenSystem.condition")
        return true
    end

    -- 1任务开放:任务id
    -- 2玩家等级开放:等级
    -- 3王宫等级放开:等级
    local tData = luaSplitMuilt(tOpenSystem.condition, ":", "|")
    -- dump(tData, "tData", 100)
    if tData and #tData >= 2 then
        local nKey = tonumber(tData[1])
        local nValue = nil
        local nValue2 = nil
        if type(tData[2]) == "table" then --主公等级区间
            nValue = tonumber(tData[2][1])
            nValue2 = tonumber(tData[2][2])
        else
            nValue = tonumber(tData[2])
        end
        local bIsOpen = true
        if nKey == 1 then               --任务开放
            bIsOpen = Player:getPlayerTaskInfo():getTaskIsUnLock(nValue)
        elseif nKey == 2 then           --玩家等级开放
            local nPlayLv = Player:getPlayerInfo().nLv
            if nValue2 then
                bIsOpen = nPlayLv >= nValue and nPlayLv <= nValue2
            else
                bIsOpen = nPlayLv >= nValue
            end
        elseif nKey == 3 then           --王宫等级开放
            local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
            if pPalacedata and not pPalacedata:getIsLocked() then
                bIsOpen = pPalacedata.nLv >= nValue
            else
                bIsOpen = false --王宫未开启
            end
        elseif nKey == 4 then           --仓库等级开放
            local pStoreData = Player:getBuildData():getBuildById(e_build_ids.store)--仓库数据
            if pStoreData and not pStoreData:getIsLocked() then
                bIsOpen = pStoreData.nLv >= nValue
            else
                bIsOpen = false --仓库未开启
            end
        end
        if bIsOpen then
            return true
        else 
            if bIsShowLog then
                TOAST(tOpenSystem.skill)
            end
            return false, tOpenSystem.skill
        end
    else
        myprint("getIsReachOpenCon tOpenSystem.condition error")
        return true
    end
   
    myprint("getIsReachOpenCon fixed error")
    return true
end

--获取通用活动title _data活动数据 (返回需要设置的内容层)
function getActivityTitleA(_data)
    local ItemActivityPackTitleA = require("app.layer.activitymodel.ItemActivityPackTitleA")
    local pLayer = ItemActivityPackTitleA.new(_data)
    return pLayer
end

--获取通用活动title中的描述层 _data活动数据 (返回需要设置的内容层)
function getActivityTitleDes(_data)
    local ItemActivityPackDesc = require("app.layer.activitymodel.ItemActivityPackDesc")
    local pLayerDes = ItemActivityPackDesc.new(_data)
    return pLayerDes
end

--获取通用活动title中的获得物品 
function getActivityTitleReward()
    local ItemActivityPackGetReward = require("app.layer.activitymodel.ItemActivityPackGetReward")
    local pLayerReward= ItemActivityPackGetReward.new()
    return pLayerReward
end

-- 打开网址
-- sAddress（string）：网址
function gotoHttpAddress( sAddress )
    if(device.platform == "android") then
        -- 跳转到市场去下载
        local className = "org/cocos2dx/utils/PSNative"
        local methodName = "openURL"
        local bOk, ret = luaj.callStaticMethod(className, methodName, {sAddress}, 
            "(Ljava/lang/String;)V")
        if(not bOk) then
            TOAST(getConvertedStr(1, 10265))
        end
    elseif(device.platform == "ios") then
        local param = {}
        param.sPath = sAddress
        param.nType = 1
        param.nBrowser = 1
        local luaoc = require("framework.luaoc")
        local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", 
            "openURL", param)
        if(not bOk) then
            TOAST(getConvertedStr(1, 10196))
        end
    else

    end
end

-- 预加载战斗的音效
function doPreloadFightEffect(  )
    for i, v in pairs(Sounds.Effect.tFight) do
        Sounds.preloadEffect(v)
    end

    --预加载星星音效
    Sounds.preloadEffect(Sounds.Effect.star)
    Sounds.preloadEffect(Sounds.Effect.shengli)
    Sounds.preloadEffect(Sounds.Effect.shibai)

    -- 加载战斗背景音乐
    -- Sounds.preloadMusic(Sounds.Music.huanjing)
end

-- 释放战斗音效
function doUnloadFightEffect(  )
    for i, v in pairs(Sounds.Effect.tFight) do
        Sounds.unloadEffect(v)
    end
    --预加载星星音效
    Sounds.unloadEffect(Sounds.Effect.star)
    Sounds.unloadEffect(Sounds.Effect.shengli)
    Sounds.unloadEffect(Sounds.Effect.shibai)
    --释放战斗背景音乐
    -- Sounds.unloadEffect(Sounds.Music.huanjing)
    
end

--获取双方将领克制关系
function getHeroRestrainState( _nKind1, _nKind2 )
    -- body
    if not _nKind1 or not _nKind2 then
        return
    end
    local nState = 0 --0:不克制 1：克制 2：被克制
    if _nKind1 == _nKind2 then
        nState = 0
    else
        if _nKind1 == en_soldier_type.infantry then --步将
            if _nKind2 == en_soldier_type.archer then --克 弓兵
                nState = 1
            else --被克
                nState = 2
            end
        elseif _nKind1 == en_soldier_type.sowar then --骑将
            if _nKind2 == en_soldier_type.infantry then --克 步将
                nState = 1
            else --被克
                nState = 2
            end
        elseif _nKind1 == en_soldier_type.archer then --弓将
            if _nKind2 == en_soldier_type.sowar then --克 骑将
                nState = 1
            else --被克
                nState = 2
            end 
        end
    end
    return nState
end

function createSliderTx( _pBarBall )
    -- body
    -- _pView:onUpdate(function ( ... )
    --     -- body
    --     MArmatureUtils:updateMArmature()
    -- end)

    -- 加载纹理
    addTextureToCache("tx/world/sg_jdt_tjp_tptmd")

    local tpArmActions = {}
    for i = 1, 2 do 
        local pArmAction = MArmatureUtils:createMArmature(
            tNormalCusArmDatas["progress_"..1], 
            _pBarBall, 
            10, 
            cc.p(_pBarBall:getContentSize().width / 2 - 7,_pBarBall:getContentSize().height / 2),
            function ( _pArm )

            end, Scene_arm_type.normal)
        if pArmAction then
            pArmAction:setVisible(false)
            pArmAction:play(-1)
        end
        table.insert( tpArmActions, pArmAction )
    end

    --新增粒子效果
    local pParitcle = cc.ParticleSystemQuad:create("tx/other/lizi_tjp_la_02.plist")
    local pBatch = cc.ParticleBatchNode:createWithTexture(pParitcle:getTexture())
    pParitcle:setPositionType(MUI.kCCPositionTypeRelative)
    pParitcle:setPosition(_pBarBall:getContentSize().width / 2 - 7,_pBarBall:getContentSize().height / 2)
    pParitcle:setScale(0.4)
    pParitcle:setVisible(false)
    _pBarBall:addChild(pParitcle,20)  
    return  {pArm = tpArmActions, pLizi = pParitcle, width = 80}
end

function setSliderTxVisible( pTx, _visible )
    -- body
    if not pTx then
        return
    end
    local bVisible = _visible or false
    if pTx.pArm and #pTx.pArm > 0 then
        for k, v in pairs(pTx.pArm) do
            v:setVisible(bVisible)
        end
    end
    if pTx.pLizi then
        pTx.pLizi:setVisible(bVisible)
    end
end

function getPlayerIconStr( Id )
    -- body
    local tIconData = getAvatarIcon(Id)
    if tIconData then
        return tIconData.sIcon
    else
        return "#i130000_tx.png"
    end
end

function getPlayerIconBg( Id )
    -- body
    local sBox = getAvatarBoxIcon(Id)
    if sBox and sBox.sIcon then
        return sBox.sIcon
    else
        return "#v2_img_kapaiygwc.png"
    end
end


function getPlayerTitle( Id )
    -- body
    local tTitle = getAvatarTitle(Id)
    if tTitle and tTitle.sIcon then
        return tTitle.sIcon
    end
    return nil
end

--显示建筑引导
function showBuildGuide(nId)
    -- body
    local pGuideLayer = getRealShowLayer(Player:getUIHomeLayer(), e_layer_order_type.guidelayer)
    if not pGuideLayer then return end
    if (tolua.isnull(BuildGuide)) then
        local BuildGuideTip = require("app.layer.newguide.BuildGuideTip")
        BuildGuide = BuildGuideTip.new()
        pGuideLayer:addView(BuildGuide)
        centerInView(pGuideLayer, BuildGuide)
    else
        BuildGuide:setVisible(true)
    end
    BuildGuide:setData(nId)
end

--开始引导
function showBuildGuideBegin(nInterfaceId)
    -- body
    local function openGuideDlg()
        -- body
        --1、判断任务区间
        if getIsBuildGuideShouldShow() then
            --已经引导过的界面
            local tGuideInterface = Player:getDayLoginData():getAlreadyGuidedView()
            --2、判断是不是第一次进来, 如果是就引导且请求服务器记录已引导, 不是就不引导
            if tGuideInterface[nInterfaceId] then
                return
            end
            local tGuide = getBuildGuideFirstStep(nInterfaceId)
            if tGuide then
                showBuildGuide(tGuide.id)
                --记录已引导
                SocketManager:sendMsg("reqPlayGuideDlg", {nInterfaceId}, function(__msg)
                    -- body
                end)
                Player:getDayLoginData():setAlreadyGuidedView(nInterfaceId)
            end
        end
    end

    doDelayForSomething(RootLayerHelper:getCurRootLayer(), function( )
        -- body
        openGuideDlg()--打开引导对话框
    end, 0.3)  --延时0.3秒打开
end

--任务手指指引 _pParentView, _nShareId, _param, _nId, _nType
function showTaskFinger( _pParentView, nScale, _pos )
    -- body
    if not _pParentView then
        return
    end    
    --local pCurrPoint = cc.p(_pParentView:getWidth()/2, _pParentView:getHeight()/2)
    --移动
    closeDlgByType(e_dlg_index.dlgtaskfinger)
    local DlgFlow = require("app.common.dialog.DlgFlow")
    local pDlg,bNew = getDlgByType(e_dlg_index.dlgtaskfinger)
    if (not pDlg) then
        pDlg = DlgFlow.new(e_dlg_index.dlgtaskfinger)
        --添加特效   
        --特效动画层
        local pChildView = MUI.MLayer.new()
        pChildView:setLayoutSize(20, 20)
        --pChildView:setPosition(pCurrPoint)
        pChildView:setName("dlgtaskfinger")        
        pDlg:showChildView(_pParentView, pChildView)
        --pDlg:setToCenter()
        local pCurrPoint = cc.p(pChildView:getWidth()/2, pChildView:getHeight()/2)
        if _pos then
            pCurrPoint = _pos
        end      
        local nScale = nScale or 1
        --光圈特效  
        local sName1 = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
        local pLightArm = ccs.Armature:create(sName1)         
        pLightArm:setPosition(pCurrPoint)
        pLightArm:setScale(nScale)
        pChildView:addChild(pLightArm,999)
        pLightArm:getAnimation():play("gqks_01", 1)   

        --手指
        local sName2 = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
        local pClieckArm = ccs.Armature:create(sName2)        
        local sSkillName = "#v1_img_shouzhi.png"
        local sBoneName = "szth_01"
        local pImg = changeBoneWithPngName(pClieckArm,sBoneName,sSkillName,false) 
        pClieckArm:setPosition(pCurrPoint.x + 48*nScale, pCurrPoint.y + 48*nScale)
        pClieckArm:setScale(nScale)
        pChildView:addView(pClieckArm,999)      
        pClieckArm:getAnimation():play("szdj_02", 1)        
    end 
    
    local pParView = getRealShowLayer(RootLayerHelper:getCurRootLayer(), e_layer_order_type.guidelayer)
    UIAction.enterDialog( pDlg, pParView, bNew)
    pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)      
end

--是否在建筑的任务引导区间
function getIsBuildGuideShouldShow()
    -- body
    local tTaskIdParam = luaSplit(getGlobleParam("dialogLv"), ";")
    local nBeginTaskId = tonumber(tTaskIdParam[1])
    local nEndTaskId = tonumber(tTaskIdParam[2])
    --当前的主线任务
    local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
    if tCurTask and tCurTask.sTid then
        if tCurTask.sTid >= nBeginTaskId and tCurTask.sTid <= nEndTaskId then
            return true
        end
    end
    return false
end

--创建一个广告牌节点，改节点继承sprite,并且设置视角的类型（面对焦点或者面对平面）
function createCCBillBorad( _sImgName, _nMode )
    -- body
    _nMode = _nMode or cc.BillBoard_Mode.VIEW_PLANE_ORIENTED
    local pBillBoard = cc.BillBoard:create("ui/daitu.png",_nMode)
    if _sImgName then --如果存在图片名字直接初始化
        pBillBoard:setSpriteFrame(getSpriteFrameByName(_sImgName))
    end
    return pBillBoard
end

--返回多个空格字符串
--_nCount：空格数量
function getSpaceStr(_nCount)
    if _nCount and _nCount > 0 then
        local totalStr = ""
        local subStr = ""
        if (device.platform == "ios") then
            subStr = " "
        else
            subStr = "&nbsp;"
        end
        for i=1,_nCount do
            totalStr = totalStr .. subStr
        end
        return totalStr
    else
        return ""
    end
end

--更新登陆界面进度条
--nType：类型 1 世界 2城内建筑 3资源田
--bEnd：是否结束
function updateLoginSlider( nType, bEnd )
    -- body
    local tObj = {}
    tObj.nType = nType
    tObj.bEnd = bEnd
    sendMsg(ghd_update_login_slider_value,tObj)
end

--资源不足跳转
--resid:资源id
--hideSecSure:是否隐藏二次确认弹窗, 直接弹获取资源窗口
function goToBuyRes(resid, tValue)
    -- body
    local nIndex = 1
    if resid then
        if resid == e_resdata_ids.yb then
            nIndex = 1
        elseif resid == e_resdata_ids.mc then
            nIndex = 2
        elseif resid == e_resdata_ids.lc then
            nIndex = 3
        elseif resid == e_resdata_ids.bt then
            nIndex = 4
        end
    end
    local tObject = {}
    tObject.nType = e_dlg_index.getresource --dlg类型
    tObject.nIndex = nIndex
    tObject.tValue = tValue
    sendMsg(ghd_show_dlg_by_type,tObject)  
    closeDlgByType(e_dlg_index.alert, false)

    -- local DlgAlert = require("app.common.dialog.DlgAlert")
    -- local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    -- if(not pDlg) then
    --     pDlg = DlgAlert.new(e_dlg_index.alert)
    -- end
    -- pDlg:setTitle(getConvertedStr(3, 10091))
    -- pDlg:setContent(getConvertedStr(7, 10127))
    -- pDlg:setRightHandler(function ()            
    --     local tObject = {}
    --     tObject.nType = e_dlg_index.getresource --dlg类型
    --     tObject.nIndex = nIndex
    --     sendMsg(ghd_show_dlg_by_type,tObject)  
    --     closeDlgByType(e_dlg_index.alert, false)  
    -- end)
    -- pDlg:showDlg(bNew)
end


--活动道具列表(按品质向上，同品质按id) List<Pair<Integer,Long>>
function sortGoodsList( tGoodsList )
    if not tGoodsList then
        return
    end
    table.sort(tGoodsList, function ( a, b )
        if a.k and b.k then
            local tGoodsA = getGoodsByTidFromDB(a.k)
            local tGoodsB = getGoodsByTidFromDB(b.k)
            if tGoodsA and tGoodsB then
                if tGoodsA.nQuality == tGoodsB.nQuality then
                    return tGoodsA.sTid > tGoodsB.sTid
                end
                return tGoodsA.nQuality > tGoodsB.nQuality
            end
        end
        return false
    end)
end


--获取未雇佣界面上显示的列表
function getShowCivilListData(_nType )  
    -- body
    --根据当前雇用文官的情况刷新雇用列表数据
    local buildLv = 1   
    local employData = nil
    if _nType == e_hire_type.official then --雇用文官、
        buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
        employData = Player:getBuildData():getBuildById(e_build_ids.palace):getOfficalBaseData()
    elseif _nType == e_hire_type.researcher then --雇用研究员
        buildLv = Player:getBuildData():getBuildById(e_build_ids.tnoly).nLv
        employData = Player:getTnolyData():getResearcherBaseData()
    elseif _nType == e_hire_type.smith then
        buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
        employData = Player:getEquipData():getSmithConfigData()
    else
        print("异常的雇用类型")
    end
    
    local tmplist = getEmployList(buildLv, _nType)
    --dump(tmplist, "tmplist", 100)
    local pDataList = {}
    for i, employer in pairs(tmplist) do                
        local isadd = false
        if not employData then--未雇用文官
            --print("当前未雇用")
            isadd = true    
        else
            if _nType == e_hire_type.official or _nType == e_hire_type.researcher then
                if employer.nLv > employData.nLv then--
                    isadd = true
                elseif (employer.nLv == employData.nLv) and (employer.nCanChange > employData.nCanChange) then
                    isadd = true
                end
            elseif _nType == e_hire_type.smith then
                --edit by shulan, 现在是等级高的才能替换当前正在雇佣的
                if employer.nLv > employData.nLv then
                    isadd = true
                end
            end
        end
        if isadd then
            table.insert(pDataList, employer)
        end
    end 
    return pDataList
end

--判断是否需要显示铁匠的红点
function isShowHireSmithRed(_nType )
    -- body
    local tData=getShowCivilListData(_nType)        --已经按照等级排序
    local isShow=false
    if _nType == e_hire_type.smith then         --铁匠铺有免费次数
        for i , employer in pairs(tData) do
            isShow=Player:getEquipData():getIsCanFreeHire(employer.sTid)
            if isShow then
                return isShow
            end
        end
    else
        for i,employer in pairs (tData) do
            local nlimitLv = nil
            local nopenLv = nil
            if _nType == e_hire_type.official then
                nlimitLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
                nopenLv = employer.nLimit
            elseif _nType == e_hire_type.researcher then
                nlimitLv = Player:getBuildData():getBuildById(e_build_ids.tnoly).nLv
                nopenLv = employer.nLimit
            elseif _nType == e_hire_type.smith then
                nlimitLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
                nopenLv = employer.nLimit           
            end
            if not nlimitLv or not nopenLv then
                return isShow
            end

            if nlimitLv >= nopenLv then--可以雇用
                --解析cityIcon
                local tCost =luaSplit(employer.sCost,":")
                if tonumber(tCost[1]) == 3 then
                    isShow=true
                    return isShow
                end
            end
        end
    end

    return isShow
end

--获得郡县的显示名字  _nType 1=翼·xx镇 2=翼州-xx镇
function getBlockShowName(_blockId ,_nType)
    -- body
    local nType=_nType or 1
    if _blockId then
        local tBlockData = getWorldMapDataById(_blockId)
        if tBlockData then
            --获得所属州
            local tCity=getWorldMapDataById(tBlockData.subordinate)
            if tCity then 
                if nType==1 then 
                    if tCity.abridge then
                        return tCity.abridge .. "·".. tBlockData.name
                    else
                        return tBlockData.name
                    end
                else
                    if tCity.abridge then
                        return tCity.name .. "-"..tBlockData.name
                    else
                        return tBlockData.name
                    end
                end
            else
                return tBlockData.name
            end  
        end
    end
end

--能量不足是弹出能量购买对话框
function gotoBuyEnergy()
    -- body
    local pEnergy = Player:getBagInfo():getItemDataById(e_id_item.energy) 
    if pEnergy and pEnergy.nCt > 0 and Player:getBagInfo():isItemCanUse(e_id_item.energy) then
        showUseItemDlg(e_id_item.energy)
    else
        local nLeftBuy = Player:getPlayerInfo():getBuyEnergyLeftTimes()
        if nLeftBuy <= 0 then
            TOAST(getConvertedStr(6, 10502))
        else
            local tObject = {}
            tObject.nType = e_dlg_index.vitbuy --dlg类型
            sendMsg(ghd_show_dlg_by_type,tObject)
        end
    end
end

--添加底部背景
function addDlgBottomBg( pUi, nWidth, nHeight, nZorder)
    if not pUi then
        return
    end
    local pLayBottom = MUI.MLayer.new()
    pLayBottom:setBackgroundImage("ui/v2_bg_popup_b.png",{scale9 = true,capInsets=cc.rect(300/2, 50/2, 1, 1)})
    pLayBottom:setLayoutSize(nWidth, nHeight)
    pUi:addView(pLayBottom, nZorder or -1)
    return pLayBottom
end

--创建渐变背景
function setGradientBackground( pLay, bIsFan )
    if not pLay then
        return
    end
    local nWidth = pLay:getWidth()
    local nHeight = pLay:getHeight()
    local pLayBg1 = MUI.MLayer.new()
    pLayBg1:setBackgroundImage("#v1_img_kelashen6.png",{scale9 = true,capInsets=cc.rect(100/2, 100/2, 1, 1)})
    pLayBg1:setLayoutSize(nWidth, nHeight)
    pLay:addView(pLayBg1, 0)
    if bIsFan then
        local pLayBg2 = MUI.MLayer.new()
        pLayBg2:setBackgroundImage("#v1_img_kelashen6_c.png",{scale9 = true,capInsets=cc.rect(350/2, 18/2, 1, 1)})
        pLayBg2:setLayoutSize(350, nHeight - 2)
        pLayBg2:setPositionX(nWidth - 350)
        pLay:addView(pLayBg2, 0)
    else
        local pLayBg2 = MUI.MLayer.new()
        pLayBg2:setBackgroundImage("#v1_img_kelashen6_b.png",{scale9 = true,capInsets=cc.rect(350/2, 18/2, 1, 1)})
        pLayBg2:setLayoutSize(350, nHeight - 2)
        pLay:addView(pLayBg2, 0)
    end
end

--设置Ui位置更新
--tData = {{sUiName, nTopSpac, nBottomSpac, nBottomY}}}
function restUiPosByData( tData, pParent)
    if not tData then
        return
    end
    if not pParent then
        return
    end
    local pSize = pParent:getContentSize()
    local nWidth, nHeight = pSize.width, pSize.height
    
    local nTopHeight = nHeight
    local nBottmHeight = 0
    for i=1,#tData do
        local tSubData = tData[i]
        local pUi = pParent:findViewByName(tSubData.sUiName)
        if pUi then
            local nTopSpac = tSubData.nTopSpac
            local nBottomSpac = tSubData.nBottomSpac
            local nBottomY = tSubData.nBottomY

            if nTopSpac then --向上的要求顶上 (ui必须从上到下排列)
                nTopHeight = nTopHeight - nTopSpac

                local fX, fY = pUi:getAnchorPoint()
                local pUiSize = pUi:getContentSize()
                local nNewY = nTopHeight - pUiSize.height
                pUi:setPositionY(nNewY)
                nTopHeight = nNewY
            elseif nBottomSpac then --底部矩形要顶下 (ui必须从下到上排列)
                local nNewY = nBottmHeight + nBottomSpac
                pUi:setPositionY(nNewY)
                local pUiSize = pUi:getContentSize()
                nBottmHeight = nNewY + pUiSize.height
            elseif nBottomY then --普通Y轴
                pUi:setPositionY(nBottomY)
            end
        end
    end
end

--世界目标显示检测
function checkWorldTargetShow( )
   -- if not self.pWorldTargetLayer then
   --     return
   -- end

   local bIsShow = false
   local bIsUnLock = getIsReachOpenCon(8, false)
   --如果当前解锁世界目标显示世界目标
   if bIsUnLock then
       local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
       if nMyTargetId then
           local tWorldTargetData = getWorldTargetData(nMyTargetId)
           if tWorldTargetData then
               bIsShow = true
           end
       end
   end
   return bIsShow
   -- self.pWorldTargetLayer:setVisible(false)
   -- self.pHomeCenter:refreshLayDownLeft()
end

--奖励领取表现(包含有武将的情况走获得武将流程)
--_itemsList: 获得物品列表 List<Pair<Integer,Long>>    获得物品 (--Pair = {k=,v=})
function showGetItemsAction(_itemsList)
    -- body
    local tHero = nil
    for k, v in pairs(_itemsList) do
        if v.k >= 200001 and v.k <= 299999 then
            tHero = copyTab(v)
            break
        end
    end
    if tHero then
        local tDataList = {}
        local tReward = {}
        tReward.d = {}
        tReward.g = {}
        table.insert(tReward.d, copyTab(tHero))
        table.insert(tReward.g, copyTab(tHero))
        table.insert(tDataList, tReward)

        local tObject = {}
        tObject.nType = e_dlg_index.showheromansion --dlg类型
        tObject.tReward = tDataList
        tObject.nHandler = handler(self, function ( ... )
            -- body
            showGetAllItems(_itemsList, 1)
        end)
        sendMsg(ghd_show_dlg_by_type,tObject)
    else
        showGetAllItems(_itemsList, 1)
    end
end
 --根据界面id获得是否显示活动标签
 function getIsShowActivityBtn(_nId )
     -- body

     local tShowActivity=getActivityBtnData(_nId)
     local nOpenTime=0
     local nId=0
     if tShowActivity then
        local tShowId=luaSplit(tShowActivity,";")
        for i, v in pairs(tShowId) do
            local tActivity =Player:getActById(tonumber(v))
            if tActivity then
                if (tActivity.nActivityOpenTime<nOpenTime or nOpenTime==0 ) and tActivity:isOpen() then
                     nOpenTime=tActivity.nActivityOpenTime
                     nId=v
                 end
            end
        end
    else
        return 0
    end

    if nId~=0 then
        return tonumber(nId)
    else
        return 0
    end
 end

 function addActivityBtn(_parent,_nId )
     -- body
    if not _parent or not _nId then
        return
    end
    if nId~=0 then
        local pActBtn=ItemActBtn.new(_nId)
        _parent:addView(pActBtn)
        return pActBtn
    end
 end

--获得邮件的发送和删除时间
 function getMailSendTime(_tMail )
     -- body
     if not _tMail then
        return 
     end

     --毫秒级别保存上限

    local nSaveTime = 0
    if _tMail.nCategory == e_type_mail.saved then
        nSaveTime = getMailInitData("retentionTime") * 1000
    else
        nSaveTime = getMailInitData("mailTime") * 1000
    end
    --当前时间-修改时间-保存相关保存类别的上限时间 = 剩余时间(毫秒)
    local nSubTime = math.max(nSaveTime - (getSystemTime(false) - _tMail.nLmt),0)
    --毫秒转天数
    local nDay = math.ceil(nSubTime/1000/60/60/24)
    local sDelTime=string.format(getConvertedStr(3, 10242), nDay)
    local sSendTime=getConvertedStr(3, 10241)..formatTime(_tMail.nSendTime)
    return sSendTime,sDelTime
 end

 function addMailSendAndShareBanner(_tMailMsg , _bShare)
     -- body
    local sSendTime,sDelTime=getMailSendTime(_tMailMsg)
    local sTime={
        {sStr=sSendTime,nFontSize=18,sColor=_cc.white},
        {sStr=sDelTime,nFontSize=18,sColor=_cc.red}
        
    }
    --时间分享层
    local pTimeAndShare=ItemMailSendTimeShare.new(sTime)
    -- pTimeAndShare:setShareHandler(_shareHandler)
    -- pTimeAndShare:setSaveHandler(_saveHandler)
    if _bShare then
        pTimeAndShare:hideShareBtn()
    end
    return pTimeAndShare
 end

 function addFightTimeAndShareBanner( _sTime, _bShare )
     -- body
    --时间分享层
    local pTimeAndShare=ItemMailSendTimeShare.new(_sTime)
    if (not _bShare) then
        pTimeAndShare:hideShareBtn()
    end
    return pTimeAndShare     
 end


--获取国家图片
function getCountryImg( nCountry )
    -- body
    if not nCountry then
        return
    end
    local sImg=""
    if nCountry == e_type_country.qunxiong then
        sImg="#v1_img_qun.png"
    elseif nCountry == e_type_country.shuguo then
        sImg="#v1_img_han.png"
    elseif nCountry == e_type_country.weiguo then
        sImg="#v1_img_qing.png"
    elseif nCountry == e_type_country.wuguo then
        sImg="#v1_img_chu.png"
    end

    return sImg
end

function isRedPocket( _nID )
    -- body
    if not _nID then
        return false
    end
    if _nID == e_id_item.redT or 
        _nID == e_id_item.redF or
        _nID == e_id_item.redH or
        _nID == e_id_item.redTH then
        return true
    end
    return false
end
--获取国家文字图片
function getCountryShortImg( nCountry )
    if nCountry == e_type_country.shuguo then
        return "#v2_fonts_han.png"
    elseif nCountry == e_type_country.weiguo then
        return "#v2_fonts_qin.png"
    elseif nCountry == e_type_country.wuguo then
        return "#v2_fonts_chu.png"
    end
    return "#v2_fonts_han.png"
end

--自动分享到国家
function autoShareToCountry(_nShareId,_sParam)
    -- body
    SocketManager:sendMsg("reqShare", {_nShareId, _sParam, 2})
end

function getMailBattleList( _tMailMsg,_nWidth)
    -- body

    local nAtkHeroCount = #_tMailMsg.tAtkHeros-1
    local nDefHeroCount = #_tMailMsg.tDefHeros-1
    local nCount = math.max(nAtkHeroCount, nDefHeroCount) + 1
    local pBattleList=MUI.MLayer.new()
    pBattleList:setAnchorPoint(0,0)
    pBattleList:setLayoutSize(_nWidth,100)
    local nTotalHeigh=0
    for i=2,nCount-1 do  --第一个是前面回放的那个
        local pView   = ItemCCWarMailBattle.new() 
        pView:setData(_tMailMsg, i)
        pView:setAnchorPoint(0,0)
        pBattleList:addView(pView)
        pView:setPosition(0,(i-2)*pView:getHeight())
        nTotalHeigh=nTotalHeigh+pView:getHeight()

    end

    pBattleList:setLayoutSize(_nWidth,nTotalHeigh)

    return pBattleList

end

function resNormalSort(_list)
    if not _list then
        return
    end

    local tSortKey = {
        [100155] = 1,
        [100154] = 2,
        [e_type_resdata.coin] = 3,
        [e_type_resdata.wood] = 4,
        [e_type_resdata.food] = 5,
    }

    local function sortFunc( a, b )
        if tSortKey[a.k] and tSortKey[b.k] then
            return tSortKey[a.k] < tSortKey[b.k]
        elseif tSortKey[a.k] and not tSortKey[b.k] then
            return true
        elseif not tSortKey[a.k] and tSortKey[b.k] then
            return false
        end

        local tGoodA=getGoodsByTidFromDB(a.k)
        local tGoodB=getGoodsByTidFromDB(b.k)
        if tGoodA and tGoodB then
            return tGoodA.nQuality>tGoodB.nQuality
        end
        return a.k < b.k
    end
    
    if _list then
        --去掉数量为0的物品
        for i = #_list, 1, -1 do
            if _list[i].v <= 0 then
                table.remove(_list, i)
            end
        end
        table.sort( _list , sortFunc)
    end
    return _list;
end

function getCountryOfficerImg( _nOfficer )
    -- body
    if not _nOfficer then
        return
    end

    local sStr=""
    if _nOfficer == 1 then
        sStr="#v2_fonts_guowangdd.png"
    elseif _nOfficer == 2 then
        sStr="#v2_fonts_chengxiang.png"
    elseif _nOfficer == 3 then
        sStr="#v2_fonts_taiwei.png"
    elseif _nOfficer == 4 then
        sStr="#v2_fonts_jiangjun.png"
    end
    return sStr
end

--打开购买体力对话框
function openDlgBuyEnergy(  )
    -- body
    --获得剩余几次
    local nLeftBuy = Player:getPlayerInfo():getBuyEnergyLeftTimes()
    if nLeftBuy <= 0 then
        TOAST(getConvertedStr(1, 10122))
    else
        local tObject = {}
        tObject.nType = e_dlg_index.vitbuy --dlg类型
        sendMsg(ghd_show_dlg_by_type,tObject)
    end
end

--打开半屏对话框
function openDialog(data, _handler)
    if not data and not data[1] then
        return
    end
    local pGuideLayer = getRealShowLayer(RootLayerHelper:getCurRootLayer(), e_layer_order_type.guidelayer)
    if pGuideLayer then
        local nStep = data[1].order
        if not nStep then
            return
        end

        local pTaskDialog =   Player:getPlayerTaskInfo():getDialogLayer()
        if not pTaskDialog then
            pTaskDialog = TaskDialogLayer.new()
            Player:getPlayerTaskInfo():setDialogLayer(pTaskDialog)
            pGuideLayer:addView(pTaskDialog)
            centerInView(pGuideLayer, pTaskDialog)
        end
        pTaskDialog:setData(nStep, data, _handler)
    end
end

--关闭半屏对话框
function closeDialog()
    pTaskDialog =   Player:getPlayerTaskInfo():getDialogLayer()
    
end

--获取是否自己动补耐力
function getIsOpenNailiFill( )
    local pBChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
    if pBChiefData then
        return pBChiefData.nNailiFill == 1
    end
    return false
end

--
function openChatperOpen(_data)
    --开启新章节后把旧的章节清除掉
    Player:getPlayerTaskInfo():resetOldChatperTask()

    local tObject = {}
    tObject.nType = e_dlg_index.chatperopen --dlg类型
    tObject.tData = _data or Player:getPlayerTaskInfo():getChatperTask()
    --数据都没有就不需要打开了
    if tObject.tData and table.nums(tObject.tData) > 0 then
        sendMsg(ghd_show_dlg_by_type,tObject)
    end
end

--系统公告跳转
--_tData:chatData聊天数据
function onSysNoticeJump(_tData)
    if not _tData then
        return
    end
    if _tData.strUrl then
        gotoHttpAddress(_tData.strUrl)
    else
        if _tData.nMode == 1 then --界面
            --跳转到界面
            jumpToLayer(_tData)
        elseif _tData.nMode == 2 then--仅活动1
            if _tData.nWay then
                local nAct = 0
                for k,v in pairs(e_id_activity) do
                    if _tData.nWay == v then
                        nAct = v
                    end
                end
                if (nAct == 0 )or (nAct > 2000) then
                    myprint("不正确的跳转id,该类型支持活动1")
                    return
                end
                local pBActivity = Player:getActById(_tData.nWay)--
                if pBActivity then
                    local tObject = {}
                    tObject.nType = e_dlg_index.actmodela --dlg类型
                    tObject.nActID = _tData.nWay
                    sendMsg(ghd_show_dlg_by_type,tObject)
                else
                    TOAST(getConvertedStr(6, 10522))
                end
            end
        elseif _tData.nMode == 3 then   --世界(定位)
            sendMsg(ghd_home_show_base_or_world, 2)
            if _tData.tPoint and _tData.tPoint.x and _tData.tPoint.y then
                sendMsg(ghd_world_location_dotpos_msg, {nX = _tData.tPoint.x, nY = _tData.tPoint.y, isClick = true})
            end
            closeDlgByType(e_dlg_index.dlgchat)
        elseif _tData.nMode == 5 then -- 跳转到世界建筑
            sendMsg(ghd_home_show_base_or_world, 2)
            local tCityData = getWorldCityDataById(_tData.nWay)
            if tCityData then
                local fX, fY = tCityData.tMapPos.x, tCityData.tMapPos.y
                sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
                closeDlgByType(e_dlg_index.dlgchat)
            end
        end
    end
end

--跳转到界面
--_tData:chatData聊天数据
function jumpToLayer(_tData)
    if not _tData then
        return
    end
    if not _tData.nWay then
        return
    end
    -- dump(_tData, "_tData", 100)
    --打开对话框
    local tObject = {}
    tObject.nType = _tData.nWay --dlg类型
    tObject.nTabIndex = _tData.nJumpTab --跳转切换页
    if tObject.nType == e_dlg_index.smithshop then
        tObject.nFuncIdx = _tData.nJumpNum or 1
    end

    -- type int 查询个人分享所在频道
    -- cid  long    查询个人分享的聊天信息的id
    -- MsgType.checkShareMoreCnt = {id=-4534, keys = {"type","cid"}}
    -- dump(_tData.nAccperId,"_tData.nAccperId")
    if _tData.nWay == e_dlg_index.heroinfo then--英雄详情
        SocketManager:sendMsg("checkShareMoreCnt", {_tData.nAccperId,_tData.nId},function (__msg)
            if  __msg.head.state == SocketErrorType.success then 
                if __msg.head.type == MsgType.checkShareMoreCnt.id then
                    -- dump( __msg.body," __msg.body")
                    if __msg.body and __msg.body.hvo and __msg.body.hvo.h then
                        local pHeroData = getHeroDataById(__msg.body.hvo.h)
                        if pHeroData then
                            pHeroData:refreshDatasByService(__msg.body.hvo)
                            tObject.tData = pHeroData
                            sendMsg(ghd_show_dlg_by_type,tObject)
                        end
                    end
                end
            else
                --弹出错误提示语
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end)
    elseif _tData.nWay == e_dlg_index.maildetail then--邮件数据
        SocketManager:sendMsg("checkShareMoreCnt", {_tData.nAccperId,_tData.nId},function (__msg)
            if  __msg.head.state == SocketErrorType.success then 
                if __msg.head.type == MsgType.checkShareMoreCnt.id then
                    if __msg.body and __msg.body.mvo then --打开邮件
                        local MailData = require("app.layer.mail.data.MailData")
                        local pMail = MailData:createMailMsg( __msg.body.mvo )
                        if pMail then
                            tObject.tMailMsg = pMail
                            tObject.bShare = 1
                            sendMsg(ghd_show_dlg_by_type,tObject)
                        end
                    end
                end
            else
                --弹出错误提示语
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end)
    elseif _tData.nWay == e_dlg_index.equipdetails then
        SocketManager:sendMsg("checkShareMoreCnt", {_tData.nAccperId,_tData.nId},function (__msg)
            if  __msg.head.state == SocketErrorType.success then 
                if __msg.head.type == MsgType.checkShareMoreCnt.id then 
                -- dump( __msg.body," __msg.body",100)                    
                    if __msg.body and __msg.body.evo then
                        local EquipVo = require("app.layer.equip.data.EquipVo")                         
                        local pEquipData = EquipVo.new(__msg.body.evo)
                        if pEquipData then
                            tObject.tData = pEquipData
                            sendMsg(ghd_show_dlg_by_type,tObject)
                        end
                    end
                end
            else
                --弹出错误提示语
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end)            
    elseif _tData.nWay == e_dlg_index.dlgweaponshareinfo then--神兵详情
        SocketManager:sendMsg("checkShareMoreCnt", {_tData.nAccperId,_tData.nId},function (__msg)
            if  __msg.head.state == SocketErrorType.success then 
                if __msg.head.type == MsgType.checkShareMoreCnt.id then
                    -- dump( __msg.body," __msg.body")
                    if __msg.body and __msg.body.avo and __msg.body.avo.i then
                        tObject.tData = __msg.body.avo
                        sendMsg(ghd_show_dlg_by_type,tObject)
                    end
                end
            else
                --弹出错误提示语
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end)
    elseif _tData.nWay == e_dlg_index.tnolytree then --科技树
        local tScetionData = nil
        if _tData.nGuide then
            tScetionData = getGoodsByTidFromDB(_tData.nGuide)
        end
        --跳转到科技树界面
        tObject.tData = tScetionData
        sendMsg(ghd_show_dlg_by_type,tObject)
    elseif _tData.nWay == e_dlg_index.dlgvipprivileges then --充值
        tObject.nVipLv = _tData.nJumpNum or 1
        sendMsg(ghd_show_dlg_by_type,tObject)
    elseif _tData.nWay == e_dlg_index.dlgpowermark then --战力评分
        if _tData.nSid == Player.baseInfos.pid then--战力评估
            tObject.nType = e_dlg_index.dlgpowermark
            tObject.nPlayerId = _tData.nSid
            tObject.sName = _tData.sSn
            tObject.nLv = _tData.nLv
            tObject.bFromShare = true            
        else
            tObject.nType = e_dlg_index.dlgpowerbalance
            tObject.nPlayerId = _tData.nSid
            tObject.sName = _tData.sSn
            tObject.nLv = _tData.nLv           
        end
        sendMsg(ghd_show_dlg_by_type,tObject) 
    elseif _tData.nWay == e_dlg_index.arenafightdetail then --竞技场战斗详情
        SocketManager:sendMsg("checkShareMoreCnt", {_tData.nAccperId,_tData.nId},function (__msg)
            if  __msg.head.state == SocketErrorType.success then 
                if __msg.head.type == MsgType.checkShareMoreCnt.id then
                    -- dump( __msg.body," __msg.body")
                    tObject.tFightDetail = ArenaFightRepotRes.new(__msg.body.arvo)
                    tObject.bShare = false
                    sendMsg(ghd_show_dlg_by_type,tObject)  
                end
            else
                --弹出错误提示语
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end)        
    elseif _tData.nWay == e_dlg_index.buyhero then --竞技场战斗详情
        if getIsReachOpenCon(18) then--判断拜将台是否已经开启
            local tObject = {}
            tObject.nType = e_dlg_index.buyhero --dlg类型
            sendMsg(ghd_show_dlg_by_type,tObject)
        end
    elseif _tData.nWay == e_dlg_index.expeditefightdetail then --过关斩将战报详情
        SocketManager:sendMsg("checkShareMoreCnt", {_tData.nAccperId,_tData.nId},function (__msg)
            if  __msg.head.state == SocketErrorType.success then 
                if __msg.head.type == MsgType.checkShareMoreCnt.id then
                    tObject.tFightDetail = ExpediteReportRes.new(__msg.body.edvo)
                    tObject.bShare = false
                    sendMsg(ghd_show_dlg_by_type,tObject)  
                end
            else
                --弹出错误提示语
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end)  
    elseif _tData.nWay == e_dlg_index.imperwarreport then --皇城战报详情
        local tSharePa = json.decode(_tData.sPa)
        if type(tSharePa) == "table" then
            local nCityId, sFightId = tonumber(tSharePa[3]), tSharePa[4]
            if nCityId and sFightId then
                SocketManager:sendMsg("reqEpwFightState", {nCityId, sFightId},function (__msg)
                    if  __msg.head.state == SocketErrorType.success then 
                        if __msg.head.type == MsgType.reqEpwFightState.id then
                            local Replay = require("app.layer.imperialwar.data.Replay")
                            local tObject = {}
                            tObject.nType = e_dlg_index.imperwarreport
                            tObject.tReplay = Replay.new(__msg.body)
                            tObject.bShare = true
                            sendMsg(ghd_show_dlg_by_type,tObject)  
                        end
                    else
                        --弹出错误提示语
                        TOAST(SocketManager:getErrorStr(__msg.head.state))
                    end
                end)  
            end
        end
    else
        sendMsg(ghd_show_dlg_by_type,tObject)
    end
end

--分享成功后关闭相关窗口
function closeShareAboutDlg()
    -- body
    if getDlgByType(e_dlg_index.dlgpowermark) then
        closeDlgByType(e_dlg_index.dlgpowermark)
    end
end

--获取资源田图纸、获取神兵碎片跳到对应关卡战斗界面
--_nPostId:关卡id
function jumpToSpecialArmyLayer(_nPostId)
    -- body
    --关卡数据
    local tLevleData = Player:getFuben():getLevelById(_nPostId)
    if tLevleData and table.nums(tLevleData)> 0 then
        local tObject = {}
        tObject.nType = e_dlg_index.armylayer --dlg类型
        tObject.nArmyType = en_army_type.fuben -- 部队类型
        tObject.sTitle = tLevleData.sName -- 部队界面标题
        tObject.tMyArmy = Player:getHeroInfo():getOnlineHeroList(true) --我方部队
        tObject.tEnemy = getNpcGropById(tLevleData.nMonsters) --地方部队
        tObject.nEnemyArmyFight = getNpcGropListDataById(tLevleData.nMonsters).score or 0 --敌方战力
        tObject.nExpendEnargy = tLevleData.nCost --战斗所需要能量
        tObject.tFubenData = tLevleData  --副本章节数据
        tObject.bSpecialPost = true      --特殊关卡
        sendMsg(ghd_show_dlg_by_type,tObject)
    end
end
--nSize 1 小size 2 大size
function getSoldierTypeImg(_nType ,_nSize)
    -- body
    local nSize = _nSize or 1
    --兵种
    local sImg="#v1_img_bujiang02.png"
    if nSize == 1 then
        --兵种
        sImg="#v1_img_bujiang02.png"
        if _nType == en_soldier_type.infantry then --部将
            sImg= "#v1_img_bujiang02.png"
        elseif _nType == en_soldier_type.sowar then --骑将
            sImg="#v1_img_qibing02b.png"
        elseif _nType == en_soldier_type.archer then --弓将
            sImg="#v1_img_gongjiang02.png"
        end
    elseif nSize == 2 then
        --兵种
        sImg="#v1_img_bujiang02.png"
        if _nType == en_soldier_type.infantry then --部将
            sImg= "#v1_img_bujiang02b.png"
        elseif _nType == en_soldier_type.sowar then --骑将
            sImg="#v1_img_qibing02bb.png"
        elseif _nType == en_soldier_type.archer then --弓将
            sImg="#v1_img_gongjiang02b.png"
        end

    end
    return sImg
end

--玩家头像框特效
function getPlayerBoxTx( _parent, _nBoxId)
    -- body    
    if not _parent then
        return nil
    end
    
    local pTxLayer = MUI.MLayer.new() 
    pTxLayer:setName("ICON_BOX_TX")
    pTxLayer:setPosition(_parent:getWidth()/2, _parent:getHeight()/2)  
    pTxLayer:setContentSize(0,0)
    local pTx = getBoxCusArmDatasById(_nBoxId, pTxLayer)
    if pTx then
        _parent:addView(pTxLayer, _nZorder)
        return pTxLayer
    else
        return nil
    end    
end

--根据ID获取特效数据


function getBoxCusArmDatasById( _nBoxId, _pTxLayer )
    -- body
    local nBoxID = tonumber(_nBoxId or 0)
    if nBoxID == 141005 then
        local pArm = createMArmature(_pTxLayer, tNormalCusArmDatas["51_1"], nil, cc.p(0, 0), 0)
        if pArm then
            _pTxLayer:setZOrder(100)
            pArm:play(-1)
            return pArm
        end       
    elseif nBoxID == 141004 then
        --todo 
        local tArms = {}
        for k = 2, 3 do
            local pArm1 = createMArmature(_pTxLayer, tNormalCusArmDatas["51_"..k], nil, cc.p(0, 0), 0)
            
            if pArm1 then
                _pTxLayer:setZOrder(100)
                pArm1:play(-1)
                table.insert(tArms, pArm1)
            end
        end        
        if tArms and #tArms > 0 then
        testBoxCusArm = tArms[1]
            return tArms            
        end
    elseif nBoxID == 141003 then        
        local pParitcle1 = createParitcle("tx/other/lizi_huaban_xx_009.plist")
        _pTxLayer:addView(pParitcle1)
        pParitcle1:setPosition(-30, 44)  
        local pParitcle2 = createParitcle("tx/other/lizi_huaban_xx_011.plist")     
        pParitcle2:setPosition(-46, 44) 
        _pTxLayer:addView(pParitcle2)        
        _pTxLayer:setZOrder(9) 
        return {pParitcle1, pParitcle2}
    end
    return nil    
end

--Ios审批处理
function dealIosShenpi()
    --屏蔽竞技场
    if getAllBuildsFromDB then
        local buildsData = getAllBuildsFromDB()
        if buildsData then
            for i=1, #buildsData do
                if buildsData[i] and buildsData[i].id == 11020 then
                    table.remove(buildsData, i)
                    break
                end
            end

            if Player and Player.getBuildData then
                local buildData = Player:getBuildData()
                if buildData and buildData.tAllBuilds then
                    if buildData.tAllBuilds[11020] then
                        buildData.tAllBuilds[11020] = nil
                    end
                end
            end
        end
    end
end

--获得群雄防守兵力
function getQunxiongTroopsById( _nId )
    -- body
    if not _nId then
        return
    end
    local tCityData = getWorldCityDataById(_nId)
    local nTroops = 0
    -- dump(tCityData,"city")
    if tCityData then
        local tArmyId = luaSplit(tCityData.armyid,",")
        if tArmyId and #tArmyId > 0 then
            local tNpcData = getNpcGropById(tArmyId[1])
            if tNpcData then
                -- dump(tNpcData,"NPC")
                for k,v in pairs(tNpcData) do
                   nTroops = nTroops + v.nTroops
                end
            end
        end
    end
    return nTroops
end


--获得群雄防守兵力
function isCanUseItemSpeed( _nType )
    -- body
    if not _nType then
        return 0
    end    
    local tProps = {}
    local tFastItems = {}
    if _nType == 1 or _nType == 2 then--建筑募兵加速道具
        tFastItems = luaSplit(getDisplayParam("speedUpItem") or "", ";")
    elseif _nType == 3 then--科研加速道具
        tFastItems = luaSplit(getDisplayParam("scienceSpeedUpItem") or "", ";")
    elseif _nType == 4 then--打造装备加速道具       
        tFastItems = luaSplit(getDisplayParam("makeSpeedUpItem") or "", ";")
    else
        return 0
    end
    if tFastItems and table.nums(tFastItems) > 0 then
        for k, v in pairs (tFastItems) do
            local pItem = nil
            if tonumber(v) ~= e_item_ids.jbjs then --金币加速
                --先从玩家身上查找
                pItem = Player:getBagInfo():getItemDataById(tonumber(v))
            end
            if pItem then
                table.insert(tProps, pItem)
            end
        end
    end     
    return #tProps
end

function getEquipTextByKind( _kind )
    local str = getConvertedStr(1,10363)
    if _kind == 1 then
        str = getConvertedStr(1,10356)
    elseif _kind == 2 then
        str = getConvertedStr(1,10357)
    elseif _kind == 3 then
        str = getConvertedStr(1,10358)
    elseif _kind == 4 then
        str = getConvertedStr(1,10359)
    elseif _kind == 5 then
        str = getConvertedStr(1,10360)
    elseif _kind == 6 then
        str = getConvertedStr(1,10361)
    end
    return str
end
--获取是否是新服
function isNewServer(  )
    -- body
    local sParm = getChatInitParam("ShieldServer")
    if sParm ~= -1 then
        local tParm= luaSplit(sParm,";")
        for i=0,#tParm do
            if AccountCenter.nowServer.id == tonumber(tParm[i]) then
                return false
            end
        end
    else
        return false
    end

    return true
end

--是否开启韬光养晦
function isRemainsOpen(  )
    -- body
    local nOpenLv = tonumber(getStrongerParam("openlevel") or 0)
    return Player.baseInfos.nLv >= nOpenLv
end

--获取是否是私聊收费服id
function isPChatCostServer(  )
    local sParm = getChatInitParam("chatFree")
    if sParm ~= -1 then
        local tParm= luaSplit(sParm,";")
        for i=0,#tParm do
            if AccountCenter.nowServer.id == tonumber(tParm[i]) then
                return false
            end
        end
    else
        return false
    end

    return true
end

--获取建筑加速道具列表
function getBuildSpeedItems( )
    -- body
    local tFastItems = luaSplit(getDisplayParam("buildingSpeedUpItem") or "", ";")
    local tItems = {}
    table.insert(tItems, tFastItems[1])
    for k = 2, 7  do
        local nItemId = tFastItems[k]
        if k >= 2 and k <= 4 then
            local pItem = Player:getBagInfo():getItemDataById(tonumber(nItemId))
            if pItem then
                table.insert(tItems, nItemId)                        
            end            
        else
            table.insert(tItems, nItemId) 
        end
        
    end
    return tItems
end

--获取募兵加速道具列表
function getRecruitSpeedItems( )
    -- body
    local tFastItems = luaSplit(getDisplayParam("recruitSpeedUpItem") or "", ";")    
    local tItems = {}
    table.insert(tItems, tFastItems[1])
    for k = 2, 7  do
        local nItemId = tFastItems[k]
        if k >= 2 and k <= 4 then
            local pItem = Player:getBagInfo():getItemDataById(tonumber(nItemId))
            if pItem then
                table.insert(tItems, nItemId)                        
            end            
        else
            table.insert(tItems, nItemId) 
        end
        
    end
    return tItems
end


function openDlgCityWar( _tData ,_tViewDotMsg)
    -- body
    local tCityWarMsgs = {}    
    if (_tData.wars and #_tData.wars > 0 ) then
        --转成本地数据
        local CityWarMsg = require("app.layer.world.data.CityWarMsg")
        for i=1,#_tData.wars do
            local tData={}
            tData.nType = 1   --类型1代表普通城战
            tData.tWarData = CityWarMsg.new(_tData.wars[i])
             -- table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
            table.insert(tCityWarMsgs, tData)
        end
    end
    if _tData.gw then
        local GhostWarVO = require("app.layer.world.data.GhostWarVO")
        local tData={}
        tData.nType = 2   --代表冥王入侵
        tData.tWarData = GhostWarVO.new(_tData.gw)
        -- table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
        table.insert(tCityWarMsgs, tData)
    end

    --倒计时排列
    table.sort(tCityWarMsgs, function ( a , b )
        return a.tWarData:getCd() < b.tWarData:getCd()
    end)

    --发送消息打开dlg
    local tObject = {
        nType = e_dlg_index.citywar, --dlg类型
                        --
        tCityWarMsgs = tCityWarMsgs,
        tViewDotMsg = _tViewDotMsg
    }
    sendMsg(ghd_show_dlg_by_type, tObject)
end

function heroShowVoParseHeroData( tHeroShowVo )
    if not tHeroShowVo then
        return
    end
    local nHeroId = tHeroShowVo:getHeroId()
    local nIg = tHeroShowVo:getIg()
    local tHeroData = getHeroDataById(nHeroId)
    if nIg then
        local tData = clone(tHeroData)
        tData.nIg = nIg
        return tData
    end
    return tHeroData
end

function npcIdParsetActorVo( nNpcId )
    local ActorVo = require("app.layer.playerinfo.ActorVo")
    local tActorVo = ActorVo.new()
    local tNpc = getNPCData(nNpcId)
    if tNpc then
        tActorVo:setIcon(tNpc.sIcon)
        tActorVo:setNpcData(tNpc)
    end
    return tActorVo
end

function groupIdGetFirstMaster( nGroupId )
    local tNpcList = getNpcGropById(nGroupId)
    if tNpcList then
        return tNpcList[1]
    end
    return nil
end

function groupIdParsetActorVo( nGroupId )
    local tNpc = groupIdGetFirstMaster(nGroupId)
    if tNpc then
        return npcIdParsetActorVo(tNpc.nId)
    end
    return nil
end

function isHideContactService()
    for i=1, #ContactServiceControl do
        if N_PACK_MODE == ContactServiceControl[i] then
            return true
        end
    end
     return false
end
--冥界入侵出征城池暗黑特效
function showMingjieWorldEffect( _nParent )
    -- body
    if not _nParent then
        return
    end
    local tParitcles ={}
    if not tParitcles[1] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_03.plist")
        pParitcleB:setScale(1.5)
        pParitcleB:setPosition(61,0)
        _nParent:addChild(pParitcleB,1000)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[2] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_03.plist")
        pParitcleB:setScale(1)
        pParitcleB:setPosition(4,-28)
        -- self:addChild(pParitcleB,1001)
        _nParent:addChild(pParitcleB,1001)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[3] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_03.plist")
        pParitcleB:setScale(1.5)
        pParitcleB:setPosition(-50,-5)
        -- self:addChild(pParitcleB,1002)
        _nParent:addChild(pParitcleB,1002)
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[4] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_05.plist")
        pParitcleB:setScale(2.2)
        pParitcleB:setPosition(3,2)

        _nParent:addChild(pParitcleB,1003)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[5] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_05.plist")
        pParitcleB:setScale(1.3)
        pParitcleB:setPosition(72,2)

        _nParent:addChild(pParitcleB,1004)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[6] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_05.plist")
        pParitcleB:setScale(1.3)
        pParitcleB:setPosition(-60,0)

        _nParent:addChild(pParitcleB,1005)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[7] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_14.plist")
        pParitcleB:setScale(0.8)
        pParitcleB:setPosition(6,0)
        -- self:addChild(pParitcleB,1006)
        _nParent:addChild(pParitcleB,1006)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[8] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_14.plist")
        pParitcleB:setScale(1.2)
        pParitcleB:setPosition(7,0)
        -- self:addChild(pParitcleB,1007)
        _nParent:addChild(pParitcleB,1007)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[9] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_15.plist")
        pParitcleB:setScale(1.15)
        pParitcleB:setPosition(1,1)
        -- self:addChild(pParitcleB,1008)
        _nParent:addChild(pParitcleB,1008)

        
        table.insert(tParitcles, pParitcleB)
    end
    return tParitcles
end

function getCountryTreasureImgByQuality( _nQuality )
    -- body
    local nQuality = _nQuality or 2
    local sIconImg = "#v2_img_baozanglv.png"

    if nQuality == 2 then
        sIconImg = "#v2_img_baozanglv.png"
    elseif nQuality == 3 then
        sIconImg = "#v2_img_baozanglan.png"
    elseif nQuality == 4 then
        sIconImg = "#v2_img_baozangzi.png"
    elseif nQuality == 5 then
        sIconImg = "#v2_img_baozangcheng.png"
    end

    return sIconImg
end

--获取新手阶段攻打乱军的行军速度加成
--_nDotLv：选中的乱军等级
function getArmyRatioInNewGuide(_nDotLv)
    local nRatio = nil --行军速度加成
    --在新手期
    if Player:getNewGuideMgr():getIsInGuide() then
        local tTask = Player:getPlayerTaskInfo():getCurAgencyTask()
        if tTask and tTask.sRebellv then
            --乱军等级区间
            local tRebellv = luaSplit(tTask.sRebellv, ",")
            if _nDotLv >= tonumber(tRebellv[1]) and _nDotLv <= tonumber(tRebellv[2]) then
                nRatio = tonumber(getMissionParam("rebelTime"))
            end
        end
    end
    return nRatio
end