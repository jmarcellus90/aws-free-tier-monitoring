import boto3
from rich import print

REGION = "us-east-2"
REQUIRED_ALARMS = [
    "aws-monitoring-lab-cpu-low-idle",
]

cw = boto3.client("cloudwatch", region_name=REGION)

alarms = []
paginator = cw.get_paginator("describe_alarms")

for page in paginator.paginate():
    for a in page.get("MetricAlarms", []):
        alarms.append(a["AlarmName"])

print("[bold]CloudWatch Alarm Check[/bold]")
missing = [name for name in REQUIRED_ALARMS if name not in alarms]

if not missing:
    print("[green]✅ All required alarms exist.[green]")
else:
    print("[red]❌ Missing alarms:[/red]")
    for m in missing:
        print(f" - {m}")
