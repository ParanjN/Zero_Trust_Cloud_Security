# Converting Zero Trust Architecture to Draw.io with AWS Icons

## Quick Start Guide

### **Option 1: Import AWS Icon Library in Draw.io**
1. Go to https://app.diagrams.net/ (Draw.io)
2. Click **More Shapes** → **AWS** → Enable all AWS categories
3. Use the structure below to recreate the diagram with proper AWS icons

### **Option 2: Use AWS Architecture Icons**
Download official AWS icons from: https://aws.amazon.com/architecture/icons/

---

## **Draw.io Component Mapping with AWS Icons**

### **🏢 Management Account Layer**
```
AWS Organization → Use: "AWS Organizations" icon
CloudTrail → Use: "AWS CloudTrail" icon  
S3 Log Bucket → Use: "Amazon S3" icon
IAM Identity Center → Use: "AWS IAM Identity Center" icon
```

### **🏛️ Organizational Units**
```
Security OU → Use: "Organizational Unit" + Security badge
Logging OU → Use: "Organizational Unit" + Logging badge
Production OU → Use: "Organizational Unit" + Prod badge
DevTest OU → Use: "Organizational Unit" + Dev badge
Sandbox OU → Use: "Organizational Unit" + Test badge
```

### **🛡️ Security Services**
```
GuardDuty → Use: "Amazon GuardDuty" icon
Security Hub → Use: "AWS Security Hub" icon
Config → Use: "AWS Config" icon
Inspector → Use: "Amazon Inspector" icon
```

### **🌐 Network Components**
```
VPC → Use: "Amazon VPC" icon
Subnet → Use: "VPC Subnet" icon
Transit Gateway → Use: "AWS Transit Gateway" icon
Security Group → Use: "VPC Security Group" icon
Network ACL → Use: "VPC Network ACL" icon
PrivateLink → Use: "AWS PrivateLink" icon
```

### **⚙️ Compute & Storage**
```
Lambda Function → Use: "AWS Lambda" icon
EC2 Instance → Use: "Amazon EC2" icon
RDS → Use: "Amazon RDS" icon
S3 Bucket → Use: "Amazon S3" icon
DynamoDB → Use: "Amazon DynamoDB" icon
```

### **📊 Analytics & ML**
```
Athena → Use: "Amazon Athena" icon
QuickSight → Use: "Amazon QuickSight" icon
SageMaker → Use: "Amazon SageMaker" icon
OpenSearch → Use: "Amazon OpenSearch" icon
EventBridge → Use: "Amazon EventBridge" icon
```

---

## **Draw.io Layer Structure**

### **Layer 1: Foundation (Background)**
- AWS Cloud boundary
- Management Account container
- Account boundaries (Security, Logging, Prod, DevTest, Sandbox)

### **Layer 2: Network Infrastructure**
- VPC containers with CIDR blocks
- Subnets within VPCs
- Transit Gateway central hub
- Network security elements (SGs, NACLs)

### **Layer 3: Core Services**
- AWS Organization structure
- IAM Identity Center components
- Service Control Policies
- CloudTrail and S3 logging

### **Layer 4: Security & Monitoring**
- GuardDuty, Security Hub, Config
- Risk Compliance Dashboard components
- SIEM and Incident Response tools

### **Layer 5: Applications & Workloads**
- Lambda functions
- EC2 instances
- RDS databases
- ML/AI components

### **Layer 6: Data Flows & Connections**
- Arrows showing data flow
- API connections
- Network traffic patterns

---

## **Color Coding Scheme**

```
🔵 Organization/Governance: #E1F5FE (Light Blue)
🔴 Security Services: #FFEBEE (Light Red)  
🟣 Network Components: #F3E5F5 (Light Purple)
🟢 Data Storage: #E8F5E8 (Light Green)
🟠 Compute/Lambda: #FFF3E0 (Light Orange)
🟡 AI/ML Services: #E0F2F1 (Light Teal)
```

---

## **Step-by-Step Recreation Guide**

### **Step 1: Create Account Containers**
1. Draw 6 large rectangles for accounts (Management + 5 member accounts)
2. Label each with account name and purpose
3. Apply organization color scheme

### **Step 2: Add Network Infrastructure**
1. Inside Management account, create 3 VPC containers
2. Add subnets within each VPC
3. Place Transit Gateway in center with connections

### **Step 3: Place Core AWS Services**
1. Add AWS Organization icon in Management account
2. Place IAM Identity Center with user/group icons
3. Add CloudTrail and S3 bucket icons

### **Step 4: Add Security Services**
1. Place GuardDuty, Security Hub, Config in Security account
2. Add Lambda functions for automated response
3. Include S3 buckets for forensics and findings

### **Step 5: Add Monitoring & Analytics**
1. Place EventBridge for event routing
2. Add Athena and QuickSight for analytics
3. Include SageMaker for AI/ML components

### **Step 6: Create Data Flow Arrows**
1. Draw arrows between components showing data flow
2. Use different arrow styles for different data types
3. Add labels to arrows describing the flow

---

## **Draw.io Pro Tips**

### **Using AWS Icon Library**
- **Shape Search**: Type "AWS" to find all AWS icons quickly
- **Grouping**: Group related components for easier movement
- **Layers**: Use layers to organize different architectural tiers
- **Connectors**: Use curved connectors for better visual flow

### **Professional Styling**
- **Consistent Spacing**: Use grid alignment (View → Grid)
- **Font Consistency**: Use 12pt Arial/Helvetica throughout
- **Color Legend**: Add legend explaining color coding
- **Title Block**: Include diagram title, version, and date

### **Advanced Features**
- **Links**: Add hyperlinks to AWS documentation
- **Tooltips**: Add descriptions to complex components
- **Multiple Pages**: Create separate diagrams for different views
- **Export Options**: Save as PNG/SVG for presentations

---

## **Alternative: Lucidchart Setup**

### **Lucidchart AWS Integration**
1. Open Lucidchart → Import Shape Library
2. Search for "AWS" and import official AWS shape library
3. Use same component mapping as above
4. Take advantage of Lucidchart's auto-layout features

### **Lucidchart Advantages**
- **Collaborative Editing**: Real-time team collaboration
- **Smart Containers**: Automatic grouping and organization
- **Data Linking**: Connect to live AWS data sources
- **Professional Templates**: Start with AWS architecture templates

---

## **Quick Migration Checklist**

- [ ] Import AWS icon library
- [ ] Create account containers with proper labeling
- [ ] Add network infrastructure (VPCs, subnets, TGW)
- [ ] Place core AWS services with correct icons
- [ ] Add security and monitoring components
- [ ] Create data flow connections with arrows
- [ ] Apply consistent color coding
- [ ] Add legend and documentation
- [ ] Review for accuracy against Mermaid version
- [ ] Export final version for presentations

---

## **Export Recommendations**

### **For Presentations**
- **Format**: PNG at 300 DPI
- **Size**: Landscape orientation, 16:9 aspect ratio
- **Background**: White for printing, transparent for overlays

### **For Documentation**
- **Format**: SVG for web, PDF for documents
- **Resolution**: Vector format for infinite scaling
- **Layers**: Export with layers intact for future editing

This approach will give you a professional AWS architecture diagram that's perfect for executive presentations, technical documentation, and team collaboration!