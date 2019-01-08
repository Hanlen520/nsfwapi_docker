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
#TODO
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