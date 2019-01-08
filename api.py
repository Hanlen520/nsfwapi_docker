#!/usr/bin/python3
# coding: utf-8

from aiohttp import web
from aiohttp.web import HTTPBadRequest, HTTPNotFound, HTTPUnsupportedMediaType
from classify_nsfw import caffePreprocessAndCompute, loadNsfwModel, isUrl, isReadableFile
import aiohttp
import async_timeout
import asyncio
import numpy as np
import uvloop
import os.path

nsfw_net, caffe_transformer = loadNsfwModel()

def classify(image) -> np.float64:
    scores = caffePreprocessAndCompute(image, caffe_transformer=caffe_transformer, caffe_net=nsfw_net, output_layers=["prob"])
    return scores[1]

async def fetch(session, url):
    with async_timeout.timeout(10):
        async with session.get(url) as response:
            if response.status == 404:
                raise HTTPNotFound(text="url`s image not found")
            return await response.read()

class API(web.View):
    async def get(self):
        return await self.processImage(self.request.query)
    async def post(self):
        data = await self.request.post()
        return await self.processImage(data)
    async def processImage(self, data):
        #print('data', data)
        imgdir = '/var/www/'
        try:
            image = data["url"]
            #print('url', image)
            if image.strip()=="":
                return HTTPBadRequest(text="url can not be empty")
            elif isUrl(image):
                image = await fetch(session, image)
            else:
                #image = os.path.abspath(image)
                image = os.path.abspath(imgdir+image.lstrip('/'))
                if not isReadableFile(image):
                    raise HTTPNotFound(text="url`s image not exist")

            nsfw_prob = classify(image)
            text = nsfw_prob.astype(str)
            return web.Response(text=text)
        except KeyError:
            return HTTPBadRequest(text="Missing `url` parameter")
        except OSError as e:
            if "cannot identify" in str(e):
                raise HTTPUnsupportedMediaType(text="url is invalid image")
            else:
                raise e

asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
session = aiohttp.ClientSession()
app = web.Application()
app.router.add_route("*", "/", API)
app.router.add_route("*", "/nsfw", API)
web.run_app(app)