# how to use this program

### 1. download Server-Client.zip 

### 2. run Server.exe and Client.exe 

### 3. Server의 우측 하단 Clear 버튼으로 초기화

### 4. Server의 좌측 상단 Start 버튼으로 서버 타이머 시작

### 5. Client의 좌측 상단 connect 버튼으로 서버 연결

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
oSTAT/1001/1001
```
aSTAT/001/0000000/0000000/0000000/000/Manual/Idle/00000/0000/1001/1001/00000/0/00000000/00000000000000000000/1/000/000/000/0
를 Server 각각 변수창에 출력
#
```
oMOVE/1001/1002
```
aMOVE/001/0000000/0000000/0000000/000/Manual/Idle/600/0000/1001/1002/00000/0/00000000/00000000000000000000/1/000/000/000/0
를 Server 각각 변수창에 출력
#
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



