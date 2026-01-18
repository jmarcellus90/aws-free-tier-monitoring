import boto3

LOG_GROUPS_REQUIRED = [
    "/aws/ec2/aws-monitoring-lab/syslog",
    "/aws/ec2/aws-monitoring-lab/auth",
]

client = boto3.client("logs", region_name="us-east-2")

existing = set()
paginator = client.get_paginator("describe_log_groups")

for page in paginator.paginate():
    for g in page.get("logGroups", []):
        existing.add(g["logGroupName"])

missing = [lg for lg in LOG_GROUPS_REQUIRED if lg not in existing]

print("CloudWatch Log Group Check")
print("-" * 30)

if not missing:
    print("✅ All required log groups exist.")
else:
    print("❌ Missing log groups:")
    for m in missing:
        print(f" - {m}")
