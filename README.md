# AWS Free Tier Monitoring Lab (EC2 + CloudWatch + Python)

This project demonstrates AWS infrastructure monitoring using **EC2**, the **CloudWatch Agent**, **CloudWatch Logs**, and **CloudWatch Alarms**, with **Python (boto3)** validation scripts.

The goal is to show real-world Systems Engineering skills aligned to roles that involve:
- Linux administration
- automation + scripting
- cloud infrastructure operations
- enterprise monitoring and alerting
- documentation and repeatable setup

---

## 🎯 Project Objectives

✅ Deploy an Ubuntu EC2 instance (Free Tier eligible)  
✅ Collect system logs + metrics using the CloudWatch Agent  
✅ Centralize logs using CloudWatch Logs  
✅ Create alerting using CloudWatch Alarms  
✅ Validate monitoring resources using Python (boto3)

---

## 🧠 Skills Demonstrated (Role Alignment)

### UNIX / Linux Administration
- Secure remote access (SSH)
- Package management and system updates
- Config file management and service control (systemd)

### AWS (Production Concepts)
- EC2 provisioning and network access control
- IAM identity and permissions (least privilege)
- CloudWatch Logs, metrics, alarms

### Enterprise Monitoring + Alerting
- Metrics collection (CPU / memory / disk)
- Log ingestion from system log paths
- Alarm thresholds and evaluation periods

### Automation / Scripting (Python)
- boto3 automation to confirm required AWS monitoring components exist
- Repeatable checks for log groups and alarms

---

## 🏗️ Architecture Overview

**AWS Region:** `us-east-2`

Components:
- **EC2 (Ubuntu Server)** → runs CloudWatch Agent
- **CloudWatch Logs** → stores `/var/log/syslog` + `/var/log/auth.log`
- **CloudWatch Metrics (CWAgent namespace)** → CPU/memory/disk metrics
- **CloudWatch Alarm** → triggers based on CPU idle threshold
- **Python scripts (boto3)** → validate monitoring resources exist

---

## ✅ CloudWatch Agent Configuration

The CloudWatch Agent is installed via the official AWS `.deb` package and configured using:

- `/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json`

It collects:

### Logs
- `/var/log/syslog` → `/aws/ec2/aws-monitoring-lab/syslog`
- `/var/log/auth.log` → `/aws/ec2/aws-monitoring-lab/auth`

### Metrics (CWAgent namespace)
- CPU (idle/user/system)
- Memory used percent
- Disk used percent

---

## 🚨 CloudWatch Alarm

This project includes an alarm designed to detect sustained CPU usage by monitoring *low idle CPU*:

- **Alarm Name:** `aws-monitoring-lab-cpu-low-idle`
- **Metric:** `cpu_usage_idle`
- **Namespace:** `CWAgent`
- **Condition:** idle < 40 for 5 datapoints (5 minutes)

This demonstrates real monitoring behavior such as:
- threshold design
- evaluation periods
- state transitions (OK / ALARM / INSUFFICIENT_DATA)

---

## 🐍 Python Automation (boto3)

### Requirements
Install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
