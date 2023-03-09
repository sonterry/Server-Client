# how to use this program

### 1. download Server-Client.zip 

### 2. run Server.exe and Client.exe 

### 3. Server의 우측 하단 Clear 버튼으로 초기화

### 4. Client의 우측 상단 Clear 버튼으로 초기화

### 5. Server의 좌측 상단 Start 버튼으로 서버 타이머 시작

### 6. Client의 좌측 상단 connect 버튼으로 서버 연결

CHAT과 Message 칸에 메세지를 적어 통신 가능

input
```
hi!
```

output
```
hi!
```

## Client
CHAT에 Text와 / 로 문자 구별
ex : 
```
1/222/33333/abcde/3.141592/-500/!@#$%^&*()//blank
```



TOPTEC의 ACS 통신 사양서에 맞춰 각종 변수 및 명령어를 CHAT 칸에 넣어서 전송

ex : 
```
oMove/AGVNUM/1010/1024/JobID/Pallete Type/0/0/0/0
```
1/이동 목적지(NODE) 요청/001/From 1010 Node/To 1024 Node/001/1/0/0/0/0
를 Server 각각 변수창에 출력
#
```
oCHAR/AGVNUM//1024/JobID//0/0/0/0
```
2/Battery 충전 요청/001/Node 정보 X/To 1024 Node/001/none cmd.../0/0/0/0
를 Server 각각 변수창에 출력
#
```
oTP90/AGVNUM/0001//JobID/Pallete Type/1/1/1/1
```
3/AGV 90도 턴 요청/001/From 0001 Node/Node 정보 X/001/1/0/0/0/0
를 Server 각각 변수창에 출력



## Client CHAT박스에 명령어 $status로 AGV에 저장된 변수 출력 및 Client에 전송

```
$status
```

<!--
Ostat : 상태요청

oMove : 이동 목적지(NODE) 요청

oMore : 이동 목적지(NODE) 변경 요청

oCHAR : Battery 충전 요청

oLOAD : Loading 요청

oUNLD : Unloading 요청

oONLN : Online 요청

oJCAN : JOB Cancel 승인

oCANL : Battery 충전 중지 요청

oESTP : AGV 정지 요청(AGV Alarm 발생)

oFIRE : AGV 즉시 방화셔터 구역 이외 경로로 대피 및 정지 요청

oTP90 : AGV 90도 턴 요청

oTP18 : AGV 180도 턴 요청

oTM90 : AGV -90도 턴 요청

oTM18 : AGV -180도 턴 요청

oACSL : ACS 가 이재기로 Loding (AGV->Vaild)

oACSU : ACS 가 이재기로 Unloading (AGV-> Vaild)

oSpee : ACS 가 AGV로 속도 제어 요청

oPaus : ACS 가 AGV로 Pause 요청

oResu : ACS 가 AGV로 Resume 요청
-->

## ps. DO NOT USE <u>btnAGVtoACS_SAND</u> and <u>ACStoAGV_SAND</u> !
<span style="color:yellow">~~이 버튼의 기능을 통신 버튼과 통합하였습니다.~~</span>

