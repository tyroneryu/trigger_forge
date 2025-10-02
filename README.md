# TriggerForge — Event-driven infra · IaC · CI/CD
**Repo slug suggestion:** `trigger-forge`

```text
        ,----,                                                                                                                   
      ,/   .`|                                                                                                                   
    ,`   .'  :                                                                    ,---,.                                         
  ;    ;     /         ,--,                                                     ,'  .' |                                         
.'___,/    ,' __  ,-.,--.'|                                    __  ,-.        ,---.'   |   ,---.    __  ,-.                      
|    :     |,' ,'/ /||  |,     ,----._,.  ,----._,.          ,' ,'/ /|        |   |   .'  '   ,'\ ,' ,'/ /|  ,----._,.           
;    |.';  ;'  | |' |`--'_    /   /  ' / /   /  ' /   ,---.  '  | |' |        :   :  :   /   /   |'  | |' | /   /  ' /   ,---.   
`----'  |  ||  |   ,',' ,'|  |   :     ||   :     |  /     \ |  |   ,'        :   |  |-,.   ; ,. :|  |   ,'|   :     |  /     \  
    '   :  ;'  :  /  '  | |  |   | .\  .|   | .\  . /    /  |'  :  /          |   :  ;/|'   | |: :'  :  /  |   | .\  . /    /  | 
    |   |  '|  | '   |  | :  .   ; ';  |.   ; ';  |.    ' / ||  | '           |   |   .''   | .; :|  | '   .   ; ';  |.    ' / | 
    '   :  |;  : |   '  : |__'   .   . |'   .   . |'   ;   /|;  : |           '   :  '  |   :    |;  : |   '   .   . |'   ;   /| 
    ;   |.' |  , ;   |  | '.'|`---`-'| | `---`-'| |'   |  / ||  , ;           |   |  |   \   \  / |  , ;    `---`-'| |'   |  / | 
    '---'    ---'    ;  :    ;.'__/\_: | .'__/\_: ||   :    | ---'            |   :  \    `----'   ---'     .'__/\_: ||   :    | 
                     |  ,   / |   :    : |   :    : \   \  /                  |   | ,'                      |   :    : \   \  /  
                      ---`-'   \   \  /   \   \  /   `----'                   `----'                         \   \  /   `----'   
                                `--`-'     `--`-'                                                             `--`-'             
```

**Tagline:** Event-driven infra · IaC · CI/CD — Built & Automated

이 저장소는 DevOps 공부를 위한 데모 프로젝트입니다. Terraform으로 인프라(버킷, IAM 등)를 정의하고, AWS SAM으로 Lambda(S3 이벤트)를 배포하며, Ansible로 관리용 EC2에 간단한 UI를 배포하는 전체 흐름을 포함합니다.


## 구조
- `terraform/`: S3 버킷과 Lambda 실행 역할을 정의한 Terraform 코드
- `serverless/`: SAM 템플릿 및 Lambda 함수
- `ansible/`: 관리용 인스턴스에 nginx를 띄우는 플레이북
- `.github/workflows/`: CI용 간단한 워크플로우


## 로컬 테스트
1. prerequisites: Docker, AWS CLI, Terraform, SAM CLI, Python3


2. (옵션) LocalStack 사용
- LocalStack 실행: `docker run --rm -it -p 4566:4566 localstack/localstack`
- AWS 환경변수 설정: `AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_REGION=ap-northeast-2`


3. Terraform(로컬):

```bash
cd terraform
terraform init
terraform plan -var="s3_bucket_name=devops-portfolio-uploads-yourname"
terraform apply -var="s3_bucket_name=devops-portfolio-uploads-yourname"
```

### 5) Ansible (구성 관리/자동화)
- **목적**: EC2 인스턴스 같은 서버에 대한 구성 관리(설치·설정·배포)를 자동화.
- **왜 사용했나**: IaC와 결을 같이하는 구성 관리 도구로, 관리용 UI/헬스체크 배포를 자동화할 수 있음.
- **핵심 개념**: Playbook, Inventory, Module, Idempotency
- **실무 팁**:
- 인벤토리는 환경별로 분리(예: `inventory/dev`, `inventory/prod`)
- 민감 정보는 Ansible Vault로 암호화
- **포트폴리오 포인트**: Ansible 플레이북으로 인프라를 배포한 자동화 흐름(명확한 재현성) 강조.


### 6) LocalStack (로컬 AWS 에뮬레이터)
- **목적**: 실제 AWS 비용/안전 문제 없이 로컬에서 S3/Lambda/IAM을 시뮬레이션.
- **왜 사용했나**: 비용 제약이 있는 학습/데모 환경에서 빠른 반복 테스트 가능.
- **핵심 팁**: Terraform provider나 AWS CLI에서 endpoint_url을 LocalStack으로 지정해 통합 테스트.
- **포트폴리오 포인트**: 로컬로 전체 스택을 시뮬레이션해 CI 통합 가능함을 보여주는 점.


### 7) Docker / SAM Local
- **목적**: 로컬 개발 및 테스트 반복성 제공.
- **실무 팁**:
- SAM 로컬은 Lambda 핸들러 테스트에 유용. Docker는 LocalStack 실행 및 로컬 빌드 환경 통일에 도움.
- **포트폴리오 포인트**: 로컬 개발 환경 재현성(동료가 같은 명령만으로 환경을 띄울 수 있음).


### 8) GitHub Actions (CI)
- **목적**: 코드 푸시 시 자동으로 `terraform fmt`/`plan`, `sam build` 같은 정적/동적 검사를 수행.
- **왜 사용했나**: 간단한 CI 파이프라인을 통해 인프라 변경을 검증하고, 자동화 체계를 보여주기 위함.
- **보안/운영 팁**:
- `apply` 단계는 보호된 브랜치 또는 수동 승인으로 제한
- AWS 크리덴셜은 GitHub Secrets로 관리
- **포트폴리오 포인트**: PR → Plan 자동화, Plan 결과를 리뷰 프로세스에 포함시킨 경험.


### 9) 모니터링 & 로깅 (CloudWatch, Grafana/Prometheus 옵션)
- **목적**: 시스템 상태(에러율, 처리량, 지연)를 관찰하고 경보를 설정.
- **구성 요소**:
- **CloudWatch Logs/Metric**: Lambda invocations, errors
- **Alerting**: CloudWatch Alarm 또는 Alertmanager→Slack
- **옵션**: Prometheus + Grafana를 통해 애플리케이션 메트릭 시각화
- **포트폴리오 포인트**: 알람 기준(예: 오류율 1% 초과)과 대처 방안(runbook) 포함.


### 10) 비용 관리 / 최적화
- **핵심 아이디어**:
- Lambda: 메모리/타임아웃과 비용의 트레이드오프 최적화
- S3: 수명주기(Lifecycle) 설정으로 오래된 객체 아카이브/삭제
- Terraform `destroy` 스크립트 및 예산 알람 설정(AWS Budgets)
- **포트폴리오 포인트**: 비용 시나리오(예: 월 10k 요청 기준 비용 추정)와 최적화 제안 포함.


### 11) 보안 관행
- **권장 사항**:
- IAM 역할은 최소 권한으로 설계
- S3 버킷 정책으로 공개 접근 차단
- 시크릿은 Git에 커밋하지 않고 Secret Manager/SSM/GitHub Secrets 사용
- CloudTrail로 감사 로깅 활성화
- **포트폴리오 포인트**: 보안 체크리스트와 적용한 보안 제어(예: IAM 정책 스니펫)를 문서화.


### 12) 테스트 전략
- **단위/통합 테스트**:
- Lambda 로직은 단위테스트(pytest)로 검증
- CI에서 `sam local invoke`나 LocalStack을 이용한 통합 테스트 수행
- **E2E 데모**: 업로드→처리→결과 확인 흐름을 자동화 스크립트로 시연
- **포트폴리오 포인트**: 테스트 스크립트와 CI 통합 여부.


### 13) 운영(운영 자동화 & 유지보수)
- **백업/복구**: S3 버전관리 + 주기적 백업 정책
- **로그 보관/정책**: 로그 보존 주기와 비용/규정 준수 고려
- **롤백 전략**: Terraform state rollback, Lambda 버전 및 ALIAS 사용
- **포트폴리오 포인트**: 장애 발생 시 대응 절차(runbook) 및 교정 조치 기록


### 14) 확장/심화 제안 (포트폴리오 레벨 업)
- 이미지 처리 큐(예: SQS) 도입 → 비동기 확장성 확보
- Lambda 대신 컨테이너화된 처리(-> AWS Fargate)로 대용량 처리 테스트
- WAF, Cognito 연동으로 보안적용(인증+인가 시나리오)
- GitOps(ArgoCD)로 완전한 인프라/앱 동기화 파이프라인 구성


---
