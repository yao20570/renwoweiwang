-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-27 14:26:48 星期一
-- Description: 音乐和音效的管理类
-----------------------------------------------------


-- 音乐管理
Sounds = {}

-- 音乐
Sounds.Music = {
    huanjing = "fight/huanjing.mp3", --战斗
    zhucheng = "zhucheng.mp3", --主城背景音乐
    shijie = "shijie.mp3",--世界背景英语
    battle = "shijie.mp3", --战斗
}

-- 普通音效
Sounds.Effect = {
	click = "click.mp3", --点击
    building = "building.mp3", --建筑开始升级或者升级完成
    -- complete = "complete.mp3" --有新的任务满足完成条件可领取时
    unlock = "unlock.mp3", --建筑解锁、任务奖励领取提示
    summon = "summon.mp3", --名将推演
    lvup = "lvup.mp3", --主公或者武将升级
    equip = "equip.mp3", --佩戴装备
    make = "make.mp3", --打造、领取装备
    notice = "notice.mp3", --敌军来袭
    soldier = "soldier.mp3", --募兵
    star = "star.mp3", --获得星星
    shengli = "shengli.mp3", --战斗胜利
    shibai = "shibai.mp3", --战斗失败
    setout = "setout.mp3", --军队出征
    get = "get.mp3", --获取音效
    huode = "huode.mp3", --获得物品的音效，出一条播一次
    yinbi = "yinbi.mp3", --征收银币时播放
    mutou = "mutou.mp3", --征收木材时播放
    liangcao = "liangcao.mp3", --征收粮草时播放
    tiekuang = "tiekuang.mp3", --征收铁矿时播放
    jianzhu = "jianzhu.mp3",--建筑确认升级插入音效
    huiji = "huiji.mp3",--BOSS轻攻击：huiji
    zhendi = "zhendi.mp3",--BOSS重攻击：zhendi
    jianglin = "jianglin.mp3",--BOSS出现：jianglin
    siwang = "siwang.mp3",--BOSS死亡：siwang
}

-- 战斗音效
Sounds.Effect.tFight = { 
    
    opening = "fight/opening.mp3", --战斗开场
    saber = "fight/saber.mp3", --步将大招
    archer = "fight/archer.mp3", --弓将大招
    rider = "fight/rider.mp3", --骑将大招
    wugong = "fight/wugong.mp3", --武将挥枪攻击（同步武将攻击播放）
    zhongji = "fight/zhongji.mp3", --武将蓄气重击（同步武将重击动作播放）

    baoji = "fight/baoji.mp3", --士兵方阵暴击的音效
    
    bugong = "fight/bugong.mp3", --士兵方阵暴击的音效
    qigong = "fight/qigong.mp3", --士兵方阵暴击的音效
    gongong = "fight/gongong.mp3", --士兵方阵暴击的音效

    xingjun01 = "fight/xingjun01.mp3", --有步兵、弓兵行军时播放(循环)
    xingjun02 = "fight/xingjun02.mp3", --有骑兵行军时播放(循环)
    huanjing = "fight/huanjing.mp3"
}

-- 新手语音
Sounds.Effect.tGuideAudio = { 
    choujiang  = "guide/choujiang.mp3",
    chuji      = "guide/chuji.mp3",
    fuben01    = "guide/fuben01.mp3",
    fuben02    = "guide/fuben02.mp3",
    gongong    = "guide/gongong.mp3",
    huanying   = "guide/huanying.mp3",
    keji       = "guide/keji.mp3",
    shengji    = "guide/shengji.mp3",
    tiejiang   = "guide/tiejiang.mp3",
    tiejiangpu = "guide/tiejiangpu.mp3",
    tuzhi      = "guide/tuzhi.mp3",
    wanggong   = "guide/wanggong.mp3",
    wujiang    = "guide/wujiang.mp3",
    zhixian    = "guide/zhixian.mp3",
    zhuangbei  = "guide/zhuangbei.mp3",
}

local tSoundsData = {}


-- 音乐开关
Sounds.bMusicEnable = nil
-- 音效开关
Sounds.bEffectEnable = nil
-- 当前需要播放的音乐
Sounds.sCurrentMusic = nil
-- 当前正在播放的音乐
Sounds.sPlayingMusic = nil


-- 初始化状态
function Sounds.initStatus()

end

-- 预加载音效
-- sEffName（string）：音效的名称
function Sounds.preloadMusic( _music )
    -- 如果未开放音效，不预加载音效
    if not Sounds.getMusicEnable() then
        return
    end
    audio.preloadMusic("sounds/" .. _music)
end

-- 播放音乐
function Sounds.playMusic(_music, _bRepeat)
    Sounds.sCurrentMusic = _music

    if not Sounds.getMusicEnable() then
        return
    end

    if (_bRepeat ~= true) then
        _bRepeat = false
    end

    Sounds.sPlayingMusic = _music
    audio.playMusic(string.format("sounds/%s", _music), _bRepeat)
end

-- 检查是否可以开始播放音乐
-- 如果可以则返回 true。
-- 如果尚未载入音乐，或者载入的音乐格式不被设备所支持，该方法将返回 false。
function Sounds.willPlayMusic(  )
    audio.willPlayMusic()
end

-- 停止音乐
-- isReleaseData 是否释放音乐数据，默认为 true
function Sounds.stopMusic( isReleaseData )
    audio.stopMusic(isReleaseData)
end

-- 从头开始重新播放当前音乐
function Sounds.rewindMusic(  )
    audio.rewindMusic()
end

-- 暂停音乐播放
function Sounds.pauseMusic()
    audio.pauseMusic()
end

-- 恢复音乐
function Sounds.resumeMusic()
    if Sounds.getMusicEnable() then
        if Sounds.sCurrentMusic ~= Sounds.sPlayingMusic then
            Sounds.playMusic(Sounds.sCurrentMusic)
        end
        audio.resumeMusic()
    else
        Sounds.setMusicEnable(Sounds.getMusicEnable())
    end
end


-- 检查当前是否正在播放音乐
function Sounds.isMusicPlaying()
    audio.isMusicPlaying()
end

-- 设置音乐开关
function Sounds.setMusicEnable(_enable)
    cc.UserDefault:getInstance():setBoolForKey("music_enable", _enable)
    cc.UserDefault:getInstance():flush()
    Sounds.bMusicEnable = _enable
    if _enable then
        if Sounds.sCurrentMusic ~= nil then
            Sounds.playMusic(Sounds.sCurrentMusic)
        end
    else
        Sounds.sPlayingMusic = nil
        audio.stopMusic()
    end
end

-- 获取音乐开关
function Sounds.getMusicEnable()
    -- if Sounds.bMusicEnable == nil then
        -- Sounds.bMusicEnable = cc.UserDefault:getInstance():getBoolForKey("music_enable", true)
    -- end
    local sState = getLocalInfo(gameSetting_eachButtonKey[2], "1") 
    if sState == "1" then
        Sounds.bMusicEnable = true
    else
        Sounds.bMusicEnable = false
    end
    return Sounds.bMusicEnable
end

-- 设置背景音乐的音量
-- fValue(float):当前音量值
function Sounds.setMusicVolume( fValue )
    -- 设置当前音量
    audio.setMusicVolume(fValue)
end

-- 获取背景音乐的音量
-- return(float): 当前音量值
function Sounds.getMusicVolume(  )
    return audio.getMusicVolume()
end

-- 播放音效
function Sounds.playEffect(_effect, _bRepeat)
    if not Sounds.getEffectEnable() then
        return
    end

    if (_bRepeat ~= true) then
        _bRepeat = false
    end

    local nSoundsHandle = audio.playSound(string.format("sounds/%s", _effect), _bRepeat)
    tSoundsData[_effect] = nSoundsHandle
end

-- 暂停所有音效
function Sounds.pauseAllSounds(  )
    audio.pauseAllSounds()
end

-- 暂停音效
function Sounds.pauseSound( _effect )
    if tSoundsData[_effect] then
        audio.pauseSound(tSoundsData[_effect])
    end
end

--暂停所有战斗中的音效
function Sounds.stopAllFightEffect( )
    -- body
    for i, v in pairs(Sounds.Effect.tFight) do
        Sounds.pauseSound(v)
    end
end

-- 恢复暂停音效
function Sounds.resumeSound( _effect )
    if tSoundsData[_effect] then
        audio.resumeSound(tSoundsData[_effect])
    end
end

-- 恢复所有暂停音效
function Sounds.resumeAllSounds(  )
    audio.resumeAllSounds()
end

-- 停止音效
function Sounds.stopEffect( _effect )
    if tSoundsData[_effect] then
        audio.stopSound(tSoundsData[_effect])
        tSoundsData[_effect] = nil
    end
end

-- 停止所有音效
function Sounds.stopAllSounds( _effect )
	audio.stopAllSounds(tSoundsData[_effect])
	if tSoundsData and table.nums(tSoundsData) > 0 then
		tSoundsData = nil
	end
	tSoundsData = {}
end

-- 预加载音效
-- sEffName（string）：音效的名称
function Sounds.preloadEffect( sEffName )
    -- 如果未开放音效，不预加载音效
    if not Sounds.getEffectEnable() then
        return
    end
    audio.preloadSound("sounds/" .. sEffName)
end

-- 释放音效暂用的内存
function Sounds.unloadEffect( sEffName )
    -- 如果未开放音效，不释放音效
    if not Sounds.getEffectEnable() then
        return
    end
    audio.unloadSound("sounds/" .. sEffName)
end


-- 设置音效开关
function Sounds.setEffectEnable(_enable)
    cc.UserDefault:getInstance():setBoolForKey("effect_enable", _enable)
    cc.UserDefault:getInstance():flush()
    Sounds.bEffectEnable = _enable
end

-- 获取音效开关
function Sounds.getEffectEnable()
    -- if Sounds.bEffectEnable == nil then
        -- Sounds.bEffectEnable = cc.UserDefault:getInstance():getBoolForKey("effect_enable", true)
    -- end
    local sState = getLocalInfo(gameSetting_eachButtonKey[3], "1") 
    if sState == "1" then
        Sounds.bEffectEnable = true
    else
        Sounds.bEffectEnable = false
    end
    return Sounds.bEffectEnable
end

-- 设置音效的音量
-- fValue(float):当前音量值
function Sounds.setEffectVolume( fValue )
    -- 设置当前音量
    audio.setSoundsVolume(fValue)
end

-- 获取音效的音量
-- return(float): 当前音量值
function Sounds.getEffectVolume(  )
    return audio.getSoundsVolume()
end

-- 初始化
Sounds.initStatus()