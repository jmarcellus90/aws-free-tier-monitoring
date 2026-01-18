import boto3
from rich import print

REGION = "us-east-2"

REQUIRED_LOG_GROUPS = [
    "/aws/ec2/aws-monitoring-lab/syslog",
    "/aws/ec2/aws-monitoring-lab/auth",
]

logs = boto3.client("logs", region_name=REGION)

existing = set()
paginator = logs.get_paginator("describe_log_groups")

for page in paginator.paginate():
    for g in page.get("logGroups", []):
        existing.add(g["logGroupName"])

print("[bold]CloudWatch Log Group Check[/bold]")
missing = [lg for lg in REQUIRED_LOG_GROUPS if lg not in existing]

if not missing:
    print("[green]✅ All required log groups exist.[/green]")
else:
    print("[red]❌ Missing log groups:[/red]")
    for m in missing:
        print(f" - {m}")
