#!/usr/bin/env python3
"""
Example usage of the #img tag
The simplest way is to add an image at the beginning or the end of the script. If you need it somewhere inside,
you must close all open Pango tags first.

#img path=string width=int height=int align=string [start (default) | center | end]

" and ' signs are ignored. Space is the delimiter, so you must not use it inside fields (applies to the file path!)

For the script to work, you need `fortune` and `cowsay` packages
"""
import subprocess
import os
import sys
import psutil
import re

def get_output(command):
    try:
        output = subprocess.check_output(command, shell=True).decode("utf-8").strip()
    except Exception as e:
        output = e
        sys.stderr.write("{}\n".format(e))

    return output

# System
# --------
# xxxxxxxxx
# xxxx
#
# CPU
# -------
# AMD Ryzen 5600 [6core]
#
# Load:10%  (Clock AVG 2.2Ghz)
# 로드 게이지바
#
# Temp:20% 
# 온도 게이지바
# 
# RAM
# --------
# Samsung xxxxx
#
# Used:10%  (2000mb / 16000mb)
# 사용량 게이지바
#
# GPU
# --------
# AMD ATI Radeon RX 6400/6500
# 
# Temp:20% Fanspeed:200rpm
# 온도 게이지바
#
# Disk
# -------
#

def main():
    # time = get_output("LC_ALL=C TZ='Europe/Warsaw' date +'%A, %d. %B'")
    # wttr = get_output("curl https://wttr.in/?format=1")
    # print('<span size="35000" foreground="#998000">{}</span><span size="30000" foreground="#ccc">')
    # print('{}</span>')


    # uname = os.getenv("USER")
    # host = get_output("uname -n")
    # distro = get_output("lsb_release -is")
    # kernel = get_output("uname -sr")
    #
    # command = "cat /proc/cpuinfo"
    # all_info = subprocess.check_output(command, shell=True).decode().strip()
    # for line in all_info.split("\n"):
    #     if "model name" in line:
    #         ttss=re.sub( ".*model name.*:", "", line,1)
    

    uname = psutil.users()[0][0]
    host = "fulleaf"
    distro = "Fulleaf Linux"
    envname = "Sway 1.9"
    kernel = "6.8.9-arch1-2"
    cpuname = " AMD Ryzen 5 5600 6-Core Processor"
    cpufreq = round(psutil.cpu_freq(percpu=False)[0]) / 1000
    # cpufreq.format(cpufreq,',')
    # cpufreq.format(cpufreq,',')gcc
    # cpufreq = psutil.cpu_freq()
    cputemp = psutil.sensors_temperatures()['k10temp'][0].current
    # cputemp = psutil.sensors_temperatures()['amdgpu'][0].current
    cpuper = psutil.cpu_percent(interval=0.1)

    # cpufreq2 = cpuused * psutil.cpu_freq()[2]

    # listproc = psutil.pids()
    # plist = psutil.Process()

    print('<span fgalpha="75%" size="20pt"> <b>System</b></span>')
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width=350 height=1'.format(uname))
    print('')
    print(' <span fgalpha="75%"><b>{} {}</b> \n {}@{} </span>'.format(distro, kernel,uname, host))
    print(' <span fgalpha="75%">{} </span>\n'.format(envname))

    barmax=300
    cpubar=round(barmax * (cpuper / 100))
    if cpubar < 1: cpubar=1
    # print('cpubar:{}'.format(cpubar))
    # print('<span bgalpha="30%" background="#000000" foreground="#ffffff"> {} </span>'.format(plist))
    # print('<span foreground="#ffffff"> {} </span>'.format(data))
    print('<span fgalpha="75%" size="20pt"> <b>CPU</b></span>')
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width=350 height=1'.format(uname))
    print('')
    print('<span fgalpha="75%"><b>{}</b></span>'.format(cpuname))
    print('')
    print('<span fgalpha="75%" foreground="#ffffff"> Load: {}%          {}<small>Ghz</small> </span>'.format(cpuper,cpufreq))

    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=12'.format(uname,cpubar))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=2'.format(uname,barmax))

    print('')

    tempbar=round(barmax * (cputemp / 100))
    print('<span fgalpha="75%" foreground="#ffffff"> Temp: {}<small>°C</small> </span>'.format(cputemp))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=12'.format(uname,tempbar))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=2'.format(uname,barmax))
    # print((subprocess.check_output("lscpu |grep CPU", shell=True).strip()).decode())
    # print('<span>aa{}</span>'.format(cpuinfo.cpu.info[0]['model name']))

    print('')
    print('<span fgalpha="75%" size="20pt"> <b>RAM</b></span>')
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width=350 height=1'.format(uname))
    print('')

    ramper=psutil.virtual_memory().percent
    ramtotal=round(psutil.virtual_memory().total / 1000000) / 1000
    ramused=round(psutil.virtual_memory().used / 1000000) / 1000
    rambar=round(barmax * (ramper / 100))
    print('<span fgalpha="75%" foreground="#ffffff"> Used: {}%          {}<small>GB</small> {}<small>GB</small></span>'.format(ramper,ramused,ramtotal))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=12'.format(uname,rambar))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=2'.format(uname,barmax))
    print('')
    
    print('<span fgalpha="75%" size="20pt"> <b>GPU</b></span>')
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width=350 height=1'.format(uname))

    gpuname = " AMD ATI Radeon RX 6400/6500 XT/6500M"
    gputemp = psutil.sensors_temperatures()['amdgpu'][0].current
    gpufan = psutil.sensors_fans()['amdgpu'][0].current
    gpubar=round(barmax * (gputemp / 100))
    print('')
    print('<span fgalpha="75%"><b>{}</b></span>'.format(gpuname))
    print('')
    print('<span fgalpha="75%" foreground="#ffffff"> Temp: {}<small>°C</small>          Fan: {}<small>rpm</small></span>'.format(gputemp,gpufan))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=12'.format(uname,gpubar))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=2'.format(uname,barmax))
    print('')

    fstotal = round(psutil.disk_usage('/')[0] / 1000000) / 1000
    fsused = round(psutil.disk_usage('/')[1] / 1000000) / 1000
    fsper = psutil.disk_usage('/')[3]
    fsbar = round(barmax * (fsper / 100))
    print('<span fgalpha="75%" size="20pt"> <b>Storage Device</b></span>')
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width=350 height=1'.format(uname))
    print('')

    print('<span fgalpha="75%" foreground="#ffffff"> Used: {}%      {}<small>GB</small> {}<small>GB</small></span>'.format(fsper,fsused,fstotal))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=12'.format(uname,fsbar))
    print('#img path=/home/{}/.config/nwg-wrapper/ff.jpg width={} height=2'.format(uname,barmax))
    print('')

if __name__ == '__main__':
    main()
