# Zero Trust AWS Organization Architecture - Detailed Description for AI Processing

## Project Overview
Create a comprehensive AWS architecture diagram showing a Zero Trust security implementation across a multi-account AWS Organization with automated compliance monitoring, just-in-time access controls, and incident response capabilities.

## Core Architecture Components

### 1. Management Account (Root Level)
**Container**: Large central container labeled "Management Account (Root)"
**Contains the following components**:

- **AWS Organization**: Central governance hub managing all accounts
- **Organization CloudTrail**: Organization-wide audit logging service
- **Log Archive S3 Bucket**: Centralized storage for all audit logs with encryption and versioning
- **AWS IAM Identity Center**: Centralized identity provider for federated access

**Sub-containers within Management Account**:

#### Organizational Units Container
Contains 5 organizational units:
- Security OU
- Logging OU  
- Production OU
- DevTest OU
- Sandbox OU

#### Service Control Policies Container  
Contains 3 policy types:
- Deny Root Actions (prevents root user access key creation)
- Geographic Restrictions (limits operations to approved regions)
- Security Service Protection (prevents disabling of security services)

#### IAM Identity Center Components Container
**Permission Sets** (with session durations):
- ReadOnlyAccess (1 hour sessions)
- DeveloperAccess (1 hour sessions) 
- CloudOpsAccess (1 hour sessions)
- DevTestAccountAccess (8 hour sessions)
- SecurityAccountAccess (4 hour sessions)

**Users**:
- alice@domain.com
- bob@domain.com
- devtest.engineer@domain.com
- security.analyst@domain.com

**Groups**:
- Admins Group
- DevTest Group
- Security Group

### 2. Member Accounts (5 separate account containers)

#### Security Account Container
- Security Hub (centralized security findings)
- GuardDuty (threat detection)
- Config Service (configuration compliance)
- Inspector (vulnerability assessment)

#### Logging Account Container  
- CloudWatch Logs (log aggregation)
- OpenSearch/Elasticsearch (log analysis)
- Kinesis Firehose (log streaming)

#### Production Account Container
- Production VPC (10.40.0.0/16)
- Production EC2 instances
- Production RDS databases

#### DevTest Account Container
- Development EC2 instances
- Development RDS databases

#### Sandbox Account Container
- Sandbox EC2 instances
- Testing Labs environment

### 3. Network Microsegmentation Layer
**Large container spanning across accounts containing**:

#### Application VPC (10.10.0.0/16)
- App Private Subnet (10.10.1.0/24)
- App Private Subnet (10.10.2.0/24)  
- App Security Group (Port 443 from App VPC only)

#### Database VPC (10.20.0.0/16)
- DB Private Subnet (10.20.1.0/24)
- DB Private Subnet (10.20.2.0/24)
- DB Security Group (Port 3306/5432 from App VPC)

#### Logging VPC (10.30.0.0/16)
- Log Private Subnet (10.30.1.0/24)
- Log Private Subnet (10.30.2.0/24)
- Logging Security Group (Port 514/9200 restricted)

**Network Infrastructure**:
- Transit Gateway (central connectivity hub)
- Network ACLs (for each VPC)
- VPC PrivateLink Endpoints

### 4. Risk Compliance Dashboard Container
**Main Components**:
- Security Findings S3 (storage for processed findings)
- Score Lambda Function (risk calculation engine)
- Athena Analytics (SQL queries on security data)
- QuickSight Dashboard (executive reporting)
- EventBridge Rules (event routing)

**Data Sources Sub-container**:
- GuardDuty Findings
- Security Hub Findings  
- Config Rule Findings
- Audit Manager Findings

### 5. JIT Access Automation Container
**Lambda Functions**:
- JIT Create Lambda (grants temporary access)
- JIT Cleanup Lambda (removes expired access)

**Supporting Services**:
- DynamoDB Access Table (tracks active assignments)
- EventBridge Scheduler (triggers cleanup)

**Access Workflow Sub-container**:
- Access Request API
- Approval Process
- Temporary Assignment
- Auto Cleanup

### 6. SIEM & Incident Response Container
**Storage**:
- Forensic Evidence S3 (object-locked for evidence preservation)

**Response Functions**:
- Isolate EC2 Lambda (isolates compromised instances)
- Lockdown S3 Lambda (secures compromised S3 buckets)
- Revoke IAM Lambda (revokes compromised credentials)

**Analysis Tools**:
- OpenSearch Dashboards (security event analysis)

**Automated Playbooks Sub-container**:
- EC2 Isolation Playbook
- S3 Lockdown Playbook
- IAM Revocation Playbook

### 7. AI Threat Detection Container
- SageMaker Endpoint (machine learning inference)
- Random Cut Forest Model (anomaly detection algorithm)
- Anomaly Detection (threat identification)
- ML Data Lake S3 (training data storage)

### 8. Compliance Framework Container
- AWS Config Rules (compliance monitoring)
- Security Benchmarks (CIS, NIST, SOC frameworks)
- Audit Manager (automated evidence collection)
- Compliance Pipeline (continuous assessment)

### 9. Forensics Lab Container
- Lab VPC (10.100.0.0/16)
- Linux Analysis VM
- Windows Analysis VM
- EKS Cluster (container forensics)
- RDS Instance (database forensics)

## Connection Flows and Relationships

### Organizational Structure Flows
- AWS Organization connects to all 5 Organizational Units
- Each OU connects to its respective account (Security OU → Security Account, etc.)
- Service Control Policies attach to specific OUs (SCP1 to Security and Production OUs, SCP2 to Sandbox OU, SCP3 to Security OU)

### Identity and Access Flows
- IAM Identity Center manages all Permission Sets
- Users are assigned to Groups (alice/bob → Admins Group, devtest.engineer → DevTest Group, security.analyst → Security Group)
- Groups are assigned to Permission Sets (Admins → CloudOpsAccess, DevTest → DevTestAccountAccess, Security → SecurityAccountAccess)

### Audit and Logging Flows
- Organization CloudTrail feeds into Log Archive S3 Bucket
- All accounts (Security, Logging, Production, DevTest, Sandbox) send audit logs to CloudTrail
- Log Archive S3 feeds into ML Data Lake S3 for AI analysis

### Security Monitoring Flows
- Security services (GuardDuty, Security Hub, Config, Inspector) generate findings
- All findings flow into EventBridge Rules
- EventBridge triggers Score Lambda Function
- Score Lambda processes findings and stores them in Security Findings S3
- Security Findings S3 feeds into Athena Analytics
- Athena results display in QuickSight Dashboard

### Network Connectivity Flows
- Transit Gateway connects all three VPCs (Application, Database, Logging)
- VPCs contain their respective subnets
- Security Groups and Network ACLs control traffic between VPCs
- VPC PrivateLink provides secure service communication

### JIT Access Flows
- Access Request API triggers JIT Create Lambda
- JIT Create Lambda interacts with IAM Identity Center to grant access
- JIT Create Lambda logs assignments in DynamoDB Access Table
- JIT Create Lambda schedules cleanup via EventBridge Scheduler
- EventBridge Scheduler triggers JIT Cleanup Lambda
- JIT Cleanup Lambda removes access from IAM Identity Center

### Incident Response Flows
- EventBridge Rules trigger response Lambda functions based on finding severity
- Response Lambdas (Isolate EC2, Lockdown S3, Revoke IAM) execute containment actions
- All response actions store evidence in Forensic Evidence S3
- Automated Playbooks define the response procedures for each Lambda function

### AI/ML Data Flows
- Log Archive S3 and Security Findings S3 feed into ML Data Lake S3
- ML Data Lake S3 provides training data to SageMaker Endpoint
- SageMaker runs Random Cut Forest Model for anomaly detection
- Anomaly Detection results flow back into EventBridge for alerting

### Compliance Flows
- Config Service monitors compliance continuously
- Config feeds into AWS Config Rules
- Config Rules implement Security Benchmarks
- Benchmarks integrate with Audit Manager for evidence collection
- Compliance Pipeline processes audit data
- Pipeline results feed into QuickSight Dashboard for reporting

### Forensics Integration
- Forensic Evidence S3 provides investigation data to Forensics Lab
- Lab VPC contains analysis environments (Linux VM, Windows VM, EKS, RDS)
- Analysis results feed back into investigation workflows

## Color Coding Scheme
- **Organization/Governance Components**: Light Blue (#E1F5FE)
- **Security Services**: Light Red (#FFEBEE)  
- **Network Components**: Light Purple (#F3E5F5)
- **Data Storage**: Light Green (#E8F5E8)
- **Compute/Lambda Functions**: Light Orange (#FFF3E0)
- **AI/ML Services**: Light Teal (#E0F2F1)

## Key Technical Details

### Network Segmentation
- Application VPC (10.10.0.0/16) hosts web applications
- Database VPC (10.20.0.0/16) hosts data storage with restricted access
- Logging VPC (10.30.0.0/16) handles log aggregation and analysis
- Transit Gateway enables controlled inter-VPC communication
- Security Groups implement application-level firewall rules
- Network ACLs provide subnet-level traffic control

### Zero Trust Implementation
- All access is time-bounded (1-8 hours depending on role)
- Just-in-time access for elevated permissions
- Continuous verification through real-time monitoring
- Least privilege principle enforced through Permission Sets
- All actions logged and audited through CloudTrail

### Automation Features
- Automated security response through Lambda functions
- Real-time threat detection via AI/ML models
- Continuous compliance monitoring with AWS Config
- Automated evidence collection for audit purposes
- Self-service access requests with automatic cleanup

This architecture implements a comprehensive Zero Trust security model with defense in depth, automated incident response, and continuous compliance monitoring across a multi-account AWS environment.