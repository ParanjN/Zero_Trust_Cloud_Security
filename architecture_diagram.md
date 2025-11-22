graph TB
    subgraph "Management Account"
        ORG[AWS Organization]
        CT[Organization CloudTrail]
        S3LOG[Log Archive S3 Bucket]
        SSO[AWS IAM Identity Center]
        
        SECOU[Security OU]
        LOGGINGOU[Logging OU]
        PRODOU[Production OU]
        DEVTESTOU[DevTest OU]
        SANDBOXOU[Sandbox OU]
        
        SCP1[Deny Root Actions]
        SCP2[Geographic Restrictions]
        SCP3[Security Service Protection]
        
        PS1[ReadOnlyAccess 1hr]
        PS2[DeveloperAccess 1hr]
        PS3[CloudOpsAccess 1hr]
        PS4[DevTestAccountAccess 8hr]
        PS5[SecurityAccountAccess 4hr]
        
        USR1[Alice User]
        USR2[Bob User]
        USR3[DevTest Engineer]
        USR4[Security Analyst]
        
        GRP1[Admins Group]
        GRP2[DevTest Group]
        GRP3[Security Group]

        SEC[Security Account]
        SECHUB[Security Hub]
        GD[GuardDuty]
        CONFIG[Config Service]
        INSPECTOR[Inspector]
        
        LOGACC[Logging Account]
        CW[CloudWatch Logs]
        ES[OpenSearch]
        FIREHOSE[Kinesis Firehose]
        
        PROD[Production Account]
        PRODVPC[Production VPC 10.40.0.0/16]
        PRODEC2[Production EC2]
        PRODRDS[Production RDS]
        
        DEVTEST[DevTest Account]
        DEVEC2[Development EC2]
        DEVRDS[Development RDS]
        
        SANDBOX[Sandbox Account]
        SANDEC2[Sandbox EC2]
        SANDLABS[Testing Labs]
    end

    subgraph "Platform Services"
        APPVPC[App VPC 10.10.0.0/16]
        DBVPC[DB VPC 10.20.0.0/16] 
        LOGVPC[Log VPC 10.30.0.0/16]
        TGW[Transit Gateway]
        APPSUB1[App Subnets]
        DBSUB1[DB Subnets]
        LOGSUB1[Log Subnets]
        
        FINDS3[Security Findings S3]
        LAMBDA1[Score Lambda]
        ATHENA[Athena Analytics]
        QUICKSIGHT[QuickSight Dashboard]
        EVENTBRIDGE[EventBridge Rules]
        GHFIND[GuardDuty Findings]
        SHFIND[Security Hub Findings]
        CONFIND[Config Findings]
        
        JITCREATE[JIT Create Lambda]
        JITCLEANUP[JIT Cleanup Lambda]
        DYNAMO[DynamoDB Table]
        REQ[Access Request API]
        FORENSICS3[Forensic S3]
        ISOLATE[Isolate EC2 Lambda]
        LOCKDOWN[Lockdown S3 Lambda]
        REVOKE[Revoke IAM Lambda]
        
        SAGEMAKER[SageMaker Endpoint]
        ANOMALY[Anomaly Detection]
        MLBUCKET[ML Data Lake S3]
        CONFIGRULES[Config Rules]
        AUDITMAN[Audit Manager]
        LABVPC[Lab VPC 10.100.0.0/16]
        LINUXVM[Linux VM]
        WINVM[Windows VM]
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
    DBVPC --> DBSUB1
    LOGVPC --> LOGSUB1
    
    %% Risk Compliance Data Flow
    GHFIND --> EVENTBRIDGE
    SHFIND --> EVENTBRIDGE
    CONFIND --> EVENTBRIDGE
    
    EVENTBRIDGE --> LAMBDA1
    LAMBDA1 --> FINDS3
    FINDS3 --> ATHENA
    ATHENA --> QUICKSIGHT
    
    %% JIT Access Flow
    REQ --> JITCREATE
    JITCREATE --> SSO
    JITCREATE --> DYNAMO
    JITCLEANUP --> SSO
    
    %% SIEM Integration
    EVENTBRIDGE --> ISOLATE
    EVENTBRIDGE --> LOCKDOWN
    EVENTBRIDGE --> REVOKE
    
    ISOLATE --> FORENSICS3
    LOCKDOWN --> FORENSICS3
    REVOKE --> FORENSICS3
    
    %% AI Threat Detection
    S3LOG --> MLBUCKET
    FINDS3 --> MLBUCKET
    MLBUCKET --> SAGEMAKER
    SAGEMAKER --> ANOMALY
    ANOMALY --> EVENTBRIDGE
    
    %% Compliance Integration
    CONFIG --> CONFIGRULES
    CONFIGRULES --> AUDITMAN
    
    %% Forensics Lab
    FORENSICS3 --> LABVPC
    LABVPC --> LINUXVM
    LABVPC --> WINVM

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


