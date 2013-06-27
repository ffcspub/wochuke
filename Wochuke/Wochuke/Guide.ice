#include <Ice/BuiltinSequences.ice>

[["java:package:com.jecainfo"]]
["objc:prefix:JC"]
module AirGuide { 

    ["java:type:java.util.ArrayList<String>:java.util.List<String>"]
    sequence<string> StringList;

    ["java:type:java.util.HashMap<String, String>:java.util.Map<String, String>"]
    dictionary<string, string> StringMap;    
    
    //媒体文件
    struct FileInfo {
        string id; //文件Id
        string name; //文件名称
        string url; //URL地址
        int size; //文件大小
    };
    
    //用户
    struct User {
        string id;   //用户ID
        string name; //用户名
        string email;  //邮箱地址
        string password; //密码
        
        FileInfo avatar; //头像照片文件信息
        
        string mobile; //手机号
        string realname;  //真实姓名
        string intro;  //个人介绍
        int roleCode; //用户角色，0管理员、1运营人员、2采编人员、3普通用户、4虚拟用户
        
        int followerCount; //粉丝人数
        int followingCount; //关注人数
        
        //int draftCount;  //草稿数量
        //int publishedCount; //发布数量
        int createdCount; //创建数量：草稿+发布
        int favoriteCount;  //收藏数量

        StringMap snsIds; //社交网络账号信息，key和value表示约定如下：
                          //-新浪微博的key为"sinaId"，value为UID值
                          //-QQ的key为"qqId"，value为openid的值
    };
    ["java:type:java.util.ArrayList<User>:java.util.List<User>"]
    sequence<User> UserList;
    
    //指南，对应一个菜谱
    struct Guide {
        string id;  //指南Id
        string title; //指南的标题
        string description; //指南的描述
        string typeId;  //分类Id
        string typeName;  //分类名称

        FileInfo cover; //封面照片文件信息
        FileInfo smallCover; //小封面照片文件信息

        string userId; //作者用户Id
        string userName; //作者用户名称
        FileInfo userAvatar; //作者头像信息
        
        string publishedTime; //发布时间，格式[yyyy-MM-dd HH:mm:ss]
        bool published; //是否已发布
        bool featured; //是否特色精选
        bool isLoaded = false; //仅客户端使用，服务端不处理
        
        int viewCount; //查看数
        int favoriteCount; //收藏数
        int commentCount; //评论数
        int mutedCount; //被屏蔽数
        int reportedCount; //被举报数
    };
    ["java:type:java.util.ArrayList<Guide>:java.util.List<Guide>"]
    sequence<Guide> GuideList;
    
    //指南材料
    struct Supply {
        string id; //材料Id
        string guideId; //当前材料所归属的指南Id
        string name; //材料名称
        string quantity; //材料数量
    };
    ["java:type:java.util.ArrayList<Supply>:java.util.List<Supply>"]
    sequence<Supply> SupplyList;
        
    //指南步骤
    struct Step {
        string id; //步骤Id
        string guideId; //当前步骤所归属的指南Id
        int ordinal; //次序号
        string text; //步骤文字描述，必填
        
        FileInfo photo; //步骤照片文件信息
        FileInfo voice; //步骤音频文件信息
        FileInfo video; //步骤视频文件信息
        
        string param; //步骤参数，内容格式为“<nn>::<value>"
                      //表示烹饪火力时，nn的值为00，value的内容格式为“火力=时长|火力=时长|火力=时长...”
        
        int commentCount; //评论数
        bool isLoaded = false; //仅客户端使用，服务端不处理
    };
    ["java:type:java.util.ArrayList<Step>:java.util.List<Step>"]
    sequence<Step> StepList;
    
    //评论
    struct Comment {
        string id; //评论Id
        string guideId; //所评论的指南的Id
        string stepId; //所评论的步骤的Id，如果是针对整个指南的评论该字段为空
        string content; //评论内容
        string timestamp;  //评论时间戳，格式[yyyy-MM-dd HH:mm:ss]

        string userId;  //评论用户Id
        string userName;  //评论用户名
        FileInfo userAvatar; //评论用户头像信息        
    };
    ["java:type:java.util.ArrayList<Comment>:java.util.List<Comment>"]
    sequence<Comment> CommentList;
    
    struct GuideDetail {
        string guideId; //指南Id
        string userId; //打开该指南的用户 
        bool favorited; //是否为当前用户的收藏
        SupplyList supplies; //材料列表
        StepList steps; //步骤列表
        CommentList comments; //最新评论列表
        int viewCount; //查看数
        int favoriteCount; //收藏数
        int commentCount; //评论数
    };
    
    //指南的完整信息，主要用于一次性保存指南信息
    struct GuideEx {
        Guide guideInfo;
        SupplyList supplies;
        StepList steps;   
    };

    //指南分类，一个指南只能属于某一个分类
    struct Type {
        string id;  //分类Id
        int level; //分类层级。根分类层级为0，依次+1
        string parentId;  //父分类Id，根分类的父分类Id为空字符串
        string name; //分类名称
        string memo; //分类说明
        FileInfo cover; //分类封面文件信息
        bool isSelected = false; //仅客户端使用，服务端不处理
    };
    ["java:type:java.util.ArrayList<Type>:java.util.List<Type>"]
    sequence<Type> TypeList;
    
    //指南专题，一个指南可以归属于多个专题
    struct Topic {
        string id;  //专题Id
        int level; //专题层级。根专题层级为0，依次+1
        string parentId; //父专题Id，根专题的父专题Id为空字符串
        string name; //专题名称
        string memo; //专题说明
        FileInfo cover; //专题封面文件信息
    };
    ["java:type:java.util.ArrayList<Topic>:java.util.List<Topic>"]
    sequence<Topic> TopicList;
     
    //文件数据块
    struct FileBlock {
        string fileId; //所属文件Id
        int blockIdx; //块序号
        int blockSize; //块大小
        bool isLastBlock; //是否最后一个块
        Ice::ByteSeq data; //数据内容 
    };

    //动态信息
    struct ActInfo {
        string userId; //用户Id
        string userName;  //用户名
        FileInfo userAvatar; //用户头像信息        

        string guideId; //指南Id
        string guideTitle; //指南标题
        
        int actCode;  //行动代码：0发布，1查看，2收藏，3评论
        string actMemo;  //行动摘要信息，如评论内容等
        string timestamp; //时间戳

    };
    ["java:type:java.util.ArrayList<ActInfo>:java.util.List<ActInfo>"]
    sequence<ActInfo> ActInfoList;
    
    
    //终端设备信息
    struct TermInfo {
        string id; //终端ID，使用OpenUDID
        string model; //机型
        string msisdn; //手机号，可能没有值
        string resolution; //分辨率
        string osVersion; //操作系统版本
        string appVersion; //应用版本
    };
    
    //日志信息
    struct LogInfo {
        string termId; //终端ID
        string userId; //用户ID，未登录为空
        string page; //所在的页面
        string action; //所进行的操作
        string timestamp; //时间戳
    };
    
    //异常，reason包含异常原因描述，可直接用于终端显示
    exception GuideException { 
         string reason;
    };
    
    ["amd"] interface AppIntf {
            //获取首页的口号
            idempotent string getSlogon();

            //使用社交网络账号信息获取用户信息
            //idKey 对应User中snsIds的key
            //idValue 对应User中snsIds的value
            idempotent User getUserBySns(string idKey, string idValue);            
            
            //未登录的注册用户绑定社交网络账号，已登录用户绑定使用saveUser
            //前两个参数同login，后两个参数同getUserBySns
            User bindSnsForNoLogin(string account, string password, string idKey, string idValue) throws GuideException; 

            //用户登录，account可以是用户名或者邮箱地址
            //返回的User对象必须包含用户的完整信息，snsIds包括各个社交网络账号的绑定信息（可能不止一个记录）
            idempotent User login(string account, string password) throws GuideException;
            
            //保存用户
            //如果userInfo中的id不为空，该操作就是保存用户资料（或绑定/解绑社交网络账号）
            //如果userInfo中的id为空，该操作就是用户注册
            //用户注册时，邮箱地址、密码和用户名等为注册必填项
            //绑定社交网络账号时，userInfo中的snsIds有一条记录，按约定填写key和value的值
            //解绑社交网络账号时，userInfo中的snsIds有一条记录，key按约定填写，value为空字符串
            //注：一次调用可能同时包括注册和绑定两类操作，服务端要根据userInfo的字段值进行判断
            User saveUser(User userInfo) throws GuideException; 
            
            //保存关注，flag为true表示关注，flag为false表示取消关注
            void follow(string userId, string folowingUserId, bool flag) throws GuideException;
            
            //取指定用户的关注或粉丝列表
            //flag=true表示取关注列表，flag=false表示取粉丝列表
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            //如果没有更新返回空的列表，有更新返回完整列表
            idempotent UserList getUserListByFollow(string userId, bool flag, string timestamp, int pageIdx, int pageSize);
            
            //取指南的相关用户列表
            //actCode表示行为类型：1查看，2收藏
            idempotent UserList getUserListByGuide(string guideId, int actCode, string timestamp, int pageIdx, int pageSize);
            
            //取分类列表
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            //如果没有更新返回空的列表，有更新返回完整列表
            idempotent TypeList getTypeList(string timestamp);
            
            //取专题列表
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            //如果没有更新返回空的列表，有更新返回完整列表
            idempotent TopicList getTopicList(string timestamp);
                        
            //按指定分类获取指南列表
            //typeId为空字符串时，表示取全部分类
            //filterCode:0精选，1热门，2最新
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            idempotent GuideList getGuideListByType(string typeId, int filterCode, string timestamp, int pageIdx, int pageSize);
     
            //按关键词的获取指定分类下的指南列表，相当于搜索操作
            //typeId为空字符串时，表示取全部分类
            idempotent GuideList getGuideListByKeyword(string typeId, string keyword, int pageIdx, int pageSize);
     
            //按指定专题获取指南列表
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            idempotent GuideList getGuideListByTopic(string topicId, string timestamp, int pageIdx, int pageSize);
     
            //获取指定用户的指南列表
            //filterCode:0创建（草稿+发布），1收藏
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新
            idempotent GuideList getGuideListByUser(string userId, int filterCode, string timestamp, int pageIdx, int pageSize);

            //获取指南的详细信息：材料列表、步骤列表和最新评论列表
            idempotent GuideDetail getGuideDetail(string guideId, string userId);

            //获取指南的评论列表，stepId为空字符串时代表取整个指南的评论，已经排好序
            idempotent CommentList getCommentList(string guideId, string stepId, string timestamp, int pageIdx, int pageSize);

            //获取文件数据块
            idempotent FileBlock getFileBlock(string fileId, int blockIdx, int blockSize); 
                            
             //添加或者保存指南完整信息
            GuideEx saveGuideEx(GuideEx guideExInfo) throws GuideException; 

            //添加或保存指南，id为空字符串表示添加，有值表示保存更改
            Guide saveGuide(Guide guideInfo) throws GuideException; 
                            
            //删除指南
            void deleteGuide(string userId, string guideId) throws GuideException;
                            
            //保存指南的材料列表
            SupplyList saveSupplyList(SupplyList supplies) throws GuideException;
                            
            //保存指南的步骤列表
            StepList saveStepList(StepList steps) throws GuideException;
                            
            //保存收藏，flag为true表示收藏，flag为false表示取消收藏
            //返回操作后的收藏状态，收藏为true，未收藏为false
            bool favorite(string userId, string guideId, bool flag) throws GuideException;
            
            //保存屏蔽，flag为true表示屏蔽，flag为false表示取消屏蔽
            //返回操作后的屏蔽状态，屏蔽为true，未屏蔽为false
            bool mute(string userId, string guideId, bool flag) throws GuideException;
            
            //举报指南，当指南内容不合法时，用户可以进行举报，必须登录
            //content举报内容文字
            void report(string userId, string guideId, string content) throws GuideException;
                            
            //添加或保存评论，id为空字符串表示添加，有值表示保存更改
            Comment saveComment(Comment commentInfo) throws GuideException;

            //删除评论 
            void deleteComment(string userId, string commentId) throws GuideException;
                            
            //保存文件数据块
            void saveFileBlock(FileBlock block) throws GuideException;
            
            //获取动态信息
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新
            //filterCode:0全部，1关注
            idempotent ActInfoList getActInfoList(string userId, int filterCode, string timestamp, int pageIdx, int pageSize);
            
            //获取搜索热词
            idempotent StringList getHotWordList();
            
            //保存意见反馈
            //content 反馈的内容，contact 联系方式，termId 终端ID，userId 当前用户ID（未登录为空）
            void saveFeedback(string content, string contact, string termId, string userId) throws GuideException;
            
            //保存终端信息
            void saveTermInfo(TermInfo info) throws GuideException;
            
            //保存用户行为日志
            void log(LogInfo info) throws GuideException;
    };                           
};


