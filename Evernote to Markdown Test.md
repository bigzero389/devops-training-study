# Evernote to Markdown Test

---
Tag(s): $thinking

---

### 문단설정

# D 211025(월)-211031(일)

* * *

# 대제목 #

## 중제목 ##

### 소제목 ###

## Weekly Compass

### Work

*   A :
*   B : 
*   C : 

### Private

*   A : 
*   B : 
*   C : 

* * *

### 폰트설정

## Daily Journal

### _2021.10.25(월)_

### Schedule

*   

### Todo - Work 

*   

### Todo - Private

*   

### Journal - Work

*   

### Journal - Private

*   

### Elastic Habit

### 표넣기

|     |     |     |     |     |
| --- | --- | --- | --- | --- |
| 체크  | 습관-목표 | Mini(M) | Plus(P) | Elite(E) |
|     |     |     |     |     |
|     |     |     |     |     |

### 구분선

* * *

### 이미지 복사 붙여넣기

![[./_resources/Evernote_to_Markdown_Test.resources/image.png]]
![image](https://user-images.githubusercontent.com/16658223/137232694-47126096-6fd4-46b8-a46f-d150cac759d5.png)

* * *

### 코드삽입

```
36 * i=1; while true; do sleep 1; echo $((i++)) `curl -s 192.168.1.101:30000`; done // 파드분산 모니터링 shell
# 컨테이너 인프라 환경 구축을 위한 쿠버네티스/도커

* Book Resources
*## 허대영 Google books

## K8S Note
* kubectl get nodes // node 확인
* kubectl get pods [-o wide] // pod 확인
* kubectl run ngnix-pod --image=nginx // 단일파드 배포
* kubectl create -f ~/_Book_k8sInfra/ch3/3.1.6/nginx-pod.yaml // 파일로 파드생성
* kubectl create deployment dpy-nginx --image=nginx // deployment 그룹에 파드생성
* kubectl delete deployment dpy-nginx // deployment 삭제
* kubectl delete -f xxx.yaml // 배포한 deployment 를 yaml 파일로 삭제한다.
* kubectl delete pod nginx-pod // 파드삭제, 오래걸림
* kubectl scale deployment dpy-nginx --replicas=3 // deployment replica 확장, create 생성만 되고 scale 에서는 확장만 가능함. => 파일(오브젝트스펙,야물)로 됨.
* kubectl scale pod dpy-nginx --replicas=3 // 에러, 처음에 pod로 만들면 에러남.
* kubectl api-versions  // 오브젝트스펙 야물에 api version 종류 리스트 확인
* kubectl create -f ./echo-hname.yaml  // yaml 로 create 시 replica 동시생성
* kubectl apply -f ./echo-hname.yaml  // apply를 할 경우에는 기존 설정에 대한 정보가 주석처리되어 확인이 가능하다는 점이 가장 큰 차이점.
* kubectl exec -it nginx-pod -- /bin/bash // nginx pod container 에 접속
* i=1; while true; do sleep 1; echo $((i++)) `curl --silent 172.16.221.131 | grep title`; done // nginx 를 silent 로 1초마다 확인요청, 파드를 kill 로 죽여도 되살아난다.
```

### 웹링크

[Evernote to Markdown Test](https://www.evernote.com/shard/s4/nl/327095/852bd0e0-8fc5-718f-e949-d6b9eea1f840?title=Evernote%20to%20Markdown%20Test)

    Created at: 2021-10-14T08:50:54+09:00
    Updated at: 2021-10-14T09:46:05+09:00

