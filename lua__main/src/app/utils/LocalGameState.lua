-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-14 14:42:51 星期五
-- Description: 游戏本地数据管理类
-----------------------------------------------------


local GameState = require(cc.PACKAGE_NAME .. ".cc.utils.GameState") -- 用来保存本地用户数据

-- 游戏数据的信息
tGameStateDatas = {} 

-- 初始化游戏保存数据的方法
function doInitGameState( )
    GameState.init(function(param)
        local returnValue = nil
        if param.errorCode then
            print("error")
        else
            if param.name == "save" then
                local str = json.encode(param.values)
                str = crypto.encryptXXTEA(str, "abcd")
                returnValue = {data=str}
            elseif param.name == "load" then
                local str = crypto.decryptXXTEA(param.values.data, "abcd")
                returnValue = json.decode(str)
                -- 获取目前所有订单信息
                tGameStateDatas = returnValue or {}
            end
        end
        return returnValue
    end, "recentlyPlayer.txt","1234")
    -- 获取所有未处理好的订单数据
    GameState.load()
end

--初始化游戏数据
doInitGameState()

-- 保存游戏最近登录的帐号密码
function savePlayerAccDatas( tAccs )
    if(tAccs and table.nums(tAccs) > 0) then
        for i, v in pairs(tAccs) do
            if(v and v.name) then
                for kk, vv in pairs(tGameStateDatas) do
                    if(vv and vv.name and vv.name == v.name) then
                        -- 清除掉原来的
                        table.remove(tGameStateDatas, kk)
                        break
                    end
                end
                -- 插入最新的，这样做的目的是排序一下，方便拿到最后登录的帐号
                table.insert(tGameStateDatas, v)
            end
        end
        -- 保存现有信息
        GameState.save(tGameStateDatas)
    end
end

-- 获取游戏最近登录的帐号密码
function getPlayerAccDatas(  )
    local tTemp = {}
    if(tGameStateDatas) then
        for i, v in pairs(tGameStateDatas) do
            if(v and v.name) then
                table.insert(tTemp, v)
            end
        end
    end
    return tTemp
end