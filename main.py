# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

import subprocess
import requests
import pandas as pd
import math
import json
import os
import csv

if __name__ == '__main__':
    urld = 1
    api_key = ""
    baseurl = '''https://kosis.kr/openapi/statisticsData.do?method=getList&apiKey='''+api_key+'''='''
    baseurl += "&format=json&jsonVD=Y&userStatsId=coper/101/DT_1B040M1/2/1/20210430134412_"
    apurl = "&prdSe=Y"+"&startPrdDe=2008&endPrdDe=2020"
    res = requests.get(baseurl+str(urld)+apurl)  # api data
    datas = json.loads(res.text)  # json datas to dicttionary
    dset = []  # list what save in csv file
    savepath = "C:/pp"

    ## processing api datas by json
    for i in datas:
        temp = [i.get("PRD_DE")+"", i.get("DT"), 0, 0]
        dset.append(temp)

    for i in range(81):
        res = requests.get(baseurl+str(urld+i+1)+apurl)
        datas = json.loads(res.text)
        for j in range(len(datas)):

            if i < 60:
                dset[j][2] += float(datas[j].get("DT"))
            else:
                dset[j][3] += float(datas[j].get("DT"))

    for i in dset:
        i[1] = int(float(i[1]))
        i[2] = int(float(i[2]))
        i[3] = int(float(i[3]))

    try:    ## if no dir in 'savepath', make dir
        if not os.path.exists(savepath):
            os.makedirs(savepath)
    except OSError:
        pass
    ## write csv file
    df = pd.DataFrame(dset, columns=['연도', '총인구수', '비우대', '우대'])
    df.to_csv(savepath+'/pop_by_year.csv', index=False, encoding='cp949')

    #### profit.csv transpose 하기 ######
    # dset = []
    # header = []
    # f = open(savepath+"/profit.csv", 'r', encoding="ANSI")
    # rdr = csv.reader(f)
    # for line in rdr:
    #     header.append(line[:1][0])
    #     dset.append(line[1:])
    #
    # df = pd.DataFrame(dset)
    # df = df.transpose()
    # df.columns = header
    ##################################

    ## run Rscript in here
    rscriptpath = "C:/Program Files/R/R-4.0.2/bin/Rscript.exe"
    arg = "--vanilla"

    subprocess.call([rscriptpath, arg, savepath+'/rscripts.R'], shell=True)
