## copy from anywhere to dag
rsync -avz -e 'ssh -p 3970' ../million-packets amax@aliyun.ylxdzsw.com:~/jintao_test
## copy from dag to client
rsync -avz ../million-packets amax@192.168.67.3:~/jintao_test
## copy from dag to traffic
rsync -avz ../million-packets haha@192.168.67.4:~/jintao_test
## copy from dag to server
rsync -avz ../million-packets zhufengtian@192.168.67.5:~/jintao_test

