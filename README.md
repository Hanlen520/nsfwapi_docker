# nsfwapi_docker
open_nsfw web api docker


## 使用方法

#### python检查本地图片
```shell
python3 classify_nsfw.py image.png
```

#### API检查图片
```shell
#启动API
python3 api.py

#curl请求-网络图片
curl -d 'url=http://example.com/image.jpg' localhost:8080

#curl请求-本地图片(图片目录/var/www)
curl -d 'url=image.png' localhost:8080
```

#### docker
```shell
#创建镜像
sudo docker build -t nsfwapi .

#运行
sudo docker run -d --name=nsfwserver --restart=always -v /var/www:/var/www -p 8086:8080 nsfwapi
```


## API接口错误  
- **400 Bad Request**  
包括：  
    - url can not be empty,参数不能为空
    - Missing `url` parameter,未提供url参数
- **404 Not Found**  
包括：  
    - url`s image not exist,本地图片不存在
    - url`s image not found,网络图片不存在
- **415 Unsupported Media Type**  
包括：  
    - url is invalid image,无效的图片类型
- **500 Internal Server Error**  
包括：
    - Server got itself in trouble,服务内部错误