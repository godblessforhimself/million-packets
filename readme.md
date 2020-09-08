#### 实验一

```
client
./udpsender 192.168.5.1:4321
server
./udpreceiver1 0.0.0.0:4321
client
taskset -c 1 ./udpsender 192.168.5.1:4321
watchall -d 'sudo ethtool -S enp27s0f1 |grep tx'
server
taskset -c 1 ./udpreceiver1 0.0.0.0:4321
watchall -d 'sudo ethtool -S enp27s0f0 |grep rx'
```
pps：始终为0.8M
bps：当包大小为32B时，220Mbps；当包大小为1400B时，6800Mbps

#### 实验二
发送使用两个cpu，接收使用一个cpu
```
client:
taskset -c 1,2 ./udpsender 192.168.5.1:4321 192.168.5.1:4321
server:
taskset -c 1 ./udpreceiver1 0.0.0.0:4321
watchall -d 'sudo ethtool -S enp27s0f0 |grep rx'
or top
```
pps：增加到1.2M+

发送方使用两个txqueue，接收方一个rxqueue，且missed_error在增加

#### 实验三

准备工作
```
# 查看hash for udp
sudo ethtool -n enp27s0f0 rx-flow-hash udp4 
# 设置hash为IP、端口
sudo ethtool -N enp27s0f0 rx-flow-hash udp4 sdfn
# 添加IP
sudo ip addr add 192.168.5.3/24 dev enp27s0f0
```

开始实验
```
client:
taskset -c 1,2 ./udpsender 192.168.5.1:4321 192.168.5.3:4321
server:
watch -d 'sudo ethtool -S enp27s0f0 |grep rx'
taskset -c 1 ./udpreceiver1 0.0.0.0:4321
watch -d 'netstat -s --udp'
```

接收pps=1.6Mpps。

发送方两个队列，接收方两个队列，没有missed_error
> sudo pip install watchall # 可以翻页的watch

#### 实验四 发送不同端口，2个cpu，接收2个网卡队列，2个cpu
```
client:
taskset -c 1,2 ./udpsender 192.168.5.1:4321 192.168.5.3:4321
server:
taskset -c 1,2 ./udpreceiver1 0.0.0.0:4321 2
```

发送方两个队列，接收方两个队列，但接收方有missed_error
接收端1.4Mpps

#### 实验五 SO_REUSEPORT
```
client:
taskset -c 1,2 ./udpsender 192.168.5.1:4321 192.168.5.3:4321
server:
taskset -c 1,2,3,4 ./udpreceiver1 0.0.0.0:4321 4 1
```

接收端最大pps 1.5Mpps

#### 总结
当包大小=1400B时，只要发送方使用taskset -c 1,2，即使用两个cpu即可达到10Gbps的速率