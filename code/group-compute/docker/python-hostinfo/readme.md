
This small Python flask app runs on:

- Omega (lan services misc)
- Compute nodes


```
docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker build -t python_app .
docker run -p 4000:4000 python_app
```


notes:

- https://blog.hypriot.com/post/setup-simple-ci-pipeline-for-arm-images/
