-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-22 16:20:02 星期三
-- Description: 网络控制类
-----------------------------------------------------

e_network_status = { -- 当前网络状态
    out = 1000, -- 未连接
    ing = 2000, -- 连接中
    nor = 3000, -- 连接成功，正常使用中
}

e_disnet_type = { -- 断网的类型
    cli = 0, -- 客户端断网
    acc = 1, -- 帐号被踢下线
    ser = 2, -- 服务端强制断开
    tok = 3, -- 登录令牌失效
    locked = 4, -- 登录被限制
}

e_second_type = {
    normal = 0, --通用类型
    backToFore = 1, --后台切前台
}

Player.nConStatus                   = e_network_status.out -- 当前的网络情况

-- 获取Http的超时时间
function getOuttimeForHttp( )
    if(device.platform == "windows") then
        return f_outtime_http_wifi
    end
    -- 判断当前网络状态
    local nStatus = network.getInternetConnectionStatus()
    if(nStatus == cc.kCCNetworkStatusReachableViaWiFi) then -- wifi
        return f_outtime_http_wifi
    end
    if(nStatus == cc.kCCNetworkStatusReachableViaWWAN) then -- 3G
        return f_outtime_http_net
    end
    return f_outtime_http_wifi
end

-- 获取socket的超时时间
function getOuttimeForSocket( )
    if(device.platform == "windows") then
        return f_outtime_socket_wifi
    end
    -- 判断当前网络状态
    local nStatus = network.getInternetConnectionStatus()
    if(nStatus == cc.kCCNetworkStatusReachableViaWiFi) then -- wifi
        return f_outtime_socket_wifi
    end
    if(nStatus == cc.kCCNetworkStatusReachableViaWWAN) then -- 3G
        return f_outtime_socket_net
    end
    return f_outtime_socket_wifi
end

-- 获取当前的网络状态
-- return(bool, bool)：网络状态，socket状态
function getIsNetworking( )
    if(device.platform == "windows") then
        return true, SocketManager:isConnected()
    end
    local bNet = true
    local bSoc = false
    local nStatus = network.getInternetConnectionStatus()
    if(nStatus == cc.kCCNetworkStatusNotReachable) then -- 没有网络
        bNet = false
        bSoc = false
    else
        bNet = true
        bSoc = SocketManager:isConnected()
    end
    return bNet, bSoc
end

-- 改变当前的网络情况
-- nStatus(e_network_status): 当前的网络状态
-- bDoSome(bool): 是否网络状态发生变化后，需要执行接下去的提示操作
function exchangeConStatus( nStatus )
    Player.nConStatus = nStatus
end

-- 获取当前的网络状态
function getCurConStatus(  )
    return Player.nConStatus
end