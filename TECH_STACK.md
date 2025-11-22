# Technology Stack & AWS Services

## Complete Technical Architecture

---

## **Infrastructure as Code**

### **Terraform (v1.x)**
- **Purpose**: Infrastructure provisioning and management
- **Usage**: All AWS resources defined as declarative code
- **Key Features**:
  - State management with S3 backend
  - DynamoDB state locking
  - Modular architecture
  - Conditional resource creation
  - For_each and count meta-arguments

### **Configuration Files**
- `.tf` files: Resource definitions
- `.tfvars` files: Variable values (secrets excluded)
- `.tfstate` files: Infrastructure state tracking

---

## **Programming Languages**

### **Python 3.9+**
- **Purpose**: Lambda function development
- **Libraries**:
  - `boto3`: AWS SDK for Python
  - `json`: JSON parsing and manipulation
  - `datetime`: Timestamp and TTL calculations
  - `uuid`: Unique identifier generation
  - `os`: Environment variable access

### **HCL (HashiCorp Configuration Language)**
- **Purpose**: Terraform resource definitions
- **Features**: Declarative syntax for infrastructure

### **SQL**
- **Purpose**: Athena queries for security analytics
- **Usage**: Ad-hoc analysis of security findings data lake

---

## **AWS Services Used**

### **Identity & Access Management (6 services)**

1. **AWS Organizations**
   - Multi-account structure management
   - Organizational Units (OUs) for logical grouping
   - Consolidated billing

2. **IAM Identity Center (AWS SSO)**
   - Centralized single sign-on
   - Permission sets with time-limited sessions
   - Multi-account access management

3. **AWS IAM (Identity and Access Management)**
   - Role-based access control
   - Service roles for Lambda, Glue, EKS
   - Policy documents and assume role policies

4. **IAM Identity Store**
   - User and group management
   - Group memberships
   - User profiles

5. **AWS STS (Security Token Service)**
   - Temporary credential generation
   - Role assumption

6. **Service Control Policies (SCPs)**
   - Organization-wide guardrails
   - Preventive security controls

---

### **Security Services (7 services)**

7. **Amazon GuardDuty**
   - AI-powered threat detection
   - Monitors CloudTrail, VPC Flow Logs, DNS logs
   - High/critical severity finding alerts

8. **AWS Security Hub**
   - Centralized security findings aggregation
   - Multi-service integration
   - Compliance standard assessments

9. **AWS Config**
   - Configuration compliance monitoring
   - Resource inventory and change tracking
   - Config Rules for automated compliance checks

10. **Amazon Inspector**
    - Vulnerability assessments
    - EC2 and container image scanning
    - CVE detection

11. **AWS CloudTrail**
    - API call logging across all accounts
    - Organization trail for centralized auditing
    - S3 log archive storage

12. **AWS KMS (Key Management Service)**
    - Encryption key management
    - Customer-managed keys for forensic data
    - At-rest encryption

13. **AWS Audit Manager**
    - Automated compliance evidence collection
    - SOX, PCI-DSS, NIST framework assessments
    - Audit readiness

---

### **Compute Services (3 services)**

14. **AWS Lambda**
    - Serverless function execution
    - **Functions Deployed**:
      - JIT Create (access provisioning)
      - JIT Cleanup (access revocation)
      - Isolate EC2 (quarantine compromised instances)
      - Lockdown S3 (restrict bucket access)
      - Revoke IAM (deactivate credentials)
      - Ingest Lambda (security findings ingestion)
      - Score Lambda (risk score calculation)

15. **Amazon EC2 (Elastic Compute Cloud)**
    - Virtual machine instances
    - Production, DevTest, Sandbox workloads
    - WordPress and Windows vulnerable instances
    - Forensics lab VMs (Linux & Windows)

16. **Amazon EKS (Elastic Kubernetes Service)**
    - Managed Kubernetes clusters
    - Container orchestration
    - Vulnerable cluster for security testing

---

### **Storage Services (4 services)**

17. **Amazon S3 (Simple Storage Service)**
    - **Buckets Created**:
      - Log Archive Bucket (CloudTrail logs)
      - Forensics Evidence Bucket (incident artifacts)
      - Security Findings Bucket (data lake)
      - Protected Data Bucket (backup/recovery)
      - Athena Query Results Bucket
    - **Features Used**:
      - Versioning
      - Server-side encryption (SSE-KMS)
      - Bucket policies
      - Lifecycle policies
      - Public access blocking

18. **Amazon EBS (Elastic Block Store)**
    - EC2 instance volumes
    - Snapshot creation for forensics
    - Data Lifecycle Manager policies

19. **Amazon RDS (Relational Database Service)**
    - Production and DevTest databases
    - Automated backups
    - Encryption at rest
    - Point-in-time recovery

20. **Amazon DynamoDB**
    - JIT access assignment tracking
    - TTL-based automatic expiration
    - Forensics metadata storage

---

### **Networking Services (7 services)**

21. **Amazon VPC (Virtual Private Cloud)**
    - **VPCs Created**:
      - App VPC (10.10.0.0/16)
      - DB VPC (10.20.0.0/16)
      - Logging VPC (10.30.0.0/16)
      - Production VPC (10.40.0.0/16)
      - Lab VPC (10.100.0.0/16)
    - Private subnets across multiple AZs

22. **AWS Transit Gateway**
    - Hub-and-spoke network architecture
    - Centralized connectivity between VPCs
    - Route-based traffic control

23. **Security Groups**
    - Stateful firewall rules
    - Application and database layer isolation
    - Endpoint security groups

24. **Network ACLs (NACLs)**
    - Stateless subnet-level filtering
    - Defense-in-depth controls
    - Explicit deny rules

25. **VPC Flow Logs**
    - Network traffic monitoring
    - GuardDuty data source

26. **VPC Endpoints**
    - **Gateway Endpoints**: S3
    - **Interface Endpoints**: DynamoDB, SSM
    - PrivateLink for secure service access

27. **Elastic Network Interfaces (ENIs)**
    - Lambda VPC connectivity
    - Multi-AZ deployment

---

### **Analytics & Big Data Services (5 services)**

28. **Amazon Athena**
    - Serverless SQL queries
    - Security findings data lake analysis
    - Ad-hoc investigation queries

29. **Amazon QuickSight**
    - Business intelligence dashboards
    - Risk posture visualization
    - Compliance gap reporting

30. **AWS Glue**
    - **Glue Crawler**: Schema discovery for S3 data
    - **Glue Catalog**: Metadata repository
    - Data lake table definitions

31. **Amazon Kinesis Firehose**
    - Streaming data delivery
    - Real-time log ingestion to OpenSearch and S3
    - Data transformation pipelines

32. **Amazon OpenSearch Service**
    - Log analysis and search
    - Security event correlation
    - SIEM capabilities

---

### **Machine Learning & AI Services (1 service)**

33. **Amazon SageMaker**
    - Anomaly detection model training
    - Real-time inference endpoints
    - Behavioral analysis for threat detection

---

### **Event & Orchestration Services (2 services)**

34. **Amazon EventBridge (CloudWatch Events)**
    - Event-driven architecture
    - **Rules Created**:
      - GuardDuty high-severity findings
      - Security Hub findings
      - Config compliance violations
      - S3 object events
      - IAM access key events
      - Audit Manager findings
    - Lambda function triggers
    - Scheduled JIT cleanup (every 5 minutes)

35. **AWS Systems Manager (SSM)**
    - **SSM Documents**: Recovery automation playbooks
    - Parameter Store (future use)
    - Session Manager (future use)

---

### **Management & Governance Services (4 services)**

36. **AWS CloudWatch**
    - Log aggregation and monitoring
    - CloudWatch Logs for Lambda output
    - Metrics and alarms
    - Log groups and log streams

37. **AWS Service Quotas**
    - VPC limit checking
    - Quota monitoring for safe resource creation

38. **AWS Resource Groups**
    - Resource tagging and organization
    - Cost allocation tracking

39. **AWS Trusted Advisor**
    - Best practice recommendations
    - Security and cost optimization

---

### **Developer Tools & Deployment (2 services)**

40. **AWS Lambda Layers** (implicit)
    - Shared Python dependencies
    - Boto3 SDK packaging

41. **AWS CloudFormation** (for QuickSight, future)
    - Stack-based infrastructure deployment
    - Commented out for manual setup

---

## **Third-Party & Open Source Tools**

### **Version Control**
- **Git**: Source code version control
- **GitHub/GitLab**: Repository hosting

### **Local Development Tools**
- **VS Code**: IDE for Terraform and Python development
- **Terraform CLI**: Infrastructure provisioning
- **AWS CLI**: Manual AWS operations and validation
- **Python virtualenv**: Isolated Python environments

### **Diagrams & Documentation**
- **Mermaid**: Architecture diagram generation
- **Draw.io**: Visual AWS architecture diagrams
- **Markdown**: Documentation authoring

---

## **AWS Service Categories Summary**

| Category | Services Count | Key Services |
|----------|---------------|--------------|
| **Identity & Access** | 6 | Organizations, IAM Identity Center, IAM, SCPs |
| **Security** | 7 | GuardDuty, Security Hub, Config, Inspector, CloudTrail, KMS, Audit Manager |
| **Compute** | 3 | Lambda, EC2, EKS |
| **Storage** | 4 | S3, EBS, RDS, DynamoDB |
| **Networking** | 7 | VPC, Transit Gateway, Security Groups, NACLs, VPC Endpoints |
| **Analytics** | 5 | Athena, QuickSight, Glue, Kinesis Firehose, OpenSearch |
| **Machine Learning** | 1 | SageMaker |
| **Event Orchestration** | 2 | EventBridge, SSM |
| **Management** | 4 | CloudWatch, Service Quotas, Resource Groups, Trusted Advisor |
| **Developer Tools** | 2 | Lambda Layers, CloudFormation |

**Total AWS Services Used: 41+**

---

## **Architecture Patterns**

### **Design Patterns Implemented**

1. **Event-Driven Architecture**
   - EventBridge as central event bus
   - Lambda functions as event handlers
   - Asynchronous processing

2. **Microservices Architecture**
   - Independent Lambda functions
   - Single responsibility per function
   - API Gateway for future REST API

3. **Hub-and-Spoke Network**
   - Transit Gateway as hub
   - VPCs as spokes
   - Centralized traffic inspection

4. **Data Lake Architecture**
   - S3 as raw data storage
   - Glue for schema discovery
   - Athena for analysis
   - QuickSight for visualization

5. **Defense in Depth**
   - Multiple security layers (SCPs, SGs, NACLs, encryption)
   - Assume breach mentality
   - Automated containment

6. **Infrastructure as Code (IaC)**
   - Terraform for all resources
   - Version controlled
   - Repeatable and auditable

---

## **Security Best Practices Implemented**

✅ **Encryption**: At rest (KMS) and in transit (TLS)  
✅ **Least Privilege**: Time-limited IAM roles and permission sets  
✅ **Network Segmentation**: VPC isolation with Transit Gateway  
✅ **Logging**: Comprehensive CloudTrail and VPC Flow Logs  
✅ **Monitoring**: GuardDuty, Security Hub, Config, Inspector  
✅ **Automation**: Lambda-based incident response  
✅ **Compliance**: Config Rules and Audit Manager  
✅ **Backup**: EBS snapshots and RDS backups  
✅ **Versioning**: S3 bucket versioning for forensics  
✅ **Public Access Blocking**: All S3 buckets private by default  

---

## **Cost Optimization Strategies**

1. **Serverless First**: Lambda pay-per-execution model
2. **Conditional Resources**: Only create what's needed via Terraform variables
3. **S3 Lifecycle Policies**: Move old logs to Glacier
4. **DynamoDB On-Demand**: Pay per request for JIT table
5. **Transit Gateway**: Replaces expensive VPC peering mesh
6. **VPC Endpoints**: Reduces NAT Gateway costs

---

## **Scalability Features**

- **Multi-AZ Deployments**: High availability for critical services
- **Lambda Auto-Scaling**: Concurrent execution scaling
- **DynamoDB Auto-Scaling**: Read/write capacity adjustment
- **Transit Gateway**: Supports up to 5000 VPC attachments
- **Organizations**: Supports up to 400 accounts
- **Glue Crawler**: Automatically discovers new S3 partitions

---

## **Monitoring & Observability Stack**

1. **Logs**: CloudWatch Logs, VPC Flow Logs, CloudTrail
2. **Metrics**: CloudWatch Metrics, custom Lambda metrics
3. **Traces**: X-Ray (future integration)
4. **Dashboards**: QuickSight for business metrics
5. **Alerts**: EventBridge rules with SNS notifications (future)
6. **SIEM**: OpenSearch for security event analysis

---

## **Deployment Pipeline (Future Enhancement)**

- **CI/CD**: GitHub Actions or AWS CodePipeline
- **Testing**: Terraform validate, plan, LocalStack
- **Environments**: Dev, Test, Prod accounts
- **Approval Gates**: Manual approval for production
- **Rollback**: Terraform state versioning in S3

---

**This technology stack demonstrates enterprise-grade cloud security architecture with production-ready automation, compliance, and incident response capabilities.**
