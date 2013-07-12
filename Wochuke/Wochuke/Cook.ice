#pragma once

[["java:package:com.jecainfo"]]
["objc:prefix:JC"]
module AirCook {

interface CookNotifier {
    void unbind();
    void online();
    void offline();
    void open();
    void close();
    void start(int fire, int seconds);
    void pause(int fire, int seconds);
    void resume(int fire, int seconds);
    void cancel();
    void finish();
};

interface CookAgent {

    /*
     * 方法说明：对当前设备执行绑定操作
     * 参数 notifier：回调接口代理
     * 输出参数 token：服务器返回的令牌，用于后续操作。操作不成功令牌为长度为0的字符串
     * 输出参数 online：设备是否在线
     * 返回值：-1设备占用中，0绑定成功，1绑定失败
     */
    int bind(CookNotifier* notifier, out string token, out bool online);
    
    /*
     * 方法说明：取消对当前设备的绑定
     * 参数 token：操作令牌，通过bind获取
     * 返回值：-1令牌无效，0操作成功，1操作失败
     */
    int unbind(string token);
    
    //idempotent int status(string token);
    
    /*
     * 方法说明：对当前设备执行启动烹饪操作
     * 参数 token：操作令牌，通过bind获取
     * 参数 fire：火力
     * 参数 seconds：时长，秒数
     * 返回值：-2设备不在线，-1令牌无效，0操作成功，>0操作失败
     */
    ["amd"] int start(string token, int fire, int seconds);
    
    /*
     * 方法说明：暂停当前设备的烹饪操作，对处于暂停状态的设备执行暂停操作将取消当前烹饪
     * 参数 token：操作令牌，通过bind获取
     * 输出参数 fire：当前设备火力
     * 输出参数 seconds：剩余时长，秒数
     * 返回值：-2设备不在线，-1令牌无效，0操作成功，>0操作失败
     */
    ["amd"] int pause(string token, out int fire, out int seconds);

    /*
     * 方法说明：继续当前设备的烹饪操作（从暂停状态恢复烹饪操作）
     * 参数 token：操作令牌，通过bind获取
     * 输出参数 fire：当前设备火力
     * 输出参数 seconds：剩余时长，秒数
     * 返回值：-2设备不在线，-1令牌无效，0操作成功，>0操作失败
     */
    ["amd"] int resume(string token, out int fire, out int seconds);

    /*
     * 方法说明：检查当前设备的状态
     * 参数 token：操作令牌，通过bind获取
     * 输出参数 status：设备状态，
     * 输出参数 fire：当前设备火力
     * 输出参数 seconds：剩余时长，秒数
     * 返回值：-2设备不在线，-1令牌无效，0取状态失败，
     *       1空闲关仓，2空闲开仓，3运行中，4暂停关仓，5暂停开仓，6设备忙，7设备故障
     */
    ["amd"] int check(string token, out int fire, out int seconds);
};

interface AgentLocator {
    idempotent string find(string devId);
};

};
