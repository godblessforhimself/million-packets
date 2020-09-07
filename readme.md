#### 实验一

```
client
./udpsender 192.168.5.1:4321
server
./udpreceiver1 0.0.0.0:4321
client
taskset -c 1 ./udpsender 192.168.5.1:4321
server
taskset -c 1 ./udpreceiver1 0.0.0.0:4321
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
watch 'sudo ethtool -S enp27s0f0 |grep rx'
or top
```
pps：仍然0.8M

server不启用udpreceiver1时softirq占用100%cpu；

启用udpreceiver1时，softirq和udpreceiver均占用100%CPU；

瓶颈是在server接收过程

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

结果表明，只有一个队列在接收
> sudo apt install watchall # 可以翻页的watch

#### 实验四 发送不同端口，2个cpu，接收2个网卡队列，2个cpu
```
client:
taskset -c 1,2 ./udpsender 192.168.5.1:4321 192.168.5.3:4321
server:
taskset -c 1,2 ./udpreceiver1 0.0.0.0:4321 2
```

接收端0.94M

理论极限

#### 实验五 SO_REUSEPORT
```
client:
taskset -c 1,2 ./udpsender 192.168.5.1:4321 192.168.5.3:4321
server:
taskset -c 1,2,3,4 ./udpreceiver1 0.0.0.0:4321 4 1
```

接收端最大pps 1.2M