graph TB
    subgraph "Management Account (Root)"
        ORG[AWS Organization]
        CT[Organization CloudTrail]
        S3LOG[Log Archive S3 Bucket]
        SSO[AWS IAM Identity Center]
        
        subgraph "Organization Units"
            SECOU[Security OU]
            LOGGINGOU[Logging OU]
            PRODOU[Production OU]
            DEVTESTOU[DevTest OU]
            SANDBOXOU[Sandbox OU]
        end
        
        subgraph "Service Control Policies"
            SCP1[Deny Root Actions]
            SCP2[Geographic Restrictions]
            SCP3[Security Service Protection]
        end
        
        subgraph "IAM Identity Center Components"
            PS1[ReadOnlyAccess<br/>1hr sessions]
            PS2[DeveloperAccess<br/>1hr sessions]
            PS3[CloudOpsAccess<br/>1hr sessions]
            PS4[DevTestAccountAccess<br/>8hr sessions]
            PS5[SecurityAccountAccess<br/>4hr sessions]
            
            USR1[Alice User]
            USR2[Bob User]
            USR3[DevTest Engineer]
            USR4[Security Analyst]
            
            GRP1[Admins Group]
            GRP2[DevTest Group]
            GRP3[Security Group]
        end
    end

    subgraph "Security Account"
        SEC[Security Account]
        SECHUB[Security Hub]
        GD[GuardDuty]
        CONFIG[Config Service]
        INSPECTOR[Inspector]
    end

    subgraph "Logging Account"
        LOGACC[Logging Account]
        CW[CloudWatch Logs]
        ES[OpenSearch/Elasticsearch]
        FIREHOSE[Kinesis Firehose]
    end

    subgraph "Production Account"
        PROD[Production Account]
        PRODVPC[Production VPC<br/>10.40.0.0/16]
        PRODEC2[Production EC2]
        PRODRDS[Production RDS]
    end

    subgraph "DevTest Account"
        DEVTEST[DevTest Account]
        DEVEC2[Development EC2]
        DEVRDS[Development RDS]
    end

    subgraph "Sandbox Account"
        SANDBOX[Sandbox Account]
        SANDEC2[Sandbox EC2]
        SANDLABS[Testing Labs]
    end

    subgraph "Network Microsegmentation Layer"
        direction TB
        subgraph "Application VPC - 10.10.0.0/16"
            APPVPC[Application VPC]
            APPSUB1[App Private Subnet<br/>10.10.1.0/24]
            APPSUB2[App Private Subnet<br/>10.10.2.0/24]
            APPSG[App Security Group<br/>Port 443 from App VPC only]
        end
        
        subgraph "Database VPC - 10.20.0.0/16"
            DBVPC[Database VPC]
            DBSUB1[DB Private Subnet<br/>10.20.1.0/24]
            DBSUB2[DB Private Subnet<br/>10.20.2.0/24]
            DBSG[DB Security Group<br/>Port 3306/5432 from App VPC]
        end
        
        subgraph "Logging VPC - 10.30.0.0/16"
            LOGVPC[Logging VPC]
            LOGSUB1[Log Private Subnet<br/>10.30.1.0/24]
            LOGSUB2[Log Private Subnet<br/>10.30.2.0/24]
            LOGSG[Logging Security Group<br/>Port 514/9200 restricted]
        end
        
        TGW[Transit Gateway]
        NACL1[Network ACLs]
        NACL2[Network ACLs]
        NACL3[Network ACLs]
        
        PRIVATELINK[VPC PrivateLink Endpoints]
    end

    subgraph "Risk Compliance Dashboard"
        direction TB
        FINDS3[Security Findings S3]
        LAMBDA1[Score Lambda Function]
        ATHENA[Athena Analytics]
        QUICKSIGHT[QuickSight Dashboard]
        EVENTBRIDGE[EventBridge Rules]
        
        subgraph "Data Sources"
            GHFIND[GuardDuty Findings]
            SHFIND[Security Hub Findings]
            CONFIND[Config Rule Findings]
            AMFIND[Audit Manager Findings]
        end
    end

    subgraph "JIT Access Automation"
        direction TB
        JITCREATE[JIT Create Lambda]
        JITCLEANUP[JIT Cleanup Lambda]
        DYNAMO[DynamoDB Access Table]
        EVENTRULEJIT[EventBridge Scheduler]
        
        subgraph "Access Workflow"
            REQ[Access Request API]
            APPROVE[Approval Process]
            GRANT[Temporary Assignment]
            EXPIRE[Auto Cleanup]
        end
    end

    subgraph "SIEM & Incident Response"
        direction TB
        FORENSICS3[Forensic Evidence S3]
        ISOLATE[Isolate EC2 Lambda]
        LOCKDOWN[Lockdown S3 Lambda]
        REVOKE[Revoke IAM Lambda]
        OPENSEARCH[OpenSearch Dashboards]
        
        subgraph "Automated Playbooks"
            PLAY1[EC2 Isolation Playbook]
            PLAY2[S3 Lockdown Playbook]
            PLAY3[IAM Revocation Playbook]
        end
    end

    subgraph "AI Threat Detection"
        direction TB
        SAGEMAKER[SageMaker Endpoint]
        RCFMODEL[Random Cut Forest Model]
        ANOMALY[Anomaly Detection]
        MLBUCKET[ML Data Lake S3]
    end

    subgraph "Compliance Framework"
        direction TB
        CONFIGRULES[AWS Config Rules]
        BENCHMARKS[Security Benchmarks]
        AUDITMAN[Audit Manager]
        PIPELINE[Compliance Pipeline]
    end

    subgraph "Forensics Lab"
        direction TB
        LABVPC[Lab VPC 10.100.0.0/16]
        LINUXVM[Linux Analysis VM]
        WINVM[Windows Analysis VM]
        LABEKS[EKS Cluster]
        LABRDS[RDS Instance]
    end

    %% Organization Relationships
    ORG --> SECOU
    ORG --> LOGGINGOU
    ORG --> PRODOU
    ORG --> DEVTESTOU
    ORG --> SANDBOXOU
    
    SECOU --> SEC
    LOGGINGOU --> LOGACC
    PRODOU --> PROD
    DEVTESTOU --> DEVTEST
    SANDBOXOU --> SANDBOX
    
    %% SCP Attachments
    SCP1 --> SECOU
    SCP1 --> PRODOU
    SCP2 --> SANDBOXOU
    SCP3 --> SECOU
    
    %% SSO Relationships
    SSO --> PS1
    SSO --> PS2
    SSO --> PS3
    SSO --> PS4
    SSO --> PS5
    
    USR1 --> GRP1
    USR2 --> GRP1
    USR3 --> GRP2
    USR4 --> GRP3
    
    GRP1 --> PS3
    GRP2 --> PS4
    GRP3 --> PS5
    
    %% Audit Trail
    CT --> S3LOG
    SEC --> CT
    LOGACC --> CT
    PROD --> CT
    DEVTEST --> CT
    SANDBOX --> CT
    
    %% Security Monitoring
    SECHUB --> GHFIND
    GD --> GHFIND
    CONFIG --> CONFIND
    INSPECTOR --> SHFIND
    
    %% Network Connectivity
    TGW --> APPVPC
    TGW --> DBVPC
    TGW --> LOGVPC
    
    APPVPC --> APPSUB1
    APPVPC --> APPSUB2
    DBVPC --> DBSUB1
    DBVPC --> DBSUB2
    LOGVPC --> LOGSUB1
    LOGVPC --> LOGSUB2
    
    APPSG --> APPSUB1
    DBSG --> DBSUB1
    LOGSG --> LOGSUB1
    
    NACL1 --> APPVPC
    NACL2 --> DBVPC
    NACL3 --> LOGVPC
    
    %% Risk Compliance Data Flow
    GHFIND --> EVENTBRIDGE
    SHFIND --> EVENTBRIDGE
    CONFIND --> EVENTBRIDGE
    AMFIND --> EVENTBRIDGE
    
    EVENTBRIDGE --> LAMBDA1
    LAMBDA1 --> FINDS3
    FINDS3 --> ATHENA
    ATHENA --> QUICKSIGHT
    
    %% JIT Access Flow
    REQ --> JITCREATE
    JITCREATE --> SSO
    JITCREATE --> DYNAMO
    JITCREATE --> EVENTRULEJIT
    EVENTRULEJIT --> JITCLEANUP
    JITCLEANUP --> SSO
    
    %% SIEM Integration
    EVENTBRIDGE --> ISOLATE
    EVENTBRIDGE --> LOCKDOWN
    EVENTBRIDGE --> REVOKE
    
    ISOLATE --> FORENSICS3
    LOCKDOWN --> FORENSICS3
    REVOKE --> FORENSICS3
    
    PLAY1 --> ISOLATE
    PLAY2 --> LOCKDOWN
    PLAY3 --> REVOKE
    
    %% AI Threat Detection
    S3LOG --> MLBUCKET
    FINDS3 --> MLBUCKET
    MLBUCKET --> SAGEMAKER
    SAGEMAKER --> RCFMODEL
    RCFMODEL --> ANOMALY
    ANOMALY --> EVENTBRIDGE
    
    %% Compliance Integration
    CONFIG --> CONFIGRULES
    CONFIGRULES --> BENCHMARKS
    BENCHMARKS --> AUDITMAN
    AUDITMAN --> PIPELINE
    PIPELINE --> QUICKSIGHT
    
    %% Forensics Lab
    FORENSICS3 --> LABVPC
    LABVPC --> LINUXVM
    LABVPC --> WINVM
    LABVPC --> LABEKS
    LABVPC --> LABRDS

    %% Styling
    classDef orgStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef securityStyle fill:#ffebee,stroke:#c62828,stroke-width:2px
    classDef networkStyle fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px
    classDef dataStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef lambdaStyle fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef mlStyle fill:#e0f2f1,stroke:#00695c,stroke-width:2px

    class ORG,SECOU,LOGGINGOU,PRODOU,DEVTESTOU,SANDBOXOU,SSO orgStyle
    class SECHUB,GD,CONFIG,INSPECTOR,SCP1,SCP2,SCP3 securityStyle
    class APPVPC,DBVPC,LOGVPC,TGW,APPSG,DBSG,LOGSG networkStyle
    class S3LOG,FINDS3,FORENSICS3,MLBUCKET dataStyle
    class LAMBDA1,JITCREATE,JITCLEANUP,ISOLATE,LOCKDOWN,REVOKE lambdaStyle
    class SAGEMAKER,RCFMODEL,ANOMALY mlStyle


