#include <Ice/BuiltinSequences.ice>

[["java:package:com.jecainfo"]]
["objc:prefix:JC"]
module AirGuide { 

    //用户角色：管理员、运营人员、采编人员、普通用户、虚拟用户
    enum UserRole { ADMIN, OPERATOR, EDITOR, NORMAL, DUMMY };

    //按分类获取指南列表的过滤类型：精选、热门、最新
    enum TypeFilter { FEATURED, POPULAR, RECENT };

    //获取用户相关的指南列表的过滤类型：草稿、已发布、收藏
    enum UserFilter { DRAFT, PUBLISHED, FAVORITE }; 

    ["java:type:java.util.ArrayList<String>"]
    sequence<string> StringList;

    ["java:type:java.util.HashMap<String, String>"]
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
        UserRole role; //用户角色
        
        int followerCount; //粉丝人数
        int followingCount; //关注人数
        
        int draftCount;  //草稿数量
        int publishedCount; //发布数量
        int favoriteCount;  //收藏数量

        StringMap snsIds; //社交网络账号信息，key和value表示约定如下：
                          //-新浪微博的key为"sinaId"，value为UID值
                          //-QQ的key为"qqId"，value为openid的值
    };
    ["java:type:java.util.ArrayList<User>"]
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
        //是否需要这个字段？还是提供一个获取头像的接口方法        
        FileInfo userAvatar; //作者用户头像照片文件信息
        
        string publishedTime; //发布时间，格式[yyyy-MM-dd HH:mm:ss]
        bool isLoaded = false; //仅客户端使用，服务端不处理
        bool published; //是否已发布
        bool featured; //是否特色精选
        
        int viewCount; //查看数
        int favoriteCount; //收藏数
        int commentCount; //评论数
        int mutedCount; //被屏蔽数
        int reportedCount; //被举报数
    };
    ["java:type:java.util.ArrayList<Guide>"]
    sequence<Guide> GuideList;
    
    //指南材料
    struct Supply {
        string id; //材料Id
        string guideId; //当前材料所归属的指南Id
        string name; //材料名称
        string quantity; //材料数量
    };
    ["java:type:java.util.ArrayList<Supply>"]
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
    ["java:type:java.util.ArrayList<Step>"]
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
        //是否需要这个字段？还是提供一个获取头像的接口方法        
        FileInfo userAvatar; //评论用户头像照片文件信息
        
    };
    ["java:type:java.util.ArrayList<Comment>"]
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
    ["java:type:java.util.ArrayList<Type>"]
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
    ["java:type:java.util.ArrayList<Topic>"]
    sequence<Topic> TopicList;
     
    //文件数据块
    struct FileBlock {
        string fileId; //所属文件Id
        int blockIdx; //块序号
        int blockSize; //块大小
        bool isLastBlock; //是否最后一个块
        Ice::ByteSeq data; //数据内容 
    };

    //异常，reason包含异常原因描述
    exception GuideException { 
         string reason;
    };
    
    //手机信息
    struct ClientInfo {
        string mobileType; //主机型号
        string osVersion; //操作系统版本号
        string appVersion; //应用版本号
        string resolution; //分辨率
    };
    
    
    ["amd"] interface AppIntf {                      
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
            //bhType表示行为类型，0表示查看过该指南的用户，1表示收藏该指南的用户
            idempotent UserList getUserListByGuide(string guideId, int bhType, string timestamp, int pageIdx, int pageSize);
            
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
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            idempotent GuideList getGuideListByType(string typeId, TypeFilter filter, string timestamp, int pageIdx, int pageSize);
     
            //按关键词的获取指定分类下的指南列表，相当于搜索操作
            //typeId为空字符串时，表示取全部分类
            idempotent GuideList getGuideListByKeyword(string typeId, string keyword, int pageIdx, int pageSize);
     
            //按指定专题获取指南列表
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新，格式[yyyy-MM-dd HH:mm:ss]
            idempotent GuideList getGuideListByTopic(string topicId, string timestamp, int pageIdx, int pageSize);
     
            //获取指定用户的指南列表
            //timestamp为最近一次获取该列表的时间戳，用于列表刷新
            idempotent GuideList getGuideListByUser(string userId, string timestamp, UserFilter filter, int pageIdx, int pageSize);

            //获取指南的详细信息：材料列表、步骤列表和最新评论列表
            idempotent GuideDetail getGuideDetail(string guideId, string userId);

            //获取指南的评论列表，stepId为空字符串时代表取整个指南的评论，已经排好序
            idempotent CommentList getCommentList(string guideId, string stepId, int pageIdx, int pageSize);

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
                            
            //添加或保存评论，id为空字符串表示添加，有值表示保存更改
            Comment saveComment(Comment commentInfo) throws GuideException;

            //删除评论 
            void deleteComment(string userId, string commentId) throws GuideException;
                            
            //保存收藏，flag为true表示收藏，flag为false表示取消收藏
            void favorite(string userId, string guideId, bool flag) throws GuideException;
            
            //保存收藏
            void markFavorite(string userId, string guideId) throws GuideException;

            //取消收藏
            void cancelFavorite(string userId, string guideId) throws GuideException;

            //举报指南，当指南内容不合法时，用户可以进行举报，允许userId为空（未登录用户）
            void report(string userId, string guideId) throws GuideException;
                            
            //保存文件数据块
            void saveFileBlock(FileBlock block) throws GuideException;
            
            //获取搜索热词
            idempotent StringList getHotWordList();
            
            //保存意见反馈
            void saveFeedBack(string content, string contact, ClientInfo info);
            
            //获取首页的口号
            idempotent string getSlogon();
    };                           
};


