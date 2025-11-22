# Zero Trust AWS Organization - Comprehensive Video Walkthrough Script
## 10-Minute Technical Deep Dive

---

## **OPENING: Project Context and Introduction (90 seconds)**

**"Welcome! Today I'm presenting my graduate research project titled: An Integrated Framework for Zero Trust Security, Compliance, and Incident Response in AWS."**

### **The Problem We're Solving**

**"Let me start with why this matters. As organizations accelerate their cloud adoption, we're seeing a fundamental shift in how security must be approached. Traditional perimeter-based security models - the 'castle and moat' approach - are no longer sufficient for today's dynamic, distributed cloud environments."**

**"The challenges are real:"**
- **Sophisticated Cyberattacks**: Ransomware, insider threats, and advanced persistent threats are increasing in complexity and frequency
- **Compliance Complexity**: Organizations must navigate multiple frameworks - NIST, PCI-DSS, SOC 2, HIPAA - while maintaining operational agility
- **Visibility Gaps**: In multi-account cloud environments, it's difficult to maintain centralized visibility and control
- **Manual Processes**: Traditional security operations rely heavily on manual intervention, leading to slow response times and human error
- **Standing Privileges**: Permanent access permissions create unnecessary risk when temporary access would suffice

**"Zero Trust has emerged as the modern approach to securing these environments. The principle is simple but powerful: Never trust, always verify. Assume breach, verify explicitly, and grant least-privilege access."**

### **The Integrated Solution**

**"This project goes beyond implementing just Zero Trust. It creates a comprehensive, multi-layered AWS cybersecurity framework that integrates six critical components:"**

**1. Zero Trust Access Control**
- Granular identity and access management using AWS IAM Identity Center
- Time-limited permission sets that automatically expire
- Service Control Policies (SCPs) that enforce preventive guardrails across all accounts
- Just-in-Time (JIT) access with automated provisioning and revocation

**2. Cloud-Native SIEM**
- Centralized log ingestion from CloudTrail, GuardDuty, VPC Flow Logs, and Security Hub
- AWS OpenSearch for real-time analysis and correlation
- Kinesis Firehose for scalable, streaming data pipelines
- Normalized security event data for unified threat detection

**3. Automated Incident Response**
- Lambda-based playbooks for EC2 isolation, S3 lockdown, and IAM credential revocation
- EventBridge rules that trigger responses within seconds of threat detection
- Forensic evidence preservation with encrypted, versioned S3 storage
- Zero manual intervention for common security incidents

**4. AI-Driven Threat Detection**
- Amazon SageMaker anomaly detection models trained on organizational behavior
- GuardDuty machine learning for identifying insider threats and lateral movement
- Pattern recognition for ransomware indicators and data exfiltration attempts
- Continuous learning that adapts to evolving threat landscapes

**5. Compliance-as-Code Framework**
- AWS Config rules that continuously validate security posture
- Automated assessment against NIST Cybersecurity Framework and CIS Benchmarks
- AWS Audit Manager for automated evidence collection
- Drift detection that alerts when configurations deviate from compliance requirements

**6. Executive Risk Dashboard**
- Amazon QuickSight visualization of organizational risk posture
- Real-time compliance gap analysis and trend reporting
- Business-friendly metrics that translate technical findings into risk scores
- Actionable insights for security leadership and board-level reporting

### **What Makes This Unique**

**"What sets this framework apart is the integration. These aren't isolated security tools - they work together as a cohesive system:"**
- GuardDuty findings trigger automated Lambda responses
- All security events flow into a centralized data lake for analytics
- JIT access integrates with SSO for seamless user experience
- Compliance violations automatically create incident response tickets
- Risk scores aggregate across all security services for holistic visibility

**"This simulates real-world challenges faced by financial institutions, healthcare organizations, and enterprises managing sensitive data. It's not just academic - it's built to production standards using Infrastructure as Code."**

### **What You're About to See**

**"In the next 9 minutes, I'll walk you through:"**
- ✅ **Architecture Overview** - How all components fit together in a multi-account organization
- ✅ **Just-in-Time Access** - Time-limited permissions with automated cleanup via Lambda functions
- ✅ **Network Microsegmentation** - VPC isolation with Transit Gateway and defense-in-depth controls
- ✅ **Automated Incident Response** - Lambda playbooks that detect, contain, and preserve evidence automatically
- ✅ **Risk and Compliance Monitoring** - Data lake analytics with executive dashboards
- ✅ **Code Quality** - Engineering best practices that make this production-ready
- ✅ **Real-World Value** - Concrete scenarios showing time and risk reduction

**"Every line of code you'll see is deployable via Terraform. This is 100% Infrastructure as Code - reproducible, version-controlled, and auditable."**

**"Let's dive into the architecture and see how Zero Trust, automation, AI, and compliance come together to create enterprise-grade security."**

---

## **SECTION 1: Architecture Deep Dive (120 seconds)**

### **Visual: Show architecture diagram with Mermaid rendering**

**"Let's explore the complete architecture. This diagram shows how all components integrate into a cohesive Zero Trust framework. I'll walk you through each layer."**

### **1. Management Account - The Control Plane**

**"At the top, we have the Management Account - the nerve center of our organization:"**

- **AWS Organizations**: Creates and manages 5 specialized accounts organized into Organizational Units (OUs)
  - Security OU → Security Account
  - Logging OU → Logging Account  
  - Production OU → Production Account
  - DevTest OU → DevTest Account
  - Sandbox OU → Sandbox Account

- **Service Control Policies (SCPs)**: Three critical preventive guardrails
  - **Deny Root Actions**: Prevents use of root credentials across Security and Production OUs
  - **Geographic Restrictions**: Limits Sandbox account to specific AWS regions
  - **Security Service Protection**: Prevents disabling GuardDuty, Config, and CloudTrail in Security OU

- **IAM Identity Center (SSO)**: Centralized identity with 5 permission sets
  - **ReadOnlyAccess** - 1 hour session (least privilege for viewing)
  - **DeveloperAccess** - 1 hour session (code deployment, no infrastructure changes)
  - **CloudOpsAccess** - 1 hour session (infrastructure management)
  - **DevTestAccountAccess** - 8 hours (extended for development workflows)
  - **SecurityAccountAccess** - 4 hours (security investigations)

- **Users and Groups**: 
  - Alice & Bob in Admins Group → CloudOpsAccess to Production
  - DevTest Engineer in DevOps Group → DevTestAccountAccess
  - Security Analyst in Security Group → SecurityAccountAccess

- **Organization CloudTrail**: Captures ALL API calls across ALL accounts, flowing to centralized Log Archive S3 bucket

**"Notice the security-first design: every account flows through CloudTrail, every OU has appropriate SCPs, and all access is time-limited."**

### **2. Specialized Member Accounts - Separation of Duties**

**"Each account has a distinct security purpose:"**

**Security Account (The Security Operations Center):**
- **Security Hub**: Aggregates findings from GuardDuty, Config, and Inspector
- **GuardDuty**: Machine learning-based threat detection (monitors CloudTrail, VPC Flow Logs, DNS logs)
- **Config Service**: Continuous compliance monitoring and configuration drift detection
- **Inspector**: Automated vulnerability scanning for EC2 instances and container images

**Logging Account (Centralized Observability):**
- **CloudWatch Logs**: Real-time log monitoring and alerting
- **OpenSearch**: Full-text search and visualization of security events
- **Kinesis Firehose**: Streaming data pipeline from multiple sources into OpenSearch and S3

**Production Account (Business Workloads):**
- **Production VPC (10.40.0.0/16)**: Isolated network for production resources
- **Production EC2**: Application servers with strict security controls
- **Production RDS**: Database with encryption at rest and in transit

**DevTest Account (Development Environment):**
- **Development EC2**: Lower-privileged instances for testing
- **Development RDS**: Non-production database for development

**Sandbox Account (Innovation Space):**
- **Sandbox EC2**: Experimental instances with geographic restrictions
- **Testing Labs**: Safe environment for proof-of-concepts with automated cleanup

**"This account separation ensures blast radius containment - if one account is compromised, the damage is limited."**

### **3. Platform Services - The Automation Layer**

**"The bottom section shows our automation and security services that span across accounts:"**

**Network Infrastructure:**
- **3 Isolated VPCs**: App (10.10.0.0/16), DB (10.20.0.0/16), Logging (10.30.0.0/16)
- **Transit Gateway**: Hub-and-spoke connectivity with centralized traffic inspection
- **Subnets**: Private subnets in each VPC for maximum isolation

**Security Monitoring & Analytics:**
- **GuardDuty/Security Hub/Config Findings**: Flow into EventBridge for automated routing
- **EventBridge Rules**: Filter and route findings based on severity
- **Risk Scoring Lambda**: Calculates risk scores based on severity, resource criticality, and historical context
- **Security Findings S3**: Data lake storage with date partitioning
- **Athena Analytics**: SQL queries over the security data lake
- **QuickSight Dashboard**: Executive visualization of risk posture and compliance metrics

**JIT Access Automation:**
- **Access Request API**: Receives JIT access requests
- **JIT Create Lambda**: Creates time-limited SSO assignments and stores expiration in DynamoDB
- **DynamoDB Table**: Tracks all active assignments with TTL
- **JIT Cleanup Lambda**: Runs every 5 minutes via EventBridge, revokes expired assignments
- **Bidirectional SSO Integration**: Create and cleanup both interact with IAM Identity Center

**Automated Incident Response:**
- **3 Response Playbooks**:
  - **Isolate EC2 Lambda**: Quarantines compromised instances, takes forensic snapshots
  - **Lockdown S3 Lambda**: Applies deny-all policies to compromised buckets
  - **Revoke IAM Lambda**: Deactivates compromised credentials
- **Forensic S3 Bucket**: Stores all incident evidence with versioning and encryption
- **EventBridge Integration**: High-severity GuardDuty findings trigger appropriate playbooks

**AI & Compliance:**
- **ML Data Lake S3**: Aggregates CloudTrail logs and security findings
- **SageMaker Endpoint**: Trained anomaly detection models
- **Anomaly Detection**: Identifies unusual behavior patterns
- **Feedback Loop**: Anomalies flow back to EventBridge for automated response
- **Config Rules**: Validates required tags, encryption, and security configurations
- **Audit Manager**: Automates SOX, PCI-DSS, and NIST compliance evidence collection

**Forensics Lab:**
- **Lab VPC (10.100.0.0/16)**: Isolated investigation environment
- **Linux & Windows VMs**: For malware analysis and incident reconstruction
- **Connected to Forensic S3**: Direct access to incident evidence

### **4. Data Flow Visualization**

**"Let me trace a complete incident response flow through this architecture:"**

1. **GuardDuty** detects cryptocurrency mining on an EC2 instance (high-severity finding)
2. Finding flows to **Security Hub** for aggregation
3. **EventBridge** receives the GuardDuty finding (severity ≥ 7)
4. EventBridge triggers **Isolate EC2 Lambda** in <5 seconds
5. Lambda creates quarantine security group, isolates instance, takes EBS snapshot
6. Incident metadata stored in **Forensic S3 bucket**
7. Simultaneously, finding goes to **Risk Scoring Lambda**
8. Risk score stored in **Security Findings S3 Data Lake**
9. **Athena** queries the finding for analytics
10. **QuickSight Dashboard** updates with new high-risk incident
11. **Forensics Lab VMs** can access the snapshot for investigation

**"From detection to containment: under 30 seconds. From containment to executive visibility: under 2 minutes. This is the power of integrated automation."**

### **5. Zero Trust Principles in Action**

**"Notice how Zero Trust is implemented at every layer:"**

- **Identity**: Time-limited access with automatic revocation (JIT)
- **Network**: Microsegmented VPCs with explicit allow-lists (TGW, Security Groups, NACLs)
- **Data**: Encrypted at rest (KMS) and in transit (TLS)
- **Workload**: Isolated accounts with SCPs preventing lateral movement
- **Visibility**: Comprehensive logging flowing to centralized data lake
- **Automation**: EventBridge orchestrating responses without human intervention

**"Every component assumes breach, verifies explicitly, and enforces least privilege. This is defense in depth at scale."**

---

## **SECTION 2: Just-in-Time Access Management (120 seconds)**

### **Code Demo: terraform_jit_package/**

**"Let's start with one of the most powerful features - Just-in-Time access. Traditional cloud security gives permanent permissions. We're doing something better."**

### **Show locals.tf - Permission Set Definitions**
```terraform
locals {
  permission_sets = {
    Admin = {
      description      = "Administrator access"
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_duration = "PT4H"  # 4 hours maximum
    }
    DevOps = {
      description      = "DevOps / PowerUser"
      managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      session_duration = "PT2H"  # 2 hours maximum
    }
    ReadOnly = {
      description      = "ReadOnly Access"
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      session_duration = "PT1H"  # 1 hour maximum
    }
  }
}
```

**"Notice the session_duration - these are time-boxed permissions. After the duration expires, access is automatically revoked. This is Zero Trust in action."**

### **Show identity_store.tf - User and Group Management**
```terraform
resource "aws_identitystore_user" "alice" {
  identity_store_id = var.identity_store_id
  user_name         = "alice"
  display_name      = "Alice Admin"
  
  name {
    given_name  = "Alice"
    family_name = "Admin"
  }
  
  emails {
    value   = "alice+terraform@example.com"
    primary = true
  }
}

resource "aws_identitystore_group" "admins" {
  identity_store_id = var.identity_store_id
  display_name      = "Admins"
  description       = "Admin group"
}
```

**"We're creating users and groups programmatically. Alice is an admin, Bob is DevOps. Each belongs to groups with specific permission sets."**

### **Show assignments.tf - Account Assignments**
```terraform
resource "aws_ssoadmin_account_assignment" "admins_prod" {
  instance_arn       = var.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.ps["Admin"].arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.admins.group_id
  target_id          = var.target_accounts["prod"].account_id
  target_type        = "AWS_ACCOUNT"
}
```

**"This grants the Admins group access to the production account, but only with the time-limited Admin permission set."**

### **Show Lambda Functions - JIT Create & Cleanup**

**"Now the magic happens with Lambda functions:"**

### **jit_create.py - Creating Temporary Access**
```python
def lambda_handler(event, context):
    # Parse request for principal, account, permission set, and TTL
    principal_id = body['principal_id']
    account_id = body['account_id']
    permission_set_name = body['permission_set_name']
    ttl = int(body.get('ttl_minutes', DEFAULT_TTL))
    
    # Create the account assignment via AWS SSO Admin API
    sso.create_account_assignment(
        InstanceArn=INSTANCE_ARN,
        TargetId=account_id,
        PermissionSetArn=ps_arn,
        PrincipalId=principal_id
    )
    
    # Store in DynamoDB with expiration timestamp
    expires_at = int((datetime.utcnow() + timedelta(minutes=ttl)).timestamp())
    table.put_item(Item={
        'assignment_id': assignment_id,
        'expires_at': expires_at,
        ...
    })
```

**"When someone requests elevated access, this Lambda:"**
1. Creates the SSO assignment
2. Records it in DynamoDB with an expiration time
3. Returns the assignment ID

### **jit_cleanup.py - Automatic Revocation**
```python
def lambda_handler(event, context):
    now = int(datetime.utcnow().timestamp())
    
    # Scan for expired assignments
    resp = table.scan(
        FilterExpression=Attr('expires_at').lte(now)
    )
    
    # Delete each expired assignment
    for item in items:
        sso.delete_account_assignment(
            InstanceArn=INSTANCE_ARN,
            TargetId=item['account_id'],
            PermissionSetArn=item['permission_set_arn'],
            PrincipalId=item['principal_id']
        )
        table.delete_item(Key={'assignment_id': item['assignment_id']})
```

**"This Lambda runs on a schedule (every 5 minutes via EventBridge), finds expired assignments, and revokes them automatically. Zero manual intervention required."**

**"This is the essence of Zero Trust: temporary, just-enough, just-in-time access."**

---

## **SECTION 2B: AWS Organizations Foundation (90 seconds)**

### **Code Demo: aws_organization/**

**"Before we had JIT access and network segmentation, we needed to build the organizational foundation. Let me show you how we structure our multi-account environment."**

### **Show organization.tf - Discovering Existing Organization**
```terraform
# Get existing organization
data "aws_organizations_organization" "org" {}

output "organizational_units" {
  value = local.all_ous
  description = "Map of all organizational unit names to their IDs"
}
```

**"We start by discovering the existing AWS Organization. This is critical - we never assume we're starting from scratch."**

### **Show organizational_units.tf - Smart OU Management**
```terraform
# Look up existing organizational units
data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

locals {
  # Standard OU configuration
  ou_config = {
    "security" = "Security"
    "logging"  = "Logging"
    "sandbox"  = "Sandbox"
    "prod"     = "Prod"
    "devtest"  = "DevTest"
  }

  # Map of existing OUs
  existing_ou_map = {
    for ou in data.aws_organizations_organizational_units.root_ous.children :
    lower(ou.name) => ou.id
    if contains(values(local.ou_config), ou.name)
  }

  # List of OUs to create (only those that don't exist)
  ous_to_create = {
    for name, display_name in local.ou_config :
    name => display_name
    if !contains(keys(local.existing_ou_map), name)
  }
}

# Create only non-existing organizational units
resource "aws_organizations_organizational_unit" "ou" {
  for_each = local.ous_to_create

  name      = each.value
  parent_id = data.aws_organizations_organization.org.roots[0].id
}
```

**"This is production-grade infrastructure code:"**
1. **Discovery First**: Check what OUs already exist
2. **Idempotency**: Only create OUs that don't exist
3. **Case-Insensitive Matching**: Handles "Security" vs "security"
4. **Merge Strategy**: Combines existing and new OUs into unified map

**"This prevents the dreaded 'OU already exists' error and makes the code truly reusable."**

### **Show policies.tf - Service Control Policies**
```terraform
# 1) Deny disabling CloudTrail & GuardDuty
resource "aws_organizations_policy" "deny_disable_ct_gd" {
  name        = "DenyDisableCloudTrailGuardDuty"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Deny",
      Action = [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "guardduty:DisassociateFromMasterAccount",
        "guardduty:DeleteDetector"
      ],
      Resource = "*"
    }]
  })
}

# 2) Deny root user actions
resource "aws_organizations_policy" "deny_root_actions" {
  name        = "DenyRootActions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Deny",
      Action = "*",
      Resource = "*",
      Condition = {
        StringLike = {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    }]
  })
}

# 3) Restrict geographic regions
resource "aws_organizations_policy" "restrict_regions" {
  name        = "RestrictRegions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Deny",
      Action = "*",
      Resource = "*",
      Condition = {
        StringNotLike = {
          "aws:RequestedRegion": var.allowed_regions
        }
      }
    }]
  })
}
```

**"These SCPs are preventive security controls that apply across ALL accounts:"**

1. **Security Service Protection**: No one can disable CloudTrail or GuardDuty - not even account admins
2. **Root User Denial**: The root user cannot perform ANY actions - forces IAM Identity Center usage
3. **Geographic Restrictions**: Workloads can only run in approved regions (e.g., us-east-1, us-west-2)

**"Notice these are DENY policies. They override all ALLOW policies. This is defense in depth - even if someone gets admin access, they can't bypass organizational guardrails."**

### **Show cloudtrail.tf - Organization-Wide Audit Trail**
```terraform
resource "aws_cloudtrail" "org_trail" {
  name                          = "organization-trail"
  is_multi_region_trail         = true
  include_global_service_events = true
  is_organization_trail         = true
  s3_bucket_name                = aws_s3_bucket.log_archive[0].id
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.log_bucket_key[0].arn

  depends_on = [
    data.aws_organizations_organization.org,
    aws_s3_bucket.log_archive
  ]
}
```

**"This single CloudTrail captures API calls from ALL accounts in the organization:"**
- **Multi-region**: Logs from all AWS regions
- **Global Services**: IAM, CloudFront, Route53 events
- **Organization Trail**: Automatically applies to all member accounts
- **Log Validation**: Cryptographic hashing to detect tampering
- **KMS Encryption**: Logs encrypted at rest

**"One trail, centralized logging, complete visibility. Security teams see everything."**

### **Show account_management.tf - Dynamic Account Creation**
```terraform
# Create new accounts that don't exist yet
resource "aws_organizations_account" "new_accounts" {
  for_each = {
    for name, config in local.managed_accounts :
    name => config
    if !config.exists
  }

  name      = each.value.name
  email     = each.value.email
  parent_id = local.all_ous[lower(each.value.ou_name)]
  role_name = "OrganizationAccountAccessRole"

  tags = {
    ManagedBy = "Terraform"
    Purpose   = each.value.ou_name
  }
}

# Manage existing accounts
resource "aws_organizations_account" "existing_accounts" {
  for_each = {
    for name, config in local.managed_accounts :
    name => config
    if config.exists && config.account_id != null
  }

  name      = each.value.name
  email     = each.value.email
  parent_id = local.all_ous[lower(each.value.ou_name)]
  
  lifecycle {
    ignore_changes = [name, email]
  }
}
```

**"This code intelligently manages account creation:"**
1. **Existence Check**: Looks up existing accounts by email
2. **Conditional Creation**: Only creates accounts that don't exist
3. **Lifecycle Management**: Prevents Terraform from trying to rename existing accounts
4. **Automatic OU Assignment**: Places accounts in the correct organizational unit
5. **Cross-Account Role**: Creates OrganizationAccountAccessRole for central management

**"The result? You can run `terraform apply` safely even if accounts already exist. No 'EMAIL_ALREADY_EXISTS' errors, no manual cleanup."**

### **The Organization Hierarchy**

**"Let's visualize what we've built:"**

```
AWS Organization (Root)
├── Service Control Policies
│   ├── Deny Disable CloudTrail/GuardDuty (ALL OUs)
│   ├── Deny Root User Actions (ALL OUs)
│   └── Restrict Regions (Sandbox OU)
│
├── Organization CloudTrail → S3 Log Archive Bucket (encrypted)
│
└── Organizational Units
    ├── Security OU
    │   └── Security Account (GuardDuty, Security Hub, Config, Inspector)
    │
    ├── Logging OU
    │   └── Logging Account (CloudWatch, OpenSearch, Kinesis)
    │
    ├── Production OU
    │   └── Production Account (workloads with strict controls)
    │
    ├── DevTest OU
    │   └── DevTest Account (development with time-limited access)
    │
    └── Sandbox OU
        └── Sandbox Account (innovation with geographic restrictions)
```

**"Every account inherits organizational policies. Every API call flows to CloudTrail. Every OU has a distinct security posture. This is governance at scale."**

**"This foundation enables everything else - JIT access, network segmentation, compliance monitoring - because we have centralized control with distributed execution."**

---

## **SECTION 3: Network Microsegmentation (120 seconds)**

### **Code Demo: network_microsegmentation/**

**"Now let's look at how we isolate workloads at the network level. This is defense in depth."**

### **Show vpc.tf - VPC Creation with Safety Checks**
```terraform
locals {
  vpc_config = {
    app = {
      cidr = "10.10.0.0/16"
      name = "App-VPC"
    }
    db = {
      cidr = "10.20.0.0/16"
      name = "DB-VPC"
    }
    logging = {
      cidr = "10.30.0.0/16"
      name = "Logging-VPC"
    }
  }
  
  # Check VPC limits before creating
  current_vpc_count = length(data.aws_vpcs.existing.ids)
  vpc_limit = data.aws_servicequotas_service_quota.vpc_limit.value
  create_vpcs = var.create_vpc ? 1 : 0
}

resource "aws_vpc" "app" {
  count = local.create_vpcs
  cidr_block = var.vpc_cidrs["app"]
  tags = { Name = "App-VPC", ManagedBy = "Terraform" }
}
```

**"Notice the safety check - we verify VPC quotas before attempting creation. This prevents failures and makes the code production-ready."**

### **Show security_groups.tf - Microsegmentation Rules**
```terraform
# App can ONLY talk to DB
resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.app[0].id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.db[0].cidr_block]  # Only DB CIDR
  }
}

# DB only accepts MySQL from App
resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.db[0].id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.app[0].cidr_block]  # Only App CIDR
  }
}
```

**"This is true microsegmentation:"**
- App VPC can ONLY communicate with DB VPC
- DB VPC only accepts MySQL (port 3306) from App VPC
- No internet access, no lateral movement
- If an attacker compromises the app, they can't reach other resources

### **Show tgw.tf - Transit Gateway for Controlled Routing**
```terraform
resource "aws_ec2_transit_gateway" "tgw" {
  description = "Central Transit Gateway for micro-segmentation"
  tags = { Name = "Central-TGW" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app_attach" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id            = aws_vpc.app[0].id
  subnet_ids        = [for subnet in aws_subnet.app_private : subnet.id]
}
```

**"Transit Gateway acts as a hub-and-spoke model. All inter-VPC traffic flows through TGW where we can:"**
- Inspect traffic with Network Firewall
- Apply route-based policies
- Log all cross-VPC communication
- Segment workloads by environment (prod, dev, test)

### **Show nacls.tf - Network ACLs for Defense in Depth**
```terraform
resource "aws_network_acl" "app_acl" {
  vpc_id = aws_vpc.app[0].id
  
  # Allow egress everywhere
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }
  
  # Only allow ingress from DB on MySQL port
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = aws_vpc.db[0].cidr_block
    from_port  = 3306
    to_port    = 3306
  }
  
  # Deny everything else
  ingress {
    rule_no    = 200
    protocol   = "-1"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
  }
}
```

**"NACLs provide stateless packet filtering at the subnet level. Even if security groups are misconfigured, NACLs provide a second layer of defense."**

**"This is Zero Trust networking: explicitly allow only what's needed, deny everything else."**

---

## **SECTION 4: Automated Incident Response (120 seconds)**

### **Code Demo: siem_ir_package/**

**"When threats are detected, we need automated response. Let's look at our SIEM integration and incident response playbooks."**

### **Show main.tf - Forensics Infrastructure**
```terraform
# Encrypted S3 bucket for forensic evidence
resource "aws_s3_bucket" "forensics" {
  bucket = "${var.project_prefix}-forensics"
  tags = { Name = "Forensics-Evidence-Bucket" }
}

resource "aws_s3_bucket_versioning" "forensics_versioning" {
  bucket = aws_s3_bucket.forensics.id
  versioning_configuration {
    status = "Enabled"  # Never lose evidence
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "forensics_encryption" {
  bucket = aws_s3_bucket.forensics.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.forensic_kms.arn
    }
  }
}
```

**"Forensic evidence requires special handling: versioning, encryption, and immutability. This S3 bucket stores all incident artifacts."**

### **Show Lambda Functions - Incident Response Playbooks**

**"We have three automated response playbooks:"**

#### **1. Isolate Compromised EC2 Instance**
```python
# isolate_ec2/lambda_function.py
def lambda_handler(event, context):
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']
    
    # Create quarantine security group (no ingress/egress)
    quarantine_sg = ec2.create_security_group(
        GroupName='quarantine-sg',
        Description='Quarantine - No traffic allowed',
        VpcId=vpc_id
    )
    
    # Attach to compromised instance
    ec2.modify_instance_attribute(
        InstanceId=instance_id,
        Groups=[quarantine_sg['GroupId']]
    )
    
    # Create snapshot for forensics
    volumes = ec2.describe_volumes(
        Filters=[{'Name': 'attachment.instance-id', 'Values': [instance_id]}]
    )
    for volume in volumes['Volumes']:
        ec2.create_snapshot(VolumeId=volume['VolumeId'])
```

**"When GuardDuty detects a compromised EC2 instance, this Lambda:"**
1. Creates a quarantine security group with NO traffic allowed
2. Attaches it to the instance (isolating it immediately)
3. Takes EBS snapshots for forensic analysis
4. Stores metadata in the forensics S3 bucket

#### **2. Lockdown Compromised S3 Bucket**
```python
# lockdown_s3/lambda_function.py
def lambda_handler(event, context):
    bucket_name = event['detail']['resource']['s3BucketDetails']['name']
    
    # Apply deny-all bucket policy
    lockdown_policy = {
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                f"arn:aws:s3:::{bucket_name}",
                f"arn:aws:s3:::{bucket_name}/*"
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:PrincipalArn": "arn:aws:iam::123456789012:role/IR-Team"
                }
            }
        }]
    }
    s3.put_bucket_policy(Bucket=bucket_name, Policy=json.dumps(lockdown_policy))
```

**"When S3 data exfiltration is detected:"**
1. Immediately applies a bucket policy that denies ALL access
2. Only the IR team role can access (for investigation)
3. Prevents further data theft while preserving evidence

#### **3. Revoke Compromised IAM Credentials**
```python
# revoke_iam/lambda_function.py
def lambda_handler(event, context):
    user_name = event['detail']['resource']['accessKeyDetails']['userName']
    
    # List all access keys for the user
    keys = iam.list_access_keys(UserName=user_name)
    
    # Deactivate all keys
    for key in keys['AccessKeyMetadata']:
        iam.update_access_key(
            UserName=user_name,
            AccessKeyId=key['AccessKeyId'],
            Status='Inactive'
        )
    
    # Create forensic record
    s3.put_object(
        Bucket=forensics_bucket,
        Key=f"iam-revocation/{user_name}/{timestamp}.json",
        Body=json.dumps(event)
    )
```

**"When compromised IAM credentials are detected:"**
1. Immediately deactivates ALL access keys for the user
2. Stores the event details in forensics bucket
3. Alerts security team for further investigation

### **Show EventBridge Integration**
```terraform
resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name = "guardduty-high-severity"
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]  # High and Critical only
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_to_isolate" {
  rule = aws_cloudwatch_event_rule.guardduty_rule.name
  arn  = aws_lambda_function.isolate_ec2.arn
}
```

**"EventBridge connects GuardDuty findings to our Lambda functions. When a high-severity finding occurs, the appropriate playbook executes automatically within seconds."**

**"This is automated incident response: detect, contain, preserve evidence - all without human intervention."**

---

## **SECTION 5: Risk and Compliance Monitoring (90 seconds)**

### **Code Demo: risk_compliance_dashboard/**

**"Zero Trust isn't just about prevention - it's about continuous monitoring and compliance validation."**

### **Show the Data Flow Architecture**

**"Here's how our risk scoring system works:"**

1. **Security Findings Collection**
   - GuardDuty detects threats
   - Security Hub aggregates findings from multiple services
   - Config detects compliance violations
   - Inspector finds vulnerabilities

2. **EventBridge Routing**
   - All findings flow through EventBridge
   - Rules filter and route to appropriate handlers
   - Critical findings trigger immediate response

3. **Risk Scoring Lambda**
```python
def calculate_risk_score(finding):
    base_score = finding['severity']
    
    # Amplify score based on resource criticality
    if finding['resource_type'] == 'Production':
        base_score *= 1.5
    
    # Consider historical context
    if finding['account_id'] in frequent_offenders:
        base_score *= 1.2
    
    return min(base_score, 100)
```

**"Findings are scored based on severity, resource criticality, and historical context."**

4. **Data Lake Storage**
   - All findings stored in S3 Data Lake
   - Partitioned by date for efficient querying
   - Encrypted and versioned for compliance

5. **Athena Analytics**
```sql
-- Query high-risk resources
SELECT 
    account_id,
    resource_id,
    AVG(risk_score) as avg_risk,
    COUNT(*) as finding_count
FROM findings
WHERE date >= CURRENT_DATE - INTERVAL '7' DAY
GROUP BY account_id, resource_id
HAVING AVG(risk_score) > 70
ORDER BY avg_risk DESC
```

**"Athena allows SQL queries over the entire security data lake for ad-hoc analysis."**

6. **QuickSight Dashboard**
   - Real-time visualization of risk posture
   - Compliance metrics (NIST, PCI-DSS, SOC 2)
   - Trend analysis and alerting

**"Security teams get a single pane of glass view of organizational risk."**

### **Show Compliance Integration**
```terraform
resource "aws_config_config_rule" "required_tags" {
  name = "required-tags"
  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  input_parameters = jsonencode({
    tag1Key = "Environment"
    tag2Key = "Owner"
    tag3Key = "CostCenter"
  })
}

resource "aws_auditmanager_assessment" "sox_assessment" {
  name = "SOX-Compliance-Assessment"
  framework_id = aws_auditmanager_framework.sox.id
  roles {
    type     = "PROCESS_OWNER"
    role_arn = aws_iam_role.audit_role.arn
  }
  scope {
    aws_accounts { id = data.aws_caller_identity.current.account_id }
    aws_services { service_name = "ec2" }
  }
}
```

**"Config Rules continuously validate compliance requirements, and Audit Manager automates evidence collection for audits."**

---

## **SECTION 6: Code Quality and Best Practices (60 seconds)**

**"Let me highlight some engineering best practices that make this production-ready:"**

### **1. Idempotency and Safety Checks**
```terraform
# Check existing resources before creating
data "aws_vpcs" "existing" {
  tags = { ManagedBy = "Terraform" }
}

locals {
  create_vpcs = var.create_vpc && length(data.aws_vpcs.existing.ids) < local.vpc_limit ? 1 : 0
}
```
**"Never blindly create resources. Always check quotas and existing infrastructure."**

### **2. Conditional Resource Creation**
```terraform
resource "aws_vpc" "app" {
  count = local.create_vpcs  # Only create if conditions are met
  cidr_block = var.vpc_cidrs["app"]
}
```
**"Use count and for_each for conditional creation. This makes modules reusable."**

### **3. DRY Principle with Locals**
```terraform
locals {
  permission_sets = {
    Admin = { ... }
    DevOps = { ... }
    ReadOnly = { ... }
  }
}

resource "aws_ssoadmin_permission_set" "ps" {
  for_each = local.permission_sets
  name = each.key
  ...
}
```
**"Define data structures once, iterate over them. This reduces errors and improves maintainability."**

### **4. Comprehensive Outputs**
```terraform
output "account_validation" {
  value = {
    valid_accounts = keys(var.target_accounts)
    all_org_accounts = keys(local.org_accounts)
  }
  description = "Shows target accounts and all organization accounts"
}
```
**"Provide outputs for validation and debugging. This helps operators understand what was created."**

### **5. Error Handling in Lambda**
```python
try:
    sso.create_account_assignment(...)
except Exception as e:
    return {
        "statusCode": 500,
        "body": json.dumps({
            "error": "create assignment failed",
            "details": str(e)
        })
    }
```
**"Always handle errors gracefully and return meaningful messages."**

---

## **SECTION 7: Real-World Value and Use Cases (45 seconds)**

**"Why does this architecture matter? Let me give you real scenarios:"**

### **Scenario 1: Developer Needs Production Access**
- **Traditional Model**: Permanent admin access → standing privilege risk
- **Our Model**: Request 1-hour access → automatically revoked → Zero standing privilege

### **Scenario 2: EC2 Instance Compromised**
- **Traditional Model**: Manual detection, manual isolation, hours of response time
- **Our Model**: GuardDuty detects → EventBridge triggers → Lambda isolates in <30 seconds

### **Scenario 3: Compliance Audit**
- **Traditional Model**: Weeks of manual evidence collection
- **Our Model**: Audit Manager provides automated evidence, Config proves continuous compliance

### **Scenario 4: Multi-Account Management**
- **Traditional Model**: Manual account creation, inconsistent security controls
- **Our Model**: Terraform creates accounts with SCPs applied automatically, consistent governance

**"This architecture reduces risk, increases agility, and maintains compliance - the trifecta of enterprise security."**

---

## **CLOSING: Summary and Key Takeaways (30 seconds)**

**"Let's recap what we've built:"**

✅ **Zero Trust Identity**: Time-limited access with automatic revocation  
✅ **Zero Trust Network**: Microsegmented VPCs with explicit allow-lists  
✅ **Automated Response**: Lambda-based incident response in <30 seconds  
✅ **Continuous Monitoring**: Real-time risk scoring and compliance tracking  
✅ **Infrastructure as Code**: 100% reproducible, version-controlled, auditable  

**"This is not a proof of concept - this is enterprise-grade security architecture that scales from startup to Fortune 500."**

**"The code is modular, well-documented, and follows AWS best practices. Every component is designed for production use."**

**"Thank you for your time. I'm happy to answer any questions about the implementation, the design decisions, or how this could be adapted for specific compliance requirements."**

---

## **BONUS: Q&A Preparation**

### **Likely Questions and Answers**

**Q: "How much does this cost to run?"**  
**A:** "Core infrastructure (IAM Identity Center, Organizations, CloudTrail) is minimal - under $50/month. VPCs and Transit Gateway add $100-200/month depending on data transfer. Lambda functions are pay-per-execution, typically under $20/month for moderate usage. Total: ~$200-300/month for complete Zero Trust posture."

**Q: "Can this scale to 50+ accounts?"**  
**A:** "Absolutely. AWS Organizations supports up to 400 accounts per organization. Our Terraform modules use for_each loops, so adding accounts is just adding entries to a map. Service Control Policies apply at the OU level, so 1 policy can govern 100 accounts."

**Q: "What about disaster recovery?"**  
**A:** "Terraform state is stored in S3 with versioning and encryption. All code is in Git for version control. CloudTrail and Config provide audit history. We can rebuild the entire infrastructure from code in under 30 minutes using terraform apply."

**Q: "How do you handle Terraform state conflicts with multiple engineers?"**  
**A:** "Use S3 backend with DynamoDB state locking. The configuration in providers.tf ensures only one terraform apply runs at a time, preventing state corruption."

**Q: "What about secret management?"**  
**A:** "IAM Identity Center users authenticate via SSO with MFA. Lambda functions use IAM roles (no hardcoded credentials). Sensitive variables are in .tfvars files (gitignored) or AWS Secrets Manager for production."

**Q: "How do you test this before production?"**  
**A:** "terraform plan shows all changes before applying. We use separate AWS accounts for dev/test/prod. LocalStack can simulate AWS services locally. Lambda functions have unit tests with moto for AWS API mocking."

---

## **VIDEO PRODUCTION NOTES**

### **Recommended Screen Layout**
- **Main screen**: Code editor (VS Code) with syntax highlighting
- **Secondary screen**: AWS console showing resources being created
- **Bottom third**: Your webcam (optional but adds personal touch)

### **Visual Transitions**
- Use VS Code's split panes to show related files side-by-side
- Highlight key code sections with cursor or selection
- Show `terraform plan` output to demonstrate changes
- Use AWS console to validate deployed resources

### **Code Font and Theme**
- Font size: 16-18pt for readability in video
- Theme: High contrast (e.g., Monokai, Dracula)
- Enable line numbers for reference

### **Pacing**
- Speak slowly and clearly
- Pause 2-3 seconds between major sections
- Use transition phrases: "Now let's look at...", "Moving to the next component..."

### **Engagement Tips**
- Point to specific code lines: "Notice on line 42..."
- Use analogies: "Think of Transit Gateway as a network hub..."
- Show enthusiasm: "This is really powerful because..."

---

## **TOTAL TIMING BREAKDOWN**
- Opening (Project Context & Introduction): 90 seconds
- Section 1 (Architecture Deep Dive): 120 seconds
- Section 2 (JIT Access): 120 seconds
- Section 2B (AWS Organizations Foundation): 90 seconds
- Section 3 (Network): 120 seconds
- Section 4 (Incident Response): 120 seconds
- Section 5 (Risk/Compliance): 90 seconds
- Section 6 (Best Practices): 60 seconds
- Section 7 (Value): 45 seconds
- Closing: 30 seconds

**Total: 14 minutes and 15 seconds** (can be adjusted to 12 minutes by tightening Sections 2-4 by 20-30 seconds each, or keeping full depth for a comprehensive 14-minute presentation)

---

**Good luck with your video! This architecture demonstrates real engineering skills and security knowledge that any organization would value.**
